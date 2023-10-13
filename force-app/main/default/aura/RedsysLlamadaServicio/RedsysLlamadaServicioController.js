({
	doInit : function(cmp, event, helper) {
        var pagos = cmp.get('v.PagoCero');
        if(pagos){
            var url = cmp.get("v.Expediente");
            window.open(url, "_self");           
        }else{
            //console.log('doInit');
            helper.showSpinner(cmp);
            helper.callRedsys(cmp);
        }        
	}
})