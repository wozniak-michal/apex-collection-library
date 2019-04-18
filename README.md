# Apex Collection Library
Library allowing collection manipulations in APEX which helps in reducing conditional `for` loops.\
The main goal is to provide all the functionality without much overhead in a standalone class.

Latest version: **0.0.3**

## Features
- fluent interface within standalone class
- operations chaining
- lazy evaluation
- missing fields detection (not populated, not existing)

## Example Usage
### Filtering
Filter accounts whose `Name` field equals `Foo`
```$xslt
List<Account> filteredAccounts = Collection.of(accountList)
	.filterBy()
	.field(Account.Name).eq('Foo')
	.get();
```

Filter accounts whose `Name` field equals `Foo` and field `AnnualRevenue` is greater or equal than `150000`
```$xslt
List<Account> filteredAccounts = Collection.of(accountList)
	.filterBy()
	.field(Account.Name).eq('Foo')
	.andAlso()
	.field(Account.AnnualRevenue).gte(150000)
	.get();
```

Get first account which `Name` field equals `Bar` or `Foo`
```$xslt
List<Account> filteredAccounts = Collection.of(accountList)
	.filterBy()
	.field(Account.Name).eq('Bar')
	.orElse()
	.field(Account.Name).eq('Foo')
	.getFirst();
```

Get top 10 accounts which `AnnualRevenue` field is less or equal than `100000`
```$xslt
List<Account> filteredAccounts = Collection.of(accountList)
	.filterBy()
	.field(Account.Name).lte('100000')
	.get(10);
```

Ignore non populated `Website` field (effectively treating them as `null`)
```$xslt
List<Account> filteredAccounts = Collection.of(accountList)
	.filterBy()
	.ignoreNonPopulatedFields()
	.field(Account.Website).isNull()
	.get();
```

### Grouping
Group accounts by `Active__c` `Boolean` field
```$xslt
Map<Object, List<Account>> groupedAccounts = Collection.of(accountList)
	.groupBy()
	.field(Account.Active__c)
	.get();
```

### Mapping
Sum accounts `AnnualRevenue` field values
```$xslt
Decimal sum = Collection.of(getList())
	.mapBy()
	.field(Account.AnnualRevenue)
	.sum();
```

Average accounts `AnnualRevenue` field values
```$xslt
Decimal sum = Collection.of(getList())
	.mapBy()
	.field(Account.AnnualRevenue)
	.average();
```

### Operations chaining
Filter accounts whose `Name` field equals to `Foo` then sum matching records `AnnualRevenue` field
```$xslt
Decimal sum = Collection.of(getList())
	.filterBy()
	.field(Account.Name).eq('Foo')
	.mapBy()
	.field(Account.AnnualRevenue)
	.sum();
```
Filter accounts whose `AnnualRevenue` field is greater or equal than `100000` then group matching records by `BillingCity` field
```$xslt
Map<Object, List<Account>> found = Collection.of(getList())
	.filterBy()
	.field(Account.AnnualRevenue).gte(100000)
	.groupBy()
	.field(Account.BillingCity)
	.get();
```

## Considerations
### Set and Map does not implement Iterable interface
Sets and Maps are not supported

## Changelog

### v0.0.3
- Added operations chaining: filter-then-map, filter-then-group

### v0.0.2
- Added mapping by field operations: sum, average
- Code base refactor

### v0.0.1
- Initial version
- Added grouping by field operation
- Added filtering by fields operation