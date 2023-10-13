({
	doInit : function (cmp, event, helper) {
        var recordId = cmp.get("v.recordId");       
        $A.get("e.force:closeQuickAction").fire(); 
        window.open ('/apex/GDPRPersonalData?id='+recordId , "_blank");
    }
})