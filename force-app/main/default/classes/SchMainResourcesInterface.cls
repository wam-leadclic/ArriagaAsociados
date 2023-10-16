/** 
 * Clic2Meet interface with methods for custom implementations on main resources/users tab
 * @author Leadclic Solutions
 * @version 1.0
 * @since 2019-10-01
 */
global interface SchMainResourcesInterface {


    /**
     * Custom Calendar Setting query criteria 
     * @return         return description
     */ 
    List<CalendarSetting__c> getResourceListWithCustomCriteria (Set<String> sSubtype);
    

}