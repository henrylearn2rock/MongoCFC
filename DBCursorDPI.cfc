component implements="IDocProxyIterator" 
{
	property DBCursor dbCursor;
	property DocProxy docProxy;
	
	
	function init(required DBCursor dbCursor, required DocProxy docProxy)
	{
		variables.dbCursor = dbCursor;
		variables.docProxy = docProxy;
		
		return this;
	}


	boolean function hasNext()
	{
		return variables.dbCursor.hasNext();		
	}

	
	DocProxy function next()
	{
		var doc = variables.dbCursor.next();
		
		docProxy.setMemento(doc);
		
		return docProxy;
	}


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
	
}