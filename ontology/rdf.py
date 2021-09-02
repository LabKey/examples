#!/usr/bin/env python3
import logging
import os

import argparse
import tempfile
import zipfile

import rdflib

verbose = False
warnings = {}

class Concept:
    def __init__(self):
        self.code = None
        self.name = None
        self.description = None
        self.parent_codes = []
        self.paths = []
        self.path_part = None
        self.synonyms = {}

    def compute_paths(self, concepts):
        if self.paths:
            return self.paths
        for parent_code in self.parent_codes:
            if not parent_code in concepts:
                continue
            parent = concepts.get(parent_code)
            if not parent or parent == self.code:   # CONSIDER actual loop detection?
                continue
            parent_paths = parent.compute_paths(concepts)
            for p in parent_paths:
                parent_path = p[1]
                self.paths.append( (parent_code, parent_path + self.path_part) )
        if not self.paths:
            self.paths.append( ("", "/" + self.path_part) )
        return self.paths


path_counter = 0

# call once per code
def valid_path_part(s):
    global path_counter
    path_counter = path_counter+1
    return str(path_counter)


def csv_value(s):
    if s is None:
        return ''
    s = str(s)
    if -1 == s.find('"'):
        return s
    return '"' + s.replace("\"", "\"\"") + '"'


def export_labkey(concepts, tempdir, archive):
    for key, c in concepts.items():
        if not c.name:
            c.name = c.code
        c.compute_paths(concepts)

    if verbose:
        print("writing hierarchy.txt")
    out = open(os.path.join(tempdir, 'hierarchy.txt'), "w")
    out.write("level|path|code|parent_code\n")
    for key, c in concepts.items():
        for p in c.paths:
            parent_code = p[0]
            parent_path = p[1]
            out.write(str(parent_path.count('/')-1) + "|" + csv_value(parent_path) + "|" +  csv_value(c.code) + "|" + csv_value(parent_code) + "\n")
    out.close()

    if verbose:
        print("writing concepts.txt")
    out = open(os.path.join(tempdir,'concepts.txt'),"w")
    out.write("code|label|description\n")
    for key, c in concepts.items():
        if (len(c.code) > 50):
            print(c.code)
        out.write(csv_value(c.code) + "|" + csv_value(c.name) + "|" + csv_value(c.description) + "\n")
    out.close()

    if verbose:
        print("writing synonyms.txt")
    out = open(os.path.join(tempdir,'synonyms.txt'),"w")
    out.write("label|code\n")
    for key, c in concepts.items():
        for s in c.synonyms.keys():
            if len(s) > 400:
                print("skipping long synonym: " + s)
                continue
            out.write(csv_value(s) + "|" + csv_value(c.code) + "\n")
    out.close()

    if verbose:
        print("zipping " + archive)
    with zipfile.ZipFile(archive, 'w') as myzip:
        myzip.write(os.path.join(tempdir, 'concepts.txt'), 'concepts.txt')
        myzip.write(os.path.join(tempdir, 'hierarchy.txt'), 'hierarchy.txt')
        myzip.write(os.path.join(tempdir, 'synonyms.txt'), 'synonyms.txt')


def main():
    global verbose
    parser = argparse.ArgumentParser(description='Process an RDF file using rdflib and generate a LabKey ontology archive.')
    parser.add_argument('input', help='input .owl file')
    parser.add_argument('output', help='output .zip file')
    parser.add_argument('-l', '--language', default="en", help='Specify desired language (default=en)')
    parser.add_argument('-k', '--keep', action="store_true", help='Keep temp files in same directory as output (may overwrite files)')
    parser.add_argument("-v", "--verbose", action="store_true", help="Show progress and debugging output")
    args = parser.parse_args()

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

    if args.verbose:
        verbose = args.verbose

    g = rdflib.Graph()
    g.parse(args.input, format='application/rdf+xml')

    concepts = {}

    for s, p, o in g:
        if -1 == s.find("#"):
            continue
        lang = args.language
        if isinstance(o, rdflib.term.BNode):
            continue
        elif isinstance(o, rdflib.term.Literal):
            if o.language and o.language != args.language:
                continue
        s = str(s)
        p = str(p)
        o = str(o)
        # print(s, p, o)
        full_code = s[s.find("#") + 1:]
        MAXCODE=40
        code = full_code[0:MAXCODE]
        if not code:
            continue
        if code not in concepts:
            c = Concept()
            if len(full_code) > MAXCODE:
                print("warning: code truncated to " + str(MAXCODE) + " chars '" + full_code + "'")
            c.code = code[0:MAXCODE]
            c.path_part = valid_path_part(code) + "/"
            c.synonyms[c.code.lower()] = True
            concepts[code] = c
        c = concepts[code]

        if p.endswith("#prefLabel"):
            c.name = o
            c.synonyms[c.name.lower()] = True
        elif p.endswith("#altLabel"):
            c.synonyms[o.lower()] = True
        elif p.endswith("#subClassOf") and o:
            parent_code = o[o.find('#')+1:]
            c.parent_codes.append(parent_code[0:MAXCODE])

    export_labkey(concepts, tempdir, args.output)


main()
