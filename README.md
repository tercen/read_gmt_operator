# Read GMT operator

##### Description

`read_gmt` reads a GMT file containing a gene set annotation.

##### Usage

Input projection|.
---|---
`col`        | character, GMT document ID

Output relations|.
---|---
`set_id`        | gene set numeric identifier
`set_name`        | character, gene set name
`set_description`        | character, gene set description
`set_genes`        | character, gene name

##### Details

GMT is a standard gene set format.