/*
@author Leadclic Solutions S.L.
@date 14/05/2019 
@description    Controlador del botón de forzar resincronización

<pre>
FECHA                   AUTOR                   ACCION
13/11/2019              LCS - GQG               Creación
*/
public with sharing class ResyncButtonController {
    
    @AuraEnabled
    public static SendDataResponse sendData(Id recordId){

        SendDataResponse response = new SendDataResponse(); 
        
        try  {

            if(!String.isBlank(recordId)) {

                // check if account or contract is present
                String objectType = String.valueOf(recordId.getSobjectType());
                switch on objectType {

                    when 'Account' {
                        resyncAccount(recordId);   
                    }   
                    when 'Contract' {
                        resyncContract(recordId);   
                    }   
                    when else {
                        response.status = false;
                        response.errorMsg = 'Exception: invalid object type';
                    } 
                }
            } else {
                response.status = false;
                response.errorMsg = 'Exception: null id found';
            }

        } catch ( Exception e ) {
            response.status = false;
            response.errorMsg = e.getMessage() + e.getStackTraceString();
        }
    
        return response;
    
    }


    private static void resyncAccount(String recordId) {

        List<String> lAccountId = new List<String>();
        lAccountId.add(recordId);
        
        System.debug('resyncAccount');
        System.debug(lAccountId);
        // production call
        MinervaRestCallouts.futureSendWSProd(null, lAccountId);

        // minerva call
        MinervaRestCallouts.futureSendWSMinerva(null, lAccountId);

    }

    /**
     * resyncContract call integration methods (minerva and production) with Contract info
     */ 
    private static void resyncContract(String recordId) {

        System.debug('resyncContract');

        Contract cont = [SELECT Id, AccountId, IdExpediente__c FROM Contract WHERE Id = :recordId LIMIT 1];
        Map<String, Id> mExpAccount = new Map<String, Id>();
        mExpAccount.put(cont.IdExpediente__c, cont.AccountId);

        System.debug(mExpAccount);
        
        // production call
        MinervaRestCallouts.futureSendWSProd(mExpAccount, null);

        // minerva call
        MinervaRestCallouts.futureSendWSMinerva(mExpAccount, null);

    }



    public class SendDataResponse {

        @auraEnabled public Boolean status = true;
        @auraEnabled public String errorMsg = '';

    }
    
}