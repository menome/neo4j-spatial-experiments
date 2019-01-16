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

## Importing Borehole Data

### Spatial References

The Boreholes.txt file uses NAD83. Currently Neo4j spatial only supports WGS84 - 'standard' lat/long. THis means we have to convert the borehole file from NAD83 to WGS84 as Neo4j does not currently support other spatial reference datums, nor does it support conversion between datums. Fortunately, there are a myriad of geospatial tools available to do this. Even better news: we can use open source tools to do this rather than needing ESRI, which is expensive. 

QGIS is the best open source alternative to ESRI, and it can be freely downloaded from: [Quantum GIS](https://qgis.org/en/site/)

I have included the converted the file in /datasources, but if you want to work through the process:


### Data Import Process


```
docker exec borehole bin/neo4j-shell -file /scripts/<name of the script from the "scripts" directory here>
```