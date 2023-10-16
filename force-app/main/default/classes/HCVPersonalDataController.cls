/*
@author Leadclic Solutions S.L.
@date 17/06/2019 
@description  Clase controladora para la VisualForce GDPRPersonalData

FECHA                   AUTOR                   ACCION
17/06/2019              LCS - RDM               Creación
*/
public class HCVPersonalDataController {
    
    public String idHCV {get;set;}
    public String idAccount {get;set;}    
    public String nombre {get;set;}
    public String apellidos {get;set;}
    public String fechaNacimiento {get;set;}
    public String documentoIdentidad {get;set;}
    public String regimenEconomico {get;set;}
    public String estadoCivil {get;set;}
    public String eMail {get;set;}
    public String segundoeMail {get;set;}
    public String telefono {get;set;}
    public String segundotelefono {get;set;}
    public String iban {get;set;}
    public String domicilio {get;set;}
    public String PersonTitle {get;set;}
    public String textoInformativo {get;set;}
    public String politica1 {get;set;}
    public String politica2 {get;set;}
    public String politica3 {get;set;}            
    
    public HCVPersonalDataController(){
        //recogemos el id de la cuenta
        idAccount = apexpages.currentpage().getparameters().get('Id');  
        


        //Indicamos el nombre del fichero para cuando el usuario lo guarde
        string nombreFichero = 'Hoja Control de Visita';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+nombreFichero+'.pdf'); 
    }

    public void getDataFromAccountToHCV(){


        try{
            List<Account> lCuenta = [SELECT Id, FirstName, LastName, PersonEmail,CorreoElectronicoSecundario__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, 
                                     ShippingCountry, PersonTitle,PersonBirthdate, Phone,PersonMobilePhone,IBAN__pc,EstadoCivil__c, DocumentoIdentidad__c ,RegimenEconomico__c, 
                                     AceptoPoliticaPrivacidad__pc, DeseoRecibirComunicacionesComerciales__pc, Deseo_recibir_Mensajes_de_Whatsapp__pc 
                                      FROM Account 
                                      WHERE Id =: this.idAccount];
            if(!lCuenta.isEmpty()){
				this.nombre = lCuenta[0].FirstName;
				this.apellidos = lCuenta[0].LastName;
                
                //Formato de la fecha
                if(lCuenta[0].PersonBirthdate != null){
                    DateTime birthDate = lCuenta[0].PersonBirthdate;
                    String formatBDate = birthDate.format('dd-MM-yyyy');
                    this.fechaNacimiento = formatBDate;
                } else {
                    this.fechaNacimiento = '';
                }
                
				this.documentoIdentidad = lCuenta[0].DocumentoIdentidad__c;
				this.eMail = lCuenta[0].PersonEmail;
				this.segundoeMail = lCuenta[0].CorreoElectronicoSecundario__c;
				this.telefono = lCuenta[0].Phone;
				this.segundotelefono = lCuenta[0].PersonMobilePhone;
                this.iban=lCuenta[0].IBAN__pc;
                this.PersonTitle=lCuenta[0].PersonTitle;
                this.regimenEconomico=lCuenta[0].RegimenEconomico__c;
                this.estadoCivil=lCuenta[0].EstadoCivil__c;
                                             
                if(lCuenta[0].AceptoPoliticaPrivacidad__pc) politica1 = 'SI'; else politica1 = 'NO';
                if(lCuenta[0].DeseoRecibirComunicacionesComerciales__pc) politica2 = 'SI'; else politica2 = 'NO';
                if(lCuenta[0].Deseo_recibir_Mensajes_de_Whatsapp__pc) politica3 = 'SI'; else politica3 = 'NO';

                //Formato de la calle
                String calle = lCuenta[0].ShippingStreet;
                String cp = lCuenta[0].ShippingPostalCode;
                String ciudad = lCuenta[0].ShippingCity;
                String provincia = lCuenta[0].ShippingState;
                String pais = lCuenta[0].ShippingCountry;
                
                //Comprobamos si es nulo, si no lo es, añadimos una coma delante de los valores por temas de visualización
                if(String.isBlank(calle)) calle = '';
                if(String.isBlank(cp)) cp = ''; else cp = ', '+ cp;
                if(String.isBlank(ciudad)) ciudad = ''; else ciudad = ', '+ ciudad;
                if(String.isBlank(provincia)) provincia = ''; else provincia = ', '+ provincia;
                if(String.isBlank(pais)) pais = ''; else pais = ', '+ pais;
                
                this.domicilio = calle + cp + ciudad + provincia + pais; 
                this.textoInformativo=System.Label.textCompliance;
            }
            else{
                //recogemos el id de hoja de visita
                idHCV = idAccount;
                List<HojaControlVisita__c> HCV = [SELECT Id, Cuenta__c 
                                        FROM HojaControlVisita__c  
                                        WHERE Id =: this.idHCV];
                this.idAccount = HCV[0].Cuenta__c;                    

                this.nombre = lCuenta[0].FirstName;
				this.apellidos = lCuenta[0].LastName;
                
                //Formato de la fecha
                if(lCuenta[0].PersonBirthdate != null){
                    DateTime birthDate = lCuenta[0].PersonBirthdate;
                    String formatBDate = birthDate.format('dd-MM-yyyy');
                    this.fechaNacimiento = formatBDate;
                } else {
                    this.fechaNacimiento = '';
                }
                
				this.documentoIdentidad = lCuenta[0].DocumentoIdentidad__c;
				this.eMail = lCuenta[0].PersonEmail;
				this.segundoeMail = lCuenta[0].CorreoElectronicoSecundario__c;
				this.telefono = lCuenta[0].Phone;
				this.segundotelefono = lCuenta[0].PersonMobilePhone;
                this.iban=lCuenta[0].IBAN__pc;
                this.PersonTitle=lCuenta[0].PersonTitle;
                this.regimenEconomico=lCuenta[0].RegimenEconomico__c;
                this.estadoCivil=lCuenta[0].EstadoCivil__c;
                                             
                if(lCuenta[0].AceptoPoliticaPrivacidad__pc) politica1 = 'SI'; else politica1 = 'NO';
                if(lCuenta[0].DeseoRecibirComunicacionesComerciales__pc) politica2 = 'SI'; else politica2 = 'NO';
                if(lCuenta[0].Deseo_recibir_Mensajes_de_Whatsapp__pc) politica3 = 'SI'; else politica3 = 'NO';

                //Formato de la calle
                String calle = lCuenta[0].ShippingStreet;
                String cp = lCuenta[0].ShippingPostalCode;
                String ciudad = lCuenta[0].ShippingCity;
                String provincia = lCuenta[0].ShippingState;
                String pais = lCuenta[0].ShippingCountry;
                
                //Comprobamos si es nulo, si no lo es, añadimos una coma delante de los valores por temas de visualización
                if(String.isBlank(calle)) calle = '';
                if(String.isBlank(cp)) cp = ''; else cp = ', '+ cp;
                if(String.isBlank(ciudad)) ciudad = ''; else ciudad = ', '+ ciudad;
                if(String.isBlank(provincia)) provincia = ''; else provincia = ', '+ provincia;
                if(String.isBlank(pais)) pais = ''; else pais = ', '+ pais;
                
                this.domicilio = calle + cp + ciudad + provincia + pais; 
                this.textoInformativo=System.Label.textCompliance;
 
            }
        } catch(Exception e){
            system.debug('*********** : ' + e.getMessage());
            this.nombre = '';
            this.apellidos = '';
            this.fechaNacimiento = null;
            this.documentoIdentidad = '';
            this.eMail = '';
            this.telefono = '';
            this.segundotelefono = '';
            this.domicilio = '';
        }
    }
}