public class CheckWithinBusinessHours {
    @InvocableMethod(label = 'Within Business Hours Check')
    public static List<Boolean> makeGetCallout(List<String> Name) {
    String BHName= String.valueOf(+Name[0]);
    // Get Business hours based on name, input from bot
    BusinessHours bh = [SELECT Id FROM BusinessHours WHERE name= :BHName];
    // Create Datetime with current date/time in local time zone
    Datetime targetTime = Datetime.now();
    // Find whether the time is within business hours
    Boolean isWithin= BusinessHours.isWithin(bh.id, targetTime);
    return new List<Boolean>{isWithin};
    }
}