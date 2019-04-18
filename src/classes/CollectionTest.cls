@IsTest
private class CollectionTest {
	
	@IsTest
	static void should_filter_eq_then_map_sum() {
		Decimal sum = Collection.of(getList())
			.filterBy()
			.field(Account.Name).eq('Foo')
			.mapBy()
			.field(Account.AnnualRevenue)
			.sum();
		System.assertEquals(310.0, sum);
	}
	
	@IsTest
	static void should_filter_lt_then_map_average() {
		Decimal average = Collection.of(getList())
			.filterBy()
			.field(Account.AnnualRevenue)
			.lt(100)
			.mapBy()
			.field(Account.AnnualRevenue)
			.average();
		System.assertEquals(60.0, average);
	}
	
	
	@IsTest
	static void should_group_by_field() {
		Map<Object, List<Account>> found = Collection.of(getList())
			.groupBy()
			.field(Account.Name)
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
			.filterBy()
			.ignoreNonPopulatedFields()
			.field(Account.BillingStreet).isNotNull()
			.groupBy()
			.field(Account.BillingStreet)
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
			.filterBy()
			.field(Account.Name).eq('Foo')
			.get();
		System.assertEquals(3, found.size());
		for (Account account : found) {
			System.assertEquals('Foo', account.Name);
		}
	}
	
	@IsTest
	static void should_filter_single_field_is_null() {
		List<Account> found = Collection.of(getList())
			.filterBy()
			.field(Account.Id).isNull()
			.get();
		System.assertEquals(3, found.size());
		for (Account account : found) {
			System.assertEquals(null, account.Id);
		}
	}
	
	@IsTest
	static void should_filter_single_field_is_not_null() {
		List<Account> found = Collection.of(getList())
			.filterBy()
			.field(Account.Id).isNotNull()
			.get();
		System.assertEquals(3, found.size());
		for (Account account : found) {
			System.assert(account.Id != null);
		}
	}
	
	@IsTest
	static void should_filter_single_field_in() {
		Set<Decimal> values = new Set<Decimal> { 60, 100 };
		List<Account> found = Collection.of(getList())
			.filterBy()
			.field(Account.AnnualRevenue).isIn(values)
			.get();
		System.assertEquals(4, found.size());
		for (Account account : found) {
			System.assert(values.contains(account.AnnualRevenue));
		}
	}
	
	@IsTest
	static void should_filter_single_field_not_in() {
		Set<String> values = new Set<String> { 'Foo' };
		List<Account> found = Collection.of(getList())
			.filterBy()
			.field(Account.Name).isNotIn(values)
			.get();
		System.assertEquals(3, found.size());
		for (Account account : found) {
			System.assert(values.contains(account.Name) == false);
		}
	}
	
	@IsTest
	static void should_filter_multiple_fields_or() {
		List<Account> found = Collection.of(getList())
			.filterBy()
			.field(Account.AnnualRevenue).eq(60)
			.orElse()
			.field(Account.AnnualRevenue).eq(150)
			.get();
		System.assertEquals(4, found.size());
		for (Account account : found) {
			System.assert(account.AnnualRevenue == 60 || account.AnnualRevenue == 150);
		}
	}
	
	@IsTest
	static void should_filter_multiple_fields_and() {
		List<Account> found = Collection.of(getList())
			.filterBy()
			.field(Account.Name).eq('Bar')
			.andAlso()
			.field(Account.AnnualRevenue).gte(100)
			.get();
		System.assertEquals(2, found.size());
		for (Account account : found) {
			System.assert(account.Name == 'Bar' && account.AnnualRevenue >= 100);
		}
	}
	
	@IsTest
	static void should_filter_first() {
		Account found = (Account)Collection.of(getList())
			.filterBy()
			.field(Account.Name).eq('Bar')
			.andAlso()
			.field(Account.AnnualRevenue).eq(60)
			.getFirst();
		System.assertNotEquals(null, found);
		System.assert(found.Name == 'Bar' && found.AnnualRevenue == 60 && found.Website == 'http://website.com');
	}
	
