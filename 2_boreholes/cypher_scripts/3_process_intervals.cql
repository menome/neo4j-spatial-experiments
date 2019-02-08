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
unwind RANGE(0,LENGTH(intervals) - 2) as idx
return c.Name,intervals[idx].FromDepth, intervals[idx+1].FromDepth

// PRocess Intervals Into Linked List
MATCH (c:Collar)-[]-(i:Interval) 
with c, i order by i.FromDepth
with c, collect(i) as intervals 
with c,intervals,intervals[0] as first
merge (c)-[:NEXT_INTERVAL]->(first)
with c,intervals
unwind RANGE(0,LENGTH(intervals)-2 ) as idx
WITH intervals[idx] AS s1, intervals[idx+1] AS s2
MERGE (s1)-[:NEXT_INTERVAL]->(s2)

// Remove original collar->interval relationship 
match (c:Collar)-[r:HAS_INTERVAL]->(i:Interval)
delete r

// Process lenth of interval onto edge
MATCH (c:Collar)-[:NEXT_INTERVAL*]-(i:Interval) 
with c, i order by i.FromDepth
with c, collect(i) as intervals 
with c,intervals
with c,intervals,intervals[0] as first
MATCH (first)-[r:NEXT_INTERVAL]->(second) set r.Length=second.ToDepth-first.ToDepth
with c,intervals
unwind RANGE(0,LENGTH(intervals)-2 ) as idx
WITH intervals[idx] AS s1, intervals[idx+1] AS s2
MATCH (s1)-[r:NEXT_INTERVAL]->(s2) set r.Length=s2.ToDepth-s1.ToDepth

// set interval on first node
// Process lenth of interval onto edge
MATCH (c:Collar)-[:NEXT_INTERVAL*]-(i:Interval) 
with c, i order by i.FromDepth
with c, collect(i) as intervals 
with c,intervals
with c,intervals,intervals[0] as first
MATCH (first)-[r:NEXT_INTERVAL]->(second) set r.Length=second.ToDepth-first.FromDepth


// Calculate X,Y,Z point for intervals
match (c:Collar {Name:'141'})-[r:NEXT_INTERVAL*]-(i:Interval)
with c, i order by i.FromDepth
with c, collect(i) as intervals 
with c,intervals
unwind intervals as interval
with c,interval,c.El_DR_masl-interval.FromDepth as depth
set interval.location=point({x: c.Lat_NAD83, y: c.Long_NAD83,z:depth, crs:'WGS-84-3D'})
return c,interval
