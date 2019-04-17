# Apex Collection Util
Library allowing collection manipulations in APEX which helps in reducing conditional `for` loops.\
The main goal is to provide all the functionality without much overhead in a standalone class.

## Features
- fluent interface within standalone class
- lazy predicate evaluation
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

## Considerations
### Set and Map does not implement Iterable interface
Sets and Maps are not supported
