/** Proxy of <code>com.mongodb.DBCursor</code> */
component accessors="true" 
{
	/**
		@setter false
	 */
	property dbCursor;
	
	/**
		@setter false
	 */
	property Util util;
	
	
	package function init(required dbCursor, required Util util)
	{
		if (!isInstanceOf(dbCursor, "com.mongodb.DBCursor"))
			throw (message="The dbCursor argument passed to the init function is not of type com.mongodb.DBCursor");
	
		variables.dbCursor = dbCursor;
		variables.util = util;
		
		return this;
	}
	

	DBCursor function copy()
	{
		return new DBCursor(variables.dbCursor.copy(), variables.util);
	}
	
	
	// iterator - ignore
	
	/** 
		@orderBy should be OrderedStruct
	*/
	DBCursor function sort(required struct orderBy)
	{
		if (!(variables.util.isOrderedStruct(orderBy) || structCount(orderBy) <= 1))
			throw (message="The orderBy argument passed to the sort function is not of type OrderedStruct");
			
		orderBy = variables.util.toDBObject(orderBy);
		variables.dbCursor.sort(orderBy);
		
		return this;
	}
	
	
	DBCursor function _addSpecial(required string name, required value)
	{
		value = variables.util.toDBObject(value);
		variables.dbCursor.addSpecial(name, value);
		
		return this;
	}
	
	
	/**
		Informs the database of indexed fields of the collection in order to improve performance.
		@index OrderedStruct or string 
	 */
	DBCursor function hint(required index)
	{
		if (isSimpleValue(index))
		{
			// do nothing
		}
		else if (variables.util.isOrderedStruct(index) || structCount(index) <= 1)
		{
			index = variables.util.toDBObject(index);
		}
		else throw (message="The index argument passed to the hint function is not of type OrderedStruct nor String")

		variables.dbCursor.hint(index);
		
		return this;
	}
	
	
	/**
		Use snapshot mode for the query. Snapshot mode assures no duplicates are returned, 
		or objects missed, which were present at both the start and end of the query's execution 
		(if an object is new during the query, or deleted during the query, it may or may not be returned, 
		even with snapshot mode). Note that short query responses (less than 1MB) are always effectively 
		snapshotted. Currently, snapshot mode may not be used with sorting or explicit hints.
		
		http://www.mongodb.org/display/DOCS/How+to+do+Snapshotted+Queries+in+the+Mongo+Database
	*/
	DBCursor function snapshot()
	{
		variables.dbCursor.snapshot();
		
		return this;
	}
	
	
	/** 
		returns: 
		"cursor" : cursor type; 
		"nScanned" : number of records examined by the database for this query; 
		"n" : the number of records that the database returned;
		"millis" : how long it took the database to execute the query;
	*/
	struct function explain()
	{
		return structNew().putAll(variables.dbCursor.explain());
	}
	
	
	/**
		Limits the number of elements returned.
		Note: Specifying a negative number instructs the server to return that number of items 
			and to close the cursor. It will only return what can fit in a single 4mb response.
	*/
	DBCursor function limit(required numeric n)
	{
		variables.dbCursor.limit(javacast("int",n));
		
		return this;
	}
	
	
	/** Limits the number of elements returned in one batch */
	DBCursor function batchSize(required numeric n)
	{
		variables.dbCursor.batchSize(javacast("int",n));
		
		return this;
	}
	
	
	/** Discards a given number of elements at the beginning of the cursor. */
	DBCursor function skip(required numeric n)
	{
		variables.dbCursor.skip(javacast("int",n));
		
		return this;
	}
	
	
	/** The cursor (id) on the server; 0 = no cursor */
	numeric function getCursorId()
	{
		return variables.dbCursor.getCursorId();
	}
	
	
	/** kill the current cursor on the server */
	void function close()
	{
		variables.dbCursor.close();
	}
	
	
	DBCursor function slaveOk()
	{
		variables.dbCursor = variables.dbCursor.slaveOK();
		
		return this; 
	}
	

	/** for valid options, see: com.mongodb.Bytes */
	void function addOption(required numeric option)
	{
		variables.dbCursor.addOption(javaCast("int", option));
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	void function setOptions(required numeric options)
	{
		variables.dbCursor.setOptions(javaCast("int", options));
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	void function resetOptions()
	{
		variables.dbCursor.resetOptions();
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	numeric function getOptions()
	{
		return variables.dbCursor.getOptions();
	}
	
	
	numeric function numGetMores()
	{
		return variables.dbCursor.numGetMores();
	}
	
	
	array function getSizes()
	{
		return variables.dbCursor.getSizes();
	}
	
	
	numeric function numSeen()
	{
		return variables.dbCursor.numSeen();
	}
	
	
	boolean function hasNext()
	{
		return variables.dbCursor.hasNext();
	}
	
	
	struct function next()
	{
		return variables.dbCursor.next();
	}
	
	
	struct function curr()
	{
		return variables.dbCursor.curr();
	}
	
	
	void function remove()
	{
		return variables.dbCursor.remove();
	}
	
	
	/** pulls back all items into an array this is slow */
	numeric function length()
	{
		return variables.dbCursor.length();
	}
	
	
	/** Converts this cursor to an array.  If there are more than a given number of elements in the resulting array, only return the first min.
		@min the minimum size of the array to return
	*/
	array function toArray(numeric min)
	{
		return isNull(min) ? 
			variables.dbCursor.toArray() :
			variables.dbCursor.toArray(javacast("int",min)); 
	}
	
	
	// itcount - ignore
	
	
	/** Counts the number of elements matching the query this does NOT take limit/skip into consideration */
	numeric function count()
	{
		return variables.dbCursor.count();
	}
	
	
	/** Counts the number of elements matching the query this does take limit/skip into consideration */
	numeric function size()
	{
		return variables.dbCursor.size();
	}
	
	
	struct function getKeysWanted()
	{
		return variables.dbCursor.getKeysWanted();
	}
	
	
	struct function getQuery()
	{
		return variables.dbCursor.getQuery();
	}	
	
}