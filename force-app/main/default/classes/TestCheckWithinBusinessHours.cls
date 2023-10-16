/*
@author OMEGA CRM
@date 17/04/2023
@description Clase Test para la clase CheckWithinBusinessHours
*/
@isTest
public class TestCheckWithinBusinessHours {
    private static final String BH_NAME = 'WhatsApp Business Hours';

    @IsTest
    static void testMakeGetCallout() {
        BusinessHours bh = [SELECT Id, Name FROM BusinessHours WHERE Name =: BH_NAME LIMIT 1];
        // Establece la hora actual en una hora fuera del horario de trabajo y verifica que el método devuelva false
        Datetime targetTime;
        Boolean isWithin;
    
        Test.startTest();
        targetTime = Datetime.now();
        isWithin = CheckWithinBusinessHours.makeGetCallout(new List<String>{bh.Name}).get(0);
        Test.stopTest();
        if(BusinessHours.isWithin(bh.id, targetTime) == true){
            Assert.areEqual(true, isWithin, 'Expected true (in schedule');
        }else{
            Assert.areEqual(false, isWithin, 'Expected false (out of schedule');
        }        
    }  
    
}