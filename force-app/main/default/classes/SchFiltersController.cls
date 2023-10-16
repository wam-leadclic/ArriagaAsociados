public with sharing class SchFiltersController {
   
    
    /**
     * Calculate custom metadata filters and custom lookups showed in Filters card
     * @param  params params received from front-end
     * @return        Custom filters
     */ 
    
    
    @auraEnabled 
    public static GetMetadataFilter getMetadataFilter (Object params) {

        // params cast
        Map<Object, Object> mParams;
        if(params != null) {
            Map<Object, Object> wrapperParam = ( Map<Object, Object>) params;
            mParams = (Map<Object, Object>) wrapperParam.get('filterValues');
        }
        
        GetMetadataFilter response = new GetMetadataFilter();

        try {

            // Calendar Settings describe
            Map<String, Schema.SObjectField> mFieldInfo = Schema.getGlobalDescribe().get('CalendarSetting__c').getDescribe().fields.getMap();

            // metadata retrieval
            List<CalendarFilter__mdt> lMetadata = [SELECT Id, FieldConstraint__c, Field__r.QualifiedApiName, LookupTo__r.QualifiedApiName, ReturningFields__c 
                                                    FROM CalendarFilter__mdt];

            // filters init values
            Map<String, Object> mValues;

            // check if a custom implementation exists
            Type t = Type.forName('SchExtendedFeaturesImplementation');
            if (t != null){
                SchExtendedFeatures extendedFeatures = (SchExtendedFeatures)t.newInstance();
                mValues = extendedFeatures.setInitFilterParams(mParams);
            }
            
            for(CalendarFilter__mdt mdt : lMetadata) {
                
                Schema.DescribeFieldResult fieldInfo = mFieldInfo.get( mdt.Field__r.QualifiedApiName.toLowerCase() ).getDescribe();
                System.debug(fieldInfo);
                
                FilterField filter = new FilterField();
                filter.fieldName = mdt.Field__r.QualifiedApiName;
                filter.fieldType = fieldInfo.type.name();
                
                System.debug(filter.fieldType);
                filter.fieldLabel = fieldInfo.label;
                filter.fieldConstraint = mdt.FieldConstraint__c;
                filter.customReference = (filter.fieldType == 'REFERENCE' && !String.isBlank(filter.fieldConstraint));
                if (filter.customReference) {
                	filter.objectType = mdt.LookupTo__r.QualifiedApiName;
                	filter.returningFields = mdt.ReturningFields__c;    
                }

                if(mValues != null && mValues.containsKey(mdt.Field__r.QualifiedApiName)) {
                    
                    if(filter.customReference) {
                        LookupSearchResult initValue = (LookupSearchResult) mValues.get(mdt.Field__r.QualifiedApiName);
                        filter.value = initValue.getId();
                        filter.lookupResultInit.add((LookupSearchResult)mValues.get(mdt.Field__r.QualifiedApiName));
                        
                    } else {
                        filter.value = mValues.get(mdt.Field__r.QualifiedApiName);
                    }
                }

                response.lFieldConstraint.add(filter);
            	
            }
            
        } catch (Exception e) {
            System.debug(e.getStackTraceString() + e.getMessage());
        }

        return response;
    }

    public class GetMetadataFilter {
        @auraEnabled public Boolean status;
        @auraEnabled public String errorMsg;
        @auraEnabled public List<FilterField> lFieldConstraint;

        public GetMetadataFilter() {
            status = true;
            errorMsg = '';
            lFieldConstraint = new List<FilterField>();
        } 
    }

    public class FilterField {
        @auraEnabled public String fieldName;
        @auraEnabled public String fieldLabel;
        @auraEnabled public Object value;
        @auraEnabled public String fieldType;
        
        // fields applied if custom reference
        @auraEnabled public String fieldConstraint;
        @auraEnabled public Boolean customReference;
        @auraEnabled public List<LookupSearchResult> lookupResultInit;
        @auraEnabled public String objectType;
        @auraEnabled public String returningFields;
        
        public FilterField() {
            this.customReference = false;
            this.lookupResultInit = new List<LookupSearchResult>();
        }
    }



}