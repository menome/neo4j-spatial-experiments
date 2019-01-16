// ------------------------------------------------------------------
// Neo4j Spatial Experiments, December 2018
// Written by Menome Technologies Inc. http://www.menome.com
//
// Set Raw Walk Score ranks based on Walk Score amenity definitions.
// These were from the Alberta study, but can be adjusted by setting different amenity types
// ------------------------------------------------------------------
// find amenity types 
// return rank of amenities
match (p:PointOfInterest)-[]-(t:OSMTags) where exists (t.amenity)
with p,t,
CASE 
	WHEN t.amenity in ['restaurant','nightclub','fast_food','pub','ice_cream']  THEN 3
	WHEN t.amenity in ['cafe','marketplace']  THEN 2
ELSE 1 
END AS result
set t.RawScore=result
return t.amenity,result