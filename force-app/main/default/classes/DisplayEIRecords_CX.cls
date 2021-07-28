public with sharing class DisplayEIRecords_CX {

    public final Course__c c;
 
    public DisplayEIRecords_CX(ApexPages.StandardController controller) {
        this.c = (Course__c) controller.getRecord();
    }


    public void CloneRecords() {
        List<Expense_Invoice_Item__c> eIIToBeAdded = new List<Expense_Invoice_Item__c>();
        List<InvoiceWrapper> Checked = new List<InvoiceWrapper>();
        for (InvoiceWrapper iw : invoiceList) {
            if (iw.checked) {
                Checked.add(iw);
                if (checked.size() >= 1) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'You have Successfully cloned an Invoice'));
                    Expense_Invoice__c clonedRecord = [SELECT id, OwnerId, Course__c FROM Expense_Invoice__c WHERE id = :iw.eI.id];
                    Expense_Invoice__c newIE = new Expense_Invoice__c(ownerId = clonedRecord.OwnerId, Course__c = c.id);
                    insert newIE;
                    List<Expense_Invoice_Item__c> ClonedEII = [SELECT id, Date__c, RecordTypeId, Expense_Invoice__c, Description__c, Amount__c FROM Expense_Invoice_Item__c WHERE Expense_Invoice__c = :iw.eI.id];
                    for(Expense_Invoice_Item__c eii : ClonedEII) {
                        Expense_Invoice_Item__c newIIE = new Expense_Invoice_Item__c(Date__c = system.today(), Description__c = eii.Description__c, Amount__c = eii.Amount__c, Expense_Invoice__c = newIE.id, RecordTypeId= eii.RecordTypeId);
                        eIIToBeAdded.add(newIIE);
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please select at least one Course'));
                }
            }
        }
        insert eIIToBeAdded;
        
    }

    public List<InvoiceWrapper> invoiceList {
        get {
            if(invoiceList == null) {
                invoiceList = new List<InvoiceWrapper>();
               for(Expense_Invoice__c inv : [SELECT id, OwnerId, Sub_Total__c, Invoice_Total__c, Status__c, VAT__c, Course__r.instructor__r.instructor__r.id, Course__r.Location__c, course__r.Course_Title__c, Course__r.instructor__c, Course__c
                                                            FROM Expense_Invoice__c
                                                            WHERE ownerId = :c.instructor__r.instructor__r.id]){
                                                                invoiceList.add(new InvoiceWrapper(inv));
                                                            }
            }
            return invoiceList;
        }
        set;
        }

    public class InvoiceWrapper{
        public Boolean Checked{get; set;}
        public Expense_Invoice__c eI{get; set;}
        public InvoiceWrapper(Expense_Invoice__c expI) {
            eI = expI;
            Checked = false;
        }
    }

    
}