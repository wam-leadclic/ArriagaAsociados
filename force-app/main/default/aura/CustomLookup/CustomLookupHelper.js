/**
@author Leadclic Solutions S.L.
@date 24/04/2019
@description    Helper class of CustomLookup component.

<pre>
FECHA                   AUTOR                   ACCION
24/04/2019              JZD                     Created
*/
({
	searchHelper : function(component,event,getInputkeyWord) {
        console.log('En searchHelper con key: '+getInputkeyWord);
	  // call the apex class method 
        var action = component.get("c.findCalendar");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord
            });
    	
      // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.lCalendar.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                console.log('sotreResponse: '+JSON.stringify(storeResponse));
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse.lCalendar);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},        
    isEmptyObject : function(component, event, helper, object){
        for(var key in object) {
            if(object.hasOwnProperty(key))
                return false;
        }
        return true;
        
    }
})