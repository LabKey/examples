#!/usr/bin/env python3

import argparse
import base64
import os
import shutil
import sys
import tempfile
import xml.dom.minidom
import zipfile

"""
some elements found Thesaurus.owl (NCI)
NHC0 code
P90  FULL_SYN
P97  DEFINITION
P106 Semantic_Type
P107 Display_Name
P108 Preferred_name
P207 UMLS_CUI
P375 Maps_To
P383 term-group SY=synonym PT=preferred term
"""

class ImportConfig:
    def __init__(self):
        self.aboutAttributeName = "rdf:about"
        self.classElementTag = 'owl:Class'
        self.labelElementTag = 'rdfs:label'
        self.subClassOfElementTag = 'rdfs:subClassOf'
        self.subClassOfAttributeName = 'rdf:resource'
        self.synonymElementTag = 'P90'
        self.codeElementTag = None
        self.descriptionElementTag = None
        self.verbose = False

    def code_from_resource(self, r):
        hash = r.rfind("#")
        slash = r.rfind("/")
        i = max(hash,slash)
        return r[i+1:].strip()

    def path_part_from_code(self, code_str):
        return code_str.replace("_","~")


class NciThesaurusConfig(ImportConfig):
    def __init__(self):
        ImportConfig.__init__(self)
        self.codeElementTag = 'NHC0'
        self.descriptionElementTag = 'P97'

    def path_part_from_code(self, code_str):
        if code_str[0] == 'C':
            code_str = code_str[1:]
        try:
            code_int = int(code_str)
            return base64.b64encode( code_int.to_bytes(6, byteorder='big') ).decode().lstrip('A').replace('/','-')
        except:
            return code_str


class GoConfig(ImportConfig):
    def __init__(self):
        ImportConfig.__init__(self)

    def path_part_from_code(self, code_str):
        if code_str[0:3] == 'GO_':
            code_str = code_str[3:]
        try:
            code_int = int(code_str)
            return base64.b64encode( code_int.to_bytes(6, byteorder='big') ).decode().lstrip('A').replace('/','-')
        except:
            return code_str


class Concept:
    def __init__(self):
        self.code = None
        self.name = None
        self.description = None
        self.parent_codes = []
        self.paths = []
        self.path_part = None
        self.synonyms = {}

    def compute_paths(self, config, concepts):
        if self.paths:
            return self.paths
        self.path_part = config.path_part_from_code(self.code) + "/"
        for parent_code in self.parent_codes:
            if not parent_code in concepts:
                continue
            parent = concepts.get(parent_code)
            if not parent or parent == self.code:   # CONSIDER actual loop detection?
                continue
            parent_paths = parent.compute_paths(config, concepts)
            for p in parent_paths:
                parent_path = p[1]
                self.paths.append( (parent_code, parent_path + self.path_part) )
        if not self.paths:
            self.paths.append( ("", "/" + self.path_part) )
        return self.paths


def add_semantic_type(semantic_types, st):
    if st in semantic_types:
        return semantic_types[st]
    # create concept for semantic type
    concept = Concept()
    concept.code = 'ST' + str(1000000 + len(semantic_types))
    concept.name = st
    semantic_types[st] = concept
    return concept


def load_owl(config, file_path):
    concepts = []
    semantic_types = {}

    if config.verbose:
        print("parsing " + file_path)

    # CONSIDER use callback sax-style parsing
    doc = xml.dom.minidom.parse(file_path)
    classes = doc.getElementsByTagName(config.classElementTag)
    for c in classes:
        concept = Concept()

        about = c.getAttribute(config.aboutAttributeName)
        if not about:
            continue
        concept.code = config.code_from_resource(about)

        if config.codeElementTag:
            code_elements = c.getElementsByTagName(config.codeElementTag)
            if code_elements:
                concept.code = code_elements[0].firstChild.data.strip()
            else:
                pass    # TODO look somewhere else?

        label_elements = c.getElementsByTagName(config.labelElementTag)
        if label_elements:
            concept.name = label_elements[0].firstChild.data.strip()
        subClassOfElements = c.getElementsByTagName(config.subClassOfElementTag)
        for sc in subClassOfElements:
            r = sc.getAttribute(config.subClassOfAttributeName)
            concept.parent_codes.append(config.code_from_resource(r))

        synonym_elements = c.getElementsByTagName(config.synonymElementTag)
        for synonym in synonym_elements:
            concept.synonyms[synonym.firstChild.data.strip().lower()] = True
        if concept.name:
            concept.synonyms[concept.name.lower()] = True
        if concept.code:
            concept.synonyms[concept.code.lower()] = True

        # if no parent_codes use semantic type as parent
        if not concept.parent_codes:
            semantic_type_elements = c.getElementsByTagName("P106")
            if semantic_type_elements:
                for semantic_type_element in semantic_type_elements:
                    if semantic_type_element.firstChild and semantic_type_element.firstChild.data:
                        semantic_concept = add_semantic_type(semantic_types, semantic_type_element.firstChild.data)
                        concept.parent_codes.append(semantic_concept.code)

        # don't let deprecated codes with no parents gunk up the root of the hierarchy
        if not concept.parent_codes:
            deprecated_elements = c.getElementsByTagName("owl:deprecated")
            if deprecated_elements and deprecated_elements[0].firstChild and "true" == deprecated_elements[0].firstChild.data:
                deprecated_concept = add_semantic_type(semantic_types, "deprecated")
                concept.parent_codes.append(deprecated_concept.code)

        if concept.code and concept.name:
            concepts.append(concept)
        elif config.verbose:
            sys.stderr.write(c.toxml())
            sys.stderr.write("\n")

    for st in semantic_types:
        concepts.append(semantic_types[st])

    return concepts


def csv_value(s):
    if s is None:
        return ''
    s = str(s)
    if -1 == s.find('"'):
        return s
    return '"' + s.replace("\"", "\"\"") + '"'


def export_labkey(config, concepts, tempdir, archive):

    if config.verbose:
        print("computing paths")

    dictionary = {}
    for c in concepts:
        if c.code:
            dictionary[c.code] = c
    for c in concepts:
        c.compute_paths(config, dictionary)

    if config.verbose:
        print("writing hierarchy.txt")
    out = open(os.path.join(tempdir,'hierarchy.txt'),"w")
    out.write("level|path|code|parent_code\n")
    for c in concepts:
        for p in c.paths:
            parent_code = p[0]
            parent_path = p[1]
            out.write(str(parent_path.count('/')-1) + "|" + csv_value(parent_path) + "|" +  csv_value(c.code) + "|" + csv_value(parent_code) + "\n")
    out.close()

    if config.verbose:
        print("writing concepts.txt")
    out = open(os.path.join(tempdir,'concepts.txt'),"w")
    out.write("code|label|description\n")
    for c in concepts:
        out.write(csv_value(c.code) + "|" + csv_value(c.name) + "|" + csv_value(c.description) + "\n")
    out.close()

    if config.verbose:
        print("writing synonyms.txt")
    out = open(os.path.join(tempdir,'synonyms.txt'),"w")
    out.write("label|code\n")
    for c in concepts:
        for s in c.synonyms.keys():
            if len(s) > 400:
                print("skipping long synonym: " + s)
                continue
            out.write(csv_value(s) + "|" + csv_value(c.code) + "\n")
    out.close()

    if config.verbose:
        print("zipping " + archive)
    with zipfile.ZipFile(archive, 'w') as myzip:
        myzip.write(os.path.join(tempdir,'concepts.txt'), 'concepts.txt')
        myzip.write(os.path.join(tempdir,'hierarchy.txt'), 'hierarchy.txt')
        myzip.write(os.path.join(tempdir,'synonyms.txt'), 'synonyms.txt')


def main():
    parser = argparse.ArgumentParser(description='Process an OWL file and generate a LabKey ontology archive.')
    parser.add_argument('input', help='input .owl file')
    parser.add_argument('output', help='output .zip file')
    parser.add_argument('-k', '--keep', action="store_true", help='Keep temp files in same directory as output (may overwrite files)')
    parser.add_argument("-t", "--type", choices=['owl', 'nci', 'go'], help="Customize parser options")
    parser.add_argument("-v", "--verbose", action="store_true", help="Show progress and debugging output")
    args = parser.parse_args()

    config = ImportConfig()
    if args.type == 'nci':
        config = NciThesaurusConfig()
    elif args.type == 'go':
        config = GoConfig()

    if args.verbose:
        config.verbose = True

    if not os.path.isfile(args.input):
        print("input file not found: " + args.input)
        quit()
    if os.path.exists(args.output):
        print("output file already exists: " + args.output)
        quit()

    if not args.keep:
        tempdir = tempfile.mkdtemp()
    else:
        tempdir = os.path.dirname(args.output)
        if os.path.isfile(os.path.join(tempdir,'concepts.txt')):
            os.remove(os.path.join(tempdir,'concepts.txt'))
        if os.path.isfile(os.path.join(tempdir,'hierarchy.txt')):
            os.remove(os.path.join(tempdir,'hierarchy.txt'))
        if os.path.isfile(os.path.join(tempdir,'synonyms.txt')):
            os.remove(os.path.join(tempdir,'synonyms.txt'))

    concepts = load_owl(config, args.input)
    export_labkey(config, concepts, tempdir, args.output)

    if not args.keep:
        shutil.rmtree(tempdir)


if __name__ == "__main__":
    main()

