/*
@author LeadClic Solutions S.L.
@date 03/10/2019
@description Trigger de Producto

FECHA                 AUTOR           ACCION
03/10/2019			LCS - RDM		 Creación. 
16/10/2019			LCS - JZD		 Evitar fallo en inserción de Productos si no existe un Pricebook activo
*/
public without sharing class TriggerProductHandler {    
    /**
     *  Método que se llama desde el trigger de Producto
     *  
     * @param  mapa de los valores insertados
     */
    public static void afterInsert(list<Product2> lNewProducts){

        List<Pricebook2> lP = [SELECT Id FROM Pricebook2 WHERE isStandard = true];
        if (!lP.isEmpty()){
            //Crearemos una linea de precio estandard por cada producto insertado en el entorno
            List<PricebookEntry> lPBE = new List<PricebookEntry>();
            //Recorremos los productos insertados para asignarles un registro de pricebookEntry
            for(Product2 p : lNewProducts){
                PricebookEntry pbe = new PricebookEntry(
                    isActive = true, 
                    Product2Id = p.Id, 
                    Pricebook2Id = lP[0].Id, 
                    UnitPrice = 0
                );                   
                
                lPBE.add(pbe);
            }
            
            //Si la lista de pricebookentry es distinta de vacía insertamos
            if(!lPBE.isEmpty()) insert lPBE;
        }
    }

}