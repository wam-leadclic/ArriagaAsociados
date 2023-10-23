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
    public final static String EXPEDIENT_NOT_FOUND = 'Invalid expedient Id';
    public final static STRING FIELD_ADDING_DOCUMENTS = 'Aportados__c';

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

    @AuraEnabled
    public static GDDocumentSummaryResponse removeUploadedDocument(String recordId, String documentLine) {
        GDDocumentSummaryResponse response;
        GDDocumentSummary.GDDocumentLine line;
        try {
            //obtenemos el expediente para saber los valores de las lineas que ya tiene aportadas.
            Contract expedient = ExpedientRepository.getById(recordId);
            line = (GDDocumentSummary.GDDocumentLine) JSON.deserialize(documentLine, GDDocumentSummary.GDDocumentLine.class);
            if (expedient == null) {
                throw new GDDocumentSummaryException(EXPEDIENT_NOT_FOUND);
            }
            //obtenemos el campo relacionado que contiene las lineas aportadas.
            String uploadDocumentsField = line.relatedField.remove('__c') + FIELD_ADDING_DOCUMENTS;
            //obtenemos los valores de las lineas.
            String fieldValues = (String) expedient.get(uploadDocumentsField);
            List<String> values = String.isBlank(fieldValues) ? new List<String>() : fieldValues.split(Utils.SEMICOLON);
            //si no contiene el valor de la linea aportada, actualizamos el expediente en modo sistema.
            if (values.isEmpty() || !values.contains(line.value)) {
                //agregamos la linea aportada
                values.add(line.value);
                expedient.put(uploadDocumentsField, String.join(values, Utils.SEMICOLON));
                Database.update(expedient, true, AccessLevel.SYSTEM_MODE);
            }
            response = new GDDocumentSummaryResponse(null);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            response = new GDDocumentSummaryResponse(LightningDataResponse.ERROR, e.getMessage() + ' ' + e.getStackTraceString());
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