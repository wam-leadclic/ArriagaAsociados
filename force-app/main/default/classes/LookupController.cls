public with sharing class LookupController {

    private final static Integer MAX_RESULTS = 10;

    /**
     * getCustomLookupResults custom lookup search using input data
     * @param  searchTerm       search term used in SOSL query
     * @param  selectedIds      ids selected in front-end (lookup value)
     * @param  fieldConstraint  constraint that will aplly in where clause
     * @param  objectType       object used in query
     * @param  returningFields  returning fields used in search result.
     * @return                  list of search results
     */ 
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getCustomLookupResults(String searchTerm, List<String> selectedIds, String fieldConstraint, String objectType, String returningFields) {
        
        System.debug(fieldConstraint);
		if(fieldConstraint.contains('Provincia__c')){
            system.debug('YES');
            fieldConstraint = fieldConstraint.remove('ShippingState = Provincia__c AND');
        }
        
        // Prepare query paramters
        searchTerm += '*';

        // extend search query if returning fields is filled
        String queryFields = 'Id,Name';
        if(!String.isBlank(returningFields)) {
            queryFields += ',' + returningFields;
        }

        String queryFind = 'FIND :searchTerm IN ALL FIELDS RETURNING ' + objectType + ' (' + queryFields;

        String queryWhere = ' WHERE id NOT IN :selectedIds';
        queryWhere += ' AND Activa__c = true';
        if (String.isNotBlank(fieldConstraint)) {
            queryWhere += ' AND ' + fieldConstraint;
        } 
        queryWhere+= ')';
        
        String queryLimit = ' LIMIT :MAX_RESULTS';

        String queryTotal = queryFind + queryWhere + queryLimit;
        System.debug(queryTotal);

        List<List<SObject>> searchResults = Search.query(queryTotal);
        
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String entityName = objectType.toLowerCase();
        String iconName = (entityName.contains('__c')) ? 'standard:account' : 'standard:' + entityName;
        
        
        // returning fields list
        List<String> lFields = (returningFields != null) ? returningFields.split(',') : new List<String>();
        
        Account [] accounts = ((List<Account>) searchResults[0]);
        
        for (Account account : accounts) {
            
            String summaryRecord = '';
            if(!lFields.isEmpty()) {

                List<String> lFieldValue = new List<String>();
                
                try {
                    for(String fieldName : lFields) {
                        lFieldValue.add((String) account.get(fieldName)); 
                    
                    }
                
                } catch (Exception e) {
                    System.debug(e.getMessage() + e.getStackTraceString());
                }
                
                summaryRecord = String.join(lFieldValue, ' • ');   
                
            }
            
            results.add(new LookupSearchResult(account.Id, objectType, iconName, account.Name, summaryRecord));
        }

        return results;
    }
}