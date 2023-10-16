/*
@author LeadClic Solutions S.L.
@date 
@description Clase que contiene el código controlador del LWC gdDocumentitems
<pre>
FECHA             AUTOR           ACCION
29/05/2019      LCS - RDM         Modificación. 
01/07/2019      LCS - RMG         Modificación. Se cambia para que al buscar los tipos de documentos se busque por el tipo de documento y no por el nombre
 
*/
public without sharing class GDDocumentListController {

    @AuraEnabled
    public static getFieldListResponse getFieldDoc(String nameDocType){
        getFieldListResponse response = new getFieldListResponse();

        try{
            // Obtenemos el id y nombre del tipo de documento correspondiente al nombre del documento enviado desde el componente
            //list<TipoDocumento__c> lTipoDoc = [SELECT Id, Name FROM TipoDocumento__c WHERE Name =:nameDocType];
            list<TipoDocumento__c> lTipoDoc = [SELECT Id, Name FROM TipoDocumento__c WHERE TipoDocumento__c =:nameDocType];

            //Si en la lista existe el valor, es decir, el tamaño de la lista es mayor a 0, realizamos la query para obtener todos los campos y tipos de la misma.
            if(lTipoDoc.size() > 0){
                list<CampoDocumento__c> lCamposDoc = [SELECT Id, Name, NombreAPI__c, TipoCampo__c FROM CampoDocumento__c WHERE TipoDocumento__c =:lTipoDoc[0].Id];
                list<FieldItem> lItems = new list<FieldItem>(); 
                for(CampoDocumento__c campos : lCamposDoc){
                    FieldItem fieldsResp = new FieldItem();   
                        fieldsResp.id = campos.Id;
                        fieldsResp.nameField = campos.Name;
                        fieldsResp.nameAPIField = campos.NombreAPI__c;
                        fieldsResp.typeField = campos.TipoCampo__c;
                    lItems.add(fieldsResp);
                }

                if(!lItems.isEmpty()) response.lFieldsItem = lItems;
                else  response.errorMsg = 'No existen campos para ese producto.';
            }
            else{
                response.errorMsg = 'No existen campos para ese producto.';
            }
        }catch(Exception e){
            response.status = false;
            response.errorMsg = 'Error : ' + e.getMessage();
        }
        return response;
    }

    @AuraEnabled(cacheable=true)
    public static List<TipoDocumento__c> getDocTypes(){
        List<TipoDocumento__c> tipoDocumento = new List<TipoDocumento__c>();
        try {
            tipoDocumento= [SELECT ValorEtiqueta__c, ExternalID__c FROM TipoDocumento__c WHERE SubidaComunidad__c= true];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return tipoDocumento;
    }

    public class getFieldListResponse {

        @AuraEnabled public Boolean status = true;
        @AuraEnabled public String errorMsg = '';
        @AuraEnabled public List<FieldItem> lFieldsItem;

    }
   
    @AuraEnabled
    public static void getIdOrigenMin(String thisidCliente, String thisidExpediente){ 
		List<Account> laccToUp = new List<Account>();
        List<Contract> lexpToUp = new List<Contract>();
        List<Opportunity> lOppToUp = new List<Opportunity>();
        system.debug('thisidExpediente '+thisidExpediente);
        List<Contract> lExp = [SELECT id, IdOrigenMinerva__c, AccountId, IdClienteMinerva__c FROM Contract WHERE IdClienteMinerva__c =: thisidCliente LIMIT 1];
        List<Opportunity> lOpp = [SELECT id, NumeroExpediente__c,NumeroExpedienteMinerva__c  FROM Opportunity WHERE NumeroExpediente__c =: thisidExpediente LIMIT 1];
        system.debug('lExp.size() '+lOpp.size());
        if(lExp.size()!=0){
            for(Contract exp :lExp){
               exp.IdOrigenMinerva__c= exp.IdClienteMinerva__c;
               lexpToUp.add(exp);
               system.debug('exp.IdOrigenMinerva__c '+exp.IdOrigenMinerva__c);
              

            }
           
            update lexpToUp;  
        }
         if(lOpp.size()!=null){
            for(Opportunity opp :lOpp){
                opp.NumeroExpedienteMinerva__c = opp.NumeroExpediente__c;
                lOppToUp.add(opp);
            }
             List<Account> lacc = [SELECT id,IdClienteMinerva__c,IdOrigen__c FROM Account WHERE IdClienteMinerva__c =: thisidCliente LIMIT 1]; 
             for(Account acc :lacc){
                 acc.IdOrigen__c=acc.IdClienteMinerva__c;
                 system.debug('acc.IdOrigen__c '+acc.IdOrigen__c);
                 laccToUp.add(acc);
             }
             system.debug('lOpp.size()' +lOpp.size());
             update laccToUp;
             update lOppToUp; 
            
        }
    }
    public class FieldItem{
         @AuraEnabled public String id;
         @AuraEnabled public String nameField;
         @AuraEnabled public String nameAPIField;
         @AuraEnabled public String typeField;
    }
}