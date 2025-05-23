/**
 * DataFactory Extension Class
 * @author Gerbrand Spaans - Gen25
 *
 * Example implementation
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
 }
 * Example Usage
 DataFactory adf = AccountDataFactory.init()
        .setId()
        .setCalculatedField(Account.Number_Of_Contacts__c, 1)
        .setCalculatedField(Accouunt.Number_Of_Orders__c, 3);
 DataFactory cdf = ContactDataFactory.init()
        .setId()
        .setRelationshipAsObject(adf.getRecord(), Contact.AccountId);
 DataFactory odf = OrderDataFactory.init()
        .setId()
        .setRelationshipAsObject(adf.getRecord(), Order.AccountId)
        .setRelationshipAsObject(cdf.getRecord(), Order.BillToContactId)
        .setRelationshipAsObject(cdf.getRecord(), Order.ShipToContactId);
*/
public abstract class DataFactory {
    // Singleton Object
    static DataFactory factory;

    /**
     * Override this method with a SObject specific implementation
     * @return Datafactory instance to allow chaining
     */
    static DataFactory init() {
        return DataFactory.factory;
    }

    private SObject record;
    /**
     * Set the current record to a pre-generated instance
     * @param record Record to set as default.
     *
     * @return Current record.
     */
    public DataFactory setRecord(SObject record) {
        this.record = record;
        return this;
    }
    /**
     * Set the current record or set a default implementation
	 * @return The current record.
	 */
    public SObject getRecord() {
        if (this.record == null) {
            this.record = this.build();
        }
        return record;
    }
    /**
     * Reset the state of the Datafactory to a default record.
     * @return Datafactory instance to allow chaining
     */
    public DataFactory reset() {
        this.record = this.build();
        return this;
    }
    /**
     * Allows setting of read-only fields. Will be set to the default instance.
     * @param field Field to set.
     * @param value Value to set
     *
     * @return Current DataFactory object. This allows chaining of methods.
     */
    public DataFactory setCalculatedField(SObjectField field, Object value) {
        // Round trip twice through JSON to skip field validation on calculated fields.
        Map<String, Object> o = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(this.record));
        o.put(field.getDescribe().getName(), value);
        this.record = (SObject)JSON.deserialize(JSON.serialize(o), SObject.class);
        return this;
    }
    /**
     * Allows setting of fields. For read-only fields choose to use setCalculatedField() instead.
     * @param field Field to set.
     * @param value Value to set on the field.
     *
     * @return Current DataFactory object. This allows chaining of methods.
     */
    public DataFactory set(SObjectField field, Object value) {
        this.record.put(field, value);
        return this;
    }
    /**
     * Generate random values for the provided field.
     * @param field Field to set.
     *
     * @return Current DataFactory object. This allows chaining of methods.
     */
    public DataFactory fill(SObjectField field) {
        String t = field.getDescribe().getType().name();
        if(t == 'STRING' || t == 'TEXTAREA') {
            this.set(field, 'Test' + this.getCounter());
        } else if(t == 'EMAIL') {
            this.set(field, 'test' + this.getCounter() + '@testcompany.com');
        } else if(t == 'PHONE') {
            String ps = '00000000' + this.getCounter();
            ps = ps.right(8);
            this.set(field, '+316' + ps);
        } else if(t == 'INTEGER' || t == 'CURRENCY' || t == 'DOUBLE' || t == 'PERCENT') {
            this.set(field, this.getCounter());
        } else if(t == 'ID') {
            this.setId();
        } else if(t == 'DATE') {
            this.set(field, System.today() - this.getCounter());
        } else if(t == 'DATETIME') {
            this.set(field, System.now() - this.getCounter());
        } else if(t == 'TIME') {
            this.set(field, Time.newInstance(this.getCounter(), this.getCounter(), this.getCounter(), 0));
        }
        return this;
    }
    /**
     * Set the relationship and the relevant Id with data. This allows parent value lookups if correctly set.
     * Example:
        DataFactory adf = AccountDataFactory.init()
                .setId();
        DataFactory odf = OrderDataFactory.init()
                .setId()
                .setRelationshipAsObject(adf.getRecord(), Order.AccountId);

        Account a = (Account)adf.getRecord();
        Order o = (Order)odf.getRecord();

        Assert.areEqual(o.AccountId, a.Id);
        Assert.areEqual(o.Account.Name, a.Name);
     * @param recordSObject The SObject to set
     * @param field The relationship field te set in on.
     *
     * @return DataFactory instance to allow chaining.
     */
    public DataFactory setRelationshipAsObject(SObject recordSObject, SObjectField field) {
        this.record.putSObject(field.getDescribe().relationshipName, recordSObject);
        this.record.put(field, recordSObject?.Id);
        return this;
    }
    /**
     * Abstract method to override with SObject specific implementation
     * @return The current record.
     */
    abstract SObject build();
    /**
     * Insert the current record, or create a default instance and insert it.
	 * @return The current inserted record.
	 */
    public SObject create() {
        if(this.record == null) {
            this.record = this.build();
        }
        return this.create(this.record);
    }
    /**
     * Insert a single SObject
     * @param item SObject to insert. Creates a default instance if null
     *
     * @return inserted SObject
     */
    public SObject create(SObject item) {
        SObject sob = (item != null) ? item : this.build();
        insert sob;
        return sob;
    }
    /**
     * Insert a list of SObjects
     * @param items List of SObjects
     *
     * @return inserted List<>
     */
    public List<SObject> create(List<SObject> items) {
        insert items;
        return items;
    }

    // Counter to make sure all issued Ids are unique.
    private Integer i = 0;
    private Integer getCounter() { return ++i;}
    /**
     * Get a new Id for the current SObjectType
     * @return 15 Digit Id
     */
    public String getNewId() {
        String idString = '00000000000000' + this.getCounter();
        return this.record.getSObjectType().getDescribe().keyPrefix + idString.right(15);
    }
    /**
     * Set the Id for the current record, as if it was inserted.
     * @return DataFactory instance for linking
     */
    public DataFactory setId() {
        this.record.Id = this.getNewId();
        return this;
    }
}