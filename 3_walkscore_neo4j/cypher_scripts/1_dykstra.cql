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
match (p:PointOfInterest)-[]-(t:OSMTags) 
with d,p1,collect(p) as pointsOfInterest

// unwind and compute actual distances from Test1
unwind (pointsOfInterest) as point
call algo.shortestPath.stream(d,point,'distance',
{relationshipQuery:'ROUTE',nodeQuery:'Routable',direction:'BOTH', defaultValue:1.0}) YIELD nodeId,cost

match (n) where id(n)=nodeId
return collect({lat:n.location.latitues,lon:n.location.longitude}) as route