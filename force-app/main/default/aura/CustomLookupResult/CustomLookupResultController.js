/**
@author Leadclic Solutions S.L.
@date 24/04/2019
@description    Controller class of CustomLookupResult component.

<pre>
FECHA                   AUTOR                   ACCION
24/04/2019              JZD                     Created
*/
({
    selectRecord : function(component, event, helper){      
     // get the selected record from list  
       var getSelectRecord = component.get("v.oRecord");
     // call the event   
       var compEvent = component.getEvent("oSelectedRecordEvent");
     // set the Selected sObject Record to the event attribute.  
          compEvent.setParams({"recordByEvent" : getSelectRecord });  
     // fire the event  
          compEvent.fire();
     },
 })