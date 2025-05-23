/*
 * Account test data factory
 * @author  Gerbrand Spaans (Gen25)
 */
@IsTest
public class AccountDataFactory extends DataFactory {

    private static AccountDataFactory factory;
    public static DataFactory init() {
        if(AccountDataFactory.factory == null) {
            AccountDataFactory.factory = new AccountDataFactory();
            AccountDataFactory.factory.getRecord();
        }
        return AccountDataFactory.factory;
    }
    /**
     * Generic Account build
     * @return Account with default values.
     */
    public SObject build() {
        this.setRecord(new Account (
            Name = 'Test Account',
            BillingStreet = 'Street',
            BillingCity = 'London',
            BillingPostalCode = 'MOSS'
        ));
        return this.getRecord();
    }
    /**
     * @param name Account name to set
     *
     * @return Account with default values and name.
     */
    public SObject build(String name) {
        Account acc = (Account)this.build();
        acc.Name = name;
        return acc;
    }
    /**
     * @param name Account name to set
     * @param numberOfRecords number of Account records to create
     *
     * @return List of Accounts with default values. Name is the provided name string with an increment postfixed.
     */
    public List<SObject> build(String name, Integer numberOfRecords) {
        List<SObject> lstAccounts= new List<SObject>();
        for (Integer i=0; i<numberOfRecords; i++) {
            Account acc = (Account)this.build();
            acc.Name = name + i;
            acc.BillingStreet = 'Street' + i;
            acc.BillingCity = 'London' + i;
            acc.BillingPostalCode = 'Moss' + i;
            acc.Phone = '12345123' + i;
            lstAccounts.add(acc);
        }
        return lstAccounts;
    }
}