({
	doInit : function (cmp, event, helper) {
        var recordId = cmp.get("v.recordId");       
        $A.get("e.force:closeQuickAction").fire(); 
        window.open ('/apex/HCVPersonalData?id='+recordId , "_blank");
    }
})