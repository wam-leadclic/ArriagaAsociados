/**
 * @author LeadClic Solutions S.L.
 * @date 04/10/2023
 * @description Clase auxiliar para almacenar los campos del big object 
 * <pre>
 * FECHA                 AUTOR           ACCION
 * 04/10/2023		     LCS - NA        Creación.
 * 20/11/2023		     LCS - NA        Modificación. Add CreatedDate field to the wrapper.
 */

public with sharing class ArchivedEmail {
    
    @AuraEnabled public String AccountOrLeadId;
    @AuraEnabled public String OriginEmailId;
    @AuraEnabled public String ContactId;
    @AuraEnabled public String CaseId;
    @AuraEnabled public String ToAddress; 
    @AuraEnabled public String FromAddress;
    @AuraEnabled public Datetime MessageDate;
    @AuraEnabled public String Subject;
    @AuraEnabled public String HTMLBody;
    @AuraEnabled public String ToAddressCC;
    @AuraEnabled public String ToAddressBCC;
    @AuraEnabled public Decimal IsOpened;
    @AuraEnabled public Datetime CreatedDate;

}