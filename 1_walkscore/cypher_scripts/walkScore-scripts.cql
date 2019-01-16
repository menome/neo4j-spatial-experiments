// ------------------------------------------------------------------
// Neo4j Spatial Experiments, December 2018
// Written by Menome Technologies Inc. http://www.menome.com
//
// Various cypher scripts working up the example
// ------------------------------------------------------------------

// Link conrnerstone to location
match (d:Building {Code:'Test'}) where exists(d.Lat) and d.Lat> 0 with c,point({ longitude: d.Long, latitude: d.Lat }) as p1
match (p:PointOfInterest) where distance(p1,point({ longitude: p.Long, latitude: p.Lat })) < 1000
with d,p
merge (c)-[:LOCATED_IN]->(o)

// find buildings in calgary and amenities close by
match (d:Building {Code:'Test'}) where exists(d.Lat) and d.Lat> 0 
with d,
point({ longitude: d.Long, latitude: d.Lat }) as p1, 
point({longitude:-114.0708,latitude:51.0486}) as calgary
match (d) where distance(p1,calgary)<100000
with d,p1
match (p:PointOfInterest)-[]-(t:OSMTags) where distance(p1,p.location) < 1000
return d.Name,p.name,t.amenity, distance(p1,p.location) order by d.Name, distance(p1,p.location) desc limit 1000

// fix dates
match (d:Building {Code:'Test'}) where exists (d.FinishDate) set d.FinishDate= date(split(d.FinishDate,'T')[0])

// find buildings with similar names to OSM
MATCH (n:OSMTags) where exists (n.building) and n.name <> ""
match (d:Building) with n,d,apoc.text.distance(apoc.text.clean(d.Name), apoc.text.clean(n.name)) as rank where rank < 5
 return d.Name,n.name,rank order by d.name, rank asc

 // merge buildings with similar name to OSM
 MATCH (n:OSMTags) where exists (n.building) and n.name <> ""
match (d:Building) with n,d,apoc.text.distance(apoc.text.clean(d.Name), apoc.text.clean(n.name)) as rank where rank < 1
merge (d)-[:BUILT_BUILDING]->(n)

// buiding we are going to test
match (d:Building {Code:'Test'}) return d

// distance from building to amenities
match (d:Building {Code:'Test'}) 
with d,point({ longitude: d.Long, latitude: d.Lat }) as p1 
match (p:PointOfInterest)-[]-(t:OSMTags) where distance(p1,p.location) < 1000
return d.Name,p.name,t.amenity, distance(p1,p.location) order by d.Name, distance(p1,p.location) desc limit 1000

// amenities nearby in 2010 
match (d:Building {Code:'Test'}) 
with d,point({ longitude: d.Long, latitude: d.Lat }) as p1 
match (p:PointOfInterest)-[]-(t:OSMTags) where distance(p1,p.location) < 1000 and d.FinishDate.year >= p.timestamp.year 
return d.Name,p.name,t.amenity, distance(p1,p.location), p.timestamp.year order by d.Name, distance(p1,p.location),p.timestamp.year desc

// identify nearest intersection to  building
match (d:Building {Code:'Test'})
with d,point({ longitude: d.Long, latitude: d.Lat }) as p1 
match (p2:Intersection) 
with p1, min(distance(p1,p2.location)) as mindist,d
match (i:Intersection) where distance(p1,i.location)=mindist
return d,i

// 2 find amenity types within the 1600 m boundary (could be expanded to all calgary amenities for dynamic classification)
// return rank of amenities
match (d:Building {Code:'Test'})
with d,point({ longitude: d.Long, latitude: d.Lat }) as p1 
match (p:PointOfInterest)-[]-(t:OSMTags) where distance(p1,p.location) <= 1600 and exists (t.amenity)
with p,t,
CASE 
	WHEN t.amenity in ['restaurant','nightclub','fast_food','pub','ice_cream']  THEN 3
	WHEN t.amenity in ['cafe','marketplace']  THEN 2
ELSE 1 
END AS result
return t.amenity,result