@isTest
private class SchUsersControllerTest {
    
    public static testMethod void testGetUserMethods() {

        List<String> lSubtype = SchDataTest.getSubtypesFromType('User');
        String subtypeLabel = lSubtype.size() >= 1 ? lSubtype[0] : '';
        String subtypeValue = lSubtype.size() >= 1 ? lSubtype[1] : '';

        // Create JSON structure
        SchUsersController.Info infoTest = new SchUsersController.Info();
        infoTest.label = subtypeLabel;
        infoTest.value = subtypeValue;

        SchUsersController.Subtype subtypeTest = new SchUsersController.Subtype();
        subtypeTest.label = subtypeLabel;
        subtypeTest.value = subtypeValue;

        SchUsersController.UserReq userReqTest = new SchUsersController.UserReq();
        userReqTest.info = infoTest;
        userReqTest.lSubtype = new List<SchUsersController.Subtype>{subtypeTest};

        SchUsersController.GetUsersRequest getUserRequestTest = new SchUsersController.GetUsersRequest();
        getUserRequestTest.User = userReqTest;
        getUserRequestTest.Resource = userReqTest;

        CalendarSetting__c cSet = SchDataTest.createCalendarSetting('User'); 
        insert cSet;

        Test.startTest();
        SchUsersController.getUsersList(getUserRequestTest);

        SchUsersController.getUserEvents(UserInfo.getUserId());
        Test.stopTest();
    }   
}