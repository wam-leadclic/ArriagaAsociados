({
	doInit : function(component, event, helper) {        
        var navegacion;
        
        var action = component.get("c.getInformacionUsuario");
        action.setCallback(this, function(response){
        	var state = response.getState();
        	if(state === "SUCCESS"){
            	var usuario = response.getReturnValue();
				navegacion = $A.get("e.force:navigateToSObject");
				if(usuario.ContactId != null){                    
                    navegacion.setParams({                        
                    	"recordId": usuario.ContactId,
                    	"slideDevName": "detail"
					});
                    navegacion.fire();
                }
        	}
        });
        $A.enqueueAction(action);
	},
})