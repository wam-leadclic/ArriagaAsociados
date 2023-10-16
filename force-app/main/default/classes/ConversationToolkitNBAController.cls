public with sharing class ConversationToolkitNBAController {
    
    @AuraEnabled
    public static List<Conversation_Helper__c> getConversationHelperList(){
        if(Schema.sObjectType.Conversation_Helper__c.fields.Value__c.isAccessible() && Schema.sObjectType.Conversation_Helper__c.fields.Recommended_Action__c.isAccessible() && Schema.sObjectType.Conversation_Helper__c.fields.Agent__c.isAccessible() && Schema.sObjectType.Conversation_Helper__c.fields.Customer__c.isAccessible() && Schema.sObjectType.Conversation_Helper__c.fields.Active__c.isAccessible()) {
            return [SELECT ID,Value__c, Recommended_Action__c, Agent__c, Customer__c, OM_Family__c FROM Conversation_Helper__c WHERE Active__c = true];        
        } else {
            return new List<Conversation_Helper__c>();
        }          
	}
}