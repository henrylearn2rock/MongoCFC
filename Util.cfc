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
	struct function orderedStructNew(Struct struct)
	{
		return isNull(struct) ? 
			createObject("java","java.util.LinkedHashMap").init() :
			createObject("java","java.util.LinkedHashMap").init(struct);
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
					key = replaceList(lcase(key), "$addtoset,$pushall,$putall", "$addToSet,$pushAll,$putAll");
			
				var value = obj[key];
				
				if (isStruct(value) || isArray(value))
					value = dbObjectNew(value);
				
				dbObject[key] = value;
			}

			return dbObject;
		}
		else if (isArray(obj))
		{
			var dbObject = createObject("java", "com.mongodb.BasicDBList").init();
			
			for (local.item in obj)
			{
				if (isStruct(item) || isArray(item))
					item = dbObjectNew(item);
			
				arrayAppend(dbObject, item);
			}

			return dbObject;
		}

		return obj;
	}
	

	boolean function isDBObject(required obj)
	{
		return isInstanceOf(obj, "com.mongodb.DBObject");
	}


	function toDBObject(required Struct struct)
	{
		return dbObjectNew( boxObjectID( javaTyped(struct) ) );
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
		if (!structKeyExists(obj, "_id"))
			throw (message="timestamp not available")
		
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
			Stromg  -> java.lang.String (unchanged).
			Numeric -> double, int or long.
			Boolean -> boolean.
			Date    -> java.util.Date (unchanged).
			Array   -> convert items into Java's equivalent.
			Struct  -> convert items into Java's equivalent.
			UDF		-> null.
	*/
	function javaTyped(obj)
	{
		if (isNull(obj) || isCustomFunction(obj))
			return;
		
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

		if (isArray(obj))
		{
			for (var i = 1; i <= arrayLen(obj); i++)
				obj[i] = javaTyped(obj[i]);
			
			return obj;
		}
		
		if (isStruct(obj))
		{
			for (local.k in obj)
				obj[k] = javaTyped(obj[k]);
			
			return obj;
		}
		
		// String and other non-CF types
		return obj;		
	}
	
	
}
