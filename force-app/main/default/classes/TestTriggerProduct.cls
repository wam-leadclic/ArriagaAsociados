/*
@author LeadClic Solutions S.L.
@date 03/10/2019
@description Test del Trigger de Producto

FECHA                 AUTOR           ACCION
03/10/2019			LCS - RDM		 Creación. 
*/
@isTest
public class TestTriggerProduct {

    @isTest static void creacion(){   
        // Se crea Pricebook2, cogiendo el Id de la lista standard
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Como workarround para crear la lista de precios standard, se ejecuta un update sobre el registro de Pricebook2, para que se active a true IsStandard
        update standardPricebook;
        
        system.Test.startTest();
            Product2 prod = new Product2();
                prod.Name = 'test Prod'; 
                prod.IsActive = true;
            insert prod;
        system.Test.stopTest();
    }
}