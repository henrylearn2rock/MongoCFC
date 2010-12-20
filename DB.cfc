/**
	Adaptor of <a href="http://api.mongodb.org/java/current/com/mongodb/DB.html"><code>com.mongodb.DB</code></a>  
*/
component accessors="true" 
{
	/** com.mongodb.DB (java)
		@setter false 
	*/
	property db;
	
	/** @setter false */
	property Mongo mongo;
	
	/** @setter false */
	property Util util;	


	/** @db com.mongodb.DB (java) */
	package DB function init(required db, required Mongo mongo)
	{
		variables.db = db;
		variables.mongo = mongo;
		variables.util = mongo.getUtil();
		
		return this;
	}


	DBCollection function getCollection(required String name)
	{
		var dbCollection = variables.db.getCollection(name);
		
		return new DBCollection(dbCollection, this);
	}

	
	DBCollection function createCollection(required string name, required struct options)
	{
		var dbCollection = variables.db.createCollection(name, variables.util.toDBObject(options));
		
		return new DBCollection(dbCollection, this);
	}


	/** Returns a collection matching a given string */
	DBCollection function getCollectionFromString(required String s)
	{
		var dbCollection = variables.db.getCollectionFromString(s);

		return new DBCollection(dbCollection, this);
	}

	
	/** 
		<a href="http://www.mongodb.org/display/DOCS/Commands">Mongo Commands</a>
		returns com.mongodb.CommandResult 
		@cmd typed orderedStruct or string
		@options see: 
	*/
	struct function runCommand(required cmd, numeric options)
	{
		if (isSimpleValue(cmd))
			local.commandResult = variables.db.command(cmd);
		else if (variables.util.isOrderedStruct(cmd) || (isStruct(cmd) && structCount(cmd) <= 1))
		{
			cmd = variables.util.toDBObject(cmd);
			
			local.commandResult = isNull(options) ? 
				variables.db.command(cmd) : 
				variables.db.command(cmd, options);
		}
		else
			throw (message="'cmd' must be String or OrderedStruct");
		
		return commandResult;
	}

	
	struct function doEval(required string code, array args)
	{
		if (isNull(args))
			args = [];
			
		return variables.db.doEval(code, args);
	}
	

	function eval(required string code, args)
	{
		if (isNull(args))
			args = [];

		return variables.db.eval(code, args);
	}
	
	
	struct function getStats()
	{
		return variables.db.getStats();
	}
	
	
	string function getName()
	{
		return variables.db.getName();
	}
	
	
	void function setReadOnly(required boolean isReadOnly)
	{
		variables.db.setReadOnly(javaCast("boolean", isReadOnly));
	}


	array function getCollectionNames()
	{
		return variables.db.getCollectionNames();
	}
	
	
	boolean function collectionExists(required string collectionName)
	{
		return variables.db.collectionExists(collectionName);
	}
	
	
	void function resetIndexCache()
	{
		variables.db.resetIndexCache();
	}
	
	
	/** returns com.mongodb.CommandResult */
	struct function getLastError(numeric w, numeric wtimeout, boolean fsync)
	{
		if (isNull(w) || isNull(wtimeout) || isNull(fsync))
			local.lastError = variables.db.getLastError(); 
		else
		{
			w = javaCast("int", w);
			wtimeout = javaCast("int", wtimeout);
			fsync = javaCast("boolean", fsync);
			
			local.lastError = variables.db.getLastError(w, wtimeout, fsync);
		}
		
		return local.lastError;
	}
	
	
	/**
		@concern <a href="http://api.mongodb.org/java/current/com/mongodb/WriteConcern.html"><code>com.mongodb.WriteConcern</code></a>
	 */
	void function setWriteConcern(required concern)
	{
		variables.db.setWriteConcern(concern);
	}
	
	
	function getWriteConcern()
	{
		return variables.db.getWriteConcern();
	}
	
	
	
	void function dropDatabase()
	{
		variables.db.dropDatabase();
	}
	
	
	boolean function isAuthenticated()
	{
		return variables.db.isAuthenticated();
	}
	

	boolean function authenticate(required string username, required password)
	{
		return variables.db.authenticate(username, password.toCharArray());
	}

	
	void function addUser(required string username, required string password)
	{
		return variables.db.addUser(username, password.toCharArray());
	}
	
	
	struct function getPreviousError()
	{
		return variables.db.getPreviousError();
	}
	
	
	void function resetError()
	{
		variables.db.resetError();
	}
	
	
	void function forceError()
	{
		variables.db.forceError();
	}
	
	
	DB function getSisterDB(required String name)
	{
		return variables.mongo.getDB(name);
	}
	

	void function slaveOK()
	{
		variables.db.slaveOK();
	}

	/** for valid options, see: com.mongodb.Bytes */
	void function addOption(required numeric option)
	{
		variables.db.addOption(javaCast("int", option));
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	void function setOptions(required numeric options)
	{
		variables.db.setOptions(javaCast("int", options));
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	void function resetOptions()
	{
		variables.db.resetOptions();
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	numeric function getOptions()
	{
		return variables.db.getOptions();
	}
	
}