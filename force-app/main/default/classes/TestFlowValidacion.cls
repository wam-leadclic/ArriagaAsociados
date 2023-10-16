/*
@author LeadClic Solutions S.L.
@date 03/07/2019
@description Clase test para la clase que se encarga de validar el DNI, CIF, o pasaporte del flujo

FECHA                 AUTOR           ACCION
03/07/2019			LCS - RDM		 Creación.
 
*/
@isTest
public class TestFlowValidacion {

    @isTest
    static void TestValidacionOK(){        

        FlowValidacion.GetParam request = new FlowValidacion.GetParam();
        List<FlowValidacion.GetParam> listRequest = new List<FlowValidacion.GetParam>();
                
        request.dni = '83676973Y';
        request.Tlf = '956985214';
        listRequest.add(request);
        
        system.Test.startTest();
        	FlowValidacion.MetodoInvocable(listRequest);
        system.Test.stopTest();
    }
    
    @isTest
    static void TestValidacionTlfKo(){        

        FlowValidacion.GetParam request = new FlowValidacion.GetParam();
        List<FlowValidacion.GetParam> listRequest = new List<FlowValidacion.GetParam>();
                
        request.dni = '83676973Y';
        request.Tlf = '9569J5214';
        listRequest.add(request);
        
        system.Test.startTest();
        	FlowValidacion.MetodoInvocable(listRequest);
        system.Test.stopTest();
    }

}