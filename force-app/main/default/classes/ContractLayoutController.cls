/*
@author LeadClic Solutions S.L.
@date 07/11/2019
@description Clase controladora del componente que sustituye el layout estándar de Expediente

FECHA		AUTOR		Descripción
07/11/2019	LCS-JZD 	Creación

*/
public class ContractLayoutController {

    /**
    * @description Método para extraer los campos del conjunto de campos ComponentLayout
    * @return ResultContracFields Estructura con el resultado y la lista de campos
    */
    @AuraEnabled
    public static ResultContracFields retrieveContractFields () {
        ResultContracFields resultCF = new ResultContracFields(); 
        List<FieldWrapper> lFieldWrapper = new List<FieldWrapper>();

        try{
            Schema.DescribeSObjectResult describeSObjectResult = Schema.getGlobalDescribe().get('Contract').getDescribe();
            Map<String,Schema.SObjectField> objFieldMap = describeSObjectResult.fields.getMap();
            Schema.FieldSet fieldSetObj = describeSObjectResult.FieldSets.getMap().get('ComponentLayout');

            if (fieldSetObj != null) {
                for(Schema.FieldSetMember fieldSet : fieldSetObj.getFields() ) {
                    lFieldWrapper.add( new FieldWrapper(
                        String.ValueOf(fieldSet.getLabel()),
                        String.ValueOf(fieldSet.getFieldPath())
                    ));
                }
            }

            resultCF.lContractFields = lFieldWrapper;

        }catch(Exception e){
            resultCF.status = false;
            resultCF.errorMsg = e.getMessage();
        }
        system.debug('result: '+resultCF);
        return resultCF; 
    }

    public class ResultContracFields {
        @AuraEnabled public Boolean status {get;set;}
        @AuraEnabled public String errorMsg {get;set;}
        @AuraEnabled public List<FieldWrapper> lContractFields {get;set;}

        public ResultContracFields (){
            status = true;
            errorMsg = '';
            lContractFields = new List<FieldWrapper>();
        }
    }

    public class FieldWrapper {
        @AuraEnabled public String fieldName {get;set;}
        @AuraEnabled public String fieldLabel {get;set;}
        
        public FieldWrapper(String fieldLabel,String fieldName) {
            this.fieldLabel  = fieldLabel;
            this.fieldName   = fieldName;
        }
    }

}