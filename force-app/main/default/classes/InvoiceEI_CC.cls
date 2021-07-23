public with sharing class InvoiceEI_CC {

    public Expense_Invoice__c eI{get;set;}
 
    public InvoiceEI_CC(ApexPages.StandardController controller) {
        this.eI = (Expense_Invoice__c) controller.getRecord();
    }

    public List<Expense_Invoice_Item__c> results {
        get {
            if(results == null) {
                results = new List<Expense_Invoice_Item__c>([SELECT id, Amount__c, Description__c, Total_Amount__c, RecordTypeId, Date__c, VAT__c, Expense_Invoice__r.Course__r.Bill_To__c, Expense_Invoice__r.Course__r.Mail_To__c
                                                            FROM Expense_Invoice_Item__c
                                                            WHERE Expense_Invoice__c = :eI.Id]);
            }
            return results;
        }
        private set;
        }
}
