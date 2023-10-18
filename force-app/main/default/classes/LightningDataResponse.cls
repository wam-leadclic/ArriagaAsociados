/*
@author LeadClic Solutions S.L.
@date 17/10/2023
@description Clase LightningDataResponse: se utiliza para encapsular respuestas en Apex
 * y enviarlas a componentes Lightning en Salesforce. Proporciona un estatus y un mensaje
 * para comunicar resultados de operaciones.
<pre>
FECHA             AUTOR           ACCION
17/10/2023		LCS - SDF	   	  Creación.
*/
public virtual class LightningDataResponse {

    public static final String SUCCESS = 'success';
    public static final String ERROR = 'error';

    @AuraEnabled
    public String status {get; set;}
    @AuraEnabled
    public String message {get; set;}
    
    public LightningDataResponse(String status, String message) {
        this.message = message;
        this.status = status;
    }

    public LightningDataResponse(String status) {
        this.status = status;
    }
}