# Menome Technologies Presents Spatial Experiments with Neo4j!

Greetings! I have a long career in working with spatial data. This covers the range of standard GIS (ESRI and Geoserver, 3d modelling for mining operations, complex geological modelling, buildings and structures, finite element and numerical analysis. 

So it was incredibly exciting when Neo4j introduced spatial capabilities. While these are currently limited compared to what something like ESRI offers in terms of standard GIS analyisis such as buffering etc., the fact that neo4j supports both 3d spatial and 3d cartesian coordinates opens up a whole realm of possiblities that will ultimately trancend what a typical GIS can do.

This is because neo4j due to its graph model of nodes and relationships when combined with veing able to assign 3d sptaial and cartsian coordinates to nodes becomes both a GIS and what runs behind most CAD and numerical models. Standard CAD and GIS sytems use tabular data structures that are converted to graph structures in memory to do their work. Generally the data aspect and the structural/spatial/3d aspects are stored in seperate table structures. Autocad and Revit actually use completely seperate data and structural data stores to model buildings and other complex 3d objects.

Neo4j with its spatial capabilties now makes it possible to actually fully combine the 3d struture, spatial structure and data into a single model. It also being a graph database then has all the power that affords, plus the text analytics, lucene full text engine and AI/ML libraries. This suddently means that not only does it become possible to model spatial surface models such as Open Street Maps, but the buildings on those maps, the boreholes and subsurface data that make up geological or geotechnical data, and all of the reports, design documents and other structured and unstructured data that are associated with any complex engineering strucutre.

This has the potential to be incredibly powerful and very disruptive to the world of engineering and geology. 

My goal with these spatial experimentes is to explore using small,focused mini-projects the range of possiblities to validate how far I can take the spatial capabilities of neo4j.

## Experiment 1 - Walkscore computation using Neo4j

The first experiement was to take Open Street Map data and see if I could construct a basic spatial analysis using Neo4j. For this experiement I chose to pursue replicating the Walk Score algortihm. I did this because it is a well known, published algorithm that I could validate my work against. 

The Walk Score example is documented and stored in 1_walkscore directory. A further experiement will seek to imporve and replace the base Walk Score algorithm using Graph Techniques for calculating actual distance instead of linear distance to assess features, and will combine the Yelp ratings scores data to factor in amenity quality as part of the rank. 

[Read about Walkscore Here](./1_walkscore/readme.md)

![Deck GL Visualization of Amenities](./1_walkscore/deck.png)

## Experiement 2 - Subsurface data - Modelling boreholes with Neo4j

One of the disruptive aspects of Neo4j is that the graph modelling approach makes it possible to model not just the data, but also the structure of the data as it would be in the real world. 

This is a powerful enabler for geoscience related appliations for environmental, geotechnical, geological and geophysical data. Historically, these types of data require modelling the structural aspects such as the shape and location of an orebody, boreholes, environmental receptors, engineered structures and the data associated with those structures using multiple approaches and multiple systems. 

Neo4j has both cartesian and spatial capabilities, and because most structural modelling approaches in the geosciences use meshes or linked lists to model data, Neo4j is very well suited to these use cases. 

Further - Neo4j offers the potnetial to not only model the structures and data that compose those structures, but all adjacent and associated data in a single repository. It also offers powerful tools such as graph algorithms, natural language processing and the ability to factor in all decisions and versions of decisions made to develop a conceptual model of a complex site. 

We at Menome Technologies feel that Neo4j has the potential to have a major impact on the world of geology and engineering, and we are working hard to use our team's domain expertise in environmental, oil and gas, engineering, geology and AEC to explore applying Neo4j's capabilities to the world of Geology and Engineering. 

It seemed appropriate therefore to focus the second post in our series of Neo4j Spatial Experiements on modelling borehole data with Neo4j. 

### Geology Data Visualization

While Modelling geological data is a big part of the equation of developing a geological model, being able to effectively visualize and work with the geological model is crucial.

We were very excited therefore when we saw what Kinviz had developed with the GraphXR tool. The Kinviz team took the borehole model example, and projected it into GraphXR. 

![GraphXR 3D Borehole Visualization](./2_boreholes/GraphXR_3d_boreholes.png)

[Read about Borehole Data Modelling wiht Neo4j Here](./borehole/readme.md)
