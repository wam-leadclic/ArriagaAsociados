/** 
 * Controller class for new calendar setting quick action or standar button override
 * @author Leadclic Solutions
 * @version 1.0
 * @since 2019-09-26
 */
public with sharing class CalendarSettingNewController {
    
    /**
     * Retrieves related info and field mapping if a custom metadata is defined.
     * @param  recordId related record Id if compoenent is called via quickaction 
     * @return          mapping and related record for calendar setting creation
     */ 
    @AuraEnabled
    public static GetInitDataResponse getInitData(Id recordId){

        GetInitDataResponse response = new GetInitDataResponse();

        try {

            String objectName;
            
            if(recordId != null) {
                
                objectName = recordId.getSobjectType().getDescribe().name;
               
                // calendar mapping retrieval, retrieve only fields related to quickaction host object
                Set<String> lRelatedField = new Set<String>();
                lRelatedField.add('Id');

                Map<String, String> mMap = new Map<String, String>();

                for(CalendarSettingMapping__mdt mapping : [SELECT Id, CalendarFilter__r.Field__r.QualifiedApiName, Field__r.QualifiedApiName 
                                                            FROM CalendarSettingMapping__mdt 
                                                            WHERE Object__r.QualifiedApiName = :objectName]) {
                    
                    lRelatedField.add(mapping.Field__r.QualifiedApiName);
                    mMap.put(mapping.CalendarFilter__r.Field__r.QualifiedApiName, mapping.Field__r.QualifiedApiName);
                }

                response.mMapping = mMap;

                // record retrieval
                String queryString = 'SELECT ' + String.join(new List<String>(lRelatedField), ',') + ' FROM ' + objectName + ' WHERE Id =  \'' + recordId + '\' LIMIT 1';  
                
                List<sObject> lObj = Database.query(queryString);
                response.relatedRecord = lObj[0];
            }

          
        } catch (Exception e) {
            System.debug(e.getMessage());
            response.status = false;
            response.errorMsg = e.getMessage() + e.getStackTraceString();
        }

        return response;
    }


    public class GetInitDataResponse {

        @auraEnabled public Boolean status = true;
        @auraEnabled public String errorMsg = ''; 

        @auraEnabled public sObject relatedRecord;
        @auraEnabled public Map<String, String> mMapping {get; set;}

    }


}