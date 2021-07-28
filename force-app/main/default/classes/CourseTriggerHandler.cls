public with sharing class CourseTriggerHandler {

    static final String COMPLETED = 'Completed';
    static final String SCHEDULED = 'Scheduled';
    static final String CANCELLED = 'Cancelled';
    

    public static void checkStatus(List<Course__c> triggerNew, Map<Id, Course__c> oldMap, Map<Id, Course__c> newMap)  {
        List<Service_Invoice__c> sIToBeAdded = new List<Service_Invoice__c>();
        List<id> serviceId = new List<id>();
        List<Service_Invoice_Item__c> sIIToBeAdded = new List<Service_Invoice_Item__c>();
        for (Course__c course :  triggerNew) {
            if (oldMap.get(course.Id).Stage__c != COMPLETED && course.Stage__c == COMPLETED ) {
                Service_Invoice__c sI = new Service_Invoice__c(
                    Service_Invoice_Date__c = system.today(),
                    OwnerId = course.OwnerId__c,
                    Course__c = course.Id,
                    Status__c = 'Draft'
                );
                sIToBeAdded.add(sI);
                serviceId.add(course.id);
            }
        }
        insert sIToBeAdded;
        List<Service_Invoice__c> current = [SELECT Course__r.Start_Date__c, Course__r.End_Date__c, Course__r.Course_Code__c, id, Course__r.Course_Title__c, Course__r.Instructor_Rate__c 
                                            FROM Service_Invoice__c 
                                            WHERE Course__c IN : serviceId];
        for(Service_Invoice__c s : current) {
            Integer numOfDays = s.Course__r.Start_Date__c.daysBetween(s.Course__r.End_Date__c) + 1;
            for(Integer i = 0; numOfDays > i ; i++) {
                Service_Invoice_Item__c sII = new Service_Invoice_Item__c(
                    Date__c = s.Course__r.Start_Date__c + i,
                    Category__c = s.Course__r.Course_Code__c,
                    Service_Invoice__c = s.id,
                    Description__c = s.Course__r.Course_Title__c + 'day :' + i,
                    Amount__c = s.Course__r.Instructor_Rate__c
                    );
                sIIToBeAdded.add(sII);
            }
        }
        insert sIIToBeAdded;
    }

    public static void createEvent(List<Course__c> triggerNew, Map<Id, Course__c> oldMap, Map<Id, Course__c> newMap) {
        List<Event> eventToAdd = new List<Event>();
        boolean checks = null;
        Event first;
        for (Course__c course :  triggerNew) {
            if (course.Stage__c == SCHEDULED) {
                List<User> getUser = [SELECT Email FROM user WHERE Id = :course.OwnerId__c];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] {getUser[0].Email};
                message.subject = 'Your course has been Scheduled';
                message.plainTextBody = 'The course: ' + course.Name + ' That Will started ' + course.Start_Date__c + ' and Will end on the ' + course.End_Date__c + ' has been Scheduled';
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

                List<Event> checkEvent = [SELECT id, WhatId, ActivityDate, StartDateTime, EndDateTime, Subject, OwnerId, IsAllDayEvent FROM Event WHERE WhatId = :course.Id];
                if(checkEvent.size() > 0) {
                    checks = true;
                    first = checkEvent[0];
                    first.ActivityDate = course.Start_Date__c;
                    first.StartDateTime = course.Start_Date__c;
                    first.EndDateTime = course.End_Date__c;
                    first.Subject = 'Other';
                    first.Location = course.Location__c;
                    first.OwnerId = course.OwnerId__c;
                    first.IsAllDayEvent = True;
                    first.WhatId = course.Id;
                } else {
                    checks = false;
                    Event e = new Event(
                        ActivityDate = course.Start_Date__c,
                        StartDateTime = course.Start_Date__c,
                        EndDateTime = course.End_Date__c,
                        Subject = 'Other',
                        Location = course.Location__c,
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
        List<Event> checkEvent = new List<Event>();
        for (Course__c course : triggerNew) {
            if (oldMap.get(course.Id).Stage__c != CANCELLED && course.Stage__c == CANCELLED) {

                List<User> getUser = [SELECT Email FROM user WHERE Id = :course.OwnerId__c];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] {getUser[0].Email};
                message.subject = 'Your course has been Cancelled';
                message.plainTextBody = 'The course: ' + course.Name + ' That would have started ' + course.Start_Date__c + ' and would have ended on the ' + course.End_Date__c + ' has been cancelled';
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

                checkEvent = [SELECT id, WhatId, ActivityDate, StartDateTime, EndDateTime, Subject, OwnerId, IsAllDayEvent FROM Event WHERE WhatId = :course.Id];
            }
        }
        if(checkEvent.size() > 0) {
            delete checkEvent[0];
        }  
    }
    
}
