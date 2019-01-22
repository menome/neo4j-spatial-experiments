// ------------------------------------------------------------------
// Spatial Experiements #2, Boreholes January 1, 2019
// Written by Menome Technologies Inc. http://www.menome.com
//
// Read + import Boreholes.txt
// ------------------------------------------------------------------

//CREATE CONSTRAINT ON (r:Interval) ASSERT r.Name,FromDepth,ToDs IS UNIQUE;
CREATE INDEX ON :Interval(Name);
CREATE INDEX ON :Interval(FromDepth);
CREATE INDEX ON :Interval(ToDepth);


CALL apoc.load.csv('file:/datasources/DIG_2014_0012/Intervals.csv'
    , {quotationCharacter: '"'}// , {limit: 100} // limit when in development
) YIELD map




// merge collars
MERGE (interval:Interval{
   Name: map['Borehole_Name'],
   FromDepth: toFloat(map['From_Depth']),
   ToDepth: toFloat(map['To_Depth'])
})
 ON CREATE SET
    interval.Source_ID=map['Source_Id'],
    interval.Depth_Units=map['Depth_Units'],
    interval.From_Depth_mbgs=toFloat(map['From_Depth_mbgs']),
    interval.To_Depth_mbgs=toFloat(map['To_Depth_mbgs']),
    interval.Int_Top_Depth=toFloat(map['Int_Top_Depth']),
    interval.Int_Top_Depth=toFloat(map['Int_Top_Depth']),
    interval.Pri_Material=map['Pri_Material'],
    interval.Sec_Material=map['Sec_Material'],
    interval.Colour=map['Colour'],
    interval.Full_Text=map['Full_Text'],
    interval.Comment=map['Comment']

 ON MATCH SET
    interval.Source_ID=map['Source_Id'],
    interval.Depth_Units=map['Depth_Units'],
    interval.From_Depth_mbgs=toFloat(map['From_Depth_mbgs']),
    interval.To_Depth_mbgs=toFloat(map['To_Depth_mbgs']),
    interval.Int_Top_Depth=toFloat(map['Int_Top_Depth']),
    interval.Int_Top_Depth=toFloat(map['Int_Top_Depth']),
    interval.Pri_Material=map['Pri_Material'],
    interval.Sec_Material=map['Sec_Material'],
    interval.Colour=map['Colour'],
    interval.Full_Text=map['Full_Text'],
    interval.Comment=map['Comment']

with map,interval
MERGE (collar:Collar{
    Name: map['Borehole_Name']
})

MERGE (collar)-[:HAS_INTERVAL]->(interval)




return *;

