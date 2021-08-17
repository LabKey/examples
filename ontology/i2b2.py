#!/usr/bin/env python3

import argparse
import os.path
import shutil
import tempfile
import zipfile
from pyspark import SparkConf, SparkContext, SQLContext


# use backslash escapes
def cleanup_field_backslash(s):
    s = s.strip()
    if len(s) >= 2 and ('"' == s[0] and '"' == s[len(s)-1]):
        s = s[1:len(s)-1]
    s = s.replace("\\", "\\\\")
    s = s.replace("|", "\\|")
    s = s.replace("\"", "\\\"")
    if "(null)" == s:
        return ""
    if (-1 == s.find('\\')):
        return s
    return '"' + s + '"'

# use "" escapes
def cleanup_field_quote(s):
    s = s.strip()
    if len(s) >= 2 and ('"' == s[0] and '"' == s[len(s)-1]):
        s = s[1:len(s)-1]
    if "(null)" == s:
        return ""
    s = s.replace("\\", "/")
    if -1 == s.find('"') and -1 == s.find('|'):
        return s
    return '"' + s.replace("\"", "\"\"") + '"'


def cleanup(in_file, out_file):

    while True:
        line = in_file.readline()
        if 0 == len(line):
            break
        field_start = 0
        field_count = 0
        while field_start < len(line):
            ch = line[field_start]
            if '"' == ch:
                field_end = line.find('"|', field_start+1)
                if -1 != field_end:
                    field = line[field_start:field_end+1]
                    field_start = field_end+2
                else:
                    # and here is the big hack... guess if we need to handle a line continuation
                    field = line[field_start:].strip()
                    if '"' != field[len(field)-1] or 1 == field.count('"') % 2:
                        l = in_file.readline()
                        if None != l:
                            line = line.strip('\n') + l
                            continue
                    field_start = len(line)
            else:
                field_end = line.find('|', field_start+1)
                if -1 == field_end:
                    field = line[field_start:].strip()
                    field_start = len(line)
                else:
                    field = line[field_start:field_end]
                    field_start = field_end + 1

            if field_count > 0:
                out_file.write("|")
            field = cleanup_field_quote(field)
            out_file.write(field)
            field_count = field_count + 1
        out_file.write("\n")


def i2b2_read(sql, path, strip):
    df = sql.read \
        .option("header",True)\
        .option("sep",'|')\
        .option("quote",'"')\
        .option("escape",'"')\
        .csv(path)
    if not strip:
        return df

    df.registerTempTable("raw")
    stripped = sql.sql(
        "SELECT coalesce(split(c_basecode,':')[1],c_basecode) AS c_basecode,"
        "    c_hlevel,c_fullname,c_name,c_synonym_cd,c_visualattributes,c_facttablecolumn,c_tablename,c_columnname,c_columndatatype,c_operator,c_dimcode,c_tooltip,sourcesystem_cd,c_symbol,c_path,i_snomed_ct,i_snomed_rt,i_cui,i_tui,i_ctv3,i_full_id,update_date,m_applied_path\n"
        "FROM raw\n"
    )
    stripped.show()
    return stripped


# this is very memory intensive
# less memory intensive would be to use df.to_csv(tempdir) and then move the generated file
def i2b2_write(sql_, df, path):
    df.toPandas().to_csv(path, index=False, header=True, sep='|', quotechar='"', escapechar='"')


def save_labkey_ontology(sqlContext, df, tempdir, archive):
    df.registerTempTable("i2b2")

    # Note problem case with SNOMED "Upper case Roman letter" and "Lower case Roman letter"
    aliases = sqlContext.sql(
        "SELECT DISTINCT LCASE(c_name) AS label, c_basecode AS code\n" +
        "FROM i2b2\n"
        "GROUP BY c_name, c_basecode"
     )
    #aliases.show()
    i2b2_write(sqlContext, aliases, os.path.join(tempdir,"synonyms.txt"))

    concepts = sqlContext.sql(
        "SELECT MIN(c_name) AS label, c_basecode AS code, MIN(c_tooltip) AS description\n" +
        "FROM i2b2\n" +
        "WHERE c_synonym_cd = 'N'"
        "GROUP BY c_basecode"
    )
    #concepts.show()
    i2b2_write(sqlContext, concepts, os.path.join(tempdir,"concepts.txt"))

    h = sqlContext.sql(
        "  SELECT MIN(c_hlevel) AS level, c_fullname AS path, MIN(c_basecode) AS code, " +
        "       regexp_replace(c_fullname, '/[^/]+/$', '/')  AS parent_path\n"
        "  FROM i2b2\n"
        "  WHERE c_synonym_cd = 'N'\n" +
        "  GROUP BY c_fullname\n"
    )
    h.registerTempTable("H")
    hierarchy = sqlContext.sql(
        "SELECT hierarchy.level, hierarchy.path, hierarchy.code, parent.code as parent_code\n"
        "FROM H hierarchy LEFT OUTER JOIN H parent ON hierarchy.parent_path = parent.path\n"
        "ORDER BY path"
    )
    #hierarchy.show()
    i2b2_write(sqlContext, hierarchy, os.path.join(tempdir,"hierarchy.txt"))

    sqlContext.dropTempTable("i2b2")

    with zipfile.ZipFile(archive, 'w') as myzip:
        myzip.write(os.path.join(tempdir,'concepts.txt'), 'concepts.txt')
        myzip.write(os.path.join(tempdir,'hierarchy.txt'), 'hierarchy.txt')
        myzip.write(os.path.join(tempdir,'synonyms.txt'), 'synonyms.txt')


# TEST CODE
def main():
    parser = argparse.ArgumentParser(description='Process an i2b2 file (.txt) and generate a LabKey ontology archive (.zip).')
    parser.add_argument('input', help='input .txt file')
    parser.add_argument('output', help='output .zip file')
    parser.add_argument('-k', '--keep', action="store_true", help='Keep temp files in same directory as output (may overwrite files)')
    parser.add_argument('-s', '--strip', action="store_true", help='Strip prefix from concept codes (e.g. "SNO:")')
    #parser.add_argument("-v", "--verbose", action="store_true", help="Show progress and debugging output")
    args = parser.parse_args()

    if not os.path.isfile(args.input):
        print("input file not found: " + args.input)
        quit()
    if os.path.exists(args.output):
        print("output file already exists: " + args.output)
        quit()

    if not args.keep:
        tempdir = tempfile.mkdtemp()
        csv_file = os.path.join(tempdir, 'i2b2.tmp.csv')
    else:
        tempdir = os.path.dirname(args.output)
        csv_file = os.path.join(tempdir, 'i2b2.tmp.csv')
        if os.path.isfile(csv_file):
            os.remove(csv_file)
        if os.path.isfile(os.path.join(tempdir,'concepts.txt')):
            os.remove(os.path.join(tempdir,'concepts.txt'))
        if os.path.isfile(os.path.join(tempdir,'hierarchy.txt')):
            os.remove(os.path.join(tempdir,'hierarchy.txt'))
        if os.path.isfile(os.path.join(tempdir,'synonyms.txt')):
            os.remove(os.path.join(tempdir,'synonyms.txt'))

    in_file = open(args.input,"r")
    out_file = open(csv_file,"x")
    cleanup(in_file,out_file)
    in_file.close()
    out_file.close()

    conf = SparkConf().setAppName("App")
    conf = (conf.setMaster('local[*]')
            .set('spark.executor.memory', '4G')
            .set('spark.driver.memory', '4G')
            .set('spark.driver.maxResultSize', '4G'))
    sc = SparkContext(conf=conf)

    sql = SQLContext(sc)
    df = i2b2_read(sql, csv_file, args.strip)
    save_labkey_ontology(sql, df, tempdir, args.output)

    if not args.keep:
        shutil.rmtree(tempdir)


if __name__ == "__main__":
    main()