// ------------------------------------------------------------------
// Neo4j Spatial Experiments, December 2018
// Written by Menome Technologies Inc. http://www.menome.com
//
// Generate a test building for walk score calc
// ------------------------------------------------------------------

with point({ longitude: -114.0387378 , latitude: 51.052368  }) as p1 

MATCH (x:OSMNode)-[:TAGS]->(t:OSMTags) WHERE distance(p1,point({ longitude: x.lon , latitude: x.lat})  ) =0 set x:PointOfInterest:Building, x.Code="Test 1"  return x,t