/*
@author Leadclic Solutions S.L.
@date 29/04/2019 
@description    Controlador del componente EmailHuerfanos

<pre>
FECHA                   AUTOR                   ACCION
29/04/2019              LCS - RMG               Creación
*/
import { LightningElement, wire, track } from 'lwc';
//Métodos de la clase controladora
import getEmailHuerfanosBusqueda from '@salesforce/apex/EmailHuerfanosController.getEmailHuerfanosBusqueda';
import eliminarEmail from '@salesforce/apex/EmailHuerfanosController.eliminarEmail';
import actualizarRemitenteEmail from '@salesforce/apex/EmailHuerfanosController.actualizarRemitenteEmail';
//Import para poder navegar a otro objeto
import { NavigationMixin } from 'lightning/navigation';
//Recuperamos las etiquetas para ponerlas en las cabeceras de la tabla
import ASUNTO from '@salesforce/label/c.Asunto';
import REMITENTE from '@salesforce/label/c.Remitente';
import FECHACREACION from '@salesforce/label/c.FechaCreacion';
import CONFIRMACIONELIMINACION from '@salesforce/label/c.ConfirmarEliminacion';
import EXITO from '@salesforce/label/c.Exito';
import EMAILELIMINADO from '@salesforce/label/c.EmailEliminado';
import ERRORELIMINACION from '@salesforce/label/c.ErrorEliminacion';
import TITULOPOPUP from '@salesforce/label/c.TituloPopupRemitente'
import GUARDAR from '@salesforce/label/c.Guardar';
import ERROR from '@salesforce/label/c.Error';
import ASIGNADOREMITENTECORRECTAMENTE from '@salesforce/label/c.AsignadoRemitenteCorrectamente';
import SINCORREOSHUERFANOS from '@salesforce/label/c.SinCorreosHuerfanos';
import NOMBREREMITENTE from '@salesforce/label/c.NombreRemitente';
import CONCOPIA from '@salesforce/label/c.ConCopia';
//Mostrar toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class EmailHuerfanos extends NavigationMixin(LightningElement) {
    @track errorBusqueda;
    @track emails = [];
    @track filteredEmails = [];
    @track mostrarModal = false;
    @track idEmailPopup;
    @track idClienteRemitente
    @track sinEmails = false;
    @track conEmails = true;
    @track conFiltro = false;
    @track filterRemitente;
    @track filterAsunto;
    @track filterDesde;
    @track filterHasta;
    @track filterNombreRmt;
    @track filterEnCopia;

    //Método que busca los emails huerfanos
    @wire(getEmailHuerfanosBusqueda) 
    EmailHuerfanosBusqueda({
        error,
        data
    }) {
        if (data) {
            this.emails.data = data; 
            this.applyFilters();
            if(data.length == 0){ 
                this.sinEmails = true;
                this.conEmails = false;
            }
            else{ 
                this.sinEmails = false;  
                this.conEmails = true;
            }
        } else if (error) {
            this.errorBusqueda = error;
        }
    }

    //Método para navegar al registro del email
    navigateToEmail(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'EmailMessage',
                actionName: 'view'
            }
        });
    }

    //Método que elimina el registro de email
    eliminarEmail(event){
        var idRegistroEliminar = event.target.value;
        var confirmaEliminacion = confirm(CONFIRMACIONELIMINACION);
        if(confirmaEliminacion){           
            eliminarEmail({idRegistro: idRegistroEliminar})
                .then(result => {  
                    //el resultado es el listado de los emails que están huerfanos actualizada
                    this.emails.data = result;
                    this.applyFilters();   
                    if(result.length == 0) {
                        this.sinEmails = true;
                        this.conEmails = false;
                    }
                    else{ 
                        this.sinEmails = false;  
                        this.conEmails = true;
                    }                              
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: EXITO,
                            message: EMAILELIMINADO,
                            variant: 'success',
                        }),
                    );
                })
                .catch(error => {                    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: ERRORELIMINACION,
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
        }
    }

    //Método que crea el remitente del email
    asignarRemitenteEmail(event){
        this.mostrarModal = true;
        this.idEmailPopup = event.target.value;
    }

    //Método para cerrar el modal
    cerrarModal(){
        this.mostrarModal = false;
        this.idEmailPopup = undefined;
        this.idClienteRemitente = undefined;
    }

    //Método para abrir la sección de filtros
    openFilters(){
        this.conFiltro = true;
    }

    //Método para cerrar la sección de filtros
    closeFilters(){
        this.conFiltro = false;
    }

    //Gestiona el cambio en los campos de filtros
    filtersChange(event) {
        this[event.target.name] = event.target.value;
    }

    //Método para aplicar los filtros y cambiar los datos a mostrar
    applyFilters(){
        
        var data = this.emails.data
        var filteredData = [];
        // Convertimos las fechas de los filtros en tipo Fecha
        var newFilterDesde = new Date(this.filterDesde);
        var newFilterHasta = new Date(this.filterHasta);
        // Le sumamos un día para que encuentre los Emails del mismo día
        newFilterHasta.setDate(newFilterHasta.getDate() + 1);

        for (var key in data){
            // Convertimos la fecha del registro en tipo fecha para la correcta comparación
            var newMessageDate = new Date(data[key].MessageDate);
            
            // Si el registro cumple las condiciones entonces lo metemos en la lista filtrada que se va a mostrar
            if( (!this.filterRemitente || (data[key].FromAddress && data[key].FromAddress.toLowerCase().search(this.filterRemitente.toLowerCase()) != -1)) &&
                (!this.filterAsunto || (data[key].Subject && data[key].Subject.toLowerCase().search(this.filterAsunto.toLowerCase()) != -1)) &&
                (!this.filterDesde || (data[key].MessageDate && newMessageDate >= newFilterDesde)) &&
                (!this.filterHasta || (data[key].MessageDate && newMessageDate <= newFilterHasta)) &&
                (!this.filterNombreRmt || (data[key].FromName && data[key].FromName.toLowerCase().search(this.filterNombreRmt.toLowerCase()) != -1)) &&
                (!this.filterEnCopia || (data[key].CcAddress && data[key].CcAddress.toLowerCase().search(this.filterEnCopia.toLowerCase()) != -1)) ){
                filteredData.push(data[key]);
            }

        }        

        this.filteredEmails.data = filteredData;
    }


    //Método para guardar al remitente
    guardarRemitente(){
        actualizarRemitenteEmail({idEmail: this.idEmailPopup, idRemitente :this.idClienteRemitente})
            .then(result => {  
                //el resultado es el listado de los emails que están huerfanos actualizada
                this.emails.data = result;  
                this.applyFilters();
                if(result.length == 0){
                    this.sinEmails = true;
                    this.conEmails = false;
                }
                else{ 
                    this.sinEmails = false;  
                    this.conEmails = true;
                }              
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: EXITO,
                        message: ASIGNADOREMITENTECORRECTAMENTE,
                        variant: 'success',
                    }),
                );
                this.mostrarModal = false;
                this.idEmailPopup = undefined;
                this.idClienteRemitente = undefined;
            })
            .catch(error => {                    
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: ERROR,
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

    //Se guarda el id del cliente que se ha seleccionado como remitente
    clienteSeleccionado(event){
        this.idClienteRemitente = event.detail.value[0];
    }

    //Etiquetas personalizadas
    label = {
        ASUNTO,
        REMITENTE,
        FECHACREACION,
        TITULOPOPUP,
        GUARDAR,
        SINCORREOSHUERFANOS,
        NOMBREREMITENTE,
        CONCOPIA
    };
}