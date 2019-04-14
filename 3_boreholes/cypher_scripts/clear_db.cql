// ------------------------------------------------------------------
// DATA FOR GOOD DATATHON November, 2018
// Written by Menome Technologies Inc. http://www.menome.com
//
// Delete all nodes and relationships in the DB
// ------------------------------------------------------------------

MATCH(n) DETACH DELETE n
RETURN count(n) as deletedNodesCount;