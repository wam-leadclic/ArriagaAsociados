/*
@author LeadClic Solutions S.L.
@date 13/10/2023
@description Clase GDDocumentSummary para la gestión de documentos requeridos y adicionales en expedientes, 
con flexibilidad mediante handlers y manejo de picklists, proporcionando acceso a etiquetas y ayuda para documentos.
<pre>
FECHA             AUTOR           ACCION
13/10/2023		LCS - SDF	   	  Creación.
*/
public inherited sharing class GDDocumentSummary {
    
    public static final String UPLOADED = 'Aportado';
    public static final String PENDING = 'Pendiente';

    private List<DocumentLinesHandler> documentLinesHandler { 
        get {
            if (documentLinesHandler == null) {
                documentLinesHandler = new List<DocumentLinesHandler> {
                    new RedactionLinesHandlerImp(),
                    new AditionalLinesHandlerImp()
                };
            }
            return documentLinesHandler; 
        } private set;  
    }
    private Id expedientId {get;set;}

    @AuraEnabled
    public List<GDDocumentLine> documentLines {
        get {
            if (documentLines == null) {
                documentLines = new List<GDDocumentLine>();
            }
            return documentLines;
        } private set;
    }
    /**
     * @description Map con los valores de los labels para cada documento
     */
    transient public Map<String,String> documentLabels {
        get {
            if(documentLabels == null) {
                documentLabels = new Map<String,String>();
                for (DocumentLinesHandler handler : this.documentLinesHandler) {
                    documentLabels.putAll(Utils.getPicklistLabels(handler.getRelatedField()));
                }
            } 
            return documentLabels;
        } private set;
        
    }
    /**
     * @description Set con los valores de los documentos aportados
     */
    @AuraEnabled
    public Set<String> uploadedRedactionLines {
        get {
            if (uploadedRedactionLines == null) {
                uploadedRedactionLines = Utils.getMultipicklistValuesAsSet(this.expedient,Contract.DocumentosRedaccionAportados__c);
            }
            return uploadedRedactionLines;
        } private set;
    }
    /**
     * @description Set con los valores de los documentos que son requeridos
     */
    @AuraEnabled
    public Set<String> redactionLines {
        get {
            if (redactionLines == null) {
                redactionLines = Utils.getMultipicklistValuesAsSet(this.expedient,Contract.DocumentosRedaccion__c);
            }
            return redactionLines;
        }
        set;
    }
    /**
     * @description Set con los valores de los documentos aportados
     */
    @AuraEnabled
    public Set<String> aditionalLines {
        get {
            if (aditionalLines == null) {
                aditionalLines = Utils.getMultipicklistValuesAsSet(this.expedient,Contract.DocumentosAdicionales__c);
            }
            return aditionalLines;
        } private set;
    }
    /**
     * @description Set con los valores de los documentos que son requeridos
     */
    @AuraEnabled
    public Set<String> uploadedAditionalLines {
        get {
            if (uploadedAditionalLines == null) {
                uploadedAditionalLines = Utils.getMultipicklistValuesAsSet(this.expedient,Contract.DocumentosAdicionalesAportados__c);
            }
            return uploadedAditionalLines;
        }
        set;
    }

    /**
     * @description Map con los valores de ayuda para cada documento.
     */
    transient public Map<String,Ayuda_Portal__c> helpPortalMap {
        get {
            if (helpPortalMap == null) {
                helpPortalMap = getPortalHelp();

            }
            return helpPortalMap;
        } private set;
    }

    public Contract expedient {
        get{
            if(expedient == null) {
                expedient = ExpedientRepository.getById(this.expedientId);
            }
            return expedient;
        }
        set;
    }

    public GDDocumentSummary(Id expedientId) {
        this.expedientId = expedientId;
        if(this.expedient != null) {
            for (DocumentLinesHandler handler : this.documentLinesHandler) {
                handler.setDocumentLines(this);
            }
        }
    }
    public GDDocumentSummary(Contract expedient) {
        this.expedient = expedient;
    }

    /**
     * @description Metodo utilitario para obtener los valores de ayuda
     * para el producto utilizado en el expediente
     * @return   retorna un map con los valores de Ayuda Portal utilizando
     * como key el valor del documento y el value un sObject de Ayuda_Portal__c
     */
    private Map<String,Ayuda_Portal__c> getPortalHelp(){
        Map<String,Ayuda_Portal__c> helpPortalMap = new Map<String,Ayuda_Portal__c>();
        for (Ayuda_Portal__c helpPortal : PortalHelpRepository.getHelpFromProductId(expedient.Producto__c)) {
            helpPortalMap.put(helpPortal.Documento__c, helpPortal);
        }
        return helpPortalMap;
    }

    public class GDDocumentLine {
        @AuraEnabled
        public String relatedField;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String helpText;
        @AuraEnabled
        public Boolean visible;
        @AuraEnabled
        public String status;

        public GDDocumentLine(Schema.SObjectField field) {
            this.relatedField = field.getDescribe().getName();
        }
    }

    public interface DocumentLinesHandler {
        /**
         * @description setea las lineas de documentos adicionales
         * para el expediente actual
         */
        void setDocumentLines(GDDocumentSummary summary);
        /**
         * @description retorna el campo que contiene las lineas
         * de documentos pendientes de aportar
         */
        Schema.SObjectField getRelatedField();
    }

    public class RedactionLinesHandlerImp implements DocumentLinesHandler{
        
        public void setDocumentLines(GDDocumentSummary summary) {
            for (String value : summary.redactionLines) {
                GDDocumentLine line = new GDDocumentLine(Contract.DocumentosRedaccion__c);
                line.helpText = summary.helpPortalMap.get(value)?.Descripcion__c;
                line.title = summary.documentLabels.get(value);
                line.status = summary.uploadedRedactionLines.contains(value) ? GDDocumentSummary.UPLOADED : GDDocumentSummary.PENDING;
                line.value = value;
                line.visible = line.status == GDDocumentSummary.PENDING;
                summary.documentLines.add(line);
            }
        }
        public Schema.SObjectField getRelatedField() {
            return Contract.DocumentosRedaccion__c;
        }
    }

    public class AditionalLinesHandlerImp implements DocumentLinesHandler{
        
        public void setDocumentLines(GDDocumentSummary summary) {
            for (String value : summary.aditionalLines) {
                GDDocumentLine line = new GDDocumentLine(Contract.DocumentosAdicionales__c);
                line.helpText = summary.helpPortalMap.get(value)?.Descripcion__c;
                line.title = summary.documentLabels.get(value);
                line.status = summary.uploadedAditionalLines.contains(value) ? GDDocumentSummary.UPLOADED : GDDocumentSummary.PENDING;
                line.value = value;
                line.visible = line.status == GDDocumentSummary.PENDING;
                summary.documentLines.add(line);
            }
        }
        public Schema.SObjectField getRelatedField() {
            return Contract.DocumentosAdicionales__c;
        }
    }

}