/**
 * Library allowing SObject collection manipulations in APEX which helps in reducing conditional for loops.
 *
 * @author Michał Woźniak
 */
public inherited sharing class Collection {
	
	private final Iterable<SObject> collection;
	
	private Collection() { }
	
	private Collection(Iterable<SObject> collection) {
		this.collection = collection;
	}

	/**
	 * Wraps {@code Iterable<SObject>} into new {@code Collection}
	 *
	 * @param collection
	 *
	 * @return wrapped {@code Iterable<SObject>}
	 */
	public static Collection of(Iterable<SObject> collection) {
		return new Collection(collection);
	}
	
	/**
	 * Returns original underlying collection
	 *
	 * @return {@code Iterable<SObject>} collection
	 */
	public Iterable<SObject> getCollection() {
		return collection;
	}
	
	/**
	 * Allows execution of grouping operations
	 */
	public CollectionGroup group() {
		return new CollectionGroupImpl(collection);
	}
	
	public interface CollectionGroup {
		/**
		 * Groups collection by given field
		 *
		 * @param field to group collection
		 */
		CollectionGroupResult byField(SObjectField field);
	}
	
	public interface CollectionGroupResult {
		/**
		 * Returns Map containing results of previous grouping calls
		 *
		 * map key   - contains unique values of given field
		 * map value - contains list of {@code SObject}'s
		 *
		 * @return grouped map for given field
		 */
		Map<Object, List<SObject>> get();
	}
	
	/**
	 * Allows execution of mapping operations
	 */
	public CollectionReduce reduce() {
		return new CollectionReduceImpl(collection);
	}
	
	public interface CollectionReduce {
		
		/**
		 * Reduces collection by given field
		 *
		 * @param field to map collection
		 */
		CollectionReduceResult byField(SObjectField field);
		
	}

	public interface CollectionReduceResult {
		/**
		 * Returns sum of given {@code SObject} field
		 *
		 * @return sum value
		 */
		Decimal sum();
		
		/**
		 * Returns average of given {@code SObject} field
		 *
		 * @return average value
		 */
		Decimal average();
	}
	
	/**
	 * Allows execution of filtering operations
	 */
	public CollectionFilter filter() {
		return new CollectionFilterImpl(collection);
	}
	
	public interface CollectionFilter {
		/**
		* Disables checks for non populated fields in all further filtering calls
		*/
		CollectionFilter ignoreNonPopulatedFields();
		
		/**
		 * Filters collection by given field
		 *
		 * @param field to filter collection
		 */
		CollectionFilterPredicate byField(SObjectField field);
	}
	
	public interface CollectionFilterPredicate {
		/**
		 * Appends equals predicate with given value
		 */
		CollectionFilterResult eq(Object value);
		
		/**
		 * Appends not equals predicate with given value
		 */
		CollectionFilterResult ne(Object value);
		
		/**
		 * Appends greater than predicate with given value
		 */
		CollectionFilterResult gt(Object value);
		
		/**
		 * Appends greater or equal than predicate with given value
		 */
		CollectionFilterResult gte(Object value);
		
		/**
		 * Appends less than predicate with given value
		 */
		CollectionFilterResult lt(Object value);
		
		/**
		 * Appends less or equal than predicate with given value
		 */
		CollectionFilterResult lte(Object value);
		
		/**
		 * Appends is in predicate with given value
		 *
		 * Equivalent of calling .eq(value) for each {@code List} value
		 */
		CollectionFilterResult isIn(List<Object> values);
		
		/**
		 * Appends is not in predicate with given value
		 *
		 * Equivalent of calling .ne(value) for each {@code List} value
		 */
		CollectionFilterResult isNotIn(List<Object> values);
		
		/**
		 * Appends is null predicate with given value
		 *
		 * Equivalent of calling .eq(null)
		 */
		CollectionFilterResult isNull();
		
		/**
		 * Appends is not null predicate with given value
		 *
		 * Equivalent of calling .ne(null)
		 */
		CollectionFilterResult isNotNull();
	}
	
	public interface CollectionFilterResult {
		
		/**
		 * Chains next operation after all previous filtering calls
		 */
		CollectionFilterChain then();
		
		/**
		 * Chains next filtering predicate with AND condition
		 */
		CollectionFilter andAlso();
		
		/**
		 * Chains next filtering predicate with OR condition
		 */
		CollectionFilter orElse();
		
		/**
		 * Returns list containing results of all previous filtering calls
		 *
		 * @return filtered {@code List<SObject>}
		 */
		List<SObject> get();
		
		/**
		 * Returns list limited in size to {@param resultLimit}, containing results of all previous filtering calls
		 *
		 * @param resultLimit
		 *
		 * @return filtered {@code List<SObject>}
		 */
		List<SObject> get(Long resultLimit);
		
		/**
		 * Returns first found result of all previous filtering calls
		 *
		 * @return filtered {@code SObject}
		 */
		SObject getFirst();
	}
	
	public interface CollectionFilterChain {
		
		/**
		 * Chains mapping operation after filtering operation
		 */
		CollectionReduce reduce();
		
		/**
		 * Chains grouping operation after filtering operation
		 */
		CollectionGroup group();
	}
	
	@TestVisible
	private class CollectionFilterImpl implements
			CollectionFilterResult, CollectionFilter, CollectionFilterPredicate, CollectionFilterChain {
		
		private final Iterable<SObject> collection;
		private final PredicateCollection predicateCollection;
		private SObjectField field;
		
		public CollectionFilterImpl(Iterable<SObject> collection) {
			this.collection = collection;
			this.predicateCollection = new PredicateCollection(collection);
		}
		
		public CollectionFilterChain then() {
			return this;
		}
		
		public CollectionReduce reduce() {
			return new CollectionReduceImpl(collection, predicateCollection);
		}
		
		public CollectionGroup group() {
			return new CollectionGroupImpl(collection, predicateCollection);
		}
		
		public CollectionFilter ignoreNonPopulatedFields() {
			this.predicateCollection.ignoreNonPopulatedFields();
			return this;
		}
		
		public CollectionFilterPredicate byField(SObjectField field) {
			this.field = field;
			return this;
		}
		
		public CollectionFilter orElse() {
			this.predicateCollection.orElse();
			return this;
		}
		
		public CollectionFilter andAlso() {
			this.predicateCollection.andAlso();
			return this;
		}
		
		public CollectionFilterResult eq(Object value) {
			this.predicateCollection.eq(field, value);
			return this;
		}
		
		public CollectionFilterResult ne(Object value) {
			this.predicateCollection.ne(field, value);
			return this;
		}
		
		public CollectionFilterResult gt(Object value) {
			this.predicateCollection.gt(field, value);
			return this;
		}
		
		public CollectionFilterResult gte(Object value) {
			this.predicateCollection.gte(field, value);
			return this;
		}
		
		public CollectionFilterResult lt(Object value) {
			this.predicateCollection.lt(field, value);
			return this;
		}
		
		public CollectionFilterResult lte(Object value) {
			this.predicateCollection.lte(field, value);
			return this;
		}
		
		public CollectionFilterResult isNull() {
			this.predicateCollection.eq(field, null);
			return this;
		}
		
		public CollectionFilterResult isNotNull() {
			this.predicateCollection.ne(field, null);
			return this;
		}
		
		public CollectionFilterResult isIn(List<Object> values) {
			this.predicateCollection.isIn(field, values);
			return this;
		}
		
		public CollectionFilterResult isNotIn(List<Object> values) {
			this.predicateCollection.isNotIn(field, values);
			return this;
		}
		
		public SObject getFirst() {
			List<SObject> objects = this.predicateCollection.process(1);
			return objects.isEmpty() ? null : objects[0];
		}
		
		public List<SObject> get() {
			return this.predicateCollection.process(-1);
		}
		
		public List<SObject> get(Long resultLimit) {
			return this.predicateCollection.process(resultLimit);
		}
	}
	
	@TestVisible
	private class CollectionGroupImpl implements CollectionGroup, CollectionGroupResult {
		
		private final Iterable<SObject> collection;
		private final PredicateCollection predicateCollection;
		private SObjectField field;
		
		public CollectionGroupImpl(Iterable<SObject> collection) {
			this.collection = collection;
			this.predicateCollection = new PredicateCollection(collection);
		}
		
		public CollectionGroupImpl(Iterable<SObject> collection, PredicateCollection predicateCollection) {
			this.collection = collection;
			this.predicateCollection = predicateCollection;
		}
		
		public CollectionGroupResult byField(SObjectField field) {
			this.field = field;
			return this;
		}
		
		public Map<Object, List<SObject>> get() {
			final Map<Object, List<SObject>> values = new Map<Object, List<SObject>>();
			final List<SObject> predicateCollection = this.predicateCollection.process(-1);
			for (SObject collectionObject : predicateCollection) {
				Object key = collectionObject.get(field);
				List<SObject> objectList = values.get(key);
				if (objectList == null) {
					objectList = new List<SObject>();
					values.put(key, objectList);
				}
				objectList.add(collectionObject);
			}
			return values;
		}
	}
	
	@TestVisible
	private class CollectionReduceImpl implements CollectionReduce, CollectionReduceResult {
		
		private final Iterable<SObject> collection;
		private final PredicateCollection predicateCollection;
		private SObjectField field;
		
		public CollectionReduceImpl(Iterable<SObject> collection) {
			this.collection = collection;
			this.predicateCollection = new PredicateCollection(collection);
		}
		
		public CollectionReduceImpl(Iterable<SObject> collection, PredicateCollection predicateCollection) {
			this.collection = collection;
			this.predicateCollection = predicateCollection;
		}
		
		public CollectionReduceResult byField(SObjectField field) {
			this.field = field;
			return this;
		}
		
		public Decimal sum() {
			final List<SObject> predicateCollection = this.predicateCollection.process(-1);
			Decimal sum = 0.0;
			for (SObject collectionObject : predicateCollection) {
				sum += getDecimal(collectionObject.get(field));
			}
			return sum;
		}
		
		public Decimal average() {
			final List<SObject> predicateCollection = this.predicateCollection.process(-1);
			Decimal average = 0.0;
			Integer count = 0;
			for (SObject collectionObject : predicateCollection) {
				average += getDecimal(collectionObject.get(field));
				count++;
			}
			return (count > 0) ? (average / count) : 0;
		}
	}
	
	/**
	 * Common implementation for collection filtered by predicates
	 */
	@TestVisible
	private class PredicateCollection {
		
		private final Iterable<SObject> collection;
		private final Set<PredicateNode> predicateNodes;
		private BooleanRelation relation;
		private Boolean ignoreNonPopulatedFields = false;
		
		public PredicateCollection(Iterable<SObject> collection) {
			this.collection = collection;
			this.predicateNodes = new Set<PredicateNode>();
		}
		
		public PredicateCollection ignoreNonPopulatedFields() {
			this.ignoreNonPopulatedFields = true;
			return this;
		}
		
		public PredicateCollection eq(SObjectField field, Object value) {
			return this.addPredicate(new PredicateNode(field, value, BooleanOperation.EQUAL, relation));
		}
		
		public PredicateCollection ne(SObjectField field, Object value) {
			return this.addPredicate(new PredicateNode(field, value, BooleanOperation.NOT_EQUAL, relation));
		}
		
		public PredicateCollection gt(SObjectField field, Object value) {
			return this.addPredicate(new PredicateNode(field, value, BooleanOperation.GREATER_THAN, relation));
		}
		
		public PredicateCollection gte(SObjectField field, Object value) {
			return this.addPredicate(new PredicateNode(field, value, BooleanOperation.GREATER_THAN_OR_EQUAL, relation));
		}
		
		public PredicateCollection lt(SObjectField field, Object value) {
			return this.addPredicate(new PredicateNode(field, value, BooleanOperation.LESS_THAN, relation));
		}
		
		public PredicateCollection lte(SObjectField field, Object value) {
			return this.addPredicate(new PredicateNode(field, value, BooleanOperation.LESS_THAN_OR_EQUAL, relation));
		}
		
		public PredicateCollection isIn(SObjectField field, Object value) {
			return this.addPredicate(new PredicateNode(field, value, BooleanOperation.IS_IN, relation));
		}
		
		public PredicateCollection isNotIn(SObjectField field, Object value) {
			return this.addPredicate(new PredicateNode(field, value, BooleanOperation.IS_NOT_IN, relation));
		}
		
		public PredicateCollection orElse() {
			this.relation = BooleanRelation.OR_ELSE;
			return this;
		}
		
		public PredicateCollection andAlso() {
			this.relation = BooleanRelation.AND_ALSO;
			return this;
		}
		
		private PredicateCollection addPredicate(PredicateNode node) {
			this.predicateNodes.add(node);
			return this;
		}
		
		public List<SObject> process(Long resultLimit) {
			final Map<SObjectField, List<PredicateNode>> fieldNodes = this.groupNodesByField();
			final List<SObject> values = new List<SObject>();
			final Iterator<SObject> iterator = this.collection.iterator();
			
			while (iterator.hasNext() && resultLimit != 0) {
				SObject collectionObject = (SObject) iterator.next();
				Boolean isMatching = true;
				
				Map<String, Object> populatedObjectFields;
				if (!ignoreNonPopulatedFields) {
					populatedObjectFields = collectionObject.getPopulatedFieldsAsMap();
				}
				
				for (SObjectField field : fieldNodes.keySet()) {
					if (!ignoreNonPopulatedFields) {
						String fieldName = field.getDescribe().getName();
						if (!populatedObjectFields.containsKey(fieldName)) {
							throw new CollectionException(
								'Field ' + fieldName + ' seems to be not populated or does not exists. ' +
									'Check if passed SObject fields are valid and properly populated e.g. in SOQL statement. ' +
									'Use ignoreNonPopulatedFields() to disable field population checks.');
						}
					}
					for (PredicateNode node : fieldNodes.get(field)) {
						Object objectFieldValue;
						try {
							objectFieldValue = collectionObject.get(node.field);
						} catch (SObjectException e) {
							throw new CollectionException(
								'SObject does not contain ' + field.getDescribe().getName() + ' field.');
						}
						isMatching = processNode(objectFieldValue, node, isMatching);
					}
				}
				if (isMatching) {
					values.add(collectionObject);
					resultLimit--;
				}
			}
			return values;
		}
		
		private Map<SObjectField, List<PredicateNode>> groupNodesByField() {
			final Map<SObjectField, List<PredicateNode>> values = new Map<SObjectField, List<PredicateNode>>();
			for (PredicateNode predicateNode : predicateNodes) {
				List<PredicateNode> nodes = values.get(predicateNode.field);
				if (nodes == null) {
					nodes = new List<PredicateNode>();
					values.put(predicateNode.field, nodes);
				}
				nodes.add(predicateNode);
			}
			return values;
		}
		
		private Boolean processNode(Object objectFieldValue, PredicateNode node, Boolean isMatchingYet) {
			Boolean isMatching;
			if (node.operation == BooleanOperation.IS_IN ||
				node.operation == BooleanOperation.IS_NOT_IN) {
				isMatching = containsOperation(objectFieldValue, node);
			} else {
				isMatching = compareOperation(objectFieldValue, node);
			}
			switch on node.relation {
				when AND_ALSO { return isMatchingYet && isMatching; }
				when OR_ELSE  { return isMatchingYet || isMatching; }
				when else     { return isMatchingYet && isMatching; }
			}
		}
		
		private Boolean compareOperation(Object value, PredicateNode node) {
			final Integer result = compare(value, node.value);
			switch on node.operation {
				when EQUAL { return result == 0; }
				when NOT_EQUAL { return result != 0; }
				when LESS_THAN { return result < 0; }
				when LESS_THAN_OR_EQUAL { return result <= 0; }
				when GREATER_THAN { return result > 0; }
				when GREATER_THAN_OR_EQUAL { return result >= 0; }
				when else { return false; }
			}
		}
		
		private Boolean containsOperation(Object collection, PredicateNode node) {
			final Boolean result = contains(node.value, collection);
			switch on node.operation {
				when IS_IN { return result == true; }
				when IS_NOT_IN { return result == false; }
				when else { return false; }
			}
		}
	}
	
	private class PredicateNode {
		public SObjectField field { get; set; }
		public Object value { get; set; }
		public BooleanOperation operation { get; set; }
		public BooleanRelation relation { get; set; }
		
		public PredicateNode(SObjectField field, Object value, BooleanOperation operation, BooleanRelation relation) {
			this.field = field;
			this.value = value;
			this.operation = operation;
			this.relation = relation;
		}
	}
	
	/*
	 * Common methods
	 */
	
	private static Decimal getDecimal(Object value) {
		if (value instanceof Long) {
			return Decimal.valueOf((Long)value);
		}
		else if (value instanceof Decimal) {
			return (Decimal)value;
		}
		else if (value instanceof String) {
			try {
				return Decimal.valueOf((String)value);
			} catch (Exception e) {
				throw new CollectionException('Invalid string format for Decimal: ' + value);
			}
		}
		else {
			throw new CollectionException('Unsupported type supplied for decimal. ' +
				'Check if passed SObject field is either Integer, Long, Double, Decimal or proper String.');
		}
	}
	
	private static Integer compare(Object first, Object second) {
		if (first instanceof Id && second instanceof Id) {
			return compareIds((Id)first, (Id)second);
		}
		else if (first instanceof String && second instanceof String) {
			return compareStrings((String)first, (String)second);
		}
		else if (first instanceof Long && second instanceof Long) {
			return compareLongs((Long)first, (Long)second);
		}
		else if (first instanceof Decimal && second instanceof Decimal) {
			return compareDecimals((Decimal)first, (Decimal)second);
		}
		else if (first instanceof Boolean && second instanceof Boolean) {
			return compareBooleans((Boolean)first, (Boolean)second);
		}
		else if (first instanceof Date && second instanceof Date) {
			return compareDates((Date)first, (Date)second);
		}
		else if (first instanceof Datetime && second instanceof Datetime) {
			return compareDateTimes((Datetime)first, (Datetime)second);
		}
		else if (first instanceof Time && second instanceof Time) {
			return compareTimes((Time) first, (Time) second);
		}
		else if (first == null || second == null) {
			return compareNulls(first, second);
		}
		throw new CollectionException('Unsupported types supplied for compare. ' +
			'Check if passed SObject fields and values are the same type.');
	}
	
	private static Boolean contains(Object values, Object value) {
		if (values == null) {
			return false;
		}
		else if (values instanceof List<Object>) {
			List<Object> validValues = (List<Object>) values;
			return listContains(validValues, value);
		}
		throw new CollectionException('Unsupported types supplied for contain. ' +
			'Check if values passed to isIn and isNotIn predicate are Set<T> type.');
	}
	
	private static Boolean listContains(List<Object> objects, Object o) {
		for (Object obj : objects) {
			if (obj.equals(o)) {
				return true;
			}
		}
		return false;
	}
	
	private static Integer compareNulls(Object a, Object b) { return (a == null && b == null) ? 0 : (a == null ? 1 : -1); }
	private static Integer compareBooleans(Boolean a, Boolean b) { return (a == b) ? 0 : (a ? 1 : -1); }
	private static Integer compareDates(Date a, Date b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	private static Integer compareTimes(Time a, Time b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	private static Integer compareDateTimes(Datetime a, Datetime b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	private static Integer compareDecimals(Decimal a, Decimal b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	private static Integer compareIds(Id a, Id b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	private static Integer compareLongs(Long a, Long b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	private static Integer compareStrings(String a, String b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	
	private enum BooleanRelation { AND_ALSO, OR_ELSE }
	
	private enum BooleanOperation {
		EQUAL, NOT_EQUAL,
		IS_IN, IS_NOT_IN,
		LESS_THAN, GREATER_THAN,
		LESS_THAN_OR_EQUAL, GREATER_THAN_OR_EQUAL
	}
	
	public class CollectionException extends Exception { }
}