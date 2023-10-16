/*
@author LeadClic Solutions S.L.
@date 13/05/2019
@description Clase manejadora del Trigger de Pagos

FECHA                 AUTOR           ACCION
13/06/2019			LCS - RDM		 Creación.
19/06/2019			LCS - RDM		 Modificación. Actualizamos el Trigger para no llamar a la clase de Minerva. En vez de eso actualizamos
                                                el expediente si el pago ha sido confirmado
 
*/
public class TriggerPagoHandler {
	 /**
     *  Método que se llama desde el trigger de Pago
     *  
     * @param  mapa de los valores actuales
     * @param  lista con los Pagos que se han modificado
     */
    public static void afterUpdate(list<Pago__c> lNewPagos, map<Id, Pago__c> mOldPagos){
        //Lista de pagos realizados
        List<Pago__c> lPagosCompletados = new List<Pago__c>();
        //Actualizar Expedientes relacionados
        List<Contract> lActualizarExp = new List<Contract>();

        for(Pago__c pago : lNewPagos){
            Contract expediente = new Contract();
            if((mOldPagos.get(pago.Id).Estado__c != pago.Estado__c) && (pago.Estado__c == System.Label.EstadoPagoConfirmado)){
                lPagosCompletados.add(pago);
                //Actualizamos campos y los añadimos a la lista de expedientes para actualizar
                    expediente.Id = pago.Expediente__c;
                    expediente.PagoConfirmado__c = true;
                lActualizarExp.add(expediente);
            } 
        }  

        //Si la lista no esta vacía, actualizamos los expedientes
        if(!lActualizarExp.isEmpty()){
			update lActualizarExp;             
        }
    }
    
	 /**
     *  Método que se llama desde el trigger de Pago
     *  
     * @param  mapa de los valores insertados
     */
    public static void afterInsert(list<Pago__c> lNewPagos){
        //Lista de pagos realizados
        List<Pago__c> lPagosCompletados = new List<Pago__c>();
        //Actualizar Expedientes relacionados
        List<Contract> lActualizarExp = new List<Contract>();

        for(Pago__c pago : lNewPagos){            
            Contract expediente = new Contract();
            if(pago.Estado__c == System.Label.EstadoPagoConfirmado){
                lPagosCompletados.add(pago);
                //Actualizamos campos y los añadimos a la lista de expedientes para actualizar
                    expediente.Id = pago.Expediente__c;
                    expediente.PagoConfirmado__c = true;
                lActualizarExp.add(expediente);
            } 
        } 

        //Si la lista no esta vacía, actualizamos los expedientes
        if(!lActualizarExp.isEmpty()){
			update lActualizarExp;             
        }
    }
}