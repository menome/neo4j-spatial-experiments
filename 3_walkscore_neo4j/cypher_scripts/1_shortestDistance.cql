// ------------------------------------------------------------------
// Neo4j Spatial Experiments, December 2018
// Written by Menome Technologies Inc. http://www.menome.com
//
// Cypher Version of the Walk Score Calculation 
// ------------------------------------------------------------------

// 6 compute walk score Walk Score® = Raw Score x 6.67 - (ID - ABL)
// Can use any lat/long or pre-configured Buildings Test 1, Test 2, Test 3
match (d:Building {Code:'Test 1'}) 
with d,point({ longitude: d.lon, latitude: d.lat }) as p1 


// find all points of interest in boundary
match (p2:PointOfInterest)-[]-(t:OSMTags)  where distance(p1,p2.location) <= 1600 and p2.name="Murrieta's Bar & Grill"
with p2,d,p1
match p=shortestPath((d)-[:ROUTE*..100]-(p2))
return p