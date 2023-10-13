/**
@author Leadclic Solutions S.L.
@date 24/04/2019
@description    Controller class of CalendarSettingNew component.

<pre>
FECHA                   AUTOR                   ACCION
24/04/2019              JZD/GQG                 Created
*/
({
    
    doInit: function(component, event, helper) {
        
        var setup = {
            method : 'getInitData', 
            params : {
               recordId : component.get('v.recordId')
                    },
            handler : helper.getInitDataCallback
                }
        helper.requestServerAction(component, setup); 
    },


    handleOnSubmit : function (component, event, helper) {

        event.preventDefault();  

        var fields = event.getParam('fields');
        
        // retieve calendar field
        var calendarId = null;
        if(component.get("v.calendarSelected").calendarId != undefined){
        	calendarId = component.get("v.calendarSelected").calendarId;
            fields['CalendarId__c'] = calendarId; 
        }
        
        // extra mapping
        var mapping = component.get('v.mapping');
        var relatedRecord = component.get('v.relatedRecord');
        var recordId = component.get('v.recordId');
        if(recordId && mapping && relatedRecord) {
           
            for(var key of Object.keys(mapping)) {
                fields[key] = relatedRecord[mapping[key]];
            }
        }
        component.find('newForm').submit(fields);
    },

    handleError : function(component, event, helper){
        
        var errorMsg = event.getParam('message');
        var errorDetail = event.getParam('detail');
        
        helper.showToast(component, {type:'error', message: errorMsg + errorDetail});
        var payload = event.getParams();
    }, 

    handleSuccess : function(component, event, helper) {
        helper.showToast(component, {type:'success', message: 'Se ha creado la configuración de calendario'});
        
        var recordId = component.get('v.recordId');

        // new override action
        if(!recordId) {
            
            var response = event.getParam('response');
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                recordId: response.id
            });
            navEvt.fire();    
        // quick action 
        } else {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();       
        }
    },
    
    cancelDialog : function(component, event, helper) {    
        
        var recordId = component.get('v.recordId');

        // new override action
        if(!recordId) {
            
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": "CalendarSetting__c"
            });
            homeEvent.fire();
        // quick action 
        } else {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();       
        }    
          
    }

   
})