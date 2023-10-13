/**
@author Leadclic Solutions S.L.
@date 24/04/2019
@description    Controller class of CustomLookup component.

<pre>
FECHA                   AUTOR                   ACCION
24/04/2019              JZD                     Created
*/
({
    doInit : function (component, event, helper){
        var selectedRecord = component.get("v.selectedRecord");
        console.log('selectedRecord: '+selectedRecord);
        if ( selectedRecord != '{}' ){
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');
       
         
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
         
            var lookUpTarget = component.find("lookupField");
             $A.util.addClass(lookUpTarget, 'slds-hide');
             $A.util.removeClass(lookUpTarget, 'slds-show');  
        }
     },
    onfocus : function(component,event,helper){
         var forOpen = component.find("searchRes");
             $A.util.addClass(forOpen, 'slds-is-open');
             $A.util.removeClass(forOpen, 'slds-is-close');
         // Get Default 5 Records order by createdDate DESC  
          var getInputkeyWord = '';
          helper.searchHelper(component,event,getInputkeyWord);
     },
     keyPressController : function(component, event, helper) {
        // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
         if( getInputkeyWord.length > 0 ){
              var forOpen = component.find("searchRes");
                $A.util.addClass(forOpen, 'slds-is-open');
                $A.util.removeClass(forOpen, 'slds-is-close');
             helper.searchHelper(component,event,getInputkeyWord);
         }
         else{  
              component.set("v.listOfSearchRecords", null ); 
              var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
           }
          
     },
     
   // function for clear the Record Selaction 
     clear :function(component,event,heplper){
       
          var pillTarget = component.find("lookup-pill");
          var lookUpTarget = component.find("lookupField"); 
          
          $A.util.addClass(pillTarget, 'slds-hide');
          $A.util.removeClass(pillTarget, 'slds-show');       
         
          $A.util.addClass(lookUpTarget, 'slds-show');
          $A.util.removeClass(lookUpTarget, 'slds-hide');
       
         var lookUpSearch = component.find("lookup-search");
             $A.util.addClass(lookUpSearch, 'slds-show');
             $A.util.removeClass(lookUpSearch, 'slds-hide');
         
          component.set("v.SearchKeyWord",null);
          component.set("v.listOfSearchRecords", null );
          component.set("v.selectedRecord", {} );
          
     },
     
   // This function call when the end User Select any record from the result list.   
     handleComponentEvent : function(component, event, helper) {
     // get the selected sObject record from the COMPONETN event 	 
        var selectedObjectGetFromEvent = event.getParam("recordByEvent");
        
        component.set("v.selectedRecord" , selectedObjectGetFromEvent); 
        
         var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');
         
         var lookUpSearch = component.find("lookup-search");
             $A.util.addClass(lookUpSearch, 'slds-hide');
             $A.util.removeClass(lookUpSearch, 'slds-show');
         
         var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
         
         var lookUpTarget = component.find("lookupField");
             $A.util.addClass(lookUpTarget, 'slds-hide');
             $A.util.removeClass(lookUpTarget, 'slds-show');  
       
     },
   // automatically call when the component is done waiting for a response to a server request.  
     hideSpinner : function (component, event, helper) {
         var spinner = component.find('spinner');
         var evt = spinner.get("e.toggle");
         evt.setParams({ isVisible : false });
         evt.fire();    
     },
  // automatically call when the component is waiting for a response to a server request.
     showSpinner : function (component, event, helper) {
         var spinner = component.find('spinner');
         var evt = spinner.get("e.toggle");
         evt.setParams({ isVisible : true });
         evt.fire();    
     },
     
 })