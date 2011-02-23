interface 
{
	boolean function hasNext();

	
	DocProxy function next();


	/** Counts the number of elements matching the query this does take limit/skip into consideration */
	numeric function size();
}