[//]: # "#to make links in gitlab: example with racon https://github.com/isovic/racon"
[//]: # "tricks in markdown: https://openclassrooms.com/fr/courses/1304236-redigez-en-markdown"

| usage | dependencies |
| --- | --- |
| [![Nextflow](https://img.shields.io/badge/code-Nextflow-blue?style=plastic)](https://www.nextflow.io/) | [![Dependencies: Nextflow Version](https://img.shields.io/badge/Nextflow-v22.10.3-blue?style=plastic)](https://github.com/nextflow-io/nextflow) |
| [![License: GPL-3.0](https://img.shields.io/badge/licence-GPL%20(%3E%3D3)-green?style=plastic)](https://www.gnu.org/licenses) | [![Dependencies: Singularity Version](https://img.shields.io/badge/Singularity-v3.8.0-blue?style=plastic)](https://github.com/apptainer/apptainer) |

<br /><br />
## TABLE OF CONTENTS


   - [AIM](#aim)
   - [CONTENT](#content)
   - [INPUT](#input)
   - [HOW TO RUN](#how-to-run)
   - [OUTPUT](#output)
   - [VERSIONS](#versions)
   - [LICENCE](#licence)
   - [CITATION](#citation)
   - [CREDITS](#credits)
   - [ACKNOWLEDGEMENTS](#Acknowledgements)
   - [WHAT'S NEW IN](#what's-new-in)

<br /><br />
## AIM

- Basic quality control of initial file structures (genotypes, pedigree information, SNP allele frequencies and SNP positions on human reference genome).
- Quality control analysis and file preparation by the Alohomora software (removal of uninformative SNPs and SNPs with Mendelian errors).
- Linkage and information analysis by the Merlin software.


<br /><br />
## CONTENT

**linkage.nf**: File that can be executed using a linux terminal, a MacOS terminal or Windows 10 WSL2.
<br /><br />
**linkage.config**: Parameter settings for the linkage.nf file. Users have to open this file, set the desired settings and save these modifications before execution.
<br /><br />
**bin**: Folder containing script files that are used by the linkage.nf file.


<br /><br />
## INPUT

- A genotype file.
- An allelic frequency file.
- A raw map file. BEWARE: replace the spaces in the Header.
- A raw pedigree file.

See the Alohomora_Format.doc in https://gmc.mdc-berlin.de/alohomora/docs.zip


<br /><br />
## HOW TO RUN

### 1. Prerequisite

Installation of:<br />
[nextflow DSL2](https://github.com/nextflow-io/nextflow)<br />
[Graphviz](https://www.graphviz.org/download/), `sudo apt install graphviz` for Linux ubuntu<br />
[Singularity/apptainer](https://github.com/apptainer/apptainer)<br />

<br /><br />
### 2. Local running (personal computer)


#### 2.1. linkage.nf file in the personal computer

- Mount a server if required:

<pre>
DRIVE="Z"
sudo mkdir /mnt/z
sudo mount -t drvfs $DRIVE: /mnt/z
</pre>

Warning: if no mounting, it is possible that nextflow does nothing, or displays a message like:
<pre>
Launching `linkage.nf` [loving_morse] - revision: d5aabe528b
/mnt/share/Users
</pre>

- Run the following command from where the linkage.nf and linkage.config files are (example: \\wsl$\Ubuntu-20.04\home\gael):

<pre>
nextflow run linkage.nf -c linkage.config
</pre>

with -c to specify the name of the config file used.

<br /><br />
#### 2.3. linkage.nf file in the public gitlab repository

Run the following command from where you want the results:

<pre>
nextflow run -hub pasteur gmillot/genetic_linkage -r v1.0.0
</pre>

<br /><br />
### 3. Distant running (example with the Pasteur cluster)

#### 3.1. Pre-execution

Copy-paste this after having modified the EXEC_PATH variable:

<pre>
EXEC_PATH="/pasteur/zeus/projets/p01/BioIT/gmillot/genetic_linkage" # where the bin folder of the linkage.nf script is located
export CONF_BEFORE=/opt/gensoft/exe # on maestro

export JAVA_CONF=java/13.0.2
export JAVA_CONF_AFTER=bin/java # on maestro
export SINGU_CONF=apptainer/1.1.5
export SINGU_CONF_AFTER=bin/singularity # on maestro
export GIT_CONF=git/2.39.1
export GIT_CONF_AFTER=bin/git # on maestro
export GRAPHVIZ_CONF=graphviz/2.42.3
export GRAPHVIZ_CONF_AFTER=bin/graphviz # on maestro

MODULES="${CONF_BEFORE}/${JAVA_CONF}/${JAVA_CONF_AFTER},${CONF_BEFORE}/${SINGU_CONF}/${SINGU_CONF_AFTER},${CONF_BEFORE}/${GIT_CONF}/${GIT_CONF_AFTER}/${GRAPHVIZ_CONF}/${GRAPHVIZ_CONF_AFTER}"
cd ${EXEC_PATH}
chmod 755 ${EXEC_PATH}/bin/*.*
module load ${JAVA_CONF} ${SINGU_CONF} ${GIT_CONF} ${GRAPHVIZ_CONF}
</pre>

<br /><br />
#### 3.2. linkage.nf file in a cluster folder

Modify the second line of the code below, and run from where the linkage.nf and linkage.config files are (which has been set thanks to the EXEC_PATH variable above):

<pre>
HOME_INI=$HOME
HOME="${ZEUSHOME}/genetic_linkage/" # $HOME changed to allow the creation of .nextflow into /$ZEUSHOME/genetic_linkage/, for instance. See NFX_HOME in the nextflow software script
trap '' SIGINT
nextflow run --modules ${MODULES} linkage.nf -c linkage.config
HOME=$HOME_INI
trap SIGINT
</pre>

<br /><br />
#### 3.3. linkage.nf file in the public gitlab repository

Modify the first and third lines of the code below, and run (results will be where the EXEC_PATH variable has been set above):

<pre>
VERSION="v1.0"
HOME_INI=$HOME
HOME="${ZEUSHOME}/genetic_linkage/" # $HOME changed to allow the creation of .nextflow into /$ZEUSHOME/genetic_linkage/, for instance. See NFX_HOME in the nextflow software script
trap '' SIGINT
nextflow run --modules ${MODULES} -hub pasteur gmillot/genetic_linkage -r $VERSION -c $HOME/linkage.config
HOME=$HOME_INI
trap SIGINT
</pre>

<br /><br />
### 4. Error messages and solutions

#### Message 1
```
Unknown error accessing project `gmillot/genetic_linkage` -- Repository may be corrupted: /pasteur/sonic/homes/gmillot/.nextflow/assets/gmillot/genetic_linkage
```

Purge using:
<pre>
rm -rf /pasteur/sonic/homes/gmillot/.nextflow/assets/gmillot*
</pre>

#### Message 2
```
WARN: Cannot read project manifest -- Cause: Remote resource not found: https://gitlab.pasteur.fr/api/v4/projects/gmillot%2Fgenetic_linkage
```

Contact Gael Millot (distant repository is not public).

#### Message 3

```
permission denied
```

Use chmod to change the user rights.


<br /><br />
## OUTPUT


**reports**: Folder containing the classical reports of nextflow including the *linkage.config* file used
<br /><br />
**merlin_reports**: Folder containing all the reports of the different processes
<br /><br />
**complete_lodscore.tsv**: Whole Genome Lodscore
<br /><br />
**cutoff\*complete_lodscore.tsv**: Lines of the complete_lodscore.tsv file above a Lodscore threshold defined in the linkage.config file
<br /><br />
**lodscore_whole_genome.pdf**: Plot of the Lodscore, whole genome and per chromosome
<br /><br />
**lodscore_settings.pdf**: Plot of the cutoff\*complete_lodscore.tsv files
<br /><br />
**lodscore_settings.pdf**: Plot of the cutoff\*complete_lodscore.tsv files
<br /><br />
**pedstats.markerinfo_c\***: Marker genotype statistics (one file per chromosome)
<br /><br />
**pedstats_c\*.pdf**: Summary of family structure (one file per chromosome)
<br /><br />
**raw_snp.freq.absent.in.map.txt**: raw snp in the freq file but absent in the map file
<br /><br />
**raw_snp.genotype.absent.in.freq.txt**: raw snp in the genotype file but absent in the freq file
<br /><br />
**raw_snp.genotype.absent.in.map.txt**: raw snp in the genotype file but absent in the map file
<br /><br />
**raw_snp.map.absent.in.freq.txt**: raw snp in the map file but absent in the freq file
<br /><br />
**raw_snp.not.geno.atall.in.genotype**: raw snp not genotyped in any of the indiv in the genotype file


<br /><br />
## VERSIONS


The different releases are tagged [here](https://gitlab.pasteur.fr/gmillot/genetic_linkage/-/tags)

<br /><br />
## LICENCE


This package of scripts can be redistributed and/or modified under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
Distributed in the hope that it will be useful, but without any warranty; without even the implied warranty of merchandability or fitness for a particular purpose.
See the GNU General Public License for more details at https://www.gnu.org/licenses.

<br /><br />
## CITATION


Not yet published


<br /><br />
## CREDITS


[Gael A. Millot](https://gitlab.pasteur.fr/gmillot), Hub, Institut Pasteur, Paris, France

<br /><br />
## ACKNOWLEDGEMENTS


Alexandre Mathieu, GHFC team, Institut Pasteur, Paris

Eric Deveaud, HPC Core Facility, Institut Pasteur, Paris

The developers & maintainers of the mentioned softwares and packages, including:

- [Bash](https://www.gnu.org/software/bash/)
- [R](https://www.r-project.org/)
- [ggplot2](https://ggplot2.tidyverse.org/)
- [ggtree](https://yulab-smu.top/treedata-book/)
- [Nextflow](https://www.nextflow.io/)
- [Singularity/Apptainer](https://apptainer.org/)
- [Docker](https://www.docker.com/)
- [Gitlab](https://about.gitlab.com/)


<br /><br />
## WHAT'S NEW IN

#### v2.6

code improved so that any error in R subprocess should stop nextflow execution


#### v2.5

code improved and debugged (error not anymore piped into tee notably)


#### v2.4

Bug solved in the R_main_functions_gael_20180123.R file


#### v2.3

Empty channel solved


### v2.2

pdf debugged and .Rdata returned, for making nice graphs thenafter


### v2.1

Small improve of linkage.nf file + README file


### v2.0

Pipeline ok. The checking process output has to be debugged (a few error messages) but not critical for the analysis


### v1.0

Pipeline ok but lack the information assembly and the checking part has to be debugged





