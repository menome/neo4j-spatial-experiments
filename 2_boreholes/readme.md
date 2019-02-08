# Borehole Experiment

In this experiment, we are going underground to try neo4j spatial out with modelling a set of boreholes. 

## Borehole uses and types

There are many different kinds of borehole logs:

- Groundwater boreholes and Water well logs: holes that are drilled to test and characterize aquifers
- Dimond Drill holes typically used to characterize hard rock minerals for the purpose of hard rock mining
- Well Logs for the purpose of petroleum exploration and produciton 

All of these have the same basic structure: 

- A surface location or collar is chosen, an underground target is chosen typically using geophysics or geochemiscal interpretations
- A drill is setup on this location - the type of drill will depend on the depth, type of hole being drilled and purpose for the hole
- The drilling process usually involves taking some form of core or sample at intervals down the hole
- Additional tests are frequently done to characterize the material in the hole
- These data are turned into logs that are then used to build an interpretation of the geological layers that exist subsurface.

The interesting thing from a graph database perspective is that these logs all are surface location points that then have linked lists of data at distances from this surface location. Traditionally these can be very challenging to model using relational databases because they have often fairly fluid, flexible data structures. 

While this is a simplificaiton of the actual process which is very involved and uses massive amounts of data, generally the interpretation process seeks to connect inervals from individual boreholes together by looking for similar defining characteristics of the layers found in the interval data. 

## Experiment: Model a set of lithological borehole interpretations using Neo4j

Borehole data seems to be a bit harder to find on the open data front. I did find a set that looks reasonable here:

