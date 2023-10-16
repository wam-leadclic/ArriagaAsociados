/*
@author LeadClic Solutions S.L.
@date 16/04/2019
@description Clase que se encarga de la lógica del trigger de cuenta

<pre>
FECHA                 AUTOR           ACCION
16/04/2019			LCS - RMG		 Creación.
04/09/2019 			LCS - RDM		 Modificación. Se añade en beforeInsert que cuando el tipo de documento sea pasaporte no realice validación
 
*/
public without sharing class TriggerAccountHandler {
	 /**
     *  Método que se llama desde el trigger de cuenta
     *  
     * @param  mapa de los valores actuales
     * @param  lista con los contactos que se han modificado
     */
    public static void afterUpdate(list<Account> lOldCuentas, map<Id, Account> nNewCuentas){
        //Recorremos las cuentas y nos quedamos con los que se han modificado el email
        list<Id> lContactosEmailModificado = new list<Id> ();//Lista con los contactos que se han modificado el email            
        //Recuperamos los metadatos para saber si la integración está activa
        system.debug('entra');
        ActivacinIntegracion__mdt activoIntegracion = [SELECT Activo__c
                                                        FROM ActivacinIntegracion__mdt
                                                        WHERE Label = 'Account' LIMIT 1];
        
        List<Id> lClientesActualizarProd = new List<Id> ();//Lista de IDs que enviaremos al método encargado de actualizar el contacto

        for(Account cuenta :lOldCuentas){
            //Si el email ha cambiado y no está vacío entonces se necesita cambiar al usuario
            if(cuenta.personEmail != nNewCuentas.get(cuenta.id).personEmail 
               && nNewCuentas.get(cuenta.id).personEmail != null && nNewCuentas.get(cuenta.id).personEmail != ''
               && cuenta.PersonContactId != null){
                lContactosEmailModificado.add(cuenta.PersonContactId);
            }
            system.debug('entra2'+cuenta.AccountSyncMinerva__c);
            if(activoIntegracion.Activo__c){
                //Para poder enviar la cuenta a producción tiene que ya ser cliente
                if(cuenta.EstadoCuenta__c == nNewCuentas.get(cuenta.id).EstadoCuenta__c &&( nNewCuentas.get(cuenta.id).EstadoCuenta__c == 'Cliente' || nNewCuentas.get(cuenta.id).EstadoCuenta__c == 'Fallecido' )
                  && !String.isBlank(cuenta.AccountSyncMinerva__c) || !String.isBlank(cuenta.AccountSyncProd__c)){
                    if(cuenta.recordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cuenta personal').getRecordTypeId()){
                        if(cuenta.FirstName != nNewCuentas.get(cuenta.id).FirstName && !lClientesActualizarProd.contains(cuenta.id)){
                            lClientesActualizarProd.add(cuenta.id); 
                        }
                        if(cuenta.LastName != nNewCuentas.get(cuenta.id).LastName && !lClientesActualizarProd.contains(cuenta.id)){
                            lClientesActualizarProd.add(cuenta.id); 
                        }
                    }
                    else{
                        if(cuenta.Name != nNewCuentas.get(cuenta.id).Name && !lClientesActualizarProd.contains(cuenta.id)){
                            lClientesActualizarProd.add(cuenta.id); 
                        }
                    }
                    if(cuenta.TipoDocumento__c != nNewCuentas.get(cuenta.id).TipoDocumento__c && !lClientesActualizarProd.contains(cuenta.id)){
                        lClientesActualizarProd.add(cuenta.id);                         
                    }
                    if(cuenta.DocumentoIdentidad__c != nNewCuentas.get(cuenta.id).DocumentoIdentidad__c && !lClientesActualizarProd.contains(cuenta.id)){
                        lClientesActualizarProd.add(cuenta.id);                         
                    }
                    if(cuenta.Phone != nNewCuentas.get(cuenta.id).Phone && !lClientesActualizarProd.contains(cuenta.id)){
                        system.debug('pasa '+cuenta.Phone);
                        lClientesActualizarProd.add(cuenta.id);                         
                    }
                    if(cuenta.PersonMobilePhone != nNewCuentas.get(cuenta.id).PersonMobilePhone && !lClientesActualizarProd.contains(cuenta.id)){
                        lClientesActualizarProd.add(cuenta.id);                         
                    }
                    if(cuenta.PersonEmail != nNewCuentas.get(cuenta.id).PersonEmail && !lClientesActualizarProd.contains(cuenta.id)){
                        lClientesActualizarProd.add(cuenta.id);                         
                    }
                    if(cuenta.CorreoElectronicoSecundario__c != nNewCuentas.get(cuenta.id).CorreoElectronicoSecundario__c && !lClientesActualizarProd.contains(cuenta.id)){
                        lClientesActualizarProd.add(cuenta.id);                         
                    }
                    if(cuenta.ShippingCity != nNewCuentas.get(cuenta.id).ShippingCity && !lClientesActualizarProd.contains(cuenta.id)){
                        lClientesActualizarProd.add(cuenta.id);                         
                    }
                    if(cuenta.ShippingCountry != nNewCuentas.get(cuenta.id).ShippingCountry && !lClientesActualizarProd.contains(cuenta.id)){
                        lClientesActualizarProd.add(cuenta.id);                         
                    }
                    if(cuenta.ShippingPostalCode != nNewCuentas.get(cuenta.id).ShippingPostalCode && !lClientesActualizarProd.contains(cuenta.id)){
                        lClientesActualizarProd.add(cuenta.id);                         
                    }
                    if(cuenta.ShippingState != nNewCuentas.get(cuenta.id).ShippingState && !lClientesActualizarProd.contains(cuenta.id)){
                        lClientesActualizarProd.add(cuenta.id);                         
                    }
                    if(cuenta.ShippingStreet != nNewCuentas.get(cuenta.id).ShippingStreet && !lClientesActualizarProd.contains(cuenta.id)){
                        lClientesActualizarProd.add(cuenta.id);                         
                    }
                    if(cuenta.IBAN__pc != nNewCuentas.get(cuenta.id).IBAN__pc && !lClientesActualizarProd.contains(cuenta.id)){
                        lClientesActualizarProd.add(cuenta.id);                       
                    }
                     
                      }
                  }
            }
                
        //Llamamos a la clase a futuro que se encarga de actualizar la información del usuario de la comunidad
        //No se puede hacer en la misma ejecución la modificación de una cuenta personal y un usuario por eso se llama a la clase a 
        //futuro para poder saltar el error MIXED_DML_OPERATION
        if(!lContactosEmailModificado.isEmpty()) ActualizarInfoUsuarioComunidad.actualizarEmailUsuarios(lContactosEmailModificado);
        //Enviamos los clientes que se enviarán a Minerva y Producción a una clase que realizará comprobaciones previas
        if(!lClientesActualizarProd.isEmpty()) sendExp(lClientesActualizarProd);
    }
    /**
     *  Método que se llama desde el trigger de cuenta
     *  
     * @param  mapa de los valores actuales
     * @param  lista con los contactos que se han modificado
     */
    public static void beforeUpdate(map<Id, Account> mOldCuentas, list<Account> lNewCuentas){
        Map<Id, String> mCuentasConError = new map<Id, string>();
        list<Account> ContactoDNICumplimentado = new list<Account>();
        
        //Recorremos las cuentas
        for(Account cuenta : lNewCuentas){
            if(!String.isBlank(cuenta.TipoDocumento__c) && cuenta.TipoDocumento__c != system.Label.PasaporteVal){
                //Si el estado de la cuenta es Cliente y el documento de identidad es vacío, mostramos error.
                if(cuenta.EstadoCuenta__c == Label.EstadoCuentaCliente && String.isBlank(cuenta.DocumentoIdentidad__c)) mCuentasConError.put(cuenta.id, Label.DNIVacio);
                //Solo realizaremos la validación del DNI aquellos contactos que ya tengan cumplimentado el DNI y que lo hayan modificado
                else if(!String.isBlank(cuenta.DocumentoIdentidad__c) && cuenta.DocumentoIdentidad__c != mOldCuentas.get(cuenta.id).DocumentoIdentidad__c) ContactoDNICumplimentado.add(cuenta);
                else if(!String.isBlank(cuenta.DocumentoIdentidad__c) && cuenta.TipoDocumento__c != mOldCuentas.get(cuenta.id).TipoDocumento__c) ContactoDNICumplimentado.add(cuenta);                
            }
        }        
        
        //Enviamos las nuevas cuentas y un mapa vacío de errores para realizar las comprobaciones
        if(!ContactoDNICumplimentado.isEmpty() && ContactoDNICumplimentado != null) validacionDNI(ContactoDNICumplimentado, mCuentasConError);
        
        //Si el mapa viene relleno, recorremos el mapa con las cuentas actualizadas y si en el mapa esta el ID, devolvemos el error
        if(!mCuentasConError.isEmpty() && mCuentasConError != null){
            for (Account cuenta : lNewCuentas){
                if(mCuentasConError.containsKey(cuenta.id)){
                    cuenta.addError(mCuentasConError.get(cuenta.Id));
                }                
            }
        }
    }
    /**
     *  Método que se llama desde el trigger de cuenta
     *  
     * @param  lista con los contactos que se han modificado
     */
    public static void beforeInsert(list<Account> lnewCuentas){               
        Map<Id, String> mCuentasConError = new map<Id, string>();
        list<Account> ContactoDNICumplimentado = new list<Account>();
        //Solo comprobaremos aquellos contactos que ya tengan cumplimentado el DNI y que aun no sean cliente
        for(Account cuenta : lnewCuentas){
            if(!String.isBlank(cuenta.TipoDocumento__c)  && cuenta.TipoDocumento__c != system.Label.PasaporteVal){
                //Si el estado de la cuenta es Cliente y el documento de identidad es vacío, mostramos error.
                if(cuenta.EstadoCuenta__c == Label.EstadoCuentaCliente && String.isBlank(cuenta.DocumentoIdentidad__c)) mCuentasConError.put(cuenta.id, Label.DNIVacio);
                //Si la cuenta a insertar es Cliente potencial y el DNI viene relleno, realizamos la comprobación
                else if(!String.isBlank(cuenta.DocumentoIdentidad__c)) ContactoDNICumplimentado.add(cuenta);
            }
        }
        //Enviamos las nuevas cuentas y un mapa vacío de errores para realizar las comprobaciones
        if(!ContactoDNICumplimentado.isEmpty() && ContactoDNICumplimentado != null) validacionDNI(ContactoDNICumplimentado, mCuentasConError);
        
        //Si el mapa viene relleno, recorremos el mapa con las cuentas actualizadas y si en el mapa esta el ID, devolvemos el error
        if(!mCuentasConError.isEmpty() && mCuentasConError != null){
            for (Account cuenta : lnewCuentas){                
                if(mCuentasConError.containsKey(cuenta.id)){
                    cuenta.addError(mCuentasConError.get(cuenta.Id));
                }                
            }
        }
    }
    
    /**
     *  Método para realizar la comprobación del DNI y añadir a un mapa con errores
     *  
     * @param  lista con los contactos que se han modificado
     * @param  mapa donde indicaremos los id de la cuenta error y su mensaje
     */
    public static void validacionDNI (list<Account> lCuentas, Map<Id, String> mCuentasError){     
        //Recorremos las cuentas para comprobar el DNI
        for(Account checkCuentas: lCuentas){  
            if(String.isBlank(checkCuentas.DocumentoIdentidad__c)) mCuentasError.put(checkCuentas.id, Label.DNIVacio);
            else{
                //Enviamos el campo de DNI a la clase que realiza la comprobación  
                String validacion = ValidacionDNI.validarCif(checkCuentas.DocumentoIdentidad__c);
                //Si la validación es errónea, añadimos el id y el error al mapa que utilizaremos mostrar el error
                if(validacion != 'OK') mCuentasError.put(checkCuentas.id, validacion);
            }
        }      
        
    }

    /**
     *  Método que comprueba si algun dato sensible ha sido modificado para enviar la información a Minerva y Producción
     *  
     * @param  lista con las Cuentas a enviar a MInerva/producción
     */
     /*04/10/2019  LCS - RDM  */
     @InvocableMethod(label='Get Account to Sync' description='Returns the list of account to sync with Minerva' category='Account')
    public static void sendExp(List<Id> lCliAenviar){ 
       //Si el mapa de Numero de expediente y cuenta es diferente a vacíos mandamos la información a Minerva
        if(!lCliAenviar.isEmpty()){   
            //LLAMADA A CLASE CALLOUT
            MinervaRestCallouts.futureSendWSMinerva(null, lCliAenviar);
            //LLAMADA A CLASE CALLOUT
            MinervaRestCallouts.futureSendWSProd(null, lCliAenviar);   
        }
    }
    
}