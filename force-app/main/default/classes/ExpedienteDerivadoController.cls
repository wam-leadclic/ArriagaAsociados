/*
@author Leadclic Solutions S.L.
@date 14/05/2019 
@description    Controlador del componente ExpedienteDerivado

<pre>
FECHA                   AUTOR                   ACCION
14/05/2019              LCS - RDM               Creación
02/12/2019              LCS - RDM               Modifición. Se añade parche en la creación de los expediente derivados para los ids antiguos.
02/12/2019				      LCS - HPS				        Modificación. Se hereda Producto__c en el método creacionExpediente

*/
public with sharing class ExpedienteDerivadoController {
    /**
    * Método que se encarga de recuperar los datos de la configuración personalizada y enviarla al componente para rellenar el picklist
    *
    * @return lista de String
    */
    @AuraEnabled
    public static list<String> getTipoDerivado(){
        Datosexpedientederivado__c datosExp = Datosexpedientederivado__c.getInstance('General');
        list<String> tipoExp = datosExp.TiposDeriv__c.split(',');

        return tipoExp;
    }
    
    public class WrapperExp{
        @AuraEnabled public String NumExpediente;
        @AuraEnabled public String Oportunidad;
        @AuraEnabled public String Cuenta;
    }
    /**
    * Método que se encarga de recuperar los datos del expediente actual y enviarlo al componente para mostrarlo
    *
    * @param Id del contrato del registro
    * @return lista de String
    */
    @AuraEnabled
    public static WrapperExp getExpediente(Id contractId){
        Contract expediente = [SELECT Id, AccountId, Account.Name, ContractNumber, IdExpediente__c, Oportunidad__c, Oportunidad__r.Name FROM Contract WHERE id =: contractId];

        WrapperExp datosExp = new WrapperExp();
            datosExp.NumExpediente = expediente.IdExpediente__c;
            datosExp.Oportunidad = expediente.Oportunidad__r.Name;
            datosExp.Cuenta = expediente.Account.Name;
       
       return datosExp;
    }
    /**
    * Método que se encarga de recuperar los datos del expediente actual y enviarlo al componente para mostrarlo
    *
    * @param Id del contrato del registro
    * @return lista de String
    */
    @AuraEnabled
    public static Boolean checkExpedienteDerivado(Id contractId){
        Boolean permitirDerivar;
        Contract expediente = [SELECT Id, ExpedientePrincipal__c FROM Contract WHERE id =: contractId];

       if(String.isBlank(expediente.ExpedientePrincipal__c)) permitirDerivar = true;
       else permitirDerivar = false;
       
       return permitirDerivar;
    }
    /**
    * Método que se encarga de crear el expediente derivado y llamar al WS de Arriaga para comunicar esta situación
    *
    * @param Id del contrato del registro
    */
    @AuraEnabled
    public static String creacionExpediente(Id contractId, String tipoDerivado){
        try{
            //Guardamos una copia de la BBDD de ese momento.
            Contract expediente = [SELECT Id, AccountId, Account.Name, ContractNumber, IdExpediente__c, Oportunidad__c, Oportunidad__r.Name, Producto__c FROM Contract WHERE id =: contractId];
            //Recuperamos todos los IdExpedientes relacionados con el derivado
            list<Contract> lExpedienteSecundarios = [SELECT IdExpediente__c FROM Contract WHERE (id =: contractId) OR (ExpedientePrincipal__c =: contractId)];
            integer idexp = 0;//Variable que utilizamos para obtener el mayor
            String oldIdentificador;//Recuperamos el identificador último utilizado relacionado al contrato padre.
            for(Contract c : lExpedienteSecundarios){
                if(idexp < integer.valueOf(c.IdExpediente__c.substring(4))){
                    idexp = integer.valueOf(c.IdExpediente__c.substring(4)); 
                    oldIdentificador = c.IdExpediente__c;
                }
            }
            //Le sumamos uno al dígito de control y lo guardamos en una variable
            String newIdentificador;
            String nuevoIdExpediente;

            if(oldIdentificador.length() < 11){
                newIdentificador = '01';
                nuevoIdExpediente = oldIdentificador.substring(0,4) + newIdentificador + oldIdentificador.substring(4,oldIdentificador.length());
            } else {
                Integer identificador = integer.valueOf(oldIdentificador.substring(5,6));
                if(identificador < 9){
                    identificador = identificador + 1;
                    newIdentificador = '0'+ identificador;
                }
                else{
                    identificador = integer.valueOf(oldIdentificador.substring(4,5));
                    identificador = identificador + 1;                
                    newIdentificador = identificador + '0';
                }
                nuevoIdExpediente = oldIdentificador.substring(0,4) + newIdentificador + oldIdentificador.substring(6,oldIdentificador.length());
            }
            Contract expedienteDerivado = new Contract();
                expedienteDerivado.AccountId = expediente.AccountId;
                expedienteDerivado.IdExpediente__c = nuevoIdExpediente;
                expedienteDerivado.Oportunidad__c = expediente.Oportunidad__c;
                expedienteDerivado.ExpedientePrincipal__c = expediente.Id;
                expedienteDerivado.TipoExpDerivado__c = tipoDerivado;
                // campo heredado añadido
            	expedienteDerivado.Producto__c = expediente.Producto__c; 
            insert expedienteDerivado;

            /* FALTA LLAMADA A SU WS */


            //Si no ha ocurrido ningún error, mostramos el nuevo expediente
            String url = URL.getSalesforceBaseUrl().toExternalForm()+'/'+expedienteDerivado.id;
            return url;
        }
        catch(Exception e){
            throw e;
        }

    }
}