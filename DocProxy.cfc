/** Proxy for adding behaviour to doc.  Must override hasProperty() */
component 
{
	variables.instance = {};
	
	function getID()
	{
		if (structKeyExists(variables.instance, "_id"))
			return variables.instance["_id"].toString();
	}
	
	
	/** @id of type ObjectID */
	function setID(required id)
	{
		if (!isInstanceOf(id, "org.bson.types.ObjectId"))
			throw ("argument 'id' it not of type 'org.bson.types.ObjectId'");
			
		variables.instance["_id"] = id;
	}


	boolean function hasField(required string fieldName)
	{
		return structKeyExists(variables.instance, ucase(fieldName));
	}
	
	
	function getField(required string fieldName)
	{
		return variables.instance[ucase(fieldName)];
	}
	
	
	void function setField(required string fieldName, required value)
	{
		variables.instance[ucase(fieldName)] = value;
	}


	/** Generic property getter / setter.  Return null if property not yet defined */
	function onMissingMethod(required string missingMethodName, required struct missingMethodArguments)
	{
		if (len(missingMethodName) > 3)
		{
			var property = ucase(missingMethodName.subString(3));
			
			if (hasProperty(property))
			{
				if (lcase(missingMethodName).startsWith("get") && structCount(missingMethodArguments) == 0)
				{
					if (structKeyExists(variables.instance, property))
						return variables.instance[property];
					else
						return;
				}
				else if (lcase(missingMethodName).startsWith("set") && structCount(missingMethodArguments) == 1)
				{
					variables.instance[property] = missingMethodArguments[1];
					return this;			// for chaining
				}
			}
		}
		
		throw (message="cannot handle method '#missingMethodName#' with #structCount(missingMethodArguments)# argument(s)");
	}


	private void function postSetMemento()
	{
		// do nothing, override this if needed
	}

	void function setMemento(required struct memento)
	{
		variables.instance = memento;
		postSetMemento();
	}
	

	private void function preGetMemento()
	{
		// do nothing, override this if needed
	}
	

	struct function getMemento()
	{
		preGetMemento();
		return variables.instance;	
	}
	

	private boolean function hasProperty(required string property)
	{
		var metadata = getMetadata(this);
	
		if (!structKeyExists(metadata, "propertyNames"))
		{
			lock name="staticVarInit#metadata.name#" timeout="10" type="exclusive"
			{
				metadata.propertyNames = {};
				
				for (var i = 1; i <= arrayLen(metadata.properties); i++)	// cannot use for...in loop here
					metadata.propertyNames[metadata.properties[i].name] = 0;
			}
		}	
		
		return structKeyExists(metadata.propertyNames, property);	
	}


	Date function getTimestamp()
	{
		if (!structKeyExists(variables.instance, "_id"))
			throw (message="timestamp not available because '_id' field is not available");
		
		return createObject("java", "java.util.Date").init(variables.instance["_id"].getTime());
	}

}