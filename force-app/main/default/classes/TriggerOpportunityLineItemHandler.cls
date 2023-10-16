/*
@author LeadClic Solutions S.L.
@date 22/05/2019
@description Controlador del trigger para el objeto linea de oportunidad

<pre>
FECHA             AUTOR           ACCION
22/05/2019		LCS - RDM	   	  Creación. 
*/
public without sharing class TriggerOpportunityLineItemHandler {
    /**
     *  Método que se llama desde el trigger de Evento cuando se inserta una linea de oportunidad
     *  
     * @param  lista con las lineas de oportunidad que se han insertado
     */
    public static void afterInsert(list<OpportunityLineItem> lnewOli){
        list<Id> lOppAsociado = new list<Id>();
        list<Id> lProdAsociado = new list<Id>();
        map<Id,Id> mOppProducto = new map<Id,Id>();
        
        //Recorremos las OLI creadas y añadimos por cada oli su Opp y Prod al mapa
        for(OpportunityLineItem oli : lnewOli){
            if(!String.isBlank(oli.OpportunityId) && !String.isBlank(oli.Product2Id)){
                lOppAsociado.add(oli.OpportunityId);
                lProdAsociado.add(oli.Product2Id);
                mOppProducto.put(oli.OpportunityId, oli.Product2Id);
            }
        }
        //Mandamos la lista y el mapa al método encargado de llevar la documentación del producto a la oportunidad
        if(!lOppAsociado.isEmpty()) copiarDatosProducto(lOppAsociado, lProdAsociado, mOppProducto);
    }
    /**
     *  Método encargado de asociar los documentos del producto a la oportunidad
     *  
     * @param  lista de las oportunidades
     * @param  mapa con el Id de las oportunidades y su Producto
     */
    public static void copiarDatosProducto(list<Id> loppId, list<Id> lprodId, map<Id,Id> mOppProducto){
        list<Opportunity> lUpdateOpp = new list<Opportunity>();
        //Recuperamos los campos de documentos de la oportunidad
        list<Opportunity> lOpp = [SELECT Id, DocumentosCompletado__c, DocumentosContratacion__c 
                                    FROM Opportunity
                                    WHERE Id IN :loppId];
        map<Id, Product2> mProduct = new map<Id, Product2>([SELECT Id, DocumentosCompletado__c, DocumentosContratacion__c, ResponsableViabilidad__c 
                                            FROM Product2
                                            WHERE Id IN :lprodId]);
        //Recorremos las oportunidadesy les asignamos los campos
        for(Opportunity opp : lOpp){
            if(mOppProducto.containsKey(opp.Id)){
                if(mProduct.containsKey(mOppProducto.get(opp.Id))){
                    //Recuperamos el producto del mapa
                    Product2 producto = mProduct.get(mOppProducto.get(opp.Id));
                    //asignamos los valores de la documentación a la oportunidad
                    opp.DocumentosCompletado__c = producto.DocumentosCompletado__c;
                    opp.DocumentosContratacion__c = producto.DocumentosContratacion__c;
                    opp.ResponsableViabilidad__c = producto.ResponsableViabilidad__c;
                    //Añadimos la oportunidad para actualizar
                    lUpdateOpp.add(opp);
                }
            }
        }

        if(!lUpdateOpp.isEmpty()) update lUpdateOpp;
    }
}