@isTest
private class CourseTriggerHandlerTest {

    static final String COMPLETED = 'Completed';
    static final String SCHEDULED = 'Scheduled';
    static final String CANCELLED = 'Cancelled';
    static final String COURSETITLE = 'Admin Essentials for Experienced Admins';


    @isTest
    private static void checkStatusTest() {
        Test.startTest();
        List<Course__c> courses = new List<Course__c>();
        Course__c test1 = new Course__c(
            Course_Title__c = 'Admin Essentials for new Admins', 
            Instructor__c = 'a044L000001AKWrQAO', 
            Start_Date__c = system.today(), 
            End_Date__c = system.today() + 5,
            Stage__c = 'Scheduled',
            Course_Code__c = 'ADX201'
            );
        courses.add(test1);
        insert courses;
        Course__c course = [SELECT id, Stage__c, Start_Date__c, End_Date__c FROM Course__c limit 1];
        course.Stage__c = 'Completed';
        update course;
        List<Service_Invoice__c> si = [SELECT id, Course__c FROM Service_Invoice__c WHERE Course__c = :course.id];
        List<Service_Invoice_Item__c> sii = [SELECT id, Service_Invoice__c FROM Service_Invoice_Item__c WHERE Service_Invoice__c = :si[0].id];
        Test.stopTest();
        System.assertEquals(1, si.size());
        System.assertEquals(course.Start_Date__c.daysBetween(course.End_Date__c) + 1, sii.size());
    }
    @isTest
    private static void createEventTest() {
        Test.startTest();
        List<Course__c> courses = new List<Course__c>();
        Course__c test1 = new Course__c(
            Course_Title__c = 'Admin Essentials for new Admins', 
            Instructor__c = 'a044L000001AKWrQAO', 
            Start_Date__c = system.today(), 
            End_Date__c = system.today() + 5, 
            Stage__c = 'Scheduled'
            );
        courses.add(test1);
        insert courses;
        Course__c course = [SELECT id, Start_Date__c FROM Course__c limit 1];
        update course;
        List<Event> checkEvent = [SELECT whatid FROM Event WHERE whatid= :course.id];
        Test.stopTest();
        System.assertEquals(1, checkEvent.size());
    }

    @isTest
    private static void deleteEventTest() {
        Test.startTest();
        List<Course__c> courses = new List<Course__c>();
        Course__c test1 = new Course__c(
            Course_Title__c = 'Admin Essentials for new Admins', 
            Instructor__c = 'a044L000001AKWrQAO', 
            Start_Date__c = system.today(), 
            End_Date__c = system.today() + 5, 
            Stage__c = 'Scheduled'
            );
        courses.add(test1);
        insert courses;
        Course__c course = [SELECT id, Stage__c FROM Course__c limit 1];
        course.Stage__c = 'Cancelled';
        update course;
        List<Event> checkEvent = [SELECT whatid FROM Event WHERE whatid= :course.id];
        Test.stopTest();
        System.assertEquals(0, checkEvent.size());
    }
}
