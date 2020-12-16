// ------------------------------------------------------------------
// Spatial Experiements #2, Boreholes January 1, 2019
// Written by Menome Technologies Inc. http://www.menome.com
//
// Process intervals into a linked list
// ------------------------------------------------------------------

// Test Readout
MATCH (c:Collar) 
with c order by c.Name
MATCH (c)-[]-(i:Interval) 
with c, i order by i.FromDepth
with c, collect(i) as intervals 
unwind RANGE(0,size(intervals) - 2) as idx
return c.Name,intervals[idx].FromDepth, intervals[idx+1].FromDepth;

// PRocess Intervals Into Linked List
MATCH (c:Collar)-[]-(i:Interval) 
with c, i order by i.FromDepth
with c, collect(i) as intervals 
with c,intervals,intervals[0] as first
merge (c)-[:NEXT_INTERVAL]->(first)
with c,intervals
unwind RANGE(0,size(intervals)-2 ) as idx
WITH intervals[idx] AS s1, intervals[idx+1] AS s2
MERGE (s1)-[:NEXT_INTERVAL]->(s2);

// Remove original collar->interval relationship 
match (c:Collar)-[r:HAS_INTERVAL]->(i:Interval)
delete r;

// Process lenth of interval onto edge
MATCH (c:Collar)-[:NEXT_INTERVAL*]-(i:Interval) 
with c, i order by i.FromDepth
with c, collect(i) as intervals 
with c,intervals
with c,intervals,intervals[0] as first
MATCH (first)-[r:NEXT_INTERVAL]->(second) set r.Length=second.ToDepth-first.ToDepth
with c,intervals
unwind RANGE(0,size(intervals)-2 ) as idx
WITH intervals[idx] AS s1, intervals[idx+1] AS s2
MATCH (s1)-[r:NEXT_INTERVAL]->(s2) set r.Length=s2.ToDepth-s1.ToDepth;

// set interval on first node
// Process lenth of interval onto edge
MATCH (c:Collar)-[:NEXT_INTERVAL*]-(i:Interval) 
with c, i order by i.FromDepth
with c, collect(i) as intervals 
with c,intervals
with c,intervals,intervals[0] as first
MATCH (first)-[r:NEXT_INTERVAL]->(second) set r.Length=second.ToDepth-first.FromDepth;


// Calculate X,Y,Z point for intervals
match (c:Collar )-[r:NEXT_INTERVAL*]-(i:Interval)
with c, i order by i.FromDepth
with c, collect(i) as intervals 
with c,intervals
unwind intervals as interval
with c,interval,c.El_DR_masl-interval.FromDepth as depth
//set interval.location=point({x: c.Lat_NAD83, y: c.Long_NAD83,z:depth, crs:'WGS-84-3D'})
  set interval.latitude=  c.latitude,interval.longitude=c.longitude,interval.elevation=depth
return c,interval;

// set lat/lng/elev for standard gis
match (c:Collar )-[r:NEXT_INTERVAL*]-(i:Interval)
 set i.lat=i.location.latitude,
i.lng=i.location.longitude,i.elev=i.location.z;

// Interpret Geology into Layers
MATCH (i:Interval) where i.Pri_Material <> '?' and i.Pri_Material <> 'no data' and i.Pri_Material <> 'not indicated' and i.Pri_Material <> 'no recovery' and i.Pri_Material <> 'no sample'
with i, 
case 
when toLower(i.Pri_Material) contains('clay') or toLower(i.Pri_Material) contains('bentonite') then 'Clay'
when toLower(i.Pri_Material) contains('boulder')  then 'Boulders'
when toLower(i.Pri_Material) contains ('till') then 'Till'
when toLower(i.Pri_Material) ends with ('sand') then 'Sand'
when toLower(i.Pri_Material) ends with ('shale') then 'Shale'
when toLower(i.Pri_Material) contains ('gravel') then 'Gravel'
when toLower(i.Pri_Material) ends with ('mudstone') then 'Mudstone'
when toLower(i.Pri_Material) contains ('bedrock') then 'Bedrock'
when toLower(i.Pri_Material) ends with ('fill') then 'Fill'
when toLower(i.Pri_Material) ends with ('silt') then 'Silt'
when toLower(i.Pri_Material) ends with ('siltstone') then 'Siltstone'
when toLower(i.Pri_Material) ends with ('pebbles') then 'Pebbles'
when toLower(i.Pri_Material) contains('rocks') or toLower(i.Pri_Material) contains('stones') then 'Rocks'
else i.Pri_Material
end as layer
set i.Layer = layer;

// Query back collars and valid intervals
MATCH (c:Collar)-[:NEXT_INTERVAL*]-(i:Interval) where i.Pri_Material <> '?' and i.Pri_Material <> 'no data' and i.Pri_Material <> 'not indicated' return c,i limit 100