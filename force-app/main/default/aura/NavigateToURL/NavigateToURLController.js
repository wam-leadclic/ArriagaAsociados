/*
 FECHA		AUTOR		Descripción
03/04/2019	LCS-RMG		Creación. Componente para que redirija a la URL indicada como atributo. 
									Se crea para usar el componente en los flujos y así porder redirigir a otra página.
*/
({
	doInit : function(component, event, helper) {    
		var url = component.get("v.URL");
        var isredirect = component.get("v.isredirect");
		//console.log('url**',url);
		var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	      "url": url,
	      "isredirect":isredirect
	    });
	    urlEvent.fire();
	},
})