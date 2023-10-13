({
	callRedsys : function(cmp, event, helper) {
        //console.log('doInit');
        var action = cmp.get('c.creationParams');
        
        action.setParams({
            idOpp : cmp.get('v.oportunidadId'),
            Amount : cmp.get('v.amount'),
            FullName : cmp.get('v.Name'),
            description : cmp.get('v.description')           
        });      

        action.setCallback(this, function(response) { 
            var state = response.getState();  
            //console.log('Apex state : ' + response.getState());  
            if (cmp.isValid() && state === "SUCCESS") {
                console.log('Apex Response : ' + response.getReturnValue());
                
                cmp.set('v.params', response.getReturnValue());
                //console.log(cmp.get('v.params'));                
                try{
                    // Creating a form to send a POST to REDSYS
                    var form = document.createElement("form");
                    form.setAttribute("method", "POST");
                    form.setAttribute("action", cmp.get('v.params').URL);
                    form.setAttribute("Content-Type", "application/x-www-form-urlencoded");
                    
                    // Setting the attribute version
                    var hiddenFieldMT = document.createElement("input");
                    hiddenFieldMT.setAttribute("type", "hidden");
                    hiddenFieldMT.setAttribute("name", 'DS_SIGNATUREVERSION');
                    hiddenFieldMT.setAttribute("value", cmp.get('v.params').DS_SIGNATUREVERSION);
                    form.appendChild(hiddenFieldMT);
                    
                    // Setting the attribute param
                    var hiddenField = document.createElement("input");
                    hiddenField.setAttribute("type", "hidden");
                    hiddenField.setAttribute("name", "DS_MERCHANTPARAMETERS");
                    hiddenField.setAttribute("value", cmp.get('v.params').DS_MERCHANTPARAMETERS);
                    form.appendChild(hiddenField);
                    
                    // Setting the attribute signature
                    var hiddenField = document.createElement("input");
                    hiddenField.setAttribute("type", "hidden");
                    hiddenField.setAttribute("name", "DS_SIGNATURE");
                    hiddenField.setAttribute("value", cmp.get('v.params').DS_SIGNATURE);
                    form.appendChild(hiddenField);
                    document.body.appendChild(form);
                    console.log(form);
                    
                    //Escondemos spinner:
                    this.hideSpinner(cmp);
                    
                    //Realizamos la llamada enviando el formulario creado:
                    form.submit();
                }
                catch(e){
                    console.log('Simulated Form error! : ' + e.message);
                    //alert('Error : ' + e.message)
                }
            }
            else{
                console.log('Apex error : ' + response);
            }
        });
        $A.enqueueAction(action);               
	},
    /* Método que muestra la máscara de carga */
    showSpinner: function(component) {
        console.log('showSpinner');
        var sppiner = component.find("spinnerId");
        $A.util.removeClass(sppiner, "slds-hidden");
    },
    /* Método que oculta la máscara de carga */
    hideSpinner : function(component){
        console.log('hideSpinner');
        var sppiner = component.find("spinnerId");
        $A.util.addClass(sppiner, "slds-hidden");
    }
})