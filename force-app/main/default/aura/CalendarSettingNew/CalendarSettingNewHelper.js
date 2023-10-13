({

    // Apex caller
    requestServerAction : function(component, setup) {
        
        this.showSpinner(component);
        var action = component.get("c." + setup.method);
        action.setParams(setup.params);
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                setup.handler(component, response.getReturnValue(), this.showToast, setup.callbackParams);
            } else {
                this.showToast(component, {type:'error', message: 'Se ha producido un error'});
            }
            this.hideSpinner(component);
        });
        $A.enqueueAction(action);          
    }, 

    getInitDataCallback : function (component, response, showToast) {

        if(response.status) {
            component.set('v.relatedRecord', response.relatedRecord);
            component.set('v.mapping', response.mMapping );
        } else {
            showToast(component, {type:'error', message: 'Se ha producido un error'});    
        }

    }, 

    // Muestra mensajes al usuario
    showToast : function(component, setup) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent) {
            toastEvent.setParams({
                "title": setup.title,
                "message": setup.message, 
                "duration" : 2000, 
                "type" : setup.type
            });
            toastEvent.fire();    
        } else {
            alert(setup.message);
        }
    }, 

    showSpinner : function(component){
        component.set("v.toggleSpinner", true); 
    }, 
    
    hideSpinner : function(component){
        component.set("v.toggleSpinner", false); 
    },

})