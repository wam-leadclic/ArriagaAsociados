@isTest
private class SchMainResourcesControllerTest {
    
    public static testMethod void testGetResourcesList() {

        List<String> lSubtype = SchDataTest.getSubtypesFromType('Resource');
        String subtypeLabel = lSubtype.size() >= 1 ? lSubtype[0] : '';
        String subtypeValue = lSubtype.size() >= 1 ? lSubtype[1] : '';

        // Create JSON structure
        SchMainResourcesController.Info infoTest = new SchMainResourcesController.Info();
        infoTest.label = subtypeLabel;
        infoTest.value = subtypeValue;

        SchMainResourcesController.Subtype subtypeTest = new SchMainResourcesController.Subtype();
        subtypeTest.label = subtypeLabel;
        subtypeTest.value = subtypeValue;

        SchMainResourcesController.UserReq userReqTest = new SchMainResourcesController.UserReq();
        userReqTest.info = infoTest;
        userReqTest.lSubtype = new List<SchMainResourcesController.Subtype>{subtypeTest};

        SchMainResourcesController.GetResourcesRequest getUserRequestTest = new SchMainResourcesController.GetResourcesRequest();
        getUserRequestTest.User = userReqTest;
        getUserRequestTest.Resource = userReqTest;

        CalendarSetting__c cSet = SchDataTest.createCalendarSetting('Resource'); 
        insert cSet;

        Test.startTest();
        SchMainResourcesController.getResourcesList(getUserRequestTest);      
        Test.stopTest(); 
    }

    public static testMethod void getResourceEvents() {
    
        Lead l = SchDataTest.createLead();
        insert l;

        Lead l2 = SchDataTest.createLead();
        l2.Email = 'tes2t@test.com';
        insert l2;
        
        Event evt = SchDataTest.createEvent(l.Id, system.now(), system.now().addMinutes(30));
        insert evt;

        // DML operation Insert not allowed on Calendar, so we have to query it
        Calendar cal = [SELECT Id FROM Calendar WHERE UserId = :UserInfo.getUserId() limit 1];

        EventRelation evtRel = new EventRelation(EventId = evt.Id, RelationId = l2.Id);
        insert evtRel;

        Test.startTest();
        SchMainResourcesController.getResourceEvents(cal.Id);
        Test.stopTest();
    }  
}