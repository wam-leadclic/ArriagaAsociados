/** 
 * Trigger on CalendarTimetable object to avoid effective dates overlapping
 * @author Leadclic Solutions
 * @version 1.0
 * @since 2019-10-08
 */
trigger TriggerCalendarTimetable on CalendarTimetable__c (before insert, before update) {

    SearchSetup__c cs = SearchSetup__c.getInstance();
    Boolean activeTrigger = cs.EffectiveDatesOverlappingControl__c != null && cs.EffectiveDatesOverlappingControl__c;

    if (activeTrigger){
        if (trigger.isBefore && trigger.isInsert){
            TriggerCalendarTimeTableHandler.beforeInsert(trigger.new);
        }
        if (trigger.isBefore && trigger.isUpdate){
            TriggerCalendarTimeTableHandler.beforeUpdate(trigger.new, trigger.oldMap);
        }
    }
}