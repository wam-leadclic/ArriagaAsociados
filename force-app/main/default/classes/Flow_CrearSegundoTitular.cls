/*
@author LeadClic Solutions S.L.
@date 02/04/2019
@description Clase que crea una cuenta personal con la información del segundo titular

<pre>
FECHA                 AUTOR           ACCION
02/04/2019			LCS - RMG		 Creación.
22/04/2019			LCS - RDM		 Modificación. Se añade la creación del rol de la oportunidad para la nueva cuenta creada.
17/07/2019			LCS - RDM		 Modificación. Se añade el tipo de documento a la hora de crear la cuenta
26/08/2019          LCS - RMG        Modificación. Se añaden nuevos parámetros para crear los roles de las oportunidades desde código ya que se necesita que sea without sharing
                                                    para que al usuario de la comunidad no le de error.
 
*/
global without sharing class Flow_CrearSegundoTitular {
    /**
     *  Método invocable desde los flujos. Utilizamos una lista de una wrapper class de datos enviados desde el flujo. 
     *  
     * 
     * @param  dni	dato procedente del flujo con la información proporcionado por el titular de la reclamación
     * @param  nombre dato procedente del flujo con la información proporcionado por el titular de la reclamación
     * @param  email dato procedente del flujo con la información proporcionado por el titular de la reclamación
     * @param  telefono dato procedente del flujo con la información proporcionado por el titular de la reclamación
     * @return	Devuelve el Id de la cuenta personal que se ha creado
     * 
     */
    @InvocableMethod(label='Llamada flujo' description='Llamada desde el flujo')
    public static list<id> MetodoInvocable (list<GetParameters> WrapperParams){
        //Lista con los resultados que recibe el flujo
        list<Id> resultado = new list<Id>();
        //Recuperamos la configuración personalizada con los parámetros que son fijos para la creación de la cuenta
        DatosFlujo__c datosFlujo = DatosFlujo__c.getOrgDefaults();
        
        //Si nos mandan el id de la cuenta del segundo titular no se tiene que crear ninguna cuenta nueva, solo hace falta crear el rol
        if(WrapperParams[0].IdCuentaSegundoTitular != null ){
            //Nos movemos al método que inserta el Rol indicado en la configuración personalizada al segundo titular
            rolSegundoTitular(WrapperParams[0].IdCuentaSegundoTitular, datosFlujo.RolSegundoTitular__c, WrapperParams[0].IdOportunidad);
            resultado.add(WrapperParams[0].IdCuentaSegundoTitular);
        }else{
            //Cuenta que se crea para el segundo titular de la reclamación
            Account cuentaNueva = new Account();  
            cuentaNueva.TipoDocumento__c = (String) WrapperParams[0].tipoDocumento;       
            cuentaNueva.DocumentoIdentidad__c = (String) WrapperParams[0].dni;
            cuentaNueva.EstadoCuenta__c = datosFlujo.EstadoCuenta__c;
            cuentaNueva.FirstName = (String) WrapperParams[0].nombre;
            cuentaNueva.LastName = (String) WrapperParams[0].nombre;
            cuentaNueva.PersonEmail = (String) WrapperParams[0].email;
            cuentaNueva.Phone = (String) WrapperParams[0].telefono;
            cuentaNueva.RecordTypeId = datosFlujo.IDTipoRegistroCuentaPersonal__c;
            cuentaNueva.OwnerId = datosFlujo.IdPropietarioSegundoTitular__c;
            insert cuentaNueva;
            
        /* system.debug('Oportunidad : ' + WrapperParams[0].IdOportunidad);
            system.debug('CuentaNueva : ' + cuentaNueva.Id);
            system.debug('Rol : ' + datosFlujo.RolSegundoTitular__c);*/
            
            //Nos movemos al método que inserta el Rol indicado en la configuración personalizada al segundo titular
            rolSegundoTitular(cuentaNueva.Id, datosFlujo.RolSegundoTitular__c, WrapperParams[0].IdOportunidad);
            resultado.add(cuentaNueva.id);
        }
        
        return resultado;
    }
    /*
     * @descripción Wrapper class que recibe los datos de entrada del flujo
     */ 
    global class GetParameters {
        
        @InvocableVariable( label = 'tipoDocumento' description = 'tipoDocumento' required=true )
        global String tipoDocumento; 
        
        @InvocableVariable( label = 'dni' description = 'dni' required=true )
        global String dni;  
        
        @InvocableVariable( label = 'nombre' description = 'nombre' required=true )
        global String nombre;  
        
        @InvocableVariable( label = 'email' description = 'email' required=true )
        global String email;  
        
        @InvocableVariable( label = 'telefono' description = 'telefono' required=false )
        global String telefono; 
        
        @InvocableVariable( label = 'IdOportunidad' description = 'Id oportunidad que usaremos para indicar el rol del nuevo contacto' required=true )
        global String IdOportunidad;  

        @InvocableVariable( label = 'IdCuentaSegundoTitular' description = 'Id de la cuenta del segundo titular' required=false )
        global String IdCuentaSegundoTitular;  
    }
    /**
     *  Método  
     *  
     * 
     * @param  dni	dato procedente del flujo con la información proporcionado por el titular de la reclamación
     * 
     */
      public static void rolSegundoTitular (Id CuentaSegundoTit, string Rol, Id Oportunidad){          
          //Recuperamos el id y el id de personCOntact que utilizaremos para crear el rol de opp
          Account cuentaContrato = [SELECT Id, personContactId FROM Account WHERE Id =: CuentaSegundoTit];
          //system.debug('CuentaNueva : ' + cuentaContrato.personContactId);
          //Función de contacto
          OpportunityContactRole rolContacto = new OpportunityContactRole();
              rolContacto.OpportunityId = Oportunidad;
              rolContacto.ContactId = cuentaContrato.personContactId;
              rolContacto.Role = Rol;
              rolContacto.IsPrimary = false;
          insert rolContacto;
          
      }
    
}