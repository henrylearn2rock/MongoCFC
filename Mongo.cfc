/**
	Proxy of <a href="http://api.mongodb.org/java/current/com/mongodb/Mongo.html"><code>com.mongodb.Mongo</code></a> 
 */
component accessors="true"
{
	/** com.mongodb.Mongo*/
	property name="mongo" setter="false";
	
	/** @setter false */
	property Util util;
	
	
	/**
		@replicaSetSeeds Array of com.mongodb.ServerAddress
	 */
	Mongo function init(string host="127.0.0.1", numeric port=27017, array replicaSetSeeds)
	{
		if (isNull(replicaSetSeeds))
			variables.mongo = createObject("java","com.mongodb.Mongo").init(host, port);
		else
			variables.mongo = createObject("java","com.mongodb.Mongo").init(replicaSetSeeds);
		
		variables.util = new Util();
		
		return this;
	}

	
	DB function getDB(required String dbname)
	{
		return new DB(variables.mongo.getDB(dbName), this);
	}
	
	
	array function getDatabaseNames()
	{
		return variables.mongo.getDatabaseNames();
	}
	
	
	void function dropDatabase(required string dbName)
	{
		variables.mongo.dropDatabase(dbName);
	}
	
	
	string function getVersion()
	{
		return variables.mongo.getVersion();
	}
	
	
	string function debugString()
	{
		return variables.mongo.debugString();
	}
	
	
	string function getConnectPoint()
	{
		return variables.mongo.getConnectPoint();
	}

	
	/** returns com.mongodb.ServerAddress */
	function getAddress()
	{
		return variables.mongo.getAddress();
	}
	
	
	/** returns array of com.mongodb.ServerAddress */
	array function getAllAddress()
	{
		return variables.mongo.getAllAddress();
	}
	
	
	void function close()
	{
		variables.mongo.close();
	}
	
	
	/** @writeConcern see: <a href="http://api.mongodb.org/java/current/com/mongodb/WriteConcern.html"><code>com.mongodb.WriteConcern</code></a> */
	void function setWriteConcern(required writeConcern)
	{
		variables.mongo.setWriteConcern(writeConcern);
	}
	
	
	/** returns: <a href="http://api.mongodb.org/java/current/com/mongodb/WriteConcern.html"><code>com.mongodb.WriteConcern</code></a> */
	function getWriteConcern()
	{
		return variables.mongo.getWriteConcern();
	}
	
	
	void function slaveOk()
	{
		variables.mongo.slaveOk();
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	void function addOption(required numeric option)
	{
		variables.mongo.addOption(javaCast("int", option));
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	void function setOptions(required numeric options)
	{
		variables.mongo.setOptions(javaCast("int", options));
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	void function resetOptions()
	{
		variables.mongo.resetOptions();
	}
	
	
	/** for valid options, see: com.mongodb.Bytes */
	numeric function getOptions()
	{
		return variables.mongo.getOptions();
	}
	
}