/*
@author Leadclic Solutions S.L.
@date 29/04/2019 
@description  Clase controladora para el componenete que se encarga de seleccionar una hoja de encargo (hojaEncargocmp)

<pre>
FECHA                   AUTOR                   ACCION
07/05/2019              LCS - RDM               Creación
02/07/2019              LCS - RMG               Modificación. Se modifica el traspaso de datos de la hoja de encargo a la oportunidad
10/09/2019              LCS - RMG               Modificación. Se crea un método que se encarga de validar si se puede generar el PDF
30/09/2019              LCS - GQG               Modificación. Inclusión del caso particular de hoja personalizada
14/10/2019              LCS - GQG               Modificación. Extensión del mapeo de campos entre HdE y Oportunidad. Detectados antes de la carga de HdE.
09/01/2020              LCS - JCL               Modificación. Se añaden comprobaciones adicionales antes de generar el PDF.
19/03/2020              LCS - SER               Modificación. Se excluye de la validación de campos de los Intervinientes a la cuenta pricnipal, que ya tiene su propia validación.
15/04/2020              LCG - GQG               Modificación. Se elimina la funcionalidad de trasladar los valores de la HdE, irá al trigger de Opp para contemplar los casos desde Comunidad.
21/07/2020              LCS - RAL               Modificación. Se incluye un método para saber si una oportunidad tiene producto asociado o no para llamarlo desde el componente.
*/
public without sharing class hojaEncargoControllerlwc {
    
    //Crear wrapper class para pasar los parametros que necesitamos
    public class WrapCamposHdE{
        @AuraEnabled public String idHoja {get;set;}
        @AuraEnabled public String tipoHoja {get;set;}
        @AuraEnabled public String producto {get;set;}
        @AuraEnabled public String codigoPlantilla {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public Boolean hojaEncargoYaRelacionada {get;set;}
        @auraEnabled public Boolean isCustomHdE {get; set;}
    }
    
    
    @AuraEnabled(cacheable = false)
    public static List<WrapCamposHdE> getConfirmarHojaCargada(Id idOportunidad){        
        list<WrapCamposHdE> lCampos = new list<WrapCamposHdE>();
        Opportunity opp = [SELECT HojaEncargo__c, HojaEncargo__r.Name, HojaEncargo__r.TipoHojaEncargo__c, HojaEncargo__r.Producto__r.Name, HojaEncargo__r.CodPlantilla__c, HojaEncargoPersonalizada__c 
                            FROM Opportunity where Id =:idOportunidad];

        
        WrapCamposHdE camposRes = new WrapCamposHdE();

        // Hoja personalizada
        if(opp.HojaEncargoPersonalizada__c) {
            camposRes.name = 'PERSONALIZADA';
            camposRes.tipoHoja = 'Accesible en el Gestor Documental';
            camposRes.codigoPlantilla = '-';
            camposRes.isCustomHdE = true;
            camposRes.hojaEncargoYaRelacionada = true;   

        // No hay hoja
        } else if(String.isBlank(opp.HojaEncargo__c)) {
            camposRes.hojaEncargoYaRelacionada = false;
            lCampos.add(camposRes);

        // Hoja
        } else {
            camposRes.idHoja = opp.HojaEncargo__c;
            camposRes.name = opp.HojaEncargo__r.Name;
            camposRes.tipoHoja = opp.HojaEncargo__r.TipoHojaEncargo__c;
            camposRes.producto = opp.HojaEncargo__r.Producto__r.Name;
            camposRes.codigoPlantilla = opp.HojaEncargo__r.CodPlantilla__c;
            camposRes.hojaEncargoYaRelacionada = true;
            camposRes.isCustomHdE = false;
        }

        lCampos.add(camposRes);
        
        return lCampos;
    }
    
    
    @AuraEnabled(cacheable = false)
    public static List<WrapCamposHdE> getHojasEncargo(Id idOportunidad){
        //creamos la lista que devolveremos
        list<WrapCamposHdE> lCampos = new list<WrapCamposHdE>();
        list<Id> lProduct2Ids = new list<Id>();
        //Obtenemos la lista de opportunity line item relacionados con la oportunidad
        list<OpportunityLineItem> oli = [SELECT Id, Product2Id FROM OpportunityLineItem WHERE OpportunityId =:IdOportunidad];
        
        //Recorremos la lista y guardamos los ids de los productos
        for(OpportunityLineItem o : oli){
            lProduct2Ids.add(o.Product2Id);
        }

        // Insertamos una hoja de encargo fake para la funcionalidad de adhoc
        WrapCamposHdE wrapper = new WrapCamposHdE();
        wrapper.idHoja = null;
        wrapper.name = 'PERSONALIZADA';
        wrapper.tipoHoja = '';
        wrapper.producto = 'PERSONALIZADA';
        wrapper.codigoPlantilla = '-';
        wrapper.isCustomHdE = true;
        lCampos.add(wrapper);


        if(!lProduct2Ids.isEmpty()){
            //Recuperamos los campos necesarios para enseñar en la tabla las cuales corresponden con el producto
            list<HojaEncargo__c> hojaEncargo = [SELECT Id, Name, TipoHojaEncargo__c, Producto__r.Name, CodPlantilla__c 
                                                FROM HojaEncargo__c 
                                                WHERE Producto__c IN:lProduct2Ids];

            for (HojaEncargo__c hde : hojaEncargo){
                WrapCamposHdE camposRes = new WrapCamposHdE();
                camposRes.idHoja = hde.Id;
                camposRes.name = hde.Name;
                camposRes.tipoHoja = hde.TipoHojaEncargo__c;
                camposRes.producto = hde.Producto__r.Name;
                camposRes.codigoPlantilla = hde.CodPlantilla__c;
                camposRes.isCustomHdE = false;
                lCampos.add(camposRes);
            }

        }
        //system.debug('Datos respuesta : ' + lCampos);
        return lCampos;
    }
    @AuraEnabled(cacheable = false)
    public static void rellenarCampos(Id idOportunidad, Id idHojaEncargo, Boolean isCustomHdE){
        
        // query opp
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id =:idOportunidad];                              

        opp.HojaEncargoPersonalizada__c = isCustomHdE;
        opp.HojaEncargo__c = idHojaEncargo;

        update opp;        
    }
    
    
    @AuraEnabled(cacheable = false)
    public static void vaciarCampos(Id idOportunidad){
        Opportunity opp = new Opportunity();
            opp.Id = idOportunidad;
            opp.HojaEncargo__c = null;
            opp.HAbogadoDivorcio__c = null;
            opp.HAbogadoLiqRegimen__c = null;
            opp.HAbogadoMedProvisional__c = null;
            opp.HAbogadoUnico__c =  null;
            opp.Hcondenacostas__c = null;
            opp.PHAcuerdoJudOExtra__c = null; 
            opp.PHAcuerdoExtra__c = null; 
            opp.PHAcuerdoJud__c = null;
            opp.PSincondenacostas__c =  null; 
            opp.ImporteEstudioAnalisis__c = null;
            opp.ImporteDesistimientoMaximo__c = null; 
            opp.ImporteDesistimientoMinimo__c = null; 
            opp.ImporteDesistimientoUnico__c =  null;
            opp.ImporteGestionesPrevias__c =  null;
            opp.PInterescondenacostas__c =  null;
            opp.PInteresSincondenacostas__c = null;
            opp.HojaEncargoPersonalizada__c = false;
        update opp;

    }

    /*
    Método que se encarga de comprobar que los intervinientes cumplen con las condiciones requeridas (documento de identidad, dirección, políticas de privacidad
    y comunicaciones).
    @param  idOportunidad: id de la oportunidad donde se va a generar el PDF
    @return booleano que devuelve true cuando se puede generar el PDF, si devuelve false no se puede generar el PDF por no cumplir los requisitos
     */
    @AuraEnabled(cacheable = false)
    public static boolean validacionGeneracionPDF(Id idOportunidad){
     
        boolean resultado = false;
        // Comprobamos que la cuenta asociada a la oportunidad cumple las condiciones mínimas
        list<Opportunity> lOportunidades = [ SELECT Id, AccountId, Account.DocumentoIdentidad__c, Account.ShippingStreet, Account.ShippingPostalCode, 
                                                    Account.PersonContactId, Account.ShippingCity, Account.IsPersonAccount, Account.AceptoPoliticaPrivacidad__pc
                                            FROM Opportunity
                                            WHERE Id = :idOportunidad AND Account.DocumentoIdentidad__c != null AND Account.ShippingStreet != null
                                                  AND Account.ShippingPostalCode != null AND Account.ShippingCity != null 
                                                  AND ( ( Account.IsPersonAccount = false ) 
                                                  OR ( Account.IsPersonAccount = true AND Account.AceptoPoliticaPrivacidad__pc = true ) ) ];
        
        if( !lOportunidades.isEmpty() ) {

            Opportunity opp = lOportunidades.get( 0 );
            // Cuentas personales
            if( opp.Account.IsPersonAccount ) {
               
                List<OpportunityContactRole> lOppContRole = [ SELECT ContactId, Contact.Account.DocumentoIdentidad__c, Contact.Account.ShippingStreet, 
                                                                     Contact.Account.ShippingPostalCode, Contact.Account.ShippingCity, 
                                                                     Contact.AceptoPoliticaPrivacidad__c
                                                              FROM OpportunityContactRole 
                                                              WHERE  OpportunityId = :opp.Id ];

                boolean tieneClienteDirecto = false;
              
              system.debug('lOppContRole '+lOppContRole.size());
                for( OpportunityContactRole ocr : lOppContRole ) {
  					boolean resFinal = (ocr.ContactId != opp.Account.PersonContactId);
                    // Validamos si el cliente directo está entre los intervinientes
                    tieneClienteDirecto = tieneClienteDirecto || ( ocr.ContactId == opp.Account.PersonContactId );
                    system.debug('res '+resFinal);
                    // Validamos si el interviniente tiene los campos requeridos
                    if (ocr.ContactId != opp.Account.PersonContactId){
                    resultado = String.isNotEmpty( ocr.Contact.Account.DocumentoIdentidad__c ) && String.isNotEmpty( ocr.Contact.Account.ShippingStreet )
                                && String.isNotEmpty( ocr.Contact.Account.ShippingPostalCode ) && String.isNotEmpty( ocr.Contact.Account.ShippingCity )
                                && ocr.Contact.AceptoPoliticaPrivacidad__c;    
                        system.debug('resultado '+resultado);
                         if (!resultado){
                            break;
                    }
         			}
                    else {
                        resultado = true;
                        
                    }
                   
                }

                // Si tiene cliente directo entre los intervinientes y todos los intervinientes tienen los campos requeridos la validación es positiva
                resultado = resultado && tieneClienteDirecto;
                

            // Cuentas empresariales
            }else {

                // Comprobamos la aceptación de políticas de privacidad y comunicaciones así como la condición de representante legal 
                List<OpportunityContactRole> lOppContRole = [ SELECT ContactId
                                                              FROM OpportunityContactRole 
                                                              WHERE OpportunityId = :opp.Id AND Contact.AccountId = :opp.AccountId 
                                                                    AND Contact.AceptoPoliticaPrivacidad__c = true 
                                                                    AND Contact.RepresentanteLegal__c = true
                                                              ORDER BY Contact.CreatedDate ASC
                                                              LIMIT 1 ];

                resultado = !lOppContRole.isEmpty();                     

            }

        }

        return resultado;
    }

    /*
    Método que se encarga de comprobar si una oportunidad tiene producto
    @param  idOportunidad: id de la oportunidad
    @return booleano que devuelve true cuando tiene producto asociado y false en caso contrario
     */
    @AuraEnabled(cacheable = false)
    public static boolean validacionProducto(Id idOportunidad){
    
        Integer numberProducts = [SELECT Count() FROM OpportunityLineItem WHERE OpportunityId = :idOportunidad];
        if (numberProducts < 1) return false;
        else return true;
    }

}