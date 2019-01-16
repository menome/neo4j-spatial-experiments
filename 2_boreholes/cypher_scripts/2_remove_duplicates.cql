// ------------------------------------------------------------------
// Spatial Experiements #2, Boreholes January 1, 2019
// Written by Menome Technologies Inc. http://www.menome.com
//
// Remove duplicate records
// ------------------------------------------------------------------

// fix drilling companies
match (d:Recipient) with r.NamePhonetic as name, collect(r) as nodes
where size(nodes) > 1
with nodes, apoc.text.distance(apoc.text.clean(nodes[0].Name), apoc.text.clean(nodes[1].Name)) as rank
where rank <=1 
CALL apoc.refactor.mergeNodes([nodes[0],nodes[1]])
YIELD node RETURN node;

match (a:ArtsOrganization) with a
match (r:Recipient) 
 where apoc.text.distance(apoc.text.clean(r.Name), apoc.text.clean(a.Name)) <=1 
 with r,a
CALL apoc.refactor.mergeNodes([r,a]) yield node as new return new;