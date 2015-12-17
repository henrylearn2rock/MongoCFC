# MongoCFC

MongoCFC (for lack of a better name) models the Mongo Shell JavaScript API as close as possible, so you don't have to learn twice! Just replace : with = and you're good to go!

e.g. 

JS: `db.people.update({name:'Joe'},{$inc:{n:1}});`

CF: `people.update({'name'='Joe'},{$inc:{'n'=1}});`

Dependency: Official MongoDB Java driver

Installation: 
1. Install MongoDB: http://www.mongodb.org/display/DOCS/Quickstart
2. Download MongoDB Java Driver: https://github.com/mongodb/mongo-java-driver/downloads 
3. Move .jar into `#web_root#/WEB-INF/lib`
4. restart your CF.
5. run demo/gettingstarted.cfm

NOTE 1: CF's struct keys are stored in UPPERCASE by default. However, MongoCFC will convert _id and all modifier operators (e.g. $set and $inc) into the correct case. To use mixed/lowercase, quotes the key like the example above.

NOTE 2: CF's struct does not preserve insertion order. When specifying multiple index or sort columns, use util.orderedStructNew() or exception will be thrown.


See `demo/gettingstarted.cfm` and compare to the other excellent project CFMongoDB at: http://cfmongodb.riaforge.org/

### Requirements:

ColdFusion 9.0.1+
