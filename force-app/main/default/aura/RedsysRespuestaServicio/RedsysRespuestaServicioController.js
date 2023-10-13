({
	doInit : function(cmp, event, helper) {
		 helper.getMessageResponse(cmp);
	},
    CreateCase : function(cmp, event, helper) {
        helper.getIdCaseCreated(cmp);           
    },
    IrContratacion : function(cmp, event, helper) {
        helper.getURL(cmp, event);           
    }
})