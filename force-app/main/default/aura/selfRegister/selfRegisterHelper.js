({
    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },
    
    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },
    
    handleSelfRegister: function (component, event, helpler) {
        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = component.find("firstname").get("v.value");
        var lastname = component.find("lastname").get("v.value");
        var email = component.find("email").get("v.value");
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
        var confirmPassword = component.find("confirmPassword").get("v.value");
        var action = component.get("c.selfRegister");
        var extraFields = JSON.stringify(component.get("v.extraFields"));   // somehow apex controllers refuse to deal with list of maps
        var startUrl = component.get("v.startUrl");
        var politicaPrivacidad = component.get("v.varPoliticaPrivacidad");    
        var recibirComunicaciones = component.get("v.varDeseaRecibirComunicaciones");    
        var movil = component.find("movil").get("v.value");
        
        startUrl = decodeURIComponent(startUrl);
        
          console.log('***movil*'+movil);
        action.setParams({firstname:firstname,lastname:lastname,email:email,
                password:password, confirmPassword:confirmPassword, accountId:accountId, regConfirmUrl:regConfirmUrl, extraFields:extraFields, 
                          startUrl:startUrl, includePassword:includePassword, politicaPrivacidad:politicaPrivacidad, movil:movil,
                          recibirComunicaciones: recibirComunicaciones});
          action.setCallback(this, function(a){
          var rtnValue = a.getReturnValue();
          console.log('***rtnValue*'+rtnValue);
          if (rtnValue !== null) {
             component.set("v.errorMessage",rtnValue);
             component.set("v.showError",true);
             
          }
          component.set("v.Spinner", false);
       });
    $A.enqueueAction(action);
    },
    
    getExtraFields : function (component, event, helpler) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, function(a){
        var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.extraFields',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    setBrandingCookie: function (component, event, helpler) {        
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    }    
})