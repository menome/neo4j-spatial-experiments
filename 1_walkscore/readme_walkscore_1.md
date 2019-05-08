
## Experiment 1 - Walkscore computation using Neo4j

The first experiement was to take Open Street Map data and see if I could construct a basic spatial analysis using Neo4j. For this experiement I chose to pursue replicating the Walk Score algortihm. I did this because it is a well known, published algorithm that I could validate my work against. 

The Walk Score example is documented and stored in 1_walkscore directory. A further experiement will seek to imporve and replace the base Walk Score algorithm using Graph Techniques for calculating actual distance instead of linear distance to assess features, and will combine the Yelp ratings scores data to factor in amenity quality as part of the rank. 

[Read about Walkscore Here](./1_walkscore/readme.md)

![Deck GL Visualization of Amenities](./1_walkscore/deck.png)