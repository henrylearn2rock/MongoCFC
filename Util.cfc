component
{
	/** return <code>java.util.ArrayList</code> that enables passed-by-reference in ColdFusion */
	array function arrayListNew(Array array)
	{
		return isNull(array) ? 
			createObject("java","java.util.ArrayList").init() :
			createObject("java","java.util.ArrayList").init(array);
	}
	
	
	boolean function isArrayList(obj)
	{
		return isNull(obj) ? false : isInstanceOf(obj, "java.util.ArrayList");
	}


	/** return <code>java.util.LinkedHashMap</code> that preserves order of insertion */
	struct function orderedStructNew()
	{
		return createObject("java","java.util.LinkedHashMap").init();
	}
	
	
	boolean function isOrderedStruct(obj)
	{
		return !isNull(obj) && isInstanceOf(obj, "java.util.LinkedHashMap");
	}
	
	
	/** return <code>org.bson.types.ObjectId</code> */
	function objectIdNew(string id)
	{
		return isNull(id) ? 
			createObject("java","org.bson.types.ObjectId").init() :
			createObject("java","org.bson.types.ObjectId").init(id);
	}


	boolean function isObjectID(obj)
	{
		return isNull(obj) ? false : isInstanceOf(obj, "org.bson.types.ObjectId");
	}
	

	function dbObjectNew(required obj)
	{
		if (isStruct(obj))
		{
			var dbObject = createObject("java", "com.mongodb.BasicDBObject").init();
			
			for (local.key in obj)
			{
				// convert '_id' and Modifier Operations into the correct case
				if (compareNoCase(key,"_ID")==0)
					key = "_id";
				else if (key.startsWith("$"))
					key = replaceList(lcase(key), "$addtoset,$pushall,$putall,$maxdistance", "$addToSet,$pushAll,$putAll,$maxDistance");
			
				if (!structKeyExists(obj, key))
					dbObject[key] = javacast("null","");
				else
				{
					var value =  obj[key];
					
					if (isStruct(value) || (isArray(value) && !isBinary(value)))
						value = dbObjectNew(value);
				
					dbObject[key] = value;
				} 
			}

			return dbObject;
		}
		else if (isArray(obj))
		{
			var dbObject = createObject("java", "com.mongodb.BasicDBList").init();
			
			for (local.item in obj)
			{
				if (isNull(item))
					arrayAppend(dbObject, javacast("null",""));
				else 
				{
					if (isStruct(item) || (isArray(item) && !isBinary(item)))
						item = dbObjectNew(item);
			
					arrayAppend(dbObject, isNull(item) ? javacast("null","") : item);
				}
			}

			return dbObject;
		}

		return obj;
	}
	

	boolean function isDBObject(obj)
	{
		return !isNull(obj) && isInstanceOf(obj, "com.mongodb.DBObject");
	}

	
	/** search for struct with key '$ref' and create DBRef objects for the struct */
	struct function toDBRef(required struct obj, required DB db)
	{
		var searchResults = structFindKey(obj, "$ref", "all");
		
		for (local.result in searchResults)
		{
			var dbRefStruct = result.owner;
			var dbRef = createObject("java","com.mongodb.DBRef").init(db.getDB(), dbRefStruct["$ref"], dbRefStruct["$id"]);
			
			var path = left(result.path, len(result.path) - len(".$ref"));		// path of struct that contains $ref 
			
			evaluate("obj#path# = dbRef");
		}
		
		return obj;
	}
	
	
	/** @db passed in to resolve DBRef */
	struct function toDBObject(required Struct struct, DB db)
	{
		javaTyped(struct);
		
		return isNull(db) ? dbObjectNew(struct) : dbObjectNew( toDBRef(struct, db) );
	}


	/** convert key "_id" from string to ObjectID */
	struct function boxObjectID(required struct obj)
	{
		if (obj.containsKey("_id") && isSimpleValue(obj["_id"]))
			obj["_id"] = objectIdNew(obj["_id"]);
		
		return obj;
	}
	
	
	/** convert key "_id" from ObjectID to string */
	struct function unboxObjectID(required struct obj)
	{
		if (obj.containsKey("_id") && isObjectID(obj["_id"]))
			obj["_id"] = obj["_id"].toString();
		
		return obj;
	}
	
	
	Date function getTimestamp(required struct obj)
	{
		if (!structKeyExists(obj, "_id") || !isObjectID(obj["_id"]))
			throw (message="timestamp not available from '_id'");
		
		return createObject("java", "java.util.Date").init(obj["_id"].getTime());
	}

	

	/** 
		return <code>java.util.regex.Pattern</code>
		@flags List or Array of 'CANON_EQ', 'CASE_INSENSITIVE', 'COMMENTS', 'DOTALL', 'LITERAL', 'MULTILINE', 'UNICODE_CASE', 'UNIX_LINES'  
	*/
	function reCompile(required String regex, flags)
	{
		var pattern = createObject("java","java.util.regex.Pattern");
		
		if (isNull(flags))
			local.compiled = pattern.compile(regex);
		else
		{
			if (isSimpleValue(flags))
				flags = listToArray(flags);
	
			var flagInt = 0;
			
			for (local.flagName in flags)
				flagInt += pattern[flagName];
			
			local.compiled = pattern.compile(regex, javacast("int", flagInt));
		}
		
		return local.compiled;
	}
	

	/** convert ColdFusion variable type into Java's equivalent.
			String  	-> java.lang.String (unchanged).
			Numeric 	-> double, int or long.
			Boolean 	-> boolean.
			Date    	-> java.util.Date (unchanged).
			Array   	-> convert items into Java's equivalent.
			Struct  	-> convert items into Java's equivalent.
			GUID/UUID 	-> java.util.UUID
			UDF			-> null.
	*/
	function javaTyped(obj)
	{
		if (isNull(obj) || isCustomFunction(obj))
			return;
		
		if (isSimpleValue(obj))
		{
			if (isNumeric(obj))
			{
				if (obj != int(obj)) 
					return javacast("double", obj);
	
				// between java.lang.Integer.MIN_VALUE and java.lang.Integer.MAX_VALUE
				if (-2147483648 <= obj && obj <= 2147483647)
					return javacast("int", obj);
	
				return javacast("long", obj); 
			}
			
			if (isBoolean(obj))
				return javaCast("boolean", obj);

			if (isValid("UUID", obj))
				return createObject("java","java.util.UUID").fromString(insert('-', obj, 23));
		
			if (isValid("GUID", obj))
				return createObject("java","java.util.UUID").fromString(obj);
			
			// isDate disabled. Too slow, and not very useful
			
			//if (isDate(obj))
			//	return dateAdd("n", 0, obj);
		}

		if (isArray(obj) && !isBinary(obj))		// binary is an array in CF :S
		{
			for (var i = 1; i <= arrayLen(obj); i++)
				obj[i] = arrayIsDefined(obj, i) ? javaTyped(obj[i]) : javacast("null", "");
			
			return obj;
		}
		
		if (isStruct(obj))
		{
			for (local.k in obj)
				obj[k] = structKeyExists(obj, k) ? javaTyped(obj[k]) : javacast("null", "");					
			
			return obj;
		}
		
		// String and other non-CF types
		return obj;
	}
	
}
