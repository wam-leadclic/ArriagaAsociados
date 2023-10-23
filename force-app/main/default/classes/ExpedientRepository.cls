/*
@author LeadClic Solutions S.L.
@date 19/10/2023
@description Clase ExpedientRepository: define una interfaz util para obtener 
los registros de Contract
<pre>
FECHA             AUTOR           ACCION
19/10/2023		LCS - SDF	   	  Creación.
*/
public with sharing class ExpedientRepository {
    
    public static Contract getById(Id expedientId) {
        List<Contract> expedients = [
            SELECT 
                Id,DocumentosRedaccion__c,DocumentosRedaccionAportados__c,Producto__c,
                DocumentosAdicionales__c,DocumentosAdicionalesAportados__c 
            FROM Contract 
            WHERE Id =:expedientId
        ];
        if (!expedients.isEmpty()) {
            return expedients[0];
        }
        return null;
    }
}