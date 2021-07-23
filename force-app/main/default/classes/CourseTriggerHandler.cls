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

    public static void createEvent(List<Course__c> triggerNew, Map<Id, Course__c> oldMap, Map<Id, Course__c> newMap) {
        List<Event> eventToAdd = new List<Event>();
        boolean checks = null;
        Event first;
        for (Course__c course :  triggerNew) {
            if (course.Stage__c == SCHEDULED) {
                List<Event> checkEvent = [SELECT id, WhatId, ActivityDate, StartDateTime, EndDateTime, Subject, OwnerId, IsAllDayEvent FROM Event WHERE WhatId = :course.Id];
                if(checkEvent.size() > 0) {
                    checks = true;
                    first = checkEvent[0];
                    first.ActivityDate = system.today();
                    first.StartDateTime = course.Start_Date__c;
                    first.EndDateTime = course.End_Date__c;
                    first.Subject = 'Other';
                    first.OwnerId = course.OwnerId__c;
                    first.IsAllDayEvent = True;
                    first.WhatId = course.Id;
                } else {
                    checks = false;
                    Event e = new Event(
                        ActivityDate = system.today(),
                        StartDateTime = course.Start_Date__c,
                        EndDateTime = course.End_Date__c,
                        Subject = 'Other',
                        OwnerId = course.OwnerId__c,
                        IsAllDayEvent = True,
                        WhatId = course.Id);
                    eventToAdd.add(e);
                    }  
                }    
            }
        if(checks == true) {
            update first;
        } else {
            insert eventToAdd;
        }
    }
    public static void deleteEvent(List<Course__c> triggerNew,  Map<Id, Course__c> oldMap) {
        for (Course__c course : triggerNew) {
            if (oldMap.get(course.Id).Stage__c != CANCELLED && course.Stage__c == CANCELLED) {

                List<User> getUser = [SELECT Email FROM user WHERE Id = :course.OwnerId__c];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] {getUser[0].Email};
                message.subject = 'Your course has been Cancelled';
                message.plainTextBody = 'The course: ' + course.Name + ' That would have started ' + course.Start_Date__c + ' and would have ended on the ' + course.End_Date__c + ' has been cancelled';
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

                List<Event> checkEvent = [SELECT id, WhatId, ActivityDate, StartDateTime, EndDateTime, Subject, OwnerId, IsAllDayEvent FROM Event WHERE WhatId = :course.Id];
                if(checkEvent.size() > 0) {
                    delete checkEvent[0];
                }
            }
        }   
    }
}