[Data Source:](https://open.alberta.ca/opendata/41d27d78-3268-48ab-9c38-34f87dd1b35a#summary)

These data are from a set of borehole lithology logs. Lithology logs are drilled typically to get a sense of the type of material in the subsurface of a given area. These are drilled in soil to characterize material for purposes of identifying contaminants, looking for useful materials such as gravel, identifying aquifers etc. 


### Spatial References

The Boreholes.txt file uses NAD83. Currently Neo4j spatial only supports WGS84 - 'standard' lat/long. THis means we have to convert the borehole file from NAD83 to WGS84 as Neo4j does not currently support other spatial reference datums, nor does it support conversion between datums. Fortunately, there are a myriad of geospatial tools available to do this. Even better news: we can use open source tools to do this rather than needing ESRI, which is expensive. 

QGIS is the best open source alternative to ESRI, and it can be freely downloaded from: [Quantum GIS](https://qgis.org/en/site/)

I have included the converted the file in /datasources, but if you want to work through the process, it involves bringing the Boreholes.csv file into Quantum GIS, setting the NAD83 reference, and projecting the collars to WGS84 using QGIS tools. 

## Importing Borehole Data

The process of importing the borehole data will involve bringing in the collar locations first, geotagging them with the lat/long/eleveation point as part of that process and setting up the borehole metadata. The code for this is in 1_import_boreholes.cql. 

The intervals will be brought in next. Because the intervals are in a CSV table and may not be in order, the first pass will link the
intervals to the collars in a cluster format: i.e. direct relationship between the collar and the interval. The code for this is in 2_import_intervals.cql. 


### Data Import Process

I have included a fully populated Zipped version of the resulting database, but if you want to work through the import and post-processing, perform the following: 

- Run the 1_import_boreholes.cql - this imports the borehole collar locations, and sets them up with the lat/long/elevation
- Run the 2_import_intervals.cql - this will bring the intervals in as a cluster of nodes around the collar. 

If you are using a newer version of Neo4j, you can turn on the multiple-statement swich in the neo4j browser, and copy/paste the import CQL files contents in. 

You can also use a terminal or command shell to paste in the following command to process the files in this manner:
```
docker exec borehole bin/neo4j-shell -file /scripts/<name of the script from the "scripts" directory here>
```


### Processing Intervals into Borehole Structure

The next step then once the boreholes are imported will be to run a CQL command that transforms the cluster into linked lists of intervals based on their depth down hole, and remove the original relationship. 

Fortunately, our good friend Mark Needham has already beaten us to a nice procedure that does this using Unwind in this [blog post](https://markhneedham.com/blog/2015/06/04/neo4j-cypher-step-by-step-to-creating-a-linked-list-of-adjacent-nodes-using-unwind/):

```
// Process Intervals Into Linked List
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

```

### Interval Length Mapping: 

Once we have the intervals into a linked list, we need to map the lengths between intervals onto the relationship between the intervals, remembering to also do this for the first relationship (we could likely do these all as one statement):

```

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

```

### Compute downhole interval point location

We will compute a downhole x,y,z coordinate for each interval. This should allow us to plot the borehole collars and intervals on a map, and visualize them using either a point cloud or borehole mapping utility. 

Boreholes are not all straight. Depending on the type of drilling, nature of the material being drilled into, and depth of drilling, boreholes will naturally tend to deflect. Oil and gas
drilling takes advantage of this fact by using advanced techology to actually direct the drill bit towards a target. This was part of the innovation that enabled fracking to become a powerful method for oil and gas extraction. 

In the case of the borehole set we are working with for this demonstration which were drilled for lithology classification, the holes are fairly shallow and thus were not surveyed. We can therefore assume they are vertical, so the point calculations for the intervals are simply subtracting the depth of the interval from the collar elevation and using the same lat/long as the collar.  

```
// Calculate X,Y,Z point for intervals
match (c:Collar {Name:'141'})-[r:NEXT_INTERVAL*]-(i:Interval)
with c, i order by i.FromDepth
with c, collect(i) as intervals 
with c,intervals
unwind intervals as interval
with c,interval,c.El_DR_masl-interval.FromDepth as depth
set interval.location=point({x: c.Lat_NAD83, y: c.Long_NAD83,z:depth, crs:'WGS-84-3D'})
return c,interval

```

## Visualizing the Borehole Data

There are a large number of ways to visulize borehole data, although due to the specific domain associted with borehole data, these typically rely on expensive commercial software. 

In this case, we will use a cloud hosted visualizing tool called [Steno3d](https://steno3d.com/). This tool has python based Jupyter notebooks, and has a free for signup version for trying it out. 

### Visualizing Using Steno3D

Steno3D is a cloud based 3D visualization platform that allows for visualization of 3d data. Its used typically for geological applications, although is not limited to that domain. 

For this example, we will first use an export/import process to get the data into Steno following the Wolf-Pass example they provide: [Wolf Pass](https://github.com/seequent/steno3d-notebooks/blob/master/example_wolfpass.ipynb)

In order to use this example, you will need to have Python3 and Jupyter notebooks, setup and use PIP to install the Steno3d python library. You will also need to register for the Steno3d Site, and signup for a free developer key. Instructions are provided here: [Steno3d Python Client](https://python.steno3d.com/en/latest/)

The Wolf Pass example has a 3d surface visualization associated with it, but in this case we do not have the full surface data with the open source data set, so will forgoe that for this spatial experiement. I'll have to do some more digging to see if I can find an open source data set that has a more comprehenive model associated with it in a future post. 

To get the data from Neo4j, we will install and use the [Neo4j Python Driver](https://neo4j.com/developer/python/).

We will then write a Cypher query to get the relevant borehole interval information into a form that works for Steno3d's line upload process as described in Wolf Pass example, and in Steno3d's documentation [Line Mesh](https://python.steno3d.com/en/latest/content/api/resources/line.html).

```
>> ...
>> my_line = steno3d.Line(...)
>> ...
>> my_data = steno3d.DataArray(
       title='Six Numbers',
       array=[0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
   )
>> my_line.data = [dict(
       location='N',
       data=my_data
   )]
```

## Analyze and Correlate the Borehole Data in Neo4j

I wanted to try as well using the graph, spatial structure, and text analytics capabilities of neo4j to determine what advantages might be derived from modelling boreholes as a graph.

The immediate benefit is that the borehole data being a linked list of nodes is closer from a modelling perspective to reality. This simplifies the data modelling aspects considerably especially when it comes to complex boreholes. I will be looking to try the approach out on an oil and gas well in a future post to validate this. 

In this case, we have only the collar, basic collar metadata, interval nodes with lithology including primary consituents of the layers the borehole passes through, and a detail textual description of those layers.

