/*
@author LeadClic Solutions S.L.
@date 07/11/2019
@description Clase controladora del componente que sustituye el layout del chatter estándar de Expediente

FECHA		AUTOR		Descripción
01/07/2021	LCS-DRA 	Creación

*/
public class ContractChatterLayoutController {

    /**
    * @description Método para extraer las entradas del chatter asociado a un expediente
    * @return ResultContracFields Estructura con el resultado y la lista de campos
    */
    @AuraEnabled
    public static ResultContracChatterFeeds retrieveContractChatterFeeds (Id recordId) {
        ResultContracChatterFeeds resultCCF = new ResultContracChatterFeeds(); 
        List<FieldWrapper> lFieldWrapper = new List<FieldWrapper>();

        try{
            List<ContractFeed> lContractFeed = new  List<ContractFeed>();
            if(recordId==null){

                lContractFeed= [SELECT Id, LastModifiedDate, Type, Body, 
                (SELECT Id, FieldName, NewValue, OldValue FROM FeedTrackedChanges) 
                 FROM ContractFeed ORDER BY LastModifiedDate DESC];
            }else{
                lContractFeed = [SELECT Id, LastModifiedDate, Type, Body, 
                (SELECT Id, FieldName, NewValue, OldValue FROM FeedTrackedChanges) 
                FROM ContractFeed WHERE ParentId = :recordId ORDER BY LastModifiedDate DESC];
            }
            

            if(!lContractFeed.isEmpty()){
                for(ContractFeed fi : lContractFeed){
                    if(fi.Type.equals('TextPost') || !String.isBlank(fi.Body)){
                        lFieldWrapper.add( new FieldWrapper(
                            String.ValueOf(fi.Id),
                            String.ValueOf(fi.Body),
                            fi.LastModifiedDate
                        ));

                    } else if(fi.Type.equals('TrackedChange')){
                        for(FeedTrackedChange ftc : fi.FeedTrackedChanges ){
                            String oldValue=ftc.OldValue!=null?String.ValueOf(ftc.OldValue):'';
                            String newValue=ftc.NewValue!=null?String.ValueOf(ftc.NewValue):'';
                            lFieldWrapper.add( new FieldWrapper(
                                String.ValueOf(fi.Id),
                                String.ValueOf(label.customChatterCardMessage.replace('%$$1%',oldValue).replace('%$$2%',NewValue)),
                                fi.LastModifiedDate
                            ));
                        }
                    }
                }
            }

            resultCCF.lContractChatterFeeds = lFieldWrapper;

        }catch(Exception e){
            resultCCF.status = false;
            resultCCF.errorMsg = e.getMessage();
        }

        return resultCCF; 
    }

    public class ResultContracChatterFeeds {
        @AuraEnabled public Boolean status {get;set;}
        @AuraEnabled public String errorMsg {get;set;}
        @AuraEnabled public List<FieldWrapper> lContractChatterFeeds {get;set;}

        public ResultContracChatterFeeds (){
            status = true;
            errorMsg = '';
            lContractChatterFeeds = new List<FieldWrapper>();
        }
    }

    public class FieldWrapper {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String body {get;set;}
        @AuraEnabled public DateTime datefeed {get;set;}
        
        public FieldWrapper(String id, String Body, DateTime datefeed) {
            this.id = id;
            this.body = body;
            this.datefeed = datefeed;
        }
    }
}