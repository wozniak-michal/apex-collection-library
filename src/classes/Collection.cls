/**
 * Collection util class allowing collections manipulation
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
		 * @return filtered SObject List
		 */
		List<SObject> get(Integer resultLimit);
		
		/**
		 * Returns first found result of all previous filtering calls
		 *
		 * @return filtered SObject
		 */
		SObject getFirst();
	}
	
	private class CollectionFilterImpl implements CollectionFilterResult, CollectionFilter, CollectionFilterPredicate {
		
		private final Iterable<SObject> collection;
		private final Map<SObjectField, List<CollectionFilterNode>> fieldNodes;
		private CollectionFilterNode node;
		private Boolean ignoreNonPopulatedFields = false;
		
		public CollectionFilterImpl(Iterable<SObject> collection) {
			this.collection = collection;
			this.fieldNodes = new Map<SObjectField, List<CollectionFilterNode>>();
			this.node = new CollectionFilterNode();
		}
		
		public CollectionFilter ignoreNonPopulatedFields() {
			this.ignoreNonPopulatedFields = true;
			return this;
		}
		
		public CollectionFilterPredicate field(SObjectField field) {
			this.node.field = field;
			return this;
		}
		
		public CollectionFilterResult eq(Object value) {
			this.node.value = value;
			this.node.operation = BooleanOperation.EQUAL;
			return addNode(this.node);
		}
		
		public CollectionFilterResult ne(Object value) {
			this.node.value = value;
			this.node.operation = BooleanOperation.NOT_EQUAL;
			return addNode(this.node);
		}
		
		public CollectionFilterResult gt(Object value) {
			this.node.value = value;
			this.node.operation = BooleanOperation.GREATER_THAN;
			return addNode(this.node);
		}
		
		public CollectionFilterResult gte(Object value) {
			this.node.value = value;
			this.node.operation = BooleanOperation.GREATER_THAN_OR_EQUAL;
			return addNode(this.node);
		}
		
		public CollectionFilterResult lt(Object value) {
			this.node.value = value;
			this.node.operation = BooleanOperation.LESS_THAN;
			return addNode(this.node);
		}
		
		public CollectionFilterResult lte(Object value) {
			this.node.value = value;
			this.node.operation = BooleanOperation.LESS_THAN_OR_EQUAL;
			return addNode(this.node);
		}
		
		public CollectionFilterResult isNull() {
			this.node.value = null;
			this.node.operation = BooleanOperation.EQUAL;
			return addNode(this.node);
		}
		
		public CollectionFilterResult isNotNull() {
			this.node.value = null;
			this.node.operation = BooleanOperation.NOT_EQUAL;
			return addNode(this.node);
		}
		
		public CollectionFilterResult isIn(/*Set<> */Object values) {
			this.node.value = values;
			this.node.operation = BooleanOperation.IS_IN;
			return addNode(this.node);
		}
		
		public CollectionFilterResult isNotIn(/*Set<> */Object values) {
			this.node.value = values;
			this.node.operation = BooleanOperation.IS_NOT_IN;
			return addNode(this.node);
		}
		
		public CollectionFilter orElse() {
			this.node.relation = BooleanRelation.OR_ELSE;
			return this;
		}
		
		public CollectionFilter andAlso() {
			this.node.relation = BooleanRelation.AND_ALSO;
			return this;
		}
		
		public SObject getFirst() {
			List<SObject> objects = process(1);
			return !objects.isEmpty() ? objects[0] : null;
		}
		
		public List<SObject> get() {
			return process(-1);
		}
		
		public List<SObject> get(Integer resultLimit) {
			return process(resultLimit);
		}
		
		private List<SObject> process(Integer valuesLimit) {
			List<SObject> values = new List<SObject>();
			Iterator<SObject> collectionIterator = this.collection.iterator();
			
			while (collectionIterator.hasNext() && valuesLimit != 0) {
				SObject collectionObject = (SObject) collectionIterator.next();
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
					
					for (CollectionFilterNode node : fieldNodes.get(field)) {
						isMatching = consumeNode(collectionObject, node, isMatching);
					}
				}
				if (isMatching) {
					values.add(collectionObject);
					valuesLimit--;
				}
			}
			return values;
		}
		
		private Boolean consumeNode(SObject collectionObject, CollectionFilterNode node, Boolean isMatchingYet) {
			Boolean isMatching;
			if (node.operation == BooleanOperation.IS_IN ||
				node.operation == BooleanOperation.IS_NOT_IN) {
				isMatching = containsOperation(collectionObject, node);
			} else {
				isMatching = compareOperation(collectionObject, node);
			}
			switch on node.relation {
				when AND_ALSO { return isMatchingYet && isMatching; }
				when OR_ELSE  { return isMatchingYet || isMatching; }
				when else     { return isMatchingYet && isMatching; }
			}
		}
		
		private CollectionFilterResult addNode(CollectionFilterNode node) {
			SObjectField field = node.field;
			List<CollectionFilterNode> nodes = this.fieldNodes.get(field);
			if (nodes == null) {
				nodes = new List<CollectionFilterNode> { node };
				this.fieldNodes.put(field, nodes);
			}
			nodes.add(node);
			this.node = new CollectionFilterNode();
			return this;
		}
	}
	
	private class CollectionFilterNode {
		public SObjectField field { get; set; }
		public Object value { get; set; }
		public BooleanOperation operation { get; set; }
		public BooleanRelation relation { get; set; }
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

	/*
	 * Common methods
	 */
	private static Boolean checkPopulatedField(Map<String,Object> populatedFields, SObjectField field) {
		String fieldName = field.getDescribe().getName();
		return populatedFields.containsKey(fieldName);
	}
	
	private static Boolean compareOperation(SObject collectionObject, CollectionFilterNode node) {
		final Integer result = compare(collectionObject.get(node.field), node.value);
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
	
	private static Boolean containsOperation(SObject collectionObject, CollectionFilterNode node) {
		final Boolean result = contains(node.value, collectionObject.get(node.field));
		switch on node.operation {
			when IS_IN { return result == true; }
			when IS_NOT_IN { return result == false; }
			when else { return false; }
		}
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