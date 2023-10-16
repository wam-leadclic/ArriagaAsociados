/** 
 * Controller class for products detail component
 * @author Leadclic Solutions
 * @version 1.0
 * @since 2019-09-04
 */
public with sharing class SchProductInfoController {
    
    private static final Decimal STANDARD_DURATION = 30.0;
    
    /**
     * retrieveCurrentProducts called on event init, retrieves 
     * @param  attendeeId Lead, Contact or PersonAccount Id
     * @return            returns current list of available products and current product relation if a lead id is passed
     */ 
    @AuraEnabled
    public static RetrieveCurrentProductsResponse retrieveCurrentProducts (Id attendeeId) {

        RetrieveCurrentProductsResponse response = new RetrieveCurrentProductsResponse();
		
        try {
            List<Id> lProductId = new List<Id>();
           
            // product pisklist population
            for(Product2 p : [SELECT Id, Name FROM Product2 WHERE isActive = true AND ExternalId__c != null ORDER BY Name ASC]) {

         PicklistEntry entry = new PicklistEntry(p.Id + '-' + p.Name, p.Name);
                response.lPicklistEntry.add(entry);

            }
		
            // product pill population
            if (attendeeId.getSobjectType().getDescribe().getName() == 'Lead') {
                response.isLead = true;
                for(LeadProduct__c p : [SELECT Id, ProductoPrincipal__c, Producto__r.Id, Producto__r.Name FROM LeadProduct__c WHERE Candidato__c = :attendeeId ]) {
                    PillWrapper wrapper = new PillWrapper(p.Producto__r.Id, p.Producto__r.Name,p.ProductoPrincipal__c); 
                    response.lProduct.add(wrapper);  
                    lProductId.add(p.Producto__c);
                    
                    
                }
            }

            // appointment duration
            response.duration = getDurationByProducts(lProductId);
            

           
        } catch (Exception e) {

            response.status = false;
            response.errorMsg = e.getMessage() + e.getStackTraceString();
            System.debug(response.errorMsg);
        }

        return response;
    }
    
    /**
     * getAppointmentDuration calculates appointment duration      
     * @param  lProductId lProductId description
     * @return            return description
     */ 
    @auraEnabled
    public static GetAppointmentDurationResponse getAppointmentDuration (List<String> lProductId) {

        GetAppointmentDurationResponse response = new GetAppointmentDurationResponse();

        try {
            String duration = getDurationByProducts(lProductId);
            response.duration = duration;
        
        
        } catch (Exception e) {
            response.status = false;
        }
        return response;
    }

    /**
     * getDurationByProducts returns amount of products duration
     * @param  lProduct product2 id list
     * @return          return formatted string duration
    */ 
    private static String getDurationByProducts(List<Id> lProductId) {

        String durationString;
        SearchSetup__c cs = SearchSetup__c.getInstance();
        

        if (cs.AppointmentDuration__c == null) cs.AppointmentDuration__C = STANDARD_DURATION;

        try {
        
            Map<Id, Product2> mProduct = new Map<Id, Product2>( [SELECT Id, DuracionEntrevista__c FROM Product2 WHERE Id IN :lProductId]) ;

            // product iteration (time calculation allows product duplication)
            Decimal duration = 0;  
            for(String idProduct : lProductId) {
                if(mProduct.containsKey(idProduct)) {
                    duration += mProduct.get(idProduct).DuracionEntrevista__c;
                }
            }

            duration = (duration != 0) ? duration : cs.AppointmentDuration__c;
            if(cs.MaxTime__c != null){
                duration = (duration <= cs.MaxTime__c) ? duration : cs.MaxTime__c;
            }
            durationString = DateTime.valueOf((Integer)duration*60000).formatGMT('HH:mm:ss');
        } catch (Exception e) {
            System.debug(e.getMessage() + e.getStackTraceString());
            durationString = DateTime.valueOf((Integer)cs.AppointmentDuration__c*60000).formatGMT('HH:mm:ss');
        }
        return durationString;

    }

    public class GetAppointmentDurationResponse {

        @auraEnabled public Boolean status = true;
        @auraEnabled public String errorMsg = '';
        @auraEnabled public String duration;

    }


    public class RetrieveCurrentProductsResponse {

        @auraEnabled public Boolean status = true;
        @auraEnabled public String errorMsg = '';
        @auraEnabled public List<PillWrapper> lProduct;
        @auraEnabled public List<PicklistEntry> lPicklistEntry;
        @auraEnabled public Boolean isLead = false;
        @auraEnabled public String duration;

        public RetrieveCurrentProductsResponse() {
            this.lProduct = new List<PillWrapper>();       
            this.lPicklistEntry = new List<PicklistEntry>();
        }
    }


    public class PillWrapper {
        @auraEnabled public String label;
        @auraEnabled public String name;
        @auraEnabled public Boolean principal;

        public PillWrapper ( String recordId, String name, Boolean principal) {
           
            if (principal){
                this.label = name + ' (Principal)'; 
                this.name = recordId + '-true';
            }
             else{
                this.label = name; 
                this.name = recordId +'-false';
            }
        }
    }

    public class PicklistEntry {
        @auraEnabled public String label;
        @auraEnabled public String value;

        public PicklistEntry (String recordId, String name) {
            this.label = name;
            this.value = recordId;
        }
    }


}