public without sharing class OM_CheckOfficeBot {
    
    @InvocableMethod(label='Obtener Cuenta por Índice')
    public static List<ReturnWrapper> getAccountByIndex(List<InputWrapper> inputInfo ) {

        List<ReturnWrapper> returnInfo = new List <ReturnWrapper>();
        ReturnWrapper returnRecord = new ReturnWrapper();
        returnRecord.officeToReturn = '';
        returnRecord.officeNamesReturn = '';
        returnRecord.index = -1;

        if(inputInfo != null && !inputInfo.isEmpty()){
            InputWrapper inputRecord = inputInfo.get(0); 
            //Si no se ha buscado todavía oficinas
            if(String.isBlank(inputRecord.officeNamesInput) && String.isNotBlank(inputRecord.stateName)){
                List<String> nameList = new List<String>();
                for(Account acc: [SELECT Name, Phone FROM Account 
                                                WHERE Recordtype.DeveloperName = 'Oficina' 
                                                    AND ShippingStreet != null 
                                                    AND ShippingState =: inputRecord.stateName 
                                                    AND ShippingStreet != null
                                                    AND Activa__c = true LIMIT 50]){

                    String nameToAdd = String.isNotBlank(acc.Phone) ? (acc.Name + ' (' + acc.Phone + ')') : acc.Name;
                    nameList.add(nameToAdd);
                }                
                inputRecord.officeNamesInput = String.join(nameList,'##');
            }

            if(String.isNotBlank(inputRecord.officeNamesInput)){
                List<String> accList = inputRecord.officeNamesInput.split('##');
                returnRecord.officeToReturn = accList.get(0);
                accList.remove(0);
                returnRecord.officeNamesReturn = String.join(accList,'##');
                returnRecord.index = accList.size();                
            }            
        }
        returnInfo.add(returnRecord);
        return returnInfo;
    }
    public class ReturnWrapper {
        @InvocableVariable
        public String officeToReturn;
        
        @InvocableVariable
        public String officeNamesReturn;

        @InvocableVariable
        public Integer index;
    }    

    public class InputWrapper {
        @InvocableVariable
        public String stateName;
        
        @InvocableVariable
        public String officeNamesInput;
    }    
    
}