<style>
*{
	font-family: sans-serif;
}
h2{
	color: navy;
}
</style>

<cfscript>
	import com.mongoCFC.*;

	//initialize the core cfmongodb Mongo object
	mongo = new Mongo();
	db = mongo.getDB("test");

	//we'll create/use a 'people' collection
	people = db.getCollection("people");
	
	//clear out the collection so we always start fresh, for demo purposes
	people.remove();


	//here's how to insert one document
	doc =
		{
			NAME = "Marc",
			SPOUSE = "Heather",
			KIDS = [
				{NAME="Alexis", AGE=7, HAIR="blonde", DESCRIPTION="crazy" },
				{NAME="Sidney", AGE=2, HAIR="dirty blonde", DESCRIPTION="ornery" }
			],
			BIKE = "Felt",
			LOVESSQL = true,
			LOVESMONGO = true,
			TS = now(),
			COUNTER = 1
		};

	people.insert(doc);
	
	writeDump( var=doc, label="Saved document", expand="false" );

	/*
	* VERY IMPORTANT: ColdFusion will automatically uppercase struct keys if you do not quote them. Consequently, the document will be stored
	* in MongoDB with upper case keys. Below, where we search, we MUST use uppercase keys.
	*
	* at the shell, mongo.find({name:'Marc'}) != mongo.find({NAME: 'Marc'})
	*/


	//here's how to insert multiple documents
	coolPeople = [];
	for( i = 1; i LTE 5; i++ ){
		DOC =
		{
			NAME = "Cool Person #i#",
			SPOUSE = "Cool Spouse #i#",
			KIDS = [
					{NAME="kid #i#", age=randRange(1,80), HAIR="strawberry", DESCRIPTION="fun" },
					{NAME="kid #i+1#", age=randRange(1,80), HAIR="raven", DESCRIPTION="joyful" }
			],
			BIKE = "Specialized",
			TS = now(),
			COUNTER = i
		};
		arrayAppend( coolPeople, doc );
	}

	people.insert(coolPeople);
	

	//find Marc
	marc = people.find({NAME="Marc"});
	showResult( marc, "Marcs" );


	//find riders of Specialized bikes
	specialized = people.find({BIKE="Specialized"});
	
	showResult( specialized, "Specialized riders" );

	//find the 3rd and 4th Specialized bike riders, sorted by "ts" descending
	
	specialized = people.find(query={BIKE="Specialized"}, skip=2, limit=2).sort({TS=-1});
	
	showResult( specialized, "Specialized riders, skipping to 3, limiting to 2, sorting by ts desc (skip is 0-based!)" );

	//find riders with counter between 1 and 3, sorted by "ts" descending
	specialized =  people.find({BIKE="Specialized",COUNTER={$gte=1,$lte=3}}).sort({TS=-1});
	showResult( specialized, "Specialized riders, COUNTER between 1 and 3" );

	//find riders with counter between 1 and 3 Exclusive, sorted by "ts" descending
	specialized =  people.find({BIKE="Specialized",COUNTER={$gt=1,$lt=3}}).sort({TS=-1});
	showResult( specialized, "Specialized riders, COUNTER between 1 and 3 Exclusive" );



	//find people with kids aged between 2 and 30
	kidSearch = people.find({"KIDS.AGE"={$gte=2,$lte=30}}, {name=1,counter=1,kids=1}).sort({COUNTER=-1});
	showResult( kidSearch, "People with kids aged between 2 and 30" );
	

	//find a document by ObjectID... note that it returns the document, NOT a SearchResult object; here, we'll "spoof" what your app would do if the id were in the URL scope
	url.personId = specialized.toArray()[1]["_id"].toString();
	
	byID = people.findOne(url.personId);
	writeOutput("<h2>Find by ID</h2>");
	writeDump(var=byID, label="Find by ID: #url.personID#", expand="false");
	
	//using count()


	//here's how to update. You'll generally do two kinds of updating:
	// 1) updating a single pre-fetched document... this is the most common. It's a find/modify/resave
	// 2) updating one or more documents based on criteria. You almost always need to use a $set in this situation!!!

	//updating a single pre-fetched document
	
	person = people.findOne();
	person.FAVORITECIGAR = "H. Upmann Cubano";
	person.MODTS = now();
	arrayAppend( person.KIDS, {NAME = "Pauly", AGE = 0} );
	
	people.update(objNew=person);

	writeOutput("<h2>Updated Person</h2>");
	writeDump( var=person, label="updated person", expand="false");
	
	//updating a single document.
	person = {NAME = "Ima PHP dev", AGE=12};
	people.save(person);

	people.update({NAME = "Ima PHP dev"}, {$set={NAME = "Ima CF Dev", HAPPY = true}});
	afterUpdate = people.findOne(person["_id"]);


