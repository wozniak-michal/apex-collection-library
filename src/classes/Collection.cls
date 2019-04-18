/**
 * Library allowing collection manipulations in APEX which helps in reducing conditional for loops.
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
	 * Wraps Iterable into new Collection class
	 *
	 * @param collection
	 *
	 * @return wrapped collection
	 */
	public static Collection of(Iterable<SObject> collection) {
		return new Collection(collection);
	}
	
	/**
	 * Returns original underlying collection
	 *
	 * @return Iterable original collection
	 */
	public Iterable<SObject> getCollection() {
		return collection;
	}
	
	/**
	 * Enables to execute grouping operations
	 *
	 * @return
	 */
	public CollectionGroupBy groupBy() {
		return new CollectionGroupByImpl(collection);
	}
	
	public interface CollectionGroupBy {
		/**
		 * Groups collection by given field
		 *
		 * @param field to group collection
		 *
		 * @return
		 */
		CollectionGroupByResult field(SObjectField field);
	}
	
	public interface CollectionGroupByResult {
		/**
		 * Returns Map containing result of previous grouping calls
		 *
		 * @return
		 */
		Map<Object, List<SObject>> get();
	}
	
	public CollectionMap mapBy() {
		return new CollectionMapByImpl(collection);
	}
	
	public interface CollectionMap {
		
		/**
		 * Maps collection by given field
		 *
		 * @param field to map collection
		 *
		 * @return
		 */
		CollectionMapPredicate field(SObjectField field);
	}
	
	public interface CollectionMapPredicate {
		/**
		 * Returns sum of given collection field
		 *
		 * @return sum value
		 */
		Decimal sum();
		
		/**
		 * Returns average of given collection field
		 *
		 * @return average value
		 */
		Decimal average();
	}

	public interface CollectionMapResult {
		/**
		 * Returns sum of given collection field
		 *
		 * @return sum value
		 */
		Decimal sum();
		
		/**
		 * Returns average of given collection field
		 *
		 * @return average value
		 */
		Decimal average();
	}
	
	/**
	 * Enables to execute filtering operations
	 *
	 * @return
	 */
	public CollectionFilter filterBy() {
		return new CollectionFilterImpl(collection);
	}
	
	public interface CollectionFilter {
		/**
		* Disables checks for non populated fields in all further filtering calls
		*
		* @return
		*/
		CollectionFilter ignoreNonPopulatedFields();
		
		/**
		 * Filters collection by given field
		 *
		 * @param field to filter collection
		 *
		 * @return
		 */
		CollectionFilterPredicate field(SObjectField field);
	}
	
	public interface CollectionFilterPredicate {
		/**
		 * Equals Predicate with given value
		 */
		CollectionFilterResult eq(Object value);
		
		/**
		 * Not Equal Predicate with given value
		 */
		CollectionFilterResult ne(Object value);
		
		/**
		 * Greater Than Predicate with given value
		 */
		CollectionFilterResult gt(Object value);
		
		/**
		 * Greater Than or Equal Predicate with given value
		 */
		CollectionFilterResult gte(Object value);
		
		/**
		 * Less Than Predicate with given value
		 */
		CollectionFilterResult lt(Object value);
		
		/**
		 * Less Than or Equal Predicate with given value
		 */
		CollectionFilterResult lte(Object value);
		
		/**
		 * In Predicate with given values
		 */
		CollectionFilterResult isIn(Object values);
		
		/**
		 * In Predicate with given values
		 */
		CollectionFilterResult isNotIn(Object values);
		
		/**
		 * Null Predicate
		 */
		CollectionFilterResult isNull();
		
		/**
		 * Not Null Predicate
		 */
		CollectionFilterResult isNotNull();
	}
	
	public interface CollectionFilterResult {
		/**
		 * Chains next filtering predicate with AND condition
		 *
		 * @return
		 */
		CollectionFilter andAlso();
		
		/**
		 * Chains next filtering predicate with OR condition
		 *
		 * @return
		 */
		CollectionFilter orElse();
		
		/**
		 * Returns List containing results of all previous filtering calls
		 *
		 * @return filtered SObject List
		 */
		List<SObject> get();
		
		/**
		 * Returns List containing results of all previous filtering calls
		 *
		 * @param resultLimit
		 *
		 * @return filtered SObject List
		 */
		List<SObject> get(Long resultLimit);
		
		/**
		 * Returns first found result of all previous filtering calls
		 *
		 * @return filtered SObject
		 */
		SObject getFirst();
	}
	
	private class CollectionFilterImpl implements CollectionFilterResult, CollectionFilter, CollectionFilterPredicate {
		
		private final Iterable<SObject> collection;
		private final PredicateCollection predicateCollection;
		private SObjectField field;
		
		public CollectionFilterImpl(Iterable<SObject> collection) {
			this.collection = collection;
			this.predicateCollection = new PredicateCollection(collection);
		}
		
		public CollectionFilter ignoreNonPopulatedFields() {
			this.predicateCollection.ignoreNonPopulatedFields = true;
			return this;
		}
		
		public CollectionFilterPredicate field(SObjectField field) {
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
		
		public CollectionFilterResult isIn(/*Set<Object>*/Object values) {
			this.predicateCollection.isIn(field, values);
			return this;
		}
		
		public CollectionFilterResult isNotIn(/*Set<Object>*/Object values) {
			this.predicateCollection.isNotIn(field, values);
			return this;
		}
		
		public SObject getFirst() {
			List<SObject> objects = this.predicateCollection.process(1);
			return !objects.isEmpty() ? objects[0] : null;
		}
		
		public List<SObject> get() {
			return this.predicateCollection.process(-1);
		}
		
		public List<SObject> get(Long resultLimit) {
			return this.predicateCollection.process(resultLimit);
		}
	}
	
	private class CollectionGroupByImpl implements CollectionGroupBy, CollectionGroupByResult {
		
		private final Iterable<SObject> collection;
		private SObjectField field;
		
		public CollectionGroupByImpl(Iterable<SObject> collection) {
			this.collection = collection;
		}
		
		public CollectionGroupByResult field(SObjectField field) {
			this.field = field;
			return this;
		}
		
		public Map<Object, List<SObject>> get() {
			final Map<Object, List<SObject>> values = new Map<Object, List<SObject>>();
			Iterator<SObject> collectionIterator = this.collection.iterator();
			while (collectionIterator.hasNext()) {
				SObject collectionObject = (SObject) collectionIterator.next();
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
	
	
	private class CollectionMapByImpl implements CollectionMap, CollectionMapPredicate, CollectionMapResult {
		
		private final Iterable<SObject> collection;
		private final PredicateCollection predicateCollection;
		private SObjectField field;
		
		public CollectionMapByImpl(Iterable<SObject> collection) {
			this.collection = collection;
			this.predicateCollection = new PredicateCollection(collection);
		}
		
		public CollectionMapPredicate field(SObjectField field) {
			this.field = field;
			return this;
		}
		
		public Decimal sum() {
			final List<SObject> filteredCollection = this.predicateCollection.process(-1);
			Decimal sum = 0.0;
			for (SObject collectionObject : filteredCollection) {
				try {
					sum += getDecimal(collectionObject.get(field));
				} catch (Exception e) {
					throw new CollectionException(e.getMessage());
				}
			}
			return sum;
		}
		
		public Decimal average() {
			final List<SObject> filteredCollection = this.predicateCollection.process(-1);
			Decimal average = 0.0;
			Integer count = 0;
			for (SObject collectionObject : filteredCollection) {
				try {
					average += getDecimal(collectionObject.get(field));
					count++;
				} catch (Exception e) {
					throw new CollectionException(e.getMessage());
				}
			}
			return (count > 0) ? (average / count) : 0;
		}
	}
	
	/**
	 * Predicate Collection
	 */
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
		
		public List<SObject> process(Long valuesLimit) {
			final Map<SObjectField, List<PredicateNode>> fieldNodes = this.groupNodesByField();
			final List<SObject> values = new List<SObject>();
			final Iterator<SObject> iterator = this.collection.iterator();
			
			while (iterator.hasNext() && valuesLimit != 0) {
				SObject collectionObject = (SObject) iterator.next();
				Boolean isMatching = true;
				
				Map<String, Object> populatedObjectFields;
				if (!ignoreNonPopulatedFields) {
					populatedObjectFields = collectionObject.getPopulatedFieldsAsMap();
				}
				
				for (SObjectField field : fieldNodes.keySet()) {
					if (!ignoreNonPopulatedFields && checkPopulatedField(populatedObjectFields, field) == false) {
						throw new CollectionException(
							'Field ' + field.getDescribe().getName() + ' seems to be not populated or does not exists');
					}
					
					for (PredicateNode node : fieldNodes.get(field)) {
						isMatching = processNode(collectionObject, node, isMatching);
					}
				}
				if (isMatching) {
					values.add(collectionObject);
					valuesLimit--;
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
		
		private Boolean processNode(SObject nodeObject, PredicateNode node, Boolean isMatchingYet) {
			Boolean isMatching;
			if (node.operation == BooleanOperation.IS_IN ||
				node.operation == BooleanOperation.IS_NOT_IN) {
				isMatching = containsOperation(nodeObject, node);
			} else {
				isMatching = compareOperation(nodeObject, node);
			}
			switch on node.relation {
				when AND_ALSO { return isMatchingYet && isMatching; }
				when OR_ELSE  { return isMatchingYet || isMatching; }
				when else     { return isMatchingYet && isMatching; }
			}
		}
		
		private Boolean compareOperation(SObject nodeObject, PredicateNode node) {
			final Integer result = compare(nodeObject.get(node.field), node.value);
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
		
		private Boolean containsOperation(SObject nodeObject, PredicateNode node) {
			final Boolean result = contains(node.value, nodeObject.get(node.field));
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
		
		public PredicateNode() { }
		
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
		if (value instanceof Integer) {
			return Decimal.valueOf((Integer)value);
		}
		else if (value instanceof Long) {
			return Decimal.valueOf((Long)value);
		}
		else if (value instanceof Double) {
			return (Decimal)value;
		}
		else if (value instanceof Decimal) {
			return (Decimal)value;
		}
		else {
			throw new CollectionException('Unsupported type for Decimal');
		}
	}
	
	private static Boolean checkPopulatedField(Map<String,Object> populatedFields, SObjectField field) {
		String fieldName = field.getDescribe().getName();
		return populatedFields.containsKey(fieldName);
	}
	
	private static Integer compare(Object first, Object second) {
		if (second == null) {
			return compareNulls(first, second);
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
		else if (first instanceof Decimal && second instanceof Decimal) {
			return compareDecimals((Decimal)first, (Decimal)second);
		}
		else if (first instanceof Double && second instanceof Double) {
			return compareDoubles((Double)first, (Double)second);
		}
		else if (first instanceof Id && second instanceof Id) {
			return compareIds((Id)first, (Id)second);
		}
		else if (first instanceof Integer && second instanceof Integer) {
			return compareIntegers((Integer)first, (Integer)second);
		}
		else if (first instanceof Long && second instanceof Long) {
			return compareLongs((Long)first, (Long)second);
		}
		else if (first instanceof String && second instanceof String) {
			return compareStrings((String)first, (String)second);
		}
		else if (first instanceof Time && second instanceof Time) {
			return compareTimes((Time)first, (Time)second);
		}
		throw new CollectionException('Unsupported compare types, first: ' + first + ', second: ' + second);
	}
	
	private static Boolean contains(Object valueSet, Object value) {
		if (valueSet instanceof Set<Boolean>) {
			Set<Boolean> validValues = (Set<Boolean>) valueSet;
			return validValues.contains((Boolean) value);
		}
		else if (valueSet instanceof Set<Date>) {
			Set<Date> validValues = (Set<Date>) valueSet;
			return validValues.contains((Date) value);
		}
		else if (valueSet instanceof Set<Datetime>) {
			Set<Datetime> validValues = (Set<Datetime>) valueSet;
			return validValues.contains((Datetime) value);
		}
		else if (valueSet instanceof Set<Decimal>) {
			Set<Decimal> validValues = (Set<Decimal>) valueSet;
			return validValues.contains((Decimal) value);
		}
		else if (valueSet instanceof Set<Double>) {
			Set<Double> validValues = (Set<Double>) valueSet;
			return validValues.contains((Double) value);
		}
		else if (valueSet instanceof Set<Id>) {
			Set<Id> validValues = (Set<Id>) valueSet;
			return validValues.contains((Id) value);
		}
		else if (valueSet instanceof Set<Integer>) {
			Set<Integer> validValues = (Set<Integer>) valueSet;
			return validValues.contains((Integer) value);
		}
		else if (valueSet instanceof Set<Long>) {
			Set<Long> validValues = (Set<Long>) valueSet;
			return validValues.contains((Long) value);
		}
		else if (valueSet instanceof Set<String>) {
			Set<String> validValues = (Set<String>) valueSet;
			return validValues.contains((String) value);
		}
		throw new CollectionException('Unsupported contain type, must be instance of Set');
	}
	
	private static Integer compareNulls(Object a, Object b) { return (a == null && b == null) ? 0 : (a == null ? 1 : -1); }
	private static Integer compareBooleans(Boolean a, Boolean b) { return (a == b) ? 0 : (a ? 1 : -1); }
	private static Integer compareDates(Date a, Date b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	private static Integer compareTimes(Time a, Time b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	private static Integer compareDateTimes(Datetime a, Datetime b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	private static Integer compareDecimals(Decimal a, Decimal b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	private static Integer compareDoubles(Double a, Double b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	private static Integer compareIds(Id a, Id b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
	private static Integer compareIntegers(Integer a, Integer b) { return (a == b) ? 0 : (a > b ? 1 : -1); }
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