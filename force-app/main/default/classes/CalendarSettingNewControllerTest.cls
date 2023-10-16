@isTest
private class CalendarSettingNewControllerTest {
    @isTest static void testGetInitData(){

        Account acc = new Account(Name = 'testAcc', Phone = '6000000000');
        insert acc;

        Test.startTest();
        CalendarSettingNewController.GetInitDataResponse gir = CalendarSettingNewController.getInitData(acc.Id);
        Test.stopTest();
    }
}