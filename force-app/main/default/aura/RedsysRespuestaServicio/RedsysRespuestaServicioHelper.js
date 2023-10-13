({
	getJsonFromUrl : function () {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            result[item[0]] = decodeURIComponent(item[1]);
        });
        return result;
    },
    getMessageResponse : function(cmp){
        var Message;
        //console.log('Comienzo respuesta - Helper');
        //recogemos los parametros de la url
        //var respuesta = this.getJsonFromUrl().ResponseKO;
        var Ds_SignatureVersion = this.getJsonFromUrl().Ds_SignatureVersion;
        var Ds_MerchantParameters = this.getJsonFromUrl().Ds_MerchantParameters;
        var Ds_Signature = this.getJsonFromUrl().Ds_Signature;
        
        //console.log('datos -->' + Ds_SignatureVersion, Ds_Signature, Ds_MerchantParameters);
        
        try{
            var action = cmp.get('c.transformarResponse');
            
            action.setParams({
                Ds_SignatureVersion : Ds_SignatureVersion,
                Ds_MerchantParameters : Ds_MerchantParameters,
                Ds_Signature : Ds_Signature
            });
            
            action.setCallback(this, function(response) { 
                var state = response.getState();  
                //console.log('Apex state : ' + response.getState());  
                if (cmp.isValid() && state === "SUCCESS") {
                    console.log('Apex Response : ' + JSON.stringify(response.getReturnValue()));
 
                    cmp.set('v.params', response.getReturnValue());
                    try{
                        //Logica de respuesta
                        if(cmp.get('v.params.Firma') == 'OK')
                        {
                            //console.log('Firma OK');
                            /*if(cmp.get('v.params.Ds_Response') == 'OK')
                            {*/
                                //console.log('RESPUESTA OK');
                                cmp.set('v.PagoKo', false);
                                Message = cmp.get('v.params.BeginMessage');
                                var texto = cmp.get('v.params.TextoPago');
                                cmp.set('v.TextoContr', texto);
                                //console.log('text . ' + texto);
                                this.succesStyle(cmp); 
                            /*}
                            else
                            {
                                //console.log('RESPUESTA KO');
                                cmp.set('v.PagoKo', true);
                                Message = cmp.get('v.params.BeginMessage') + ' : ' + cmp.get('v.params.Ds_Response_Code') + ' - ' + cmp.get('v.params.Ds_Response_Meaning');
                                this.errorStyle(cmp);
                            }*/
                        }
                        else
                        {
                            //console.log('Firma KO');
                            cmp.set('v.PagoKo', true);
                            Message = cmp.get('v.params.BeginMessage');
                            this.errorStyle(cmp);                            
                        }
                        //console.log(Message, cmp.get('v.params.Ds_Response'),cmp.get('v.params.Firma'));
                        
                        cmp.set('v.MessageResponse', Message);
                    }
                    catch(e){
                        console.log('Simulated Form error! : ' + e.message);
                        //alert('Error : ' + e.message)
                    }
                }
            });
            $A.enqueueAction(action);
        }
        catch(Exception){ console.log(Exception)}
    },
    errorStyle: function(cmp) {
        var cmpTarget = cmp.find('message');
        $A.util.addClass(cmpTarget, 'error');
    },    
    succesStyle: function(cmp) {
        var cmpTarget = cmp.find('message');
        $A.util.addClass(cmpTarget, 'success');
    },
    getIdCaseCreated: function(cmp) {
        var action = cmp.get('c.CrearCaso');
        var Asunto = cmp.get('v.AsuntoTxt');
        var Descrp = cmp.get('v.DescTxt');
        var order = cmp.get('v.params.Ds_Order');
        
        //console.log(Asunto, Descrp, order);
        
        action.setParams({
            Asunto : Asunto,
            Descripcion : Descrp,
            ds_order : order
        });
        
        action.setCallback(this, function(response) { 
            var state = response.getState();  
            //console.log('Apex state : ' + response.getState());  
            if (cmp.isValid() && state === "SUCCESS") {
                //console.log('Apex Response : ' + response.getReturnValue());
                
                var url = response.getReturnValue();
                window.open(url, "_self");
            }
        });
        $A.enqueueAction(action);        
    },
    getURL: function(cmp, event) {
        //console.log('getURL');
        var action = cmp.get('c.obtenerURLdeContratcion');
        //console.log(event.getSource().get("v.name"));
        //console.log(event.getSource().get("v.title"));
        var nombreProd = event.getSource().get("v.name");
        var boton = event.getSource().get("v.title");
        console.log(nombreProd);
        action.setParams({
            nProducto : nombreProd,
            botonPulsado : boton
        });
        
        action.setCallback(this, function(response) { 
            var state = response.getState();  
            console.log('Apex state : ' + response.getState());  
            if (cmp.isValid() && state === "SUCCESS") {
                console.log('Apex Response : ' + response.getReturnValue());
                
                cmp.set('v.UrlRedireccion', response.getReturnValue());
                var url = cmp.get('v.UrlRedireccion.url');
                var target = cmp.get('v.UrlRedireccion.target');
                if(url.includes('ERROR')){
                    alert(url);
                }else{
                    window.open(url, target);
                }
            }
        });
        $A.enqueueAction(action);      
    }
})