//	afterUpdate = people.findAndModify(
//		query={NAME = "Ima PHP dev"}, 
//		update={$set={NAME="Ima CF dev",HAPPY=true}},
//		new=true);

	writeOutput("<h2>>Updated person by criteria</h2>");
	writeDump(var = person, label="Original", expand=false);
	writeDump(var = afterUpdate, label = "After update", expand=false);


	//updating a single document based on criteria and overwriting instead of updating
	person = {NAME = "Ima PHP dev", AGE=12};
	people.save( person );

	people.update({NAME = "Ima PHP dev"}, {NAME = "Ima CF Dev", HAPPY = true});
	afterUpdate = people.findOne( person["_id"]);

	writeOutput("<h2>Updated person by criteria. Notice it OVERWROTE the entire document</h2>");
	writeDump(var = person, label="Original", expand=false);
	writeDump(var = afterUpdate, label = "After update without using $set", expand=false);


	//updating multiple documents
	people.insert([
		{NAME = "EmoHipster", AGE=16},
		{NAME = "EmoHipster", AGE=15},
		{NAME = "EmoHipster", AGE=18}
	]);

	people.update(criteria={NAME = "EmoHipster"},
				  objNew ={$set={NAME = "Oldster",AGE=76, REALIZED="tempus fugit"}},
				  multi =true);
	
	oldsters = people.find({NAME="Oldster"}).toArray();

	writeOutput("<h2>Updating multiple documents</h2>");
	writeDump( var=oldsters, label="Even EmoHipsters get old some day", expand="false");
	
	//perform an $inc update
	cast = [{NAME = "Wesley", LIFELEFT=50, TORTUREMACHINE=true},
		{NAME = "Spaniard", LIFELEFT=42, TORTUREMACHINE=false},
		{NAME = "Giant", LIFELEFT=6, TORTUREMACHINE=false},
		{NAME = "Poor Forest Walker", LIFELEFT=60, TORTUREMACHINE=true}];

	people.insert(cast);

	suckLifeOut = {"$inc" = {LIFELEFT = -1}};
	victims = {TORTUREMACHINE = true};
	
	people.update(	criteria=victims, 
					objNew=suckLifeOut,
					multi=true);
	
	rugenVictims = people.find({TORTUREMACHINE=true}).toArray(); 

	writeOutput("<h2>Atomically incrementing with $inc</h2>");
	writeDump( var = cast, label="Before the movie started", expand=false);
	writeDump( var = rugenVictims, label="Instead of sucking water, I'm sucking life", expand=false);


	//Upserting
	doc = {
		NAME = "Marc",
		BIKE = "Felt",
		JOYFUL = true
	};
	//mongo.save(doc = doc, collectionName = collection);
	people.save(doc);

	writeOutput("<h2>Upserted document after saving initially</h2>");
	writeDump( var = doc, label = "Upserted doc: #doc['_id'].toString()#", expand = false);

	doc.WANTSSTOGIE = true;
	people.save(doc);

	writeOutput("<h2>Upserted document after updating</h2>");
	writeDump( var = doc, label = "Upserted doc: #doc['_id'].toString()#", expand = false);


	//findAndModify: Great for Queuing!
	//insert docs into a work queue; find the first 'pending' one and modify it to 'running'
	tasks = db.getCollection("tasks");
	tasks.remove({});
	
	jobs = [
		{STATUS = 'P', N = 1, DATA = 'Let it be'},
		{STATUS = 'P', N = 2, DATA = 'Hey Jude!'},
		{STATUS = 'P', N = 3, DATA = 'Ebony and Ivory'},
		{STATUS = 'P', N = 4, DATA = 'Bang your head'}
	];
	tasks.insert(jobs);

	query = {STATUS = 'P'};
	update = {STATUS = 'R', started = now(), owner = cgi.server_name};

	nowScheduled = tasks.findAndModify( query = query, 
										update = update,
										sort = {N=1});

	writeOutput("<h2>findAndModify()</h2>");
	writeDump(var=nowScheduled, label="findAndModify", expand="false");

	
	writeOutput("<h2>Indexes</h2>");
	//here's how to add indexes onto collections for faster querying
	people.ensureIndex({NAME=1});
	people.ensureIndex({BIKE=1});
	people.ensureIndex({KIDS.AGE=1});
	writeDump(var=people.getIndexes(), label="Indexes", expand="false");



	//show how you get timestamp creation on all documents, for free, when using the default ObjectID
	all = people.find().toArray();
	first = all[1];
	last = all[ arrayLen(all) ];
	
	util = people.getUtil();
	
	writeOutput("<h2>Timestamps from Doc</h2>");
	writeOutput("Timestamp on first doc: #first['_id'].getTime()# = #util.getTimestamp(first)#   <br>");
	writeOutput("Timestamp on last doc: #last['_id'].getTime()# = #util.getTimestamp(last)#   <br>");

	//close the Mongo instance. Very important!
	mongo.close();


	function showResult( searchResult, label ){
		writeOutput("<h2>#label#</h2>");
		writeDump( var=searchResult.toArray(), label=label, expand="false" );
		writeOutput( "<br>Total #label# in this result, accounting for skip and limit: " & searchResult.size() );
		writeOutput( "<br>Total #label#, ignoring skip and limit: " & searchResult.count() );
		writeOutput( "<br>Query: " & searchResult.getQuery().toString() & "<br>");
	}

</cfscript>
