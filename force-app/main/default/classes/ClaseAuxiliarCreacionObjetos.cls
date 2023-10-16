/*
@author LeadClic Solutions S.L.
@date 14/03/2019
@description Clase Auxiliar que crea los objetos correspondientes al expediente

<pre>
FECHA                 AUTOR           ACCION
14/03/2019			LCS - RDM		 Creación.
08/04/2019			LCS - RDM		 Modificación. Cambiamos los ficheros para que esten asociados al expediente y no a la contratación 
08/05/2019			LCS - RDM		 Modificación. Actualizamos el estado de la oportunidad una vez haya sido creado el expediente
17/06/2019          LCS - RMG        Modificación. Al crear la oportunidad se asigna la hoja de encargo por defecto que se tenga en el producto
26/08/2019          LCS - RDM        Modificación. Añadir el campo de importe total a la oportunidad


*/
global without sharing class ClaseAuxiliarCreacionObjetos {
    /**
     * Método invocable desde los flujos. Utilizamos una lista de una wrapper class de datos enviados desde el flujo.
     * 
     * 
     * @param  IdCuenta	Id de la cuenta a la cual asignaremos una oportunidad y una contratación online
     * @param  IdPriceBook	Id del pricebook del producto el cual asignaremos a la oportunidad 
     * @param  IdProduct	Id del producto el cual asignaremos a la oportunidad 
     * @param  Opción	Opción desde donde se indica si creamos una contratación online o un expediente
     * @param  Flujo	Flujo desde donde llamamos al método. Sirve para nombrar la oportunidad
     * 
     * @return		Devolvemos el id del objeto creado en el métod al que llamamos
     * 
     */
    @InvocableMethod(label='Llamada flujo' description='Llamada desde el flujo con el id y lo que se quiere crear')
    public static list<ReturnParameters> MetodoInvocable (list<GetParameters> wrapperParams){
        list<ReturnParameters> resultado = new list<ReturnParameters>();
        ReturnParameters res = new ReturnParameters();
        
        Id objeto = (Id) wrapperParams[0].idCuenta;
        Id priceBk = (Id) wrapperParams[0].idPriceBook;
        Id priceBkEntry = (Id) wrapperParams[0].idPriceBookEntry;
        Id prodct = (Id) wrapperParams[0].idProduct;
        Id idOpp = (Id) wrapperParams[0].idOportunidad;
        Id idContrt = (Id) wrapperParams[0].idContratOnline;
        String opcion = wrapperParams[0].opcion;
        
        switch on opcion {
            when 'Contratación Online' {
                res.Id = creacionContratacionOnline(objeto, wrapperParams[0].flujo, priceBk, prodct, priceBkEntry);
                res.URL = '';
                resultado.add(res);
            }
            when 'Expediente' {
                //Al venir desde el flujo crearemos un pago a 0 automáticamente, ya que el pago real lo creará la clase de Redsys. por eso también ponemos un precio 0
                list<String> valores = new list<String>(creacionExpediente(objeto, true, priceBk, 0, idOpp));
                    res.id = valores.get(0);
                    res.url = valores.get(1);
                resultado.add(res);
            }
            when 'Buscar Oportunidad' {
                //Al venir desde el flujo crearemos un pago a 0 automáticamente, ya que el pago real lo creará la clase de Redsys. por eso también ponemos un precio 0
                res.id = buscarOportunidad(idContrt);
                res.url = '';
                resultado.add(res);
            }
        }
        
        return resultado;
    }
    /**
@descripción Wrapper class que recibe los datos de entrada para la creación de objetos
*/
    global class GetParameters {
        
        @InvocableVariable( label = 'IdCuenta' description = 'IdCuenta' required=true )
        global String idCuenta; 
        
        @InvocableVariable( label = 'IdPriceBook' description = 'IdPriceBook' required=true )
        global String idPriceBook; 
        
        @InvocableVariable( label = 'IdPriceBookEntry' description = 'IdPriceBookEntry' required=false )
        global String idPriceBookEntry;
        
        @InvocableVariable( label = 'IdProduct' description = 'IdProduct' required=false )
        global String idProduct; 
        
        @InvocableVariable( label = 'IdOportunidad' description = 'IdOportunidad' required=false )
        global String idOportunidad; 
        
        @InvocableVariable( label = 'IdContratOnline' description = 'IdContratOnline' required=false )
        global String idContratOnline;
        
        @InvocableVariable( label = 'Opción' description = 'Opción indicada en el flujo para saber si se crea la contratación online o la oportunidad y el expediente' required=true )
        global String opcion;  
        
        @InvocableVariable( label = 'Flujo' description = 'Flujo por el que viene la llamada a la creación de la oportunidad' required=false )
        global String flujo; 
    }
    /**
@descripción Wrapper class que recibe los datos de entrada para la creación de objetos
*/
    global class ReturnParameters {
        
        @InvocableVariable( label = 'Id' description = 'Id')
        global String id; 
        
        @InvocableVariable( label = 'URL' description = 'URL' )
        global String url;
    }
   /**
     * @ Descripción: Método donde creamos la Oportunidad y la contratación online.
     *  
     * 
     * @param  idClienteAsociado	Id de la cuenta a la cual asignaremos la oportunidad y la contratación online
     * @param  NameFlow	Nombre que asignaremos a la oportunidad
     * @param  PriceBook	Id del pricebook del producto el cual asignaremos a la oportunidad 
     * @param  Product	Id del producto el cual asignaremos a la oportunidad   
     * @param  PriceBookEntry	Id de la lista de producto que se añadira al alinea de oportunidad  
     * @return		Devolvemos el id de la contratación creada
     * 
     */
    public static Id creacionContratacionOnline (Id idClienteAsociado, String nameFlow, Id priceBook, Id product, Id priceBookEntry){
        
		PriceBookEntry pb = [SELECT UnitPrice, Product2.HojaEncargoPorDefecto__c FROM PriceBookEntry Where Id =:priceBookEntry]; 
        //Recuperamos el id y el id de personCOntact que utilizaremos para crear el rol de opp
        Account cuentaContrato = [SELECT Id, personContactId FROM Account WHERE Id =: idClienteAsociado];
        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults();
        
        Opportunity opp = new Opportunity();
            opp.AccountId = cuentaContrato.Id;
            opp.StageName = configDatosflujo.EtapaOEtapaOportuniportunidadContrOnline__c;      
            opp.Name = nameFlow;
            opp.Pricebook2Id = priceBook;
            Opp.CloseDate = date.valueOf(system.now());
            Opp.HojaEncargo__c = pb.Product2.HojaEncargoPorDefecto__c;
        	opp.CreadoComunidad__c = true;
        insert opp;
        
        CommunityOpp__c contratOnline = new CommunityOpp__c();
            contratOnline.Cuenta__c = cuentaContrato.Id;
            contratOnline.Oportunidad__c = opp.Id;  
            contratOnline.IdOportunidad__c = opp.Id; 
        	contratOnline.CantidadPagar__C = pb.UnitPrice;
        	contratOnline.IDProducto__c = product;
        insert contratOnline;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        	oli.OpportunityId = opp.id;
        	oli.Product2Id = product;
        	oli.Quantity = 1;
        	oli.PricebookEntryId = priceBookEntry;
        	oli.TotalPrice = pb.UnitPrice;
        insert oli;
        
        	opp.PrecioTotal__c = oli.TotalPrice;
        update opp;
        
        //Función de contacto
        OpportunityContactRole rolContacto = new OpportunityContactRole();
            rolContacto.OpportunityId = opp.id;
            rolContacto.ContactId = cuentaContrato.personContactId;
            rolContacto.Role = configDatosflujo.RolFuncionContacto__c;
            rolContacto.IsPrimary = true;
       insert rolContacto;
        
        return contratOnline.Id;
    }
   /**
     * @ Descripción: Método donde creamos el expediente y el método de pago
     * Uno de los usos es cuando el Pago es 0 y venimos del flujo
     *  
     * 
     * @param  idClienteAsociado	Id de la cuenta a la cual asignaremos la oportunidad y la contratación online
     * @param  NameFlow	Nombre que asignaremos a la oportunidad
     * @param  PriceBook	Id del pricebook del producto el cual asignaremos a la oportunidad 
     * @param  Product	Id del producto el cual asignaremos a la oportunidad   
     * @param  PriceBookEntry	Id de la lista de producto que se añadira al alinea de oportunidad  
     * @return		Devolvemos una lista cuyo primer valor es el id del pago y el segundo es la url del expediente creado
     * 
     */
    public static list<String> creacionExpediente (Id idClienteAsociado, Boolean noPago, Id priceBook, Integer precioExpediente, Id idOpportunity){
        
        //Opportunity opp = [SELECT NumeroExpediente__c, Id FROM Opportunity Where Id =:IdOpportunity];
        CommunityOpp__c contrat = [SELECT IdOportunidad__c, /*Oportunidad__r.NumeroExpediente__c,*/ Id FROM CommunityOpp__c Where IdOportunidad__c =:idOpportunity];
        list<String> resultado = new list<String>();
        DatosFlujo__c configDatosflujo = DatosFlujo__c.getOrgDefaults();
            
        //Buscamos la Oli correspondiente para obtener el Producto y mandarlo al expediente
        list<OpportunityLineItem> lOli = [SELECT Id, OpportunityId, Product2Id
                                          FROM OpportunityLineItem
                                          WHERE OpportunityId = :idOpportunity];
        
        //Cramos los expedientes asociandolo a la oportunidad y al cliente
        Contract expediente = new Contract();
       		expediente.AccountId = idClienteAsociado;
        	expediente.Pricebook2Id = priceBook;
        	//expediente.IdExpediente__c = contrat.Oportunidad__r.NumeroExpediente__c;
        	expediente.Oportunidad__c = contrat.IdOportunidad__c;
        	expediente.Producto__c = lOli.get(0).Product2Id;
        insert expediente;
        
        //Creamos una linea de pago al expediente
        Pago__c pago = new Pago__c();
        	pago.Expediente__c = expediente.Id;
        if(noPago){
            pago.PrecioTotal__c = 0;
            pago.Estado__c = Label.EstadoPagoCero;
            pago.Tipo__c = Label.TipoPagoCero;
        }
        else{
            pago.PrecioTotal__c = precioExpediente;
            pago.Estado__c = Label.EstadoPagoNoCero;
        }
        insert pago;
        
        //Actualizamos la contración Online para indicar que el producto ha sido gratis y finalizado
        CommunityOpp__c c = new CommunityOpp__c();
            c.id = contrat.id;
        	c.Gratis__c = true;
        	c.ContrFinalizado__c = true;
        update c;
        
        //Pasamos los documentos adjuntos de la contratación online al expediente creado
        list<ContentDocumentLink> ldocins = new list<ContentDocumentLink>();
        list<ContentDocumentLink> ldocdel = new list<ContentDocumentLink>();
        list<ContentDocumentLink> lcd = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId =:Contrat.id];
        for(ContentDocumentLink cd : lcd){
            ContentDocumentLink insertCd = cd.clone();
                insertCd.LinkedEntityId = expediente.id;
                insertCd.ShareType = cd.ShareType;
            ldocins.add(insertCd);
            ldocdel.add(cd);
        }
        if(!ldocins.isEmpty() && ldocins != null) insert ldocins;
        if(!ldocdel.isEmpty() && ldocdel != null) delete ldocdel;

        //Actualizamos la oportunidad para indicarle el estado Cerrada ganada    
        Opportunity opp = new Opportunity();
            opp.Id = contrat.IdOportunidad__c;
            opp.StageName = configDatosflujo.EtapaFinalOportunidadContrOnline__c;
        update opp;
        
        
        String url = URL.getSalesforceBaseUrl().toExternalForm()+'/'+expediente.id;
		
        resultado.add(pago.id);
        resultado.add(url);
        
        return resultado;
    }
   /**
     * @ Descripción: Método donde Realizamos la busqueda del ID de la oportunidad dentro del objeto contratación online
     *  
     * 
     * @param  IdContratOnline	Id de la contratación online recién creada
     * @return		Devolvemos el id de la oportunidad
     * 
     */
    public static Id buscarOportunidad (Id IdContratOnline){
        
        CommunityOpp__c contratOnline = [SELECT IdOportunidad__c FROM CommunityOpp__c Where Id =:IdContratOnline];		
        
        return contratOnline.IdOportunidad__c;
    }
}