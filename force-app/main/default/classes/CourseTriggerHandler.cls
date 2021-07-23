public with sharing class CourseTriggerHandler {

    static final String COMPLETED = 'Completed';
    static final String SCHEDULED = 'Scheduled';
    static final String CANCELLED = 'Cancelled';
    

    public static void checkStatus(List<Course__c> triggerNew, Map<Id, Course__c> oldMap, Map<Id, Course__c> newMap)  {
        List<Service_Invoice__c> sIToBeAdded = new List<Service_Invoice__c>();
        
        for (Course__c course :  triggerNew) {
            if (oldMap.get(course.Id).Stage__c != COMPLETED && course.Stage__c == COMPLETED ) {
                Service_Invoice__c sI = new Service_Invoice__c(
                    Service_Invoice_Date__c = system.today(),
                    OwnerId = course.OwnerId__c,
                    Course__c = course.Id,
                    Status__c = 'Draft'
                );
                sIToBeAdded.add(sI);
                
                
            }
        }
        
        insert sIToBeAdded;
    }

    
    
}
