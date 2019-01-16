// ------------------------------------------------------------------
// Spatial Experiements #2, Boreholes January 1, 2019
// Written by Menome Technologies Inc. http://www.menome.com
//
// Read + import Boreholes.txt
// ------------------------------------------------------------------

CREATE CONSTRAINT ON (r:Collar) ASSERT r.Name IS UNIQUE;
CREATE INDEX ON :DrillingMethod(Name);
CREATE INDEX ON :Logger(Name);
CREATE INDEX ON :DrillingCompany(Name);


CALL apoc.load.csv('file:/datasources/DIG_2014_0012/Boreholes.csv'
    // , {limit: 100} // limit when in development
) YIELD map

// merge collars
MERGE (collar:Collar{
   Name: map['Name']
   
})
 ON CREATE SET
    collar.SourceID= map['Source_ID'],
    collar.Alias1= map['Alias1'],
    collar.DateDrilled= date(map['Date_Drilled']),
    collar.Depth_Reference=map['Depth_Reference'],
    collar.El_DR_masl=toFloat(map['El_DR_masl']),
    collar.Elev_Method=map['Elev_Method'],
    collar.Total_Depth_m=toFloat(map['Total_Depth_m']),
    collar.E_10TM83=toFloat(map['E_10TM83']),
    collar.N_10TM83=toFloat(map['N_10TM83']),
    collar.Lat_NAD83=toFloat(map['Lat_NAD83']),
    collar.Long_NAD83=toFloat(map['Long_NAD83']),
    collar.Source_CRS=toFloat(map['Source_CRS']),
    collar.Spatial_Precision=toFloat(map['Spatial_Precision']),
    collar.Folder=map['Folder'],
    collar.LogPDF=map['LogPDF'],
    collar.Purpose=map['Purpose'],
    collar.Comment=map['Comment'],
    collar.Georef=map['Georef'],
    collar.Owner=map['Owner'],
    collar.Well_Presence=map['Well_Presence'],
    collar.Location=point({x: toFloat(map['Lat_NAD83']), y: toFloat(map['Long_NAD83']),height:toFloat(map['El_DR_masl']), crs: 'wgs-84'})
 ON MATCH SET
    collar.SourceID= map['Source_ID'],
    collar.Alias1= map['Alias1'],
    collar.DateDrilled= date(map['Date_Drilled']),
    collar.Depth_Reference=map['Depth_Reference'],
    collar.El_DR_masl=toFloat(map['El_DR_masl']),
    collar.Elev_Method=map['Elev_Method'],
    collar.Total_Depth_m=toFloat(map['Total_Depth_m']),
    collar.E_10TM83=toFloat(map['E_10TM83']),
    collar.N_10TM83=toFloat(map['N_10TM83']),
    collar.Lat_NAD83=toFloat(map['Lat_NAD83']),
    collar.Long_NAD83=toFloat(map['Long_NAD83']),
    collar.Source_CRS=toFloat(map['Source_CRS']),
    collar.Spatial_Precision=toFloat(map['Spatial_Precision']),
    collar.Folder=map['Folder'],
    collar.LogPDF=map['LogPDF'],
    collar.Purpose=map['Purpose'],
    collar.Comment=map['Comment'],
    collar.Georef=map['Georef'],
    collar.Owner=map['Owner'],
    collar.Well_Presence=map['Well_Presence'],
    collar.Location=point({x: toFloat(map['Lat_NAD83']), y: toFloat(map['N_10TM83']),z:toFloat(map['El_DR_masl'])})

with map,collar
MERGE (drillingMethod:DrillingMethod{
    Name: map['Drilling_Method']
})

with map,collar 

MERGE (logger:Logger{
    Name: map['Logger']
})

MERGE (collar)-[:LOGGED_BY]->(logger)

with map,collar

MERGE (drillingCompany:DrillingCompany{
    Name: map['Drilling_Company']
})

MERGE (collar)-[:DRILLED_BY]->(drillingCompany)

with map,collar,drillingCompany

MERGE (driller:Driller{
    Name: map['Driller']
})

with map,collar,drillingCompany,driller

MERGE (driller)-[:WORKS_FOR]->(drillingCompany)


return *;

