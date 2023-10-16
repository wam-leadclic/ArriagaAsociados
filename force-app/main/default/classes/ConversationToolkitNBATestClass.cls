@isTest
private class ConversationToolkitNBATestClass {    
   private static final String USER_NAME = 'puser' + UserInfo.getUserId()  + '@test' + String.valueOf(Date.today())+'.com';
    
    @TestSetup
    static void makeData(){
        Conversation_Helper__c chInput = new Conversation_Helper__c();
        chInput.Value__c = 'TestValue';
        chInput.Active__c = true;
        insert chInput;
        
        User newUser = new User();
        newUser.FirstName = 'Prueba';
        newUser.LastName = 'Usuario';
        newUser.Email = 'puser@test.com';
        newUser.Username = USER_NAME;
        newUser.Alias = 'pUser';
        newUser.TimeZoneSidKey = 'America/Los_Angeles';
        newUser.LocaleSidKey = 'en_US';
        newUser.LanguageLocaleKey = 'en_US';
        newUser.EmailEncodingKey ='UTF-8';
        newUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CALL CENTER Agente' LIMIT 1].Id;
        insert newUser;  
    }
    
    @isTest
    static void checkConversationTest() {       
        
        User tUser = [SELECT Id FROM User WHERE UserName =: USER_NAME LIMIT 1];
       	List<Conversation_Helper__c> conversationList;
        Test.startTest();
        System.runAs(tUser) {
        	conversationList = ConversationToolkitNBAController.getConversationHelperList();
        }
        Test.stopTest();
        System.assertNotEquals(0, conversationList.size());
    }
}