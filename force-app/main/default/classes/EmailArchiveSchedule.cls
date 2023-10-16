/*
@author LeadClic Solutions S.L.
@date 15/08/2023
@description Clase schedule para el batch de archivado de emails antiguos.

<pre>
FECHA             AUTOR           ACCION
15/08/2023		LCS - DRU	   	  Creación. 
*/

global class EmailArchiveSchedule implements Schedulable {
    
    /**
     * Método que se ejecuta cuando se programa la clase.
     * Lanza el proceso batch EmailArchiveBatch.
     * @param context El contexto de ejecución del proceso programado.
     */
    global void execute(SchedulableContext context) {
        EmailArchiveBatch batch = new EmailArchiveBatch();
        Database.executeBatch(batch);
    }
}