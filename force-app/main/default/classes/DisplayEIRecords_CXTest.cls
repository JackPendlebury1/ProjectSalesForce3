@isTest
private class DisplayEIRecords_CXTest {
    @isTest
    private static void CloneRecordsTest() {
        User user = [SELECT id, ProfileId, Name FROM User WHERE Name = 'Peter Smith' limit 1];
        Instructor__c testinstructor = new Instructor__c(
            Name = '2121',
            Instructor__c = user.id,
            Course_Type__c = 'ADX201'
        );
        insert testinstructor;
        Instructor__c instructor = [SELECT id FROM Instructor__c limit 1];
        //create course
        List<Course__c> courses = new List<Course__c>();
        Course__c test1 = new Course__c(
            Course_Title__c = 'Admin Essentials for new Admins', 
            Instructor__c = instructor.id, 
            Start_Date__c = system.today(), 
            End_Date__c = system.today() + 5,
            Stage__c = 'Scheduled',
            Course_Code__c = 'ADX201'
            );
        courses.add(test1);
        insert courses;
        Course__c course = [SELECT id, Stage__c, Start_Date__c, End_Date__c, Ownerid__c, Instructor__r.Instructor__r.id, Instructor__c, OwnerId, Course_Code__c, Course_Title__c FROM Course__c limit 1];
        Pagereference EIRecordPage = page.EIRecordPage;
        Test.setCurrentPage(EIRecordPage);

        Test.startTest();
        Apexpages.StandardController controller = new Apexpages.StandardController(course);

        DisplayEIRecords_CX dr = new DisplayEIRecords_CX(controller);
        
        List<DisplayEIRecords_CX.InvoiceWrapper> wrappers = dr.invoiceList;
        dr.invoiceList = wrappers;
        Test.stopTest();
        List<DisplayEIRecords_CX.InvoiceWrapper> updatedWrappers = dr.invoiceList;
        Integer i = 0;
        for (DisplayEIRecords_CX.InvoiceWrapper w : updatedWrappers) {
            if(w.checked) {
                i++;
            }
        }
        System.assertEquals(updatedWrappers.size(), i);
          
    }
}
