/*
@author LeadClic Solutions S.L.
@date 14/03/2019
@description Clase que comprueba si se debe realizar un pago

<pre>
FECHA                 AUTOR           ACCION
15/03/2019			LCS - RDM		 Creación.
16/04/2019			LCS - RDM		 Modificación. Se crea método que comprueba que el segundo producto que se contrata no es el mismo que el primero para devolver
													la información de si el cliente paga o no el producto
09/05/2019			LCS - RDM		 Modificación. Se añade campo que indica si se tiene que validar si el producto es gratis o no
22/10/2019			LCS - RDM		 Modificación. Al buscar el pricebookEntry, buscamos el pricebook2 por nombre para obtener el de Catálogo General.

 
*/
global class Flow_ComprobacionPagos {
    /**
     *  Método invocable desde los flujos. Utilizamos una lista de una wrapper class de datos enviados desde el flujo. 
     *  
     * 
     * @param  IdCuenta	d de la cuenta para realizar comprobaciones  
     * @param  IdProducto	Id del producto asignado para el flujo activado.  
     * @return		Devuelve el Id de pricebook para asignarlo a la oportunidad y si debe o no realizar el pago
     * 
     */
    @InvocableMethod(label='Llamada flujo' description='Llamada desde el flujo')
    public static list<SendParameters> MetodoInvocable (list<GetParameters> WrapperParams){
        SendParameters response = new SendParameters();
        list<SendParameters> resultado = new list<SendParameters>();
                
        Id producto = (Id) WrapperParams[0].idProducto;
        Id cuenta = (Id) WrapperParams[0].idCuenta;
        Boolean prodGratis = WrapperParams[0].productoGratis;
        
        //Comprobamos si el flujo viene desde un producto que puede salir gratis, si es asi, comprobamos el cliente, sino saltamos estas validaciones
        if(prodGratis){
            //Comprobamos si la cuenta ya es cliente
            if(comprobarCuenta(cuenta)) response.pago = true;
            else{
                //La cuenta ya es cliente, por lo que comprobamos que el segundo Producto a contratar 
                //no coincide con el anterior producto contratado
                if(comprobarProducto(producto, cuenta))response.pago = true;
                else{
                    //si el contacto ya es cliente y esta contratando un producto diferente,
                    //no paga el siguiente producto
                    response.pago = false;            
                }
            }
        }
        
        //Obtenemos el PricebookEntry y el Pricebook que asignaremos a una oportunidad
        map<String, String> IdPrice = obtenerlistaPrecio(producto);
        //Recorremos el mapa para guardar en las variables el valor del pricebook y del pricebookEntry.
        //Solo vendrá un único valor
        for(String idPriceBookEntry : IdPrice.keySet()){
            response.idPriceBook = IdPrice.get(idPriceBookEntry);
            response.idPriceBookEntry = idPriceBookEntry;
        }
        
        resultado.add(response);
        return resultado;
    }
    /*
     * @descripción Wrapper class que recibe los datos de entrada del flujo
     */ 
    global class GetParameters {
        
        @InvocableVariable( label = 'productoGratis' description = 'productoGratis' required=true )
        global Boolean productoGratis;
        
        @InvocableVariable( label = 'idCuenta' description = 'idCuenta' required=true )
        global String idCuenta;  
        
        @InvocableVariable( label = 'idProducto' description = 'idProducto' required=true )
        global String idProducto;  
    }
    /*
     * @descripción Wrapper class que devuelve los datos al flujo
     */ 
    global class SendParameters {
        
        @InvocableVariable( label = 'idPriceBook' description = 'idPriceBook' required=true )
        global String idPriceBook;  
        
        @InvocableVariable( label = 'idPriceBookEntry' description = 'idPriceBookEntry' required=true )
        global String idPriceBookEntry;
        
        @InvocableVariable( label = 'pago' description = 'pago' required=true )
        global Boolean pago;  
        
    }
    /**
     * Método de recuperación del id de la lista de precios
     *  
     * 
     * @param  IdProducto	Id del producto asignado para el flujo activado.  
     * @return		mapa de ids donde indicamos el Id del pricebook2 y del PriceBookEntry
     * 
     */
    public static map<String,String> obtenerlistaPrecio (Id idProducto){
        map<String,String> priceBookAsociado = new map<String,String>();
        
        //Obtenmos los datos sobre el Pricebook2 y el pricebook entre y los añadimos a un mapa
        list<PriceBookEntry> lPrecios = [SELECT PriceBook2Id, isActive, PriceBook2.IsStandard FROM PriceBookEntry Where PriceBook2.Name =:system.Label.NombreCatalogGeneral AND Product2Id =:idProducto AND PriceBook2.IsStandard = false];        
        for(PriceBookEntry p : lPrecios){
           //En este mapa metemos como clave el Id del PricebookEntry y como valor el id del Pricebook2 relacionado con el pricebookEntry
           priceBookAsociado.put(p.id,p.PriceBook2Id);
        }  

        return priceBookAsociado;
    }
    /**
     * Método de comprobación de datos sobre el objeto Cuenta.
     *  
     * 
     * @param  IdCuenta	Id de la cuenta para realizar comprobaciones  
     * @return		devuelve true si la cuenta es ya cliente y false si no lo es
     * 
     */
    public static Boolean comprobarCuenta (Id idCuenta){
        Boolean resultado;
     	//Comprobamos si el estado de la cuenta es "Ya cliente". Si ya es cliente devolvemos false y si no lo es devolvemos true.
        Account ac = [SELECT EstadoCuenta__c FROM Account WHERE Id =:idCuenta];        
	        
        //Si el valor es true significa que debe pagar. Si es false significa que no debe pagar        
        if(ac.EstadoCuenta__c == Label.EstadoCuentaPotencial) resultado = true;
        else resultado = false;
        
        return resultado;
    }
    /**
     * Método de comprobación de datos sobre el objeto producto donde comprobaremos que no dejamos una segunda contratación del mismo producto a precio 0.
     *  
     * 
     * @param  IdProducto	Id del producto que utilizaremos para realizar comprobaciones  
     * @return		devuelve true si debe pagar, false si no
     * 
     */
    public static Boolean comprobarProducto (Id idProducto, Id idCuenta){
        Boolean resultado;
        //Cargo la config personalizada correspondientes al grupo de productos relacionados
        list<ProductosContrt__c> lConfigProd = ProductosContrt__c.getAll().values();
        
     	// Obtenemos los ids y la cuenta de las contratación online relacionada con la cuenta 
     	map<Id, Integer> Pagados = new map<Id, Integer>();
        map<Id, Integer> Gratis = new map<Id, Integer>();
        list<Id> lProductos = new list<Id>();
        
        for (ProductosContrt__c p : lConfigProd){
            if(!p.SiemprePago__c){
                Pagados.put(p.IdProduct__c, 0);	
                Gratis.put(p.IdProduct__c, 0);	
                lProductos.add(p.IdProduct__c);
            }
        }
        //Recuperamos los productos contratados por el contacto
        list<CommunityOpp__c> productoContr = [SELECT iDProducto__c, Gratis__c FROM CommunityOpp__c where Cuenta__c =:idCuenta AND ContrFinalizado__c = true AND iDProducto__c IN :lProductos];
        
        //Recorremos la lista y realizamos la contabilización en cada mapa en función de si el ha pagado o no
        for (CommunityOpp__c c : productoContr){
            if(c.Gratis__c){
                if(Gratis.containsKey(c.iDProducto__c)){
                    Gratis.put(c.iDProducto__c, Gratis.get(c.iDProducto__c) + 1);
                }
            }else{
                if(Pagados.containsKey(c.iDProducto__c)){
                    Pagados.put(c.iDProducto__c, Pagados.get(c.iDProducto__c) + 1);
                }
            }
        }
        
        //Recorremos los mapas para comprobar si debe pagar o no el nuevo producto
        Integer pago = 0;
        Integer grts = 0;
        //Obtenemos el valor de nuestro producto a contratar que ya haya sido pagado.
        if(Gratis.containsKey(idProducto)){
            grts = Gratis.get(idProducto);
        }
        //Recorremos el mapa de pagados para obtener los valores de aquellos que no sean nuestro producto para realizar el pago
        for(String key : Pagados.keySet()){
            if(Key != idProducto){
                pago += Pagados.get(Key);
            }
        }        
        
        //Si los pagados son mayores que gratis, no debe pagar el producto
        if(pago > grts) resultado = false;        
        else resultado = true;
        
        return resultado;
    }    
}