Find OWL files for many important ontologies here:

 * [http://bioportal.bioontology.org/ontologies](http://bioportal.bioontology.org/ontologies)

Here is the NCI file I've used in testing:

 * [http://bioportal.bioontology.org/ontologies/NCIT](http://bioportal.bioontology.org/ontologies/NCIT)

Find i2b2 translated ontologies here:

 * [http://i2b2.bioontology.org/](http://i2b2.bioontology.org/)

# scripts 

**[rdf.py](./rdf.py)**

This script uses the rdflib python library to parse .owl files.  It should parse most owl files even if they use extensions to the OWL schema.  Except for
GO and NCI, try this script first.

**[owl.py](./owl.py)**

This is a simple script that understands basic OWL xml files.  However, it does not understand OWL extensions.  This script is recommended for
[NCI](http://bioportal.bioontology.org/ontologies/NCIT) and [GO](https://bioportal.bioontology.org/ontologies/GO) ontologies (see command-line options by running owl.py with no arguments).

**[i2b2.py](./i2b2.py)**
This script will convert files that are formatted for importing into i2b2.  NOTE: Many of these files handle escaping special characters
very poorly.