	@IsTest
	static void should_filter_limit() {
		List<Account> found = Collection.of(getList())
			.filterBy()
			.field(Account.AnnualRevenue).gt(60)
			.get(3);
		System.assertEquals(3, found.size());
		for (Account account : found) {
			System.assert(account.AnnualRevenue > 60);
		}
	}
	
	@IsTest
	static void should_map_sum_field() {
		Decimal sum = Collection.of(getList())
			.mapBy()
			.field(Account.AnnualRevenue)
			.sum();
		
		System.assertEquals(620.0, sum);
	}
	
	@IsTest
	static void should_map_average_field() {
		Decimal average = Collection.of(getList())
			.mapBy()
			.field(Account.AnnualRevenue)
			.average();
		
		System.assertEquals(103.333333333333333333333333333333, average);
	}
	
	@IsTest
	static void should_throw_field_not_supported_for_sum() {
		try {
			Collection.of(getList())
				.mapBy()
				.field(Account.Name)
				.sum();
		} catch (Exception e) {
			System.assert(e.getMessage().contains('Invalid string format for Decimal'));
		}
	}
	
	@IsTest
	static void should_throw_field_not_populated_or_not_exist_collection_exception() {
		try {
			Collection.of(getList()).filterBy()
				.field(Account.Fax).isNotNull()
				.get();
		} catch (Exception e) {
			System.assertEquals('Field Fax seems to be not populated or does not exists', e.getMessage());
		}
	}
	
	@IsTest
	static void should_throw_field_not_populated_collection_exception() {
		try {
			Collection.of(getList()).filterBy()
				.field(Case.CaseNumber).isNotNull()
				.get();
		} catch (Exception e) {
			System.assertEquals('Field CaseNumber seems to be not populated or does not exists', e.getMessage());
		}
	}
	
	@IsTest
	static void should_throw_field_does_not_belong_sobject_exception() {
		try {
			Collection.of(getList()).filterBy()
				.ignoreNonPopulatedFields()
				.field(Case.CaseNumber).isNotNull()
				.get();
		} catch (Exception e) {
			System.assertEquals('Case.CaseNumber does not belong to SObject type Account', e.getMessage());
		}
	}
	
	@IsTest
	static void should_return_underlying_collection() {
		List<Account> accountList = getList();
		List<Account> underlyingAccountList = (List<Account>)Collection.of(accountList).getCollection();
		System.assertEquals(accountList.size(), underlyingAccountList.size());
		accountList.add(new Account(Name = 'test'));
		System.assertEquals(accountList.size(), underlyingAccountList.size());
	}
	
	@IsTest
	static void performance_test_ignoring_non_populated_field_enabled() {
		Collection.of(getLargeList()).filterBy()
			.ignoreNonPopulatedFields()
			.field(Account.Name).eq('A')
			.andAlso()
			.field(Account.AnnualRevenue).eq(0)
			.andAlso()
			.field(Account.Website).eq('C')
			.andAlso()
			.field(Account.BillingStreet).eq('D')
			.andAlso()
			.field(Account.BillingCity).eq('E')
			.get();
	}
	
	@IsTest
	static void performance_test_ignoring_non_populated_field_disabled() {
		Collection.of(getLargeList()).filterBy()
			.field(Account.Name).eq('A')
			.andAlso()
			.field(Account.AnnualRevenue).eq(0)
			.andAlso()
			.field(Account.Website).eq('C')
			.andAlso()
			.field(Account.BillingStreet).eq('D')
			.andAlso()
			.field(Account.BillingCity).eq('E')
			.get();
	}

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
	
	/*
	 * Predicates Tests
	 */
	@IsTest
	static void test_equal() {
		List<Account> accounts = Collection.of(
			new List<Account> { new Account(Name = 'A'), new Account(Name = 'B') }
		).filterBy()
			.field(Account.Name).eq('B')
			.get();
		
		System.assertEquals(1, accounts.size());
		System.assertEquals('B', accounts[0].Name);
	}
	
	@IsTest
	static void test_not_equal() {
		List<Account> accounts = Collection.of(
			new List<Account> { new Account(Name = 'A'), new Account(Name = 'B') }
		).filterBy()
			.field(Account.Name).ne('A')
			.get();
		
		System.assertEquals(1, accounts.size());
		System.assertEquals('B', accounts[0].Name);
	}
}