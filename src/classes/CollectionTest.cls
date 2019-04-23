@IsTest
private class CollectionTest {
	
	@IsTest
	static void should_filter_eq_then_map_sum() {
		Decimal sum = Collection.of(getList())
			.filter()
			.byField(Account.Name).eq('Foo')
			.then()
			.reduce()
			.byField(Account.AnnualRevenue)
			.sum();
		System.assertEquals(310.0, sum);
	}
	
	@IsTest
	static void should_filter_lt_then_map_average() {
		Decimal average = Collection.of(getList())
			.filter()
			.byField(Account.AnnualRevenue).lt(100)
			.then()
			.reduce()
			.byField(Account.AnnualRevenue)
			.average();
		System.assertEquals(60.0, average);
	}
	
	
	@IsTest
	static void should_group_by_field() {
		Map<Object, List<Account>> found = Collection.of(getList())
			.group()
			.byField(Account.Name)
			.get();
		System.assertEquals(2, found.keySet().size());
		for (Object accountName : found.keySet()) {
			System.assert(accountName == 'Foo' || accountName == 'Bar');
			List<Account> accounts = found.get(accountName);
			System.assertEquals(3, accounts.size());
			for (Account account : accounts) {
				System.assertEquals(account.Name, accountName);
			}
		}
	}
	
	@IsTest
	static void should_filter_then_group_by_field() {
		Map<Object, List<Account>> found = Collection.of(getList())
			.filter()
			.ignoreNonPopulatedFields()
			.byField(Account.BillingStreet).isNotNull()
			.then()
			.group()
			.byField(Account.BillingStreet)
			.get();
		System.assertEquals(2, found.keySet().size());
		for (Object accountBillingStreet : found.keySet()) {
			System.assert(accountBillingStreet == 'Narutowicza' || accountBillingStreet == '3 Maja');
			List<Account> accounts = found.get(accountBillingStreet);
			System.assertEquals(1, accounts.size());
			for (Account account : accounts) {
				System.assertEquals(account.BillingStreet, accountBillingStreet);
			}
		}
	}
	
	@IsTest
	static void should_filter_single_field_eq() {
		List<Account> found = Collection.of(getList())
			.filter()
			.byField(Account.Name).eq('Foo')
			.get();
		System.assertEquals(3, found.size());
		for (Account account : found) {
			System.assertEquals('Foo', account.Name);
		}
	}
	
	@IsTest
	static void should_filter_single_field_is_null() {
		List<Account> found = Collection.of(getList())
			.filter()
			.byField(Account.Id).isNull()
			.get();
		System.assertEquals(3, found.size());
		for (Account account : found) {
			System.assertEquals(null, account.Id);
		}
	}
	
	@IsTest
	static void should_filter_single_field_is_not_null() {
		List<Account> found = Collection.of(getList())
			.filter()
			.byField(Account.Id).isNotNull()
			.get();
		System.assertEquals(3, found.size());
		for (Account account : found) {
			System.assert(account.Id != null);
		}
	}
	
	@IsTest
	static void should_filter_single_field_in() {
		List<Decimal> values = new List<Decimal> { 60, 100 };
		List<Account> found = Collection.of(getList())
			.filter()
			.byField(Account.AnnualRevenue).isIn(values)
			.get();
		System.assertEquals(4, found.size());
		for (Account account : found) {
			System.assert(values.contains(account.AnnualRevenue));
		}
	}
	
	@IsTest
	static void should_filter_single_field_not_in() {
		List<String> values = new List<String> { 'Foo' };
		List<Account> found = Collection.of(getList())
			.filter()
			.byField(Account.Name).isNotIn(values)
			.get();
		System.assertEquals(3, found.size());
		for (Account account : found) {
			System.assert(values.contains(account.Name) == false);
		}
	}
	
	@IsTest
	static void should_filter_multiple_fields_or() {
		List<Account> found = Collection.of(getList())
			.filter()
			.byField(Account.AnnualRevenue).eq(60)
			.orElse()
			.byField(Account.AnnualRevenue).eq(150)
			.get();
		System.assertEquals(4, found.size());
		for (Account account : found) {
			System.assert(account.AnnualRevenue == 60 || account.AnnualRevenue == 150);
		}
	}
	
	@IsTest
	static void should_filter_multiple_fields_and() {
		List<Account> found = Collection.of(getList())
			.filter()
			.byField(Account.Name).eq('Bar')
			.andAlso()
			.byField(Account.AnnualRevenue).gte(100)
			.get();
		System.assertEquals(2, found.size());
		for (Account account : found) {
			System.assert(account.Name == 'Bar' && account.AnnualRevenue >= 100);
		}
	}
	
	@IsTest
	static void should_filter_first() {
		Account found = (Account)Collection.of(getList())
			.filter()
			.byField(Account.Name).eq('Bar')
			.andAlso()
			.byField(Account.AnnualRevenue).eq(60)
			.getFirst();
		System.assertNotEquals(null, found);
		System.assert(found.Name == 'Bar' && found.AnnualRevenue == 60 && found.Website == 'http://website.com');
	}
	
	@IsTest
	static void should_filter_limit() {
		List<Account> found = Collection.of(getList())
			.filter()
			.byField(Account.AnnualRevenue).gt(60)
			.get(3);
		System.assertEquals(3, found.size());
		for (Account account : found) {
			System.assert(account.AnnualRevenue > 60);
		}
	}
	
	@IsTest
	static void should_map_sum_field() {
		Decimal sum = Collection.of(getList())
			.reduce()
			.byField(Account.AnnualRevenue)
			.sum();
		
		System.assertEquals(620.0, sum);
	}
	
	@IsTest
	static void should_map_average_field() {
		Decimal average = Collection.of(getList())
			.reduce()
			.byField(Account.AnnualRevenue)
			.average();
		
		System.assertEquals(103.333333333333333333333333333333, average);
	}
	
	@IsTest
	static void should_return_underlying_collection() {
		List<Account> accountList = getList();
		List<Account> underlyingAccountList = (List<Account>)Collection.of(accountList).getCollection();
		System.assertEquals(accountList.size(), underlyingAccountList.size());
		accountList.add(new Account(Name = 'test'));
		System.assertEquals(accountList.size(), underlyingAccountList.size());
	}
	
	/*
	 * Exception Cases
	 */
	
	
	@IsTest
	static void should_throw_field_not_supported_for_sum() {
		try {
			Collection.of(getList())
				.reduce()
				.byField(Account.Name)
				.sum();
		} catch (Collection.CollectionException e) {
			System.assert(e.getMessage().contains('Invalid string format for Decimal'));
		}
	}
	
	@IsTest
	static void should_throw_field_not_populated_or_not_exist_collection_exception() {
		try {
			Collection.of(getList()).filter()
				.byField(Account.Fax).isNotNull()
				.get();
		} catch (Collection.CollectionException e) {
			System.assert(e.getMessage().contains('seems to be not populated or does not exists'));
		}
	}
	
	@IsTest
	static void should_throw_field_not_populated_collection_exception() {
		try {
			Collection.of(getList()).filter()
				.byField(Case.CaseNumber).isNotNull()
				.get();
		} catch (Collection.CollectionException e) {
			System.assert(e.getMessage().contains('seems to be not populated or does not exists'));
		}
	}
	
	@IsTest
	static void should_throw_field_does_not_belong_sobject_exception() {
		try {
			Collection.of(getList()).filter()
				.ignoreNonPopulatedFields()
				.byField(Case.CaseNumber).isNotNull()
				.get();
		} catch (Collection.CollectionException e) {
			System.assert(e.getMessage().contains('SObject does not contain'));
		}
	}
	
	@IsTest
	static void should_throw_unsupported_types_supplied_for_compare_exception() {
		try {
			Collection.of(getList()).filter()
				.byField(Account.Id).eq(1)
				.get();
		} catch (Collection.CollectionException e) {
			System.assert(e.getMessage().contains('Unsupported types supplied for compare'));
		}
	}
	
	/*
	 * Performance Tests
	 */
	
	@IsTest
	static void performance_test_ignoring_non_populated_field_enabled() {
		Collection.of(getLargeList()).filter()
			.ignoreNonPopulatedFields()
			.byField(Account.Name).eq('A')
			.andAlso()
			.byField(Account.AnnualRevenue).eq(0)
			.andAlso()
			.byField(Account.Website).eq('C')
			.andAlso()
			.byField(Account.BillingStreet).eq('D')
			.andAlso()
			.byField(Account.BillingCity).eq('E')
			.get();
	}
	
	@IsTest
	static void performance_test_ignoring_non_populated_field_disabled() {
		Collection.of(getLargeList()).filter()
			.byField(Account.Name).eq('A')
			.andAlso()
			.byField(Account.AnnualRevenue).eq(0)
			.andAlso()
			.byField(Account.Website).eq('C')
			.andAlso()
			.byField(Account.BillingStreet).eq('D')
			.andAlso()
			.byField(Account.BillingCity).eq('E')
			.get();
	}
	
	/*
	 * PredicateCollection Tests
	 */
	
	@IsTest
	static void test_equal_predicate() {
		// given
		Collection.PredicateCollection collection = new Collection.PredicateCollection(getList());
		
		// when
		collection.eq(Account.Name, 'Foo');
		
		// then
		List<Account> accounts = collection.process(-1);
		System.assertEquals(3, accounts.size());
		for (Account account : accounts) {
			System.assertEquals(account.Name, 'Foo');
		}
	}
	
	@IsTest
	static void test_not_equal_predicate() {
		// given
		Collection.PredicateCollection collection = new Collection.PredicateCollection(getList());
		
		// when
		collection.ne(Account.Name, 'Foo');
		
		// then
		List<Account> accounts = collection.process(-1);
		System.assertEquals(3, accounts.size());
		for (Account account : accounts) {
			System.assertEquals(account.Name, 'Bar');
		}
	}
	
	@IsTest
	static void test_greater_than_predicate() {
		// given
		Collection.PredicateCollection collection = new Collection.PredicateCollection(getList());
		
		// when
		collection.gt(Account.AnnualRevenue, 100);
		
		// then
		List<Account> accounts = collection.process(-1);
		System.assertEquals(2, accounts.size());
		for (Account account : accounts) {
			System.assert(account.AnnualRevenue > 100);
		}
	}
	
	@IsTest
	static void test_greater_or_equal_than_predicate() {
		// given
		Collection.PredicateCollection collection = new Collection.PredicateCollection(getList());
		
		// when
		collection.gte(Account.AnnualRevenue, 100);
		
		// then
		List<Account> accounts = collection.process(-1);
		System.assertEquals(4, accounts.size());
		for (Account account : accounts) {
			System.assert(account.AnnualRevenue >= 100);
		}
	}
	
	@IsTest
	static void test_less_than_predicate() {
		// given
		Collection.PredicateCollection collection = new Collection.PredicateCollection(getList());
		
		// when
		collection.lt(Account.AnnualRevenue, 100);
		
		// then
		List<Account> accounts = collection.process(-1);
		System.assertEquals(2, accounts.size());
		for (Account account : accounts) {
			System.assert(account.AnnualRevenue < 100);
		}
	}
	
	@IsTest
	static void test_less_or_equal_than_predicate() {
		// given
		Collection.PredicateCollection collection = new Collection.PredicateCollection(getList());
		
		// when
		collection.lte(Account.AnnualRevenue, 100);
		
		// then
		List<Account> accounts = collection.process(-1);
		System.assertEquals(4, accounts.size());
		for (Account account : accounts) {
			System.assert(account.AnnualRevenue <= 100);
		}
	}
	
	@IsTest
	static void test_is_in_list_predicate() {
		// given
		List<Decimal> revenues = new List<Decimal> { 60.0, 100.0 };
		Collection.PredicateCollection collection = new Collection.PredicateCollection(getList());
		
		// when
		collection.isIn(Account.AnnualRevenue, revenues);
		
		// then
		List<Account> accounts = collection.process(-1);
		System.assertEquals(4, accounts.size());
		for (Account account : accounts) {
			System.assert(account.AnnualRevenue == 60.0 || account.AnnualRevenue == 100.0);
		}
	}
	
	@IsTest
	static void test_is_not_in_list_predicate() {
		// given
		List<Decimal> revenues = new List<Decimal> { 60.0, 100.0 };
		Collection.PredicateCollection collection = new Collection.PredicateCollection(getList());
		
		// when
		collection.isNotIn(Account.AnnualRevenue, revenues);
		
		// then
		List<Account> accounts = collection.process(-1);
		System.assertEquals(2, accounts.size());
		for (Account account : accounts) {
			System.assert(account.AnnualRevenue != 60.0 && account.AnnualRevenue != 100.0);
		}
	}
	
	@IsTest
	static void test_and_also_predicate() {
		// given
		Collection.PredicateCollection collection = new Collection.PredicateCollection(getList());
		
		// when
		collection.eq(Account.Id, '0011t00000L0aiN');
		collection.andAlso();
		collection.eq(Account.Name, 'Bar');
		
		// then
		List<Account> accounts = collection.process(-1);
		System.assertEquals(1, accounts.size());
		for (Account account : accounts) {
			System.assertEquals(account.Id, '0011t00000L0aiN');
			System.assertEquals(account.Name, 'Bar');
		}
	}
	
	@IsTest
	static void test_or_else_predicate() {
		// given
		Collection.PredicateCollection collection = new Collection.PredicateCollection(getList());
		
		// when
		collection.eq(Account.AnnualRevenue, 60);
		collection.orElse();
		collection.eq(Account.AnnualRevenue, 100);
		
		// then
		List<Account> accounts = collection.process(-1);
		System.assertEquals(4, accounts.size());
		for (Account account : accounts) {
			System.assert(account.AnnualRevenue == 60 || account.AnnualRevenue == 100);
		}
	}
	
	/*
	 * Test Data
	 */
	
	private static List<Account> getList() {
		return new List<Account>{
			new Account(Id = null,              Name = 'Foo', AnnualRevenue = 100, Website = 'http://test.eu'),
			new Account(Id = '0011t00000L0aiN', Name = 'Bar', AnnualRevenue = 100, BillingCity = 'Lublin'),
			new Account(Id = null,              Name = 'Foo', AnnualRevenue = 60, BillingStreet = '3 Maja'),
			new Account(Id = '0011t00000L0amh', Name = 'Bar', AnnualRevenue = 60, Website = 'http://website.com'),
			new Account(Id = null,              Name = 'Foo', AnnualRevenue = 150, BillingCity = 'Lublin'),
			new Account(Id = '0011t00000L0aiP', Name = 'Bar', AnnualRevenue = 150, BillingStreet = 'Narutowicza')
		};
	}
	
	private static List<Account> getLargeList() {
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 10000; i++) {
			accounts.add(new Account(
				Name = 'A ' + i,
				AnnualRevenue = i,
				Website = 'B ' + i,
				BillingStreet = 'C ' + 1,
				BillingCity = 'D ' + i
			));
		}
		return accounts;
	}
}