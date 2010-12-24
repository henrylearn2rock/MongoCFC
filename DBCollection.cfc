/** simulate syntax of db.collection in JS */
component accessors="true" 
{
	/** <code>com.mongodb.DB</code>
		@setter false 
	*/
	property dbCollection;

	/** @setter false */
	property DB db;

	/** @setter false */
	property Util util;	


	/** @dbCollection <code>com.mongodb.DB</code> */
	package function init(required dbCollection, required DB db)
	{
		variables.dbCollection = dbCollection;
		variables.db = db;
		variables.util = db.getUtil();
		
		return this;
	}
	

	/** 
		return <code>com.mongodb.WriteResult</code>
		
		@collection 'struct' or 'array', must use 'arrayList' to get '_id' fields back
		@concern    com.mongodb.WriteConcern
	*/
	function insert(required doc, concern)
	{
		if (!isNull(concern) && !isInstanceOf(concern, "com.mongodb.WriteConcern"))
			throw(message="argument concern must be of Java type com.mongodb.WriteConcern");
			
		if (isStruct(doc))
			return insertSingle(argumentCollection=arguments);
		
		if (isArray(doc))
			return insertMulti(argumentCollection=arguments);
		
		throw(message="argument 'doc' must be a struct or an array");
	}
	
	
	private function insertSingle(required struct doc, concern)
	{
		var dbObject = variables.util.toDBObject(doc, variables.db); 

		if (isNull(concern))
			concern = getWriteConcern();
		
		var writeResult = variables.dbCollection.insert(dbObject, concern);
		
		doc["_id"] = dbObject["_id"];
		
		return writeResult;
	}

	
	private function insertMulti(required array doc, concern)
	{
		var docLen = arrayLen(doc);
		
		for (var i = 1; i <= docLen; i++)
			if (!variables.util.isDBObject(doc[i]))
				doc[i] = variables.util.toDBObject(doc[i], variables.db);

		return isNull(concern) ? 
				variables.dbCollection.insert(doc) : 
				variables.dbCollection.insert(doc, concern);
	}
	
	
	/**
		return <code>com.mongodb.WriteResult</code>
		
		@criteria   query which selects the record to update
		@objNew     updated object or $ operators (e.g., $inc) which manipulate the object
		@upsert     if this should be an "upsert"; that is, if the record does not exist, insert it
		@multi      if all documents matching query should be updated
		@concern    com.mongodb.WriteConcern
	 */
	function update(struct criteria, required struct objNew, boolean upsert=false, boolean multi=false, concern)
	{
		if (isNull(criteria))
			criteria = {};
			
		criteria	= variables.util.toDBObject(criteria, variables.db);
		objNew 		= variables.util.toDBObject(objNew, variables.db);
		upsert 		= javacast("boolean", upsert);
		multi 		= javacast("boolean", multi);
		
		return isNull(concern) ? 
			variables.dbCollection.update(criteria, objNew, upsert, multi) : 
			variables.dbCollection.update(criteria, objNew, upsert, multi, concern);
	}
	

	/**
		return <code>com.mongodb.WriteResult</code>
		
		@query		query which selects the record to remove
		@concern    com.mongodb.WriteConcern
	 */
	function remove(struct query, concern)
	{
		if (isNull(query))
			query = {};
			
		query = variables.util.toDBObject(query, variables.db);
	
		return isNull(concern) ? 
			variables.dbCollection.remove(query) : 
			variables.dbCollection.remove(query, concern);
	}


	/** 
		@query   	query used to search
	 	@fields 	the fields of matching objects to return
		@limit      objects per batch sent back from the db (positive), hard limit (negative)
		@skip 		will not return the first <code>skip</code> matches
		@options    see Bytes QUERYOPTION_*
	*/
	DBCursor function find(struct query, struct fields, numeric limit=0, numeric skip=0, numeric options)
	{
		if (isNull(query))
			query = {};
		
		if (isNull(fields))
			fields = {};
		
		query = variables.util.toDBObject(query, variables.db);
		fields = variables.util.toDBObject(fields);
		
		var dbCursor = isNull(options) ?
			variables.dbCollection.find(query, fields, skip, limit) : 
			variables.dbCollection.find(query, fields, skip, limit, options);
		
		return new DBCursor(dbCursor, variables.util);
	}
	
	
	/** 
		return the object found, or null if no such object exists
		@query struct, ObjectID or String.  String will be wrapped by {"_id":string} 
	*/
	function findOne(query, struct fields)
	{	
		if (isNull(query))
			query = {};
		else if (variables.util.isObjectID(query))
			query = {"_id"=query};
		else if (isSimpleValue(query))
			query = {"_id"=variables.util.objectIdNew(query)};
		
		if (isNull(fields))
			fields = {};
		
		query = variables.util.toDBObject(query, variables.db);
		fields = variables.util.toDBObject(fields);
		
		return variables.dbCollection.findOne(query, fields);
	}
	

	/** This command can be used to atomically modify a document (at most one) and return it. 
	    Note that, by default, the document returned will not include the modifications made on the update.
		
		Returns Null if query returns nothing 
	
		@query a filter for the query
		@sort if multiple docs match, choose the first one in the specified sort order as the object to manipulate
		@remove set to a true to remove the object before returning 
		@update a modifier object
		@new set to true if you want to return the modified object rather than the original. Ignored for remove
		@fields see <a href="http://www.mongodb.org/display/DOCS/Retrieving+a+Subset+of+Fields">Retrieving a Subset of Fields</a> (1.5.0+)
		@upsert create object if it doesn't exist
	*/
	function findAndModify(	struct query,
									struct fields,
									struct sort,
									struct update,
									boolean remove = false,
									boolean new = false,
									boolean upsert = false)
	{
		if (!isNull(sort) && !(variables.util.isOrderedStruct(sort) || structCount(sort) <= 1))
			throw (message="The sort argument passed to the findAndModify function is not of type OrderedStruct");
				
		return variables.dbCollection.findAndModify(
			isNull(query)	? javacast("null","") : variables.util.toDBObject(query, variables.db), 
			isNull(fields) 	? javacast("null","") : variables.util.toDBObject(fields), 
			isNull(sort) 	? javacast("null","") : variables.util.toDBObject(sort), 
			javacast("boolean", remove), 
			isNull(update) 	? javacast("null","") : variables.util.toDBObject(update, variables.db), 
			javacast("boolean", new), 
			javacast("boolean", upsert));
	}
	

	/**
		@options should be a struct with these possible fields: name, unique, dropDups
	 */
	void function ensureIndex(required struct keys, struct options)
	{
		if (!(variables.util.isOrderedStruct(keys) || structCount(keys) <= 1))
			throw (message="'keys' must be 'OrderedStruct' for more than 1 key");

		keys = variables.util.toDBObject(keys);
		
		if (isNull(options))
			options = {};
			
		options = variables.util.toDBObject(options);
		
		variables.dbCollection.ensureIndex(keys, options);
	}
	
	
	void function resetIndexCache()
	{
		variables.dbCollection.resetIndexCache();
	}


	string function genIndexName(required struct keys)
	{
		variables.dbCollection.genIndexName(variables.util.toDBObject(keys));
	}

	
	/** set hint fields for this collection */
	void function setHintFields(required array structs)
	{
		structs = variables.util.javaTyped(structs);
		
		var structsLen = arraylen(structs);
		
		for (var i=1; i<=structsLen; i++)
			structs[i] = variables.util.dbObjectNew(structs[i]);
		
		variables.dbCollection.setHintFields(structs);
	}
	
	
	/** Adds the "private" fields _id to an object */
	function apply(required struct obj, boolean ensureID=true)
	{
		obj = variables.util.toDBObject(obj);
		ensureID = javacast("boolean", ensureID);
		
		return variables.dbCollection.apply(obj, ensureID);
	}
	
	
	/**
		@object
		@concern com.mongodb.WriteConcern
	 */
	function save(required struct object, concern)
	{
		var dbObject = variables.util.toDBObject(object, variables.db);

		var writeResult = isNull(concern) ? 
			variables.dbCollection.save(dbObject) : 
			variables.dbCollection.save(dbObject, concern);
			
		object["_id"] = dbObject["_id"];
				
		return writeResult;
	}
	

	void function dropIndexes(string name)
	{
		if (structKeyExists(arguments,"name"))
			variables.dbCollection.dropIndexes(name);
		else
			variables.dbCollection.dropIndexes();
	}
	

	void function drop()
	{
		variables.dbCollection.drop();
	}
	
	
	
	numeric function count(struct query)
	{
		if (isNull(query))
			query = {};
		
		query = variables.util.toDBObject(keys, variables.db);
		
		return variables.dbCollection.count(query);
	}
	
	
	numeric function getCount(struct query, struct fields, numeric limit=0, numeric skip=0)
	{
		query = isNull(query) ? variables.util.dbObjectNew({}) : variables.util.toDBObject(query, variables.db);
		fields = isNull(fields) ? variables.util.dbObjectNew({}) : variables.util.toDBObject(fields);
		limit = javacast("long", limit);
		skip = javacast("long", skip);
		
		return variables.dbCollection.getCount(query, fields, limit, skip);
	}
	
	
	//TODO: support (dropTarget) like in shell
	DBCollection function renameCollection(required string newName)
	{
		var dbCollection = new DBCollection(variables.dbCollection.rename(newName)); 
		
		dbCollection.setUtil(variables.util);
		
		return dbCollection;
	}
	
	/**
		@key { a : true }
		@cond optional condition on query
		@reduce javascript reduce function
		@initial initial value for first match on a key
	*/
	struct function group(struct key, struct initial, string reduce="", struct cond)
	{
		key = isNull(key) ? variables.util.dbObjectNew({}) : variables.util.toDBObject(key);
		initial = isNull(initial) ? variables.util.dbObjectNew({}) : variables.util.toDBObject(initial);
		cond = isNull(cond) ? variables.util.dbObjectNew({}) : variables.util.toDBObject(cond, variables.db);
		
		return variables.dbCollection.group(key, cond, initial, reduce);
	}
	
	
	array function distinct(required string key, struct query)
	{
		return isNull(query) ? 
			variables.dbCollection.distinct(key) 
			: variables.dbCollection.distinct(key, variables.util.toDBObject(query, toDBObject)); 
	}
	
	
	MapReduceOutput function mapReduce(required struct command)
	{
		var mapReduceOutput = variables.dbCollection.mapReduce(variables.util.toDBObject(command));
		
		return new MapReduceOutput(mapReduceOutput, variables.db);
	}
	
	
	array function getIndexes()
	{
		return variables.dbCollection.getIndexInfo();
	}

	
	void function dropIndex(string name, struct keys)
	{
		if (!isNull(keys))
			variables.dbCollection.dropIndex(variables.util.toDBObject(keys));
		else if (!isNull(name))
			variables.dbCollection.dropIndex(name);
		else
			throw (message="must pass in 'keys' or 'name'");
	}
	
	
	/** returns <a href="http://api.mongodb.org/java/current/com/mongodb/CommandResult.html"><code>com.mongodb.CommandResult</code></a> */
	struct function stats()
	{
		var stats = {};
		
		stats.putAll(variables.dbCollection.getStats());
		
		return stats;
	}
	
	
	boolean function isCapped()
	{
		return variables.dbCollection.isCapped();
	}

	
	DBCollection function getCollection(required string n)
	{
		var dbCollection = new DBCollection(variables.dbCollection.getCollection(n));
		
		dbCollection.setUtil(variables.util);
		
		return dbCollection;
	}
	
	
	/** Returns the name of this collection. */
	string function getName()
	{
		return variables.dbCollection.getName();
	}
	
	/** Returns the full name of this collection, with the database name as a prefix. */
	string function getFullName()
	{
		return variables.dbCollection.getFullName();
	}
	
		
	//setObjectClass
	//getObjectClass
	//setInteralClass
	//getInternalClass

	/**
		@concern <a href="http://api.mongodb.org/java/current/com/mongodb/WriteConcern.html"><code>com.mongodb.WriteConcern</code></a>
	 */
	void function setWriteConcern(required writeConcern)
	{
		if(!isInstanceOf(writeConcern, "com.mongodb.WriteConcern"))
			throw(message="argument concern must be of Java type com.mongodb.WriteConcern");
			
		variables.dbCollection.setWriteConcern(writeConcern);
	}


	function getWriteConcern()
	{
		return variables.dbCollection.getWriteConcern();
	}


	void function slaveOK()
	{
		variables.dbCollection.slaveOK();
	}


	/** for valid options, see: com.mongodb.Bytes */
	void function addOption(required numeric option)
	{
		variables.dbCollection.addOption(javaCast("int", option));
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	void function setOptions(required numeric options)
	{
		variables.dbCollection.setOptions(javaCast("int", options));
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	void function resetOptions()
	{
		variables.dbCollection.resetOptions();
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	numeric function getOptions()
	{
		return variables.jMongo.getOptions();
	}
	


	// functions in Mongo Shell, but not in Java driver
	
	struct function runCommand(required string cmd)
	{
		var command = {};
		
		command[cmd] = variables.dbCollection.getName();
		
		return variables.db.runCommand(command);
	}


	void function reIndex()
	{
		variables.db.runCommand({"reIndex"=variables.dbCollection.getName()});
	}
	

	numeric function dataSize()
	{
		return variables.dbCollection.getStats()["size"];
	}
	
	
	numeric function storageSize()
	{
		return variables.dbCollection.getStats()["storageSize"];
	}
	
	
	numeric function totalIndexSize()
	{
		return variables.dbCollection.getStats()["totalIndexSize"];
	}
	
	
	numeric function totalSize()
	{
		var stats = variables.dbCollection.getStats();
		
		return stats["storageSize"] + stats["totalIndexSize"];
	}
	
	
	struct function validate()
	{
		return variables.db.runCommand({"validate"=variables.dbCollection.getName()});
	}
	
}