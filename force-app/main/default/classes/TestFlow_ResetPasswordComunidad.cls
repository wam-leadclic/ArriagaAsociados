/*
@author LeadClic Solutions S.L.
@date 23/04/2019
@description Clase Test para la clase Flow_ResetPasswordComunidad

<pre>
FECHA                 AUTOR           ACCION
23/04/2019			LCS - RMG		 Creación.

*/
@isTest
public class TestFlow_ResetPasswordComunidad {

    @isTest
    static void TestCambiarPassword(){   
        system.Test.startTest();
        	Flow_ResetPasswordComunidad.resetearPassword();
        system.Test.stopTest();
    }

}