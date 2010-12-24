component 
{
	/**
		WARNING: this init function does not return an instance of DBRef.cfc!
		
		return a struct : { $ref = <collname>, $id = <idvalue>[, $db = <dbname>] }
		
		@collName collection name referenced (without the database name)
		@idvalue value of the _id field for the object referenced
		@dbname allows for references to documents in other databases
	*/
	struct function init(required string collName, required idvalue, string dbname)
	{
		if (!isInstanceOf(idvalue, "org.bson.types.ObjectId"))
			throw (message="Argument idvalue must be of java type org.bson.types.ObjectId, use objIdNew()");
		
		var dbRefStruct = {
			"$ref" = collName,
			"$id" = idvalue
		};
		
		if (structKeyExists(arguments,"dbname"))
			dbRefStruct["$db"] = dbname;
		
		return dbRefStruct;
	}

}