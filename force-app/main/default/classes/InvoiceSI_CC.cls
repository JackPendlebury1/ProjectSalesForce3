public with sharing class InvoiceSI_CC {

    public Service_Invoice__c sI{get;set;}
 
    public InvoiceSI_CC(ApexPages.StandardController controller) {
        this.sI = (Service_Invoice__c) controller.getRecord();
    }

    public List<Service_Invoice_Item__c> results {
        get {
            if(results == null) {
                results = new List<Service_Invoice_Item__c>([SELECT id, Amount__c, Total_Amount__c, Date__c, VAT__c, Service_Invoice__r.Course__r.Bill_To__c, Service_Invoice__r.Course__r.Mail_To__c
                                                            FROM Service_Invoice_Item__c
                                                            WHERE Service_Invoice__c = :sI.Id]);
            }
            return results;
        }
        private set;
        }
}
