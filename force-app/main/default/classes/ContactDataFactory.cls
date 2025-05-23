/*
 * Contact test data factory
 * @author  Gerbrand Spaans (Gen25)
 */
@IsTest
public class ContactDataFactory extends DataFactory {

    private static ContactDataFactory factory;
    public static DataFactory init() {
        if(ContactDataFactory.factory == null) {
            ContactDataFactory.factory = new ContactDataFactory();
            ContactDataFactory.factory.getRecord();
        }
        return ContactDataFactory.factory;
    }
    
    public SObject build() {
        this.setRecord( new Contact(
            LastName = 'Test Contact'
        ));
        return this.getRecord();
    }

    public SObject build(Id accountId, String lastName) {
        this.setRecord( new Contact(
                Phone = '123456',
                Firstname = 'Test',
                LastName = lastName,            	
                AccountId = accountId
        ));
        return this.getRecord();
    }

    
    public List<SObject> build(Id accountId, String lastName, Integer numberOfRecords) {
        List<SObject> lstContact = new List<SObject>();

        for (Integer i=0; i<numberOfRecords; i++) {
            Contact cnt = (Contact) build(accountId, lastName + ' ' + i);
            // LastName = lastName + ' ' + i
            lstContact.add(cnt);
        }

        return lstContact;
    }
}