// ------------------------------------------------------------------
// Neo4j Spatial Experiments, December 2018
// Written by Menome Technologies Inc. http://www.menome.com
//
// Generate routing using periodic Iterate
// ------------------------------------------------------------------


call apoc.periodic.iterate("MATCH (x:Routable:OSMNode) WHERE NOT (x)-[:ROUTE]->(:Intersection) WITH x CALL spatial.osm.routeIntersection(x,true,false,false) YIELD fromNode, toNode, fromRel, toRel, distance, length, count return fromNode, toNode, fromRel, toRel, distance, length, count",

"MERGE (fromNode)-[r:ROUTE {fromRel:id(fromRel),toRel:id(toRel)}]->(toNode) ON CREATE SET r.distance = distance, r.length = length, r.count = count",{limit:100,parallel:false,iterateList:true });