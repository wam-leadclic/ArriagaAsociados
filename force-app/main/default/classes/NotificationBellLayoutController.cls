/*
@author LeadClic Solutions S.L.
@date 
@description Clase que contiene el código controlador del LWC NotificationBellLayout
<pre>
FECHA             AUTOR           ACCION
30/07/2021      LCS - SRG         Creación.  Obtenemos todas las notificaciones de los chatter y task que está vinculado un contacto
18/09/2023      LCS - MHG         Se corrige la query sobre LoginHistory porque ya supera los 50K registros en Partial y falla en los despliegues
*/
public with sharing class NotificationBellLayoutController {

    @AuraEnabled(cacheable=true)
    public static List<FieldWrapper> getNotifications(Boolean noTime, String recordId){
        List<FieldWrapper> fieldWrapper = new List<FieldWrapper>();
        try {
            User user=[SELECT Id, ContactId,AccountId,LastViewedDate, LastLoginDate FROM User WHERE Id = :UserInfo.getUserId() limit 1];
            List<LoginHistory> loginHistory =[SELECT UserId, LoginTime FROM LoginHistory WHERE UserId = :user.Id Order By LoginTime DESC limit 1];
            
            DateTime lastLogin= DateTime.now();
            lastlogin=Datetime.newInstanceGMT(lastLogin.yearGmt(),lastlogin.monthGmt(),lastlogin.dayGmt(),lastlogin.hourGmt(),lastlogin.minuteGmt()-4,0);
            if(loginHistory!=null && loginHistory.size()>0){
                if(loginHistory[0].LoginTime>=lastLogin && loginHistory.size()>1){
                    lastLogin=loginHistory[1].LoginTime;
                }
            } else{ noTime=false;}
            
            List<Task> listado = getTask(noTime,lastLogin,user.AccountId,recordId);
            List<FieldWrapper> lFieldWrapper = new List<FieldWrapper>();
            
            if(!listado.isEmpty()){
                
                List<String> ids=new List<String>();
                
                for(Task fi : listado){ids.add(fi.WhatId);}
                Map<Id,Contract> contracts = new Map<Id,Contract>([SELECT IdExpediente__c FROM Contract WHERE Id IN : ids]);
                for (Task variable : listado) {
                    Contract contract = contracts.get(variable.WhatId);
                    lFieldWrapper.add( new FieldWrapper(
                        contract!=null?System.Label.customChatterCardTitleBellExpediente+' '+String.ValueOf(contract.IdExpediente__c):'',
                                String.ValueOf(variable.Subject) + (String.isEmpty(variable.Description)?'':' ' + String.ValueOf(variable.Description)),
                                variable.LastModifiedDate,
                                ''
                            )); 
                }      
            }    
            if(recordId==''){
                List<Event> eventos = getEvent(noTime,lastLogin,user.AccountId);
                
                List<FieldWrapper> lFieldWrapper2 = new List<FieldWrapper>();
                if(!eventos.isEmpty()){
                   
                    for (Event variable : eventos) {
                        String message = System.Label.citaNotification;
                        lFieldWrapper2.add( new FieldWrapper(
                                    '',message.replace('%Subject%',variable.Subject).replace('%Time%',variable.StartDateTime.format('dd/MM/YYYY HH:mm')).replace('%oficina%',variable.DireccionOficinaCita__c),
                                    variable.LastModifiedDate,
                                    ''
                                )); 
                    }      
                } 
                fieldWrapper.addAll(lFieldWrapper2);
            }  
            fieldWrapper.addAll(lFieldWrapper);
            fieldWrapper.addAll(getChatter(user,lastLogin,noTime,recordId));
            fieldWrapper.sort();      
        } catch (Exception e) {
             System.debug(e);
            throw new AuraHandledException(e.getMessage());
        }
        return fieldWrapper;
    }

    private static List<FieldWrapper> getChatter(User user,DateTime lastLogin,Boolean noTime,String recordId){
        List<FieldWrapper> lFieldWrapper = new List<FieldWrapper>();
        List<ContractFeed> lContractFeed= new List<ContractFeed>();
        lContractFeed=getChatterDB(notime,lastLogin,recordId);
        
        if(!lContractFeed.isEmpty()){
            List<String> ids=new List<String>();
            
            for(ContractFeed fi : lContractFeed){ids.add(fi.ParentId);}
            Map<Id,Contract> contracts = new Map<Id,Contract>([SELECT IdExpediente__c FROM Contract WHERE Id IN : ids]);
            
            for(ContractFeed fi : lContractFeed){
                Contract contract = contracts.get(fi.ParentId);
                if(contract!=null){
                    if(fi.Type.equals('TextPost') || !String.isBlank(fi.Body)){
                        lFieldWrapper.add( new FieldWrapper(
                            System.Label.customChatterCardTitleBellExpediente+' '+String.ValueOf(contract.IdExpediente__c),
                            String.ValueOf(fi.Body),
                            fi.LastModifiedDate,
                            fi.ParentId
                        ));
            
                    } else if(fi.Type.equals('TrackedChange')){
                        for(FeedTrackedChange ftc : fi.FeedTrackedChanges ){
                            String oldValue=ftc.OldValue!=null?String.ValueOf(ftc.OldValue):'';
                            String newValue=ftc.NewValue!=null?String.ValueOf(ftc.NewValue):'';
                            lFieldWrapper.add( new FieldWrapper(
                                System.Label.customChatterCardTitleBellExpediente+' '+String.ValueOf(contract.IdExpediente__c),
                                String.ValueOf(label.customChatterCardMessage.replace('%$$1%',oldValue).replace('%$$2%',NewValue)),
                                fi.LastModifiedDate,
                                fi.ParentId
                            ));
                        }
                    }
                }
            }
        }
        return lFieldWrapper;
    }
    private static List<Task> getTask(Boolean noTime,DateTime lastLogin,String Id,String recordId)
    {
        if(Test.isRunningTest()){
            Id=NotificationBellLayoutControllerTest.account;
        }
        if(recordId!=''){
            return [SELECT Id,Subject,Description,LastModifiedDate,OwnerId,WhatId FROM Task WHERE AccountId=:Id and WhatId=:recordId ORDER BY LastModifiedDate DESC];
        }
        if(notime){
            return [SELECT Id,Subject,Description,LastModifiedDate,OwnerId,WhatId FROM Task WHERE AccountId=:Id and LastModifiedDate>=:lastLogin  ORDER BY LastModifiedDate DESC];
        }
        return [SELECT Id,Subject,Description,LastModifiedDate,OwnerId,WhatId FROM Task WHERE AccountId=:Id ORDER BY LastModifiedDate DESC];
    }
    private static List<Event> getEvent(Boolean noTime,DateTime lastLogin,String Id)
    {
        if(Test.isRunningTest()){
            Id=NotificationBellLayoutControllerTest.account;
        }
        if(notime){
            return [SELECT Id,Subject,StartDateTime,Oficina__c,LastModifiedDate,DireccionOficinaCita__c FROM Event WHERE AccountId=:Id and LastModifiedDate>=:lastLogin  ORDER BY LastModifiedDate DESC];
        }
        return [SELECT Id,Subject,StartDateTime,Oficina__c,LastModifiedDate,DireccionOficinaCita__c FROM Event WHERE AccountId=:Id ORDER BY LastModifiedDate DESC];
    }
    private static List<ContractFeed> getChatterDB(boolean noTime,DateTime lastLogin,String recordId){
        
        if(recordId!=''){            
            return [SELECT Id, LastModifiedDate, Type, ParentId, Body, 
                     (SELECT Id, FieldName, NewValue, OldValue FROM FeedTrackedChanges) 
                    FROM ContractFeed c WHERE ParentId=:recordId ORDER BY LastModifiedDate DESC];
        }
        if(noTime){
            return [SELECT Id, LastModifiedDate, Type, ParentId, Body, 
            (SELECT Id, FieldName, NewValue, OldValue FROM FeedTrackedChanges)
            FROM ContractFeed WHERE LastModifiedDate >=: lastLogin ];
        }
        
        return [SELECT Id, LastModifiedDate, Type, ParentId, Body, 
                 (SELECT Id, FieldName, NewValue, OldValue FROM FeedTrackedChanges) 
                FROM ContractFeed c ORDER BY LastModifiedDate DESC];
    }
    public class FieldWrapper implements Comparable  {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String body {get;set;}
        @AuraEnabled public DateTime datefeed {get;set;}
        @AuraEnabled public String ParentId {get;set;}
        
        public FieldWrapper(String id, String Body, DateTime datefeed,String ParentId) {
            this.id = id;
            this.body = body;
            this.datefeed = datefeed;
            this.ParentId=ParentId;
        }
        public Integer compareTo(Object compareTo) {
            // Cast argument to MemberWrapper
            FieldWrapper compareTomember = (FieldWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (datefeed > compareTomember.datefeed) {
                // Set return value to a positive value.
                returnValue = -1;
            } else if (datefeed < compareTomember.datefeed) {
                // Set return value to a negative value.
                returnValue = 1;
            }
            
            return returnValue;       
        }
    }
}