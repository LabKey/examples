#!/usr/bin/env python3

import argparse
import os.path
import shutil
import tempfile
import zipfile
from pyspark import SparkConf, SparkContext, SQLContext


def i2b2_read(sql_, path):
    return sql_.read \
        .option("header",True)\
        .option("sep",'|')\
        .option("quote",'"')\
        .option("escape",'"')\
        .csv(path)


def validate(sqlContext, concepts, hierarchy, aliases):
    errors = []
    warnings = []

    conceptsCount = concepts.count()
    aliasCount = aliases.count()
    hierarchyCount = hierarchy.count()

    if 0 == conceptsCount:
        errors.append("No concepts were found in concepts.txt")
    if 0 == hierarchyCount:
        errors.append("No paths were found in hierarchy.txt.")
    if 0 == aliasCount:
        warnings.append("No aliases were found in synonyms.txt.")

    if errors:
        return (errors, warnings)

    concepts.registerTempTable("C")
    hierarchy.registerTempTable("H")
    aliases.registerTempTable("A")

    # check code is PK
    v = sqlContext.sql("SELECT DISTINCT code FROM C WHERE code IS NOT NULL")
    if conceptsCount != v.count():
        errors.append("Concept codes are not all unique.")
    v.unpersist()

    # check label is NOT NULL
    v = sqlContext.sql("SELECT label FROM C WHERE label IS NULL")
    if 0 != v.count():
        errors.append("Some concepts do not have a label")
    v.unpersist()

    # check path is PK
    v = sqlContext.sql("SELECT DISTINCT path FROM H WHERE path IS NOT NULL")
    if hierarchyCount != v.count():
        errors.append("Hierarchy paths are not all unique.")
    v.unpersist()

    # check code is NOT NULL
    v = sqlContext.sql("SELECT code FROM H WHERE code IS NULL")
    if 0 != v.count():
        errors.append("Some hierarchies do not have a concept code.")
    v.unpersist()

    if errors:
        return (errors, warnings)

    # all concepts have at least one hierarchy
    # BUG/UNSUPPORTED? v = sqlContext.sql("SELECT code FROM C WHERE code NOT IN (SELECT DISTINCT code FROM H)")
    v = sqlContext.sql("SELECT code FROM C LEFT OUTER JOIN (SELECT DISTINCT code AS match FROM H) _H ON code = match WHERE match IS NULL")
    if 0 < v.count():
        error = "Some concepts were not found in hierarchies.txt."
        for row in v.take(10): error +=  "\n    " + row.code
        errors.append(error+'\n')
    v.unpersist()

    # all hierarchies have a valid concept code
    # BUG/UNSUPPORTED? v = sqlContext.sql("SELECT code FROM H WHERE code is NULL OR code NOT IN (SELECT code FROM C WHERE code IS NOT NULL)")
    v = sqlContext.sql("SELECT code FROM H LEFT OUTER JOIN (SELECT code AS match FROM C) _C ON code = match WHERE match IS NULL")
    if 0 < v.count():
        error = "Some paths are not associated with a recognized code."
        for row in v.take(10): error +=  "\n    " + row.code
        errors.append(error+'\n')
    v.unpersist()

    # all paths begin and end with “/”
    v = sqlContext.sql("SELECT path FROM H WHERE path NOT LIKE '/%/'")
    if 0 < v.count():
        error = "Some paths did not start and end with '/'."
        for row in v.take(10): error +=  "\n    " + row.path
        errors.append(error+'\n')
    v.unpersist()

    # paths should not contain pattern characters
    v = sqlContext.sql("SELECT path FROM H WHERE 0<instr(path,'%') OR 0<instr(path,'\\\\') OR  0<instr(path,'_')")
    if 0 < v.count():
        error = "Some paths contained reserved characters '%_\\' (percent, underscore, backslash)"
        for row in v.take(10): error +=  "\n    " + row.path
        errors.append(error+'\n')
    v.unpersist()

    # skip test if aliases tests if table is empty
    if 0 < aliasCount:
        # all concepts have at least one alias
        v = sqlContext.sql("SELECT code FROM C LEFT OUTER JOIN (SELECT DISTINCT code AS match FROM A) _H ON code = match WHERE match IS NULL")
        if 0 < v.count():
            warning = str(v.count()) + " concept codes do not have entries in aliases table."
            for row in v.take(10): warning += "\n    " + row.code
            warnings.append(warning)

        v.unpersist()

        v = sqlContext.sql("SELECT label FROM C LEFT OUTER JOIN (SELECT DISTINCT label AS match FROM A) _H ON lower(label) = match WHERE match IS NULL")
        if 0 < v.count():
            warning = str(v.count()) + " concept labels do not have entries in aliases table."
            for row in v.take(10): warning += "\n    " + row.label
            warnings.append(warning)
        v.unpersist()

    # no missing intermediate paths in hierarchy e.g. /a/ and /a/b/c/, but missing /a/b/
    v = sqlContext.sql("SELECT parent, path FROM (SELECT regexp_extract(path,'(.*/)[^/]+/', 1) AS parent FROM H) P LEFT OUTER JOIN H ON parent=path WHERE parent IS NOT NULL AND parent != '/' AND path IS NULL")
    if 0 < v.count():
        errors.append("Some paths are missing entries for their parent paths.")

    return (errors, warnings)


def main():
    parser = argparse.ArgumentParser(description='Run validation checks on a LabKey ontology archive.')
    parser.add_argument('input', help='LabKey ontology archive file (.zip)')
    args = parser.parse_args()

    if not os.path.isfile(args.input):
        print("input file not found: " + args.input)
        quit()

    conf = SparkConf().setAppName("App")
    conf = (conf.setMaster('local[*]')
            .set('spark.executor.memory', '4G')
            .set('spark.driver.memory', '4G')
            .set('spark.driver.maxResultSize', '4G'))
    sc = SparkContext(conf=conf)
    sql = SQLContext(sc)

    tempdir = None
    try:
        tempdir = tempfile.mkdtemp()

        with zipfile.ZipFile(args.input, 'r') as archive:
            archive.extractall(tempdir)

        concepts = i2b2_read(sql, os.path.join(tempdir, "concepts.txt"))
        hierarchy = i2b2_read(sql, os.path.join(tempdir, "hierarchy.txt"))
        aliases = i2b2_read(sql, os.path.join(tempdir, "synonyms.txt"))

        (errors,warnings) = validate(sql, concepts, hierarchy, aliases)
    finally:
        if tempdir:
            shutil.rmtree(tempdir)

    if errors:
        print("ERRORS")
        print("\n".join(errors))
    elif warnings:
        print("WARNINGS")
        print("\n".join(warnings))
    else:
        print("SUCCESSS")
        print("  no problems found")


if __name__ == "__main__":
    main()