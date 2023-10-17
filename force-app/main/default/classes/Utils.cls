/*
@author LeadClic Solutions S.L.
@date 13/10/2023
@description Clase Utils: utilitarios para la reutilización de codigo generico o repetitivo.
<pre>
FECHA             AUTOR           ACCION
13/10/2023		LCS - SDF	   	  Creación.
*/
public class Utils {
    
    public static final String SEMICOLON = ';';
    
    public static Map<String, String> getPicklistLabels(Schema.SObjectField field) {
        Map<String, String> picklistLabels = new Map<String, String>();

        for(Schema.PicklistEntry ple : field.getDescribe().getPicklistValues()) {
            picklistLabels.put(ple.getValue(), ple.getLabel());
        }

        return picklistLabels;
    }

    public static Set<String> getMultipicklistValuesAsSet(SObject record, Schema.SObjectField field) {
        String fieldValue = (String) record.get(field);
        if (String.isBlank(fieldValue)) {
            return new Set<String>();
        }
        return new Set<String>(fieldValue.split(Utils.SEMICOLON));
    }
}