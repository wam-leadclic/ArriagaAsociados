/*
@author LeadClic Solutions S.L.
@date 16/04/2019
@description Clase Test para el trigger de cuenta y su handler. También testea la clase ActualizarInfoUsuarioComunidad

<pre>
FECHA                 AUTOR           ACCION
16/04/2019			LCS - RDM		 Creación.
 
*/
@isTest
public class TestValidacionDNI {

    @isTest static void ComprobacionDNI(){
        system.Test.startTest();
        	 ValidacionDNI.validarCif('57420062X');
        	 ValidacionDNI.validarCif('5742062X');
        	 ValidacionDNI.validarCif('5742S062X');
        	 ValidacionDNI.validarCif('Z0415424A');
        	 ValidacionDNI.validarCif('A00723254');
        	 ValidacionDNI.validarCif('N9685158I');
        	 ValidacionDNI.validarCif('CUB315048E');
        	 ValidacionDNI.validarCif('I0415424A');
        	 ValidacionDNI.validarCif('57920062X');
        System.Test.stopTest();
    }
}