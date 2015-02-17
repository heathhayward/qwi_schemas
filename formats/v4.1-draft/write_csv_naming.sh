#!/bin/bash
# print out info
if [[ -z $1 ]]
then
echo "
	$0 [start|version]

	will build the format documentation from CSV files and a template.
	
	Providing a format version overrides the automatically defined one
	"
	exit 1
fi

if [[ "$1" = "start" ]] 
then
# parse version from directory
   cwd=$(pwd)
   version=${cwd##*/}
else
   version=$1
fi
# convert the column definitions to CSV
sed 's/  /,/g;s/R N/R,N/; s/,,/,/g; s/,,/,/g; s/,,/,/g; s/, /,/g' column_definitions.txt | tail -n +2 > tmp.csv

# create ascii doc version
asciifile=lehd_csv_naming.asciidoc
echo "= LEHD Public Use CSV Naming Schema $version - CSV Naming Convention
$(date +%d\ %B\ %Y)

( link:$(basename $asciifile .asciidoc).pdf[Printable version] )

Purpose
-------
The public-use data from the Longitudinal Employer-Household Dynamics Program, including the Quarterly Workforce Indicators (QWI)
and Job-to-Job Flows (J2J), are available for download with the following data schema. 
These data are available as Comma-Separated Value (CSV) files through the LEHD website’s Data page at 
http://lehd.ces.census.gov/data/ and through LED Extraction Tool at http://ledextract.ces.census.gov/. 

This document describes the file naming schema for LEHD-provided CSV files. The contents (schema) are described in  link:lehd_public_use_schema.html[].

[IMPORTANT]
.Important
==============================================
This specification is draft. Feedback is welcome. Please write us at link:mailto:erika.mcentarfer@census.gov?subject=LEHD_Schema_draft[erika.mcentarfer@census.gov]
or link:mailto:lars.vilhuber@census.gov?subject=LEHD_Schema_draft[lars.vilhuber@census.gov].
==============================================


Extends
-------
This version extends v4.0. Any file compliant with LEHD or QWI Schema v4.0 will also be compliant with this schema.

Supersedes
----------
For the specified files, this is the first schema.


Basic Schema
------------

All files are preceded by a file type definition, followed by additional information on the aggregation level of the file, or 
some other identifier.

-------------------
[TYPE]_[DETAILS].csv
-------------------

=== QWIPU from the LED Extraction Tool
CSV files downloaded through the  LED Extraction Tool at http://ledextract.ces.census.gov/ follow the following naming convention:
------------------------------------
[type]_[id].csv
------------------------------------
where +[id]+ is the Request ID (a unique string of characters) generated every time ``Submit Request'' is clicked. The ID references each query submission made to the database.

=== Other files
Full CSV files downloaded from the LEHD website at http://lehd.ces.census.gov/data follow the following naming convention:
--------------------------------
[type]_[geohi]_[demo]_[fas]_[geocat]_[indcat]_[ownercat]_[sa]
--------------------------------
where each component is described in more detail below. Schema files detailing legal values for each component can be downloaded from this website. 

" > $asciifile


#########################3 Types
echo "
== Description of Filename Components

=== Types

( link:naming_type.csv[] )

[width=\"90%\",format=\"csv\",delim=\";\",cols=\"^1,<3,<5,<3\",options=\"header\"]
|===================================================
include::naming_type.csv[]
|===================================================
" >> $asciifile

######################## other components
# start with fips postal
name=fipsalpha
  arg=naming_$name.csv
  echo "=== $name 
( link:${arg}[] )

This component is the alphabetic FIPS state code equivalent to the numeric FIPS code in link:label_fipsnum.csv[], based on FIPS PUB 5-2.

[width=\"60%\",format=\"csv\",cols=\"^1,<4\",options=\"header\"]
|===================================================
type,Description
st,Any legal 2-character state postal code (see link:${arg}[] ))
us,National data (50 states + DC)
|===================================================
" >> $asciifile

for name in demo fas geocat indcat owncat sa
do
  arg=naming_$name.csv
  echo "=== $name 
( link:${arg}[] )

$( [[ $name = geohi ]] && echo 'This component is the alphabetic FIPS state code equivalent to the numeric FIPS code in link:label_geohi.csv[], based on https://catalog.data.gov/dataset/fips-state-codes[FIPS PUB 5-2].')

[width=\"60%\",format=\"csv\",cols=\"^1,<4\",options=\"header\"]
|===================================================
include::$arg[]
|===================================================
" >> $asciifile
done

echo "
[IMPORTANT]
.Important
==============================================
Some of the data products noted above do not exist yet.
==============================================

*******************
This version: $Revision: 595 $
*******************
" >> $asciifile
echo "$asciifile created"
asciidoc -a icons -a toc -a numbered -a linkcss $asciifile
echo "$(basename $asciifile .asciidoc).html created"
a2x -f pdf -a icons -a toc -a numbered -a linkcss $asciifile
echo "$(basename $asciifile .asciidoc).pdf created"
html2text $(basename $asciifile .asciidoc).html > $(basename $asciifile .asciidoc).txt
echo "$(basename $asciifile .asciidoc).txt created"
