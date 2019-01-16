# Computing Walk Score With Open Street Map and Neo4j

The goal of this experiment is to see if it is possible to construct a methodology for computing a specific Walk Score for communities immediately surrouding buidlings.

While these data are available on the [Walkscore website](https://www.walkscore.com/), the intent of this experiement is to validate a baseline methdology applying Neo4j Spatial against a known metric. This then can provide a foundation for processing and analyzing other forms of metrics for computing community wellbeing metrics and/or blending or aumenting baseline walkscore beyond its simple foundation. 

I also wanted to try to visualize how a community changes over time by connecting Neo4j to the [Deck.gl](http://deck.gl/#/) visualizaiton framework. 

![Deck GL](/deck.png "Logo Title Text 1")

# Walkscore Data Example: 

Uses:

- [Neo4j Open Street Map Importer](https://github.com/neo4j-contrib/osm)
- [Deck.gl](http://deck.gl/#/)
- [Neo4j Community Edition](https://hub.docker.com/_/neo4j/) via Docker. 
- [Craig Traverner from Neo4j's Open Street Map processor Example](https://neo4j.com/news/geoprocessing-with-neo4j-spatial-and-osm-2/)
- [Open Street Map Processor Source Code](https://github.com/neo4j-contrib/osm)


## Quick Start

Follow these steps to get a running neo4j instance loaded with demo data.

### 1. Database

Unzip the Neo4j database: neo4j-data/databases/graph.db.zip 

In the root of this repo, run:

```
docker-compose up
```

This will start the Neo4j database, and the Deck.gl container. 

See [docker-compose.yml](docker-compose.yml) for configuration of the neo4j instance in docker. 

### 2. Data 

The Neo4j database was small enough for this example to be checked in with the repo, so everything should be good to go.  

## Data and Development 

I used the [Open Stree Map Editor](https://www.openstreetmap.org/export#map=16/51.0532/-114.0623) to export the base data for the City of Calgary. I have stored the raw Open Stree Map data in the datasources folder as well for reference. 

I then used Craig's [Open Street Map Processor Source Code](https://github.com/neo4j-contrib/osm) to pull in the Open Street Map data for the Calgary region for this example. I then followed the steps outlined in the slide deck and the presentation from [Graph Connect](https://neo4j.com/graphconnect-2018/session/neo4j-spatial-mapping) to post-process the OSM data. You can follow Craig's process to do this with any Open Street Map data and I have also put the Periodic Iterate versions of the steps into the repo as well for reference. 

I then generated Points of Interest for Amenities based on the list outlined in the Walk Score algorithm Document (see the Documentation Folder) using the query in 3_amenities. 

I generated a RawScore rank for the amenities:

```
// find amenity types 
// return rank of amenities
match (p:PointOfInterest)-[]-(t:OSMTags) where exists (t.amenity)
with p,t,
CASE 
	WHEN t.amenity in ['restaurant','nightclub','fast_food','pub','ice_cream']  THEN 3
	WHEN t.amenity in ['cafe','marketplace']  THEN 2
ELSE 1 
END AS result
return t.amenity,result

```


## Run ad-hoc cypher queries on the DB

Go to [the Neo4J browser](http://localhost:7474/browser/) and smash away

## Deck Visualization

This is a very basic Deck.gl visualzation just to get the connectivity working between neo4j and deck. I plan to do some more interesting things on subsequent posts. This basic visualizaition shows Amenities over Time in downtown Calgary for 2010,2014 and 2018. You can see how the number of amenities increases over the eight year period. 

The map also shows the locations of the Walk Score test buildings:
- Test 1 shows a walk score of 95%, which visually makes sense given the dense cluster of amenities with in the 1600m radius.
- Test 2 shows a walk score of 37%, which visually fits due to it being on the far side of the city core with no amenities in the immediate radius.

You will need to generate a [Mapbox Token](https://www.mapbox.com) - once that is done go to http://localhost:3000/. 


### Walk Scores 

The following is derived from the Walk Score documents found in the Documentaiton folder. I may still not have the calculation completely bang on as I think there is an additional weighting characteristic associated with the number of amenities in each collection. 

Walk Score® is scaled linearly, ranging from: 

- 0 to 24 “car-dependent” (car required for almost all errands), 
- 25–49 “car-dependent” (car required for most errands), 
- 50–69 “somewhat walkable” (car required for some errands), 
- 70–89 “very walkable” (car not required for most errands), to 
- 90–100 “walker's paradise” (car not required for errands) (Walk Score, 2012).

Walk Score® is calculated by determining a raw score out of fifteen, normalizing that score from zero to one hundred, and deducting two penalties for low intersection density (ID) and high average block length (ABL) (Walk Score, 2012). 

Walk Score® = Raw Score/15 x 6.67 - (ID - ABL)

The raw score is composed of nine amenity categories of walking destinations (grocery, restaurants, shopping, coffee shops, bank services, schools, entertainment, bookstores, and parks) each weighted from one to three points based on low, medium, or high importance for walking in six research articles referenced by Walk Score®

Scores within each category were attenuated by a close approximation of the Walk Score® distance decay function awarding:

- 100% of the possible maximum points to amenities located within a network walkshed distance of 0.25 miles (400 m or 5 min walk)
- 75% within 0.5 miles (800 m or 10 min), 
- 40% within 0.75 miles (1200 m or 15 min), 
- 12.5% within 1.0 mile (1600m or 20min) of each location (Walk Score, 2012)

The weighting of three categories (restaurants, shopping, and coffee shops) reflects the number of destinations available (or “depth of choice”) (Walk Score, 2012). 

Finally, the Walk Score® intersection density (ID) function was used to deduct a maximum 5% penalty for 60 intersections per square mile and the Walk Score® average block length (ABL) function was used to deduct the Same maximum of 5% for N195 m length per block.

### General Walkscore Algorithm Ranks:

- Grocery 3 Grocery stores; ethnic food stores
- Restaurants 3 Fast food counters/restaurants; full service/hotel/ethnic restaurants; banquet halls; outdoor dining; bars/nightclubs; other food outlets
- Shopping 2 Big box shops; shoppingmalls; stripmalls; bakeries; butcher shops; delicatessens; farmers' markets 
- Coffee shops 2 Coffee shops
- Bank services 1 Commercial banks; financial services
- Schools 1 Elementary/junior high schools; high schools; universities; other schools
- Entertainment 1 Auditoriums/concert halls; theatres; museums; movie theatres; games rooms; gyms/fitness centres; indoor/outdoor hockey arenas; indoor/outdoor pools; wading pools; tennis courts; basketball nets; community gardens;
- other recreational spaces/public places
- Bookstores 1 Bookstores; libraries
- Parks 1 Playgrounds; spray decks; playing fields; open green spaces; golf courses; lakes/ponds; fountains/reflecting ponds; campgrounds; streams/rivers/creeks/canals;

### Intersection Density and Average Block Length

The Walk Score® intersection density (ID) function is used to deduct a maximum 5% penalty for < 60 intersections per square mile.

- 1600 m radius = 8042477.193 m^2 = 3.1052 mi^2 
- ID = #Intersections/3.1502 

Intersection density (intersections per square mile): over 200: no penalty

- 150-200: 1% penalty
- 120-150: 2% penalty
- 90-120: 3% penalty 60-90: 4% penalty under 60: 5% penalty

The Walk Score® average block length (ABL) function is used to deduct the same maximum of 5% for > 195 m length per block.
Average block length (in meters): 

- under 120 m: no penalty 120-150 m: 1% penalty
- 150-165 m: 2% penalty
- 165-180 m: 3% penalty 180-195m: 4% penalty over 195m: 5% penalty

- [Field Validation Of Walk Score Study](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5065046/)
- [Validation of Walk Score for estimating access to walkable amenities](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4845899/)

## Limitations of Walk Score, and Some Thoughts For Graph Database Augmentation Approach

The walkscore algorithm is an approximation, and doesn't include such factors as topography, street design, available public transportation or bodies of water in its rankings. It calculates using linear distance, which means it doesn't factor in barriers such as lakes, rivers, open spaces, closed spaces or routing. 

The Walk Score algorithm also doesn't rate a neighborhood on visual aspect but rather how easy it is to live car-free. If you live near a nature preserve or hiking trails, that greenery may improve your quality of life, but it won't improve your walk score.

Walk Score was created in a time when data was more limited and less available, and the toolsets more primitive than are now available. 

The ready availability of Open Street Data, Government data it is conceptually possible to construct a far more powerful algorithmic approach to computing the outlined indicators and metrics. 

For example: the Open Street Map data is in fact a graph, it becomes possible to increase the accuracy and power of walk score type calculations by using graph analtyics methods. The A* algorithm for example makes it possible to use route finding between buidling and amenities instead of relying on abstractions for assessing walkability of a neighborhood. In effect - the computation theoretically becomes more accurate as the algorithm is in effect sending an 'agent' down the actual path between the building and all potential amenities. 

This could provide a powerful alternatives for making assessments of community well being by actually having agents walk the graph and computing a set of not single but combinatorial metrics along the route.

The agent pattern could be run continuously over time as new data sources became available. This would provide a powerful set of dashboards for continuously assessing the wellbeing of communities. 


## Open Data Sources, Resources and References

### Mapping Base Data: Open Street Map

Open Street Map is an open source globally assembled spatial database. It is well supported, has a broad set of tools both open and closed source and is extensible by individuals and organizations. It has established definitions and tagging structures as well, and is broadly used by government bodies as a foudnation for adjacent open data sets. Open Street map sets are easily blended with other data sets external and internal. All mapping systems including ESRI, Geoserver, neo4j etc. can be tied into Open Street Maps data sets as well. 


### Open Street Map Resources

- [Open Street Map Site:](https://www.openstreetmap.org): Main open street map site - account can be setup to add, download or edit open street map data
- [Editing and Adding Open Street Data:](https://blog.mapbox.com/get-on-openstreetmap-48bfe68a7914): Blog post on editing open street map data
- [Open Street Map Editing Walkthrough:](https://blog.mapbox.com/a-friendlier-introduction-to-editing-openstreetmap-eaca9e233a7c): Walkthrough of open street map data editing
- [JOSM Java Open Street Map editor](https://josm.openstreetmap.de/) Editor for working on open street map data
- [You tube video for import process for OSM](https://www.youtube.com/watch?v=OkFCkPBR7PA&feature=youtu.be) Video tutorial of import process. Contributors can sign up for an import account and use this to bring data into open street map
- [Open Street Map Tag information](https://taginfo.openstreetmap.org/tags/natural=tree#combinations) Open Street Map Tag definitions
- [Open Street Map Biking Export For Ottawa](https://download.bbbike.org/osm/bbbike/Ottawa/) Ottawa open street map dataset for cycling


### Open Data Building Data Sources 

Open street map has been adopted by the federal government as a mechanism for capturing and storing data associated with buildings, communities, cities etc. There is an initiative undertaken by Ottawa and other communities to crowdsource the input of these data through the Canada Open Street Map Building inventory project. 


- [Federal facility green house gas data](https://open.canada.ca/data/en/dataset/6bed41cd-9816-4912-a2b8-b0b224909396): datasets for federal buildings and fleets for green house gas emissions
- [Canada Open street Map Building Inventory](https://wiki.openstreetmap.org/wiki/WikiProject_Canada/Building_Canada_2020) Project for capturing building data for all of canada
- [Canada buiding 2020 data sets](https://wiki.openstreetmap.org/wiki/WikiProject_Canada/Building_Canada_2020/building_OD_tables)
- [Open Database Of Buildings](https://www.statcan.gc.ca/eng/open-building-data/open-database)
- [Calgary open street map buliding task](http://tasks.osmcanada.ca/project/83) Task associated with mapping Calgary buildings

## Visualization Tools

- [Uber Deck.gl](https://deck.gl/#/): Uber's powerful spatial visualizaiton javascript framework. This tool is desgined for website developers to create powerful interactive spatial visualizaitons
- [Uber Kepler](http://kepler.gl/#/): Uber's simple user friendly quick visualizaiton tool. Data can be added using simple CSV spatial files as layers to quickly build visualizations
- [Quantum GIS](https://www.qgis.org): Open source powerful general purpose GIS tool. Just as good as ESRI for most spatial analytics and spatial data manipulation and translation

## Data Tools

- [Neo4j Open Street Map importer](https://github.com/neo4j-contrib/osm): java based importer that pulls open street map data into neo4j. Open Street Map is actually a graph, so this importer brings data directly into neo4j using the underlying spatial graph represenation. A lot of potential here for combining spatial open street map data with other sorts of non-spatial data for wellness analytics spatial to non-spatial. 
- [Spacetime Reviews spatial query/graph example](https://github.com/johnymontana/spacetime-reviews): Example of using spatial queries against neo4j to plot graphs of data associated with spatial and non-spatial data
- [Blog post on neo4j spatial and time data](https://medium.com/neo4j/working-with-neo4j-date-and-spatial-types-in-a-react-js-app-5475b5042b50): Example of using neo4j spatial and javascript to make an interactive spatial website



## Walkscore Cypher Calculation:
```
// 6 compute walk score Walk Score® = Raw Score x 6.67 - (ID - ABL)
match (d:Building )
with d,point({ longitude: d.Long, latitude: d.Lat }) as p1 
match (i:Intersection) where distance(p1,i.location) <= 1600 
with p1,d,count(i)/3.1502 as ID

// determine ID Penality
with p1,d,ID,
CASE 
    WHEN ID <= 60 then 0.05
    WHEN ID > 60 and ID <=90 then .04
    WHEN ID > 90 and ID <=120 then .03
    WHEN ID > 150 and ID <= 200 then .01
    ELSE 0.0
END as IDPenalty

// compute ABL Penalty
match (i:Intersection) where distance(p1,i.location) <= 1600 
with d,p1,IDPenalty,i, collect(i) as intersections
unwind intersections as i1
match (i1)-[r:ROUTE]->(i2:Intersection)
with d,p1,IDPenalty,avg(r.distance) as ABL

with ABL,p1,d,IDPenalty,
CASE 
    WHEN ABL <= 120 then 0.0
    WHEN ABL > 120 and ABL <=150 then .01
    WHEN ABL > 150 and ABL <=165 then .02
    WHEN ABL > 165 and ABL <= 180 then .03
    WHEN ABL > 180 and ABL <= 195 then .04
    ELSE .05
END as ABLPenalty

// compute walk score
with p1,d,IDPenalty,ABLPenalty

// find all points of interest in boundary
match (p:PointOfInterest)-[]-(t:OSMTags) where distance(p1,p.location) <= 1600 

// compute walk score using weighted boundaries
with p1,d,IDPenalty,ABLPenalty,collect(p) as points
unwind points as point
with p1,d,IDPenalty,ABLPenalty,point,
CASE 
    when distance(p1,point.location) <= 400 then point.RawScore
    when distance(p1,point.location) > 400 and distance(p1,point.location) <= 800 then point.RawScore * 0.75
    when distance(p1,point.location) > 800 and distance(p1,point.location) <= 1200 then point.RawScore * 0.40
    when distance(p1,point.location) > 1200 and distance(p1,point.location) <= 1600 then point.RawScore * 0.125
    else 0
END as rawScore

with p1,d,IDPenalty,ABLPenalty,sum(rawScore) as totalRawScore

with IDPenalty,ABLPenalty,totalRawScore,
// Check rawscore total - 15 is max
CASE 
    when totalRawScore > 15.0 then 15.0 * 6.67
    else totalRawScore * 6.67
END as score

return (score - (IDPenalty * score + ABLPenalty * score)) as WalkScore, IDPenalty,ABLPenalty
```