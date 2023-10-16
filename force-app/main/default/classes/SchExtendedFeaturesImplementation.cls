/** 
 * Clic2Meet interface implementation for Arriaga 
 * @author Leadclic Solutions
 * @version 1.0
 * @since 2019-07-02
 */
public without sharing class SchExtendedFeaturesImplementation implements SchExtendedFeatures{
    
    private static final Decimal STANDARD_DAYS_FORWARD = 7.0;

    /**
     * setInitParams overrides main scheduler inicializaton params. Included url params.
     * @param  attendeeId attendee id (lead, contact or person account Id)
     * @return            return map with params values
     */ 
     public static Map<String, Object> setInitParams (Id attendeeId){

        SearchSetup__c cs = SearchSetup__c.getInstance();
        
        if (cs.SearchDaysForward__c == null) cs.SearchDaysForward__c = STANDARD_DAYS_FORWARD;

        Map<String, Object> mParams = new Map<String, Object>();
        Date toDate = System.today().addDays((Integer)cs.SearchDaysForward__c);
        mParams.put('searchToDate', toDate.year() + '-' + toDate.month() + '-' + toDate.day());
        mParams.put('searchByEvents', cs.SearchByEvents__c != null && cs.SearchByEvents__c);
        // If the current profile is Call Center
        List<PerfilesCallCenter__c> lPcs = PerfilesCallCenter__c.getall().values();
        for (PerfilesCallCenter__c pcs : lPcs){
            if (pcs.Id__c == UserInfo.getProfileId()){
                mParams.put('isSummaryResult', true);
                break;
            }
        }

        List<String> lCustomValidation = new List<String>();

        // Oficina__c filter
        lCustomValidation.add('filterValues.Oficina__c');
        
        // Product validation (list not empty)
        lCustomValidation.add('extraParams.products');

        mParams.put('customValidation', lCustomValidation);
         

        return mParams;
     }

    
    /**
     * setInitFilterParams description
     * @mParams  params params passed from front-ent
     * @return   return description
     */ 
    public Map<String, Object> setInitFilterParams ( Map<Object, Object> mParams) {

        Map<String, Object> mReturn = new Map<String, Object>();

        // itinerantes use case
        if(mParams != null && mParams.containsKey('Oficina__c') && (String)mParams.get('Oficina__c') != '') {

            String officeId = (String)mParams.get('Oficina__c');
           
            List<Account> lOffice = [SELECT Id, Name, ShippingCity FROM Account WHERE Id = :officeId];
            if(!lOffice.isEmpty()) {
                LookupSearchResult initValues = new LookupSearchResult(lOffice[0].Id, 'Account', 'standard:account', lOffice[0].Name, ('Account • ' +lOffice[0].ShippingCity));
                mReturn.put('Oficina__c', initValues);
            }

        // standard init searching current calendar setting 
        } else {
            
            // Calendar setting retrieval
            List<Calendar> lCal = [SELECT Id FROM Calendar WHERE UserId = :UserInfo.getUserId() LIMIT 1];
    
            if (!lCal.isEmpty()) {

                // Calendar  Settings retrieval
                List<CalendarSetting__c> lSetting = [SELECT Id, Oficina__c, Provincia__c 
                                                    FROM CalendarSetting__c 
                                                    WHERE CalendarId__c = :lCal[0].Id LIMIT 1];
                if(!lSetting.isEmpty()) {
                    
                    if(lSetting[0].Provincia__c != null) {
                        mReturn.put('Provincia__c', lSetting[0].Provincia__c);
                    }
                    
                    if(lSetting[0].Oficina__c != null) {
                        // Recuperación de la cuenta asociada
                        List<Account> lAcc = [SELECT Id, Name, ShippingCity FROM Account WHERE Id = :lSetting[0].Oficina__c LIMIT 1];
                        if(!lAcc.isEmpty()) {
                            LookupSearchResult initValues = new LookupSearchResult(lAcc[0].Id, 'Account', 'standard:account', lAcc[0].Name, ('Account • ' +lAcc[0].ShippingCity));
                            mReturn.put('Oficina__c', initValues);
                        }
                    }  
                }
            }
        }

        
        return mReturn;
    } 


    /**
     * Fill event info with custom data, overrides standard event creation
     * @param  evt           event being created
     * @param  mParams       event info for event creation
     * @param  mCalendarUser calendar settings ids
     * @return               created event
     */ 
    public Event setEventParams (Event evt, Map<Object, Object> mParams, Map<Id, Id> mCalendarUser){


        Map<Object, Object> assignedTo = (Map<Object, Object>) mParams.get('assignedTo');
        Map<Object, Object> lResource = (Map<Object, Object>) mParams.get('lResource');
        Map<Object, Object> filterValues = (Map<Object, Object>) mParams.get('filterValues');
        Map<Object, Object> extraParams = (Map<Object, Object>) mParams.get('extraParams');
        String productosInteres = '';
        if(extraParams != null) {
            try {
                List<Object> lProduct = (List<Object>) extraParams.get('products'); 
                Set<String> sId = new Set<String>();
                Set<String> sIdPrincipal = new Set<String>();
                
                for(Object productInfo : lProduct) {
                    Map<Object, Object> wrapper = (Map<Object, Object>) productInfo;
                    String principal = (String)wrapper.get('name');
                    List<String> lSplit = principal.split('-');
                    if (lSplit[1].contains('true')){
                        sIdPrincipal.add(lSplit[0]);
                        sId.add(lSplit[0]);
                    }
                    else{
                        sId.add(lSplit[0]);
                    }
                }

                List<String> lProductId = new List<String>();
                List<String> lProductInteres = new List<String>();
                for(Product2 p : [SELECT Id, ExternalId__c,Name FROM Product2 WHERE Id IN :sId]) {
                    lProductId.add(p.ExternalId__c);
                    if(sIdPrincipal.contains(p.Id)){
                        lProductInteres.add(p.Name);
                    }
                }
                String productListConcat = String.join(lProductId, ';');
                productosInteres = String.join(lProductInteres,',');
                evt.Productos__c = productListConcat;
            } catch (Exception e) {
                System.debug('Exception related product: ' + e.getMessage() + e.getStackTraceString());
            }
        }

        // Standard Fields
        evt.StartDatetime = (Datetime) mParams.get('startDate');
        evt.EndDateTime = (Datetime) mParams.get('endDate');
        evt.Subject = 'Cita'; // todo, set this field in custom setting
        evt.WhoId = (Id) mParams.get('attendeeId');
        if (productosInteres != '') evt.Description = (String) mParams.get('comments') + ' Es producto principal ' + productosInteres;
        else evt.Description = (String) mParams.get('comments');
		
        
        // Custom Fields
        List<Object> videoMeeting = (List<Object>) extraParams.get('typeSelected');
        
        String attendeeId = String.valueOf(evt.WhoId);
        evt.Estado__c = 'Pendiente';
        evt.TipoCita__c = (String) mParams.get('appointmentType');
        if(!Test.isRunningTest() && videoMeeting != null && videoMeeting.size() != 0) {
        	evt.Videollamada__c = videoMeeting[0] == 'Videollamada' ? true : false;
        }
        
        List<Object> notSendMail = (List<Object>) extraParams.get('sendMail');
		if(!Test.isRunningTest() && notSendMail != null && notSendMail.size() != 0 && notSendMail[0]=='No enviar correo al cliente') {
        	evt.No_enviar_email_Confirmacion_de_Cita__c = true;
        }
        
        List<EventRelation> lRelation = new List<EventRelation>();

        // Asesor
        if(assignedTo.containsKey('Asesor')) {
            Id calendarAsesorId = (Id) assignedTo.get('Asesor');    
            evt.OwnerId = mCalendarUser.get(calendarAsesorId);
        }
        
        // Administrativo
        if(assignedTo.containsKey('Administrativo')) {
            Id calendarAdmId = (Id) assignedTo.get('Administrativo');
            Id userAdmId = mCalendarUser.get(calendarAdmId);

            // if not Asesor role present
            if( evt.OwnerId == null) {
                evt.OwnerId = userAdmId;
            
            // relation creation if asesor role is present
            } else {
                EventRelation rel = new EventRelation();   
                rel.RelationId = userAdmId;
                lRelation.add(rel);
            }
        }

        // Event relations
        for(Object resourceId : lResource.values()) {
            EventRelation rel = new EventRelation();
            rel.RelationId = (Id)resourceId;
            rel.Status = 'Accepted';
            lRelation.add(rel);
        }
		
        // Office
       	
        if(filterValues.containsKey('Oficina__c') && filterValues.get('Oficina__c') != null && filterValues.get('Oficina__c') != ''){
            evt.Oficina__c = (Id) filterValues.get('Oficina__c');
        }
       
        insert evt;
                
        for(EventRelation rel : lRelation) {
            rel.EventId = evt.Id;
        }

        insert lRelation;
        return evt;
    }

}