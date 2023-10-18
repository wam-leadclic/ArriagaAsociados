/*
@author LeadClic Solutions S.L.
@date 17/10/2023
@description Clase GDDocumentSummaryController: controller para la clase GDDocumentSummary.
<pre>
FECHA             AUTOR           ACCION
17/10/2023		LCS - SDF	   	  Creación.
*/
public with sharing class GDDocumentSummaryController {
    
    public final static String INVALID_ID = 'Invalid or null contractId';
    public final static String INVALID_SOBJECT_TYPE = 'Id must be a valid Contract sObject Type';

    /**
     * @description getDocumentSumary Método anotado con @AuraEnabled y cacheable=true 
     * para obtener un resumen de documentos a partir de un contrato (expediente)
     * @param  expedientId id del expediente
     * @return             retorna Una respuesta que encapsula el resumen de documentos 
     * o un mensaje de error.
     */
    @AuraEnabled(cacheable=true)
    public static GDDocumentSummaryResponse getDocumentSumary(String expedientId){
        GDDocumentSummaryResponse response;
        try {
            if(String.isBlank(expedientId) || !(expedientId instanceOf Id)) {
                throw new GDDocumentSummaryException(INVALID_ID);
            } 
            else if (Id.valueOf(expedientId).getSobjectType() != Contract.getSObjectType()) {
                throw new GDDocumentSummaryException(INVALID_SOBJECT_TYPE);
            }
            response = new GDDocumentSummaryResponse(new GDDocumentSummary(expedientId));
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            response = new GDDocumentSummaryResponse(LightningDataResponse.ERROR, e.getMessage());
        }
        return response;
    }

    public class GDDocumentSummaryResponse extends LightningDataResponse {
        @AuraEnabled
        public GDDocumentSummary data;

        public GDDocumentSummaryResponse(GDDocumentSummary data) {
            super(LightningDataResponse.SUCCESS);
            this.data = data;
        }
        public GDDocumentSummaryResponse(String status, String message) {
            super(status,message);
        }
    }


    public class GDDocumentSummaryException extends Exception {}
}