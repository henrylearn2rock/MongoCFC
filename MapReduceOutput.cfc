/** Proxy of <code>com.mongodb.MapReduceOutput</code> */
component accessors="true"
{
	/** com.mongodb.MapReduceOutput 
		@setter false
	*/
	property mapReduceOutput;
	
	/** @setter false */
	property DB db;
	
	
	package function init(required mapReduceOutput, required DB db)
	{
		variables.mapReduceOutput = mapReduceOutput;
		variables.db = db;
	}
	
	
	void function drop()
	{
		variables.mapReduceOutput.drop();
	}
	
	
	DBCollection function getOutputCollection()
	{
		var outputCollectionName = variables.mapReduceOutput.getOutputCollection().getName();
		
		return variables.db.getCollection(outputCollectionName);
	}
	
	
	DBCursor function results()
	{
		return new DBCursor(variables.mapReduceOutput.results(), db.getUtil());
	}
	
}