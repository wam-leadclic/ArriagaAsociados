/*
@author LeadClic Solutions S.L.
@date 13/10/2023
@description Clase PortalHelpRepository: define una interfaz util para obtener 
los registros de Ayuda_Portal__c
<pre>
FECHA             AUTOR           ACCION
13/10/2023		LCS - SDF	   	  Creación.
*/
public with sharing class PortalHelpRepository {
    
    public static List<Ayuda_Portal__c> getHelpFromProductId(Id productId) {
        return [
            SELECT 
                Name,Producto__c,Documento__c,Descripcion__c,
                Link__c,Video__c,InlineHelp__c,Respuesta__c
            FROM Ayuda_Portal__c
            WHERE Producto__c =:productId
        ];
    }
}