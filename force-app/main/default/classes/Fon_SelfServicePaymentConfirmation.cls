public class Fon_SelfServicePaymentConfirmation {
    
    @AuraEnabled  
    public static Decimal sendEmailToContact(list<OrderApi__Receipt_Line__c> duesReceiptLinelst,list<OrderApi__Receipt_Line__c> receiptLinelst,String confirmationNumber,String contactId){
        Contact[] con = [select id,email from contact where id=:contactId AND email!=null];
        Decimal amt=0.00;
        Set<String> rl = new Set<String>();
        String tempIds;
        receiptLinelst.addAll(duesReceiptLinelst);
        for(OrderApi__Receipt_Line__c rlObj:receiptLinelst){
            if(String.isBlank(tempIds)){
                tempIds = rlObj.Id;
                amt=rlObj.OrderApi__Total__c;
            }
            else{
                tempIds=tempIds+','+rlObj.Id;
                amt=amt+rlObj.OrderApi__Total__c;
            }
        }
        if(con.size()>0){
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            PageReference pg = new PageReference('/apex/Fon_SelfServiceConfirmationEmailTemplate?confirmationNumber='+confirmationNumber+'&totalAmount='+amt+'&id='+tempIds);
            pg.setRedirect(true);
            String pageAsString ;
            if(!Test.isRunningTest() ){
                Blob b = pg.getContent();
                pageAsString = pg.getContent().tostring();
            }else{
                Blob b = blob.valueOf('Test');
                pageAsString = 'test';
            }
            email.setSubject(Label.Fon_PaymentConfirmation);
            email.setHtmlBody(pageAsString);
            email.settoAddresses(new List<String>{con[0].email});
            mails.add(email);
            Messaging.sendEmailResult[] sendingEmail = Messaging.sendEmail(mails); 
        }
        return amt;
    }
}