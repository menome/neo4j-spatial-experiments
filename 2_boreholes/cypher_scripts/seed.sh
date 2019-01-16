#!/bin/bash

# Run a bunch of cypher queries one after another

/var/lib/neo4j/bin/neo4j-shell -file /scripts/clear_db.cql
/var/lib/neo4j/bin/neo4j-shell -file /scripts/1_import_boreholes.cql
