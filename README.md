[//]: # "#to make links in gitlab: example with racon https://github.com/isovic/racon"
[//]: # "tricks in markdown: https://openclassrooms.com/fr/courses/1304236-redigez-en-markdown"

| usage | dependencies |
| --- | --- |
| [![Nextflow](https://img.shields.io/badge/code-Nextflow-blue?style=plastic)](https://www.nextflow.io/) | [![Dependencies: Nextflow Version](https://img.shields.io/badge/Nextflow-v22.10.3-blue?style=plastic)](https://github.com/nextflow-io/nextflow) |
| [![License: GPL-3.0](https://img.shields.io/badge/licence-GPL%20(%3E%3D3)-green?style=plastic)](https://www.gnu.org/licenses) | |

<br /><br />
## TABLE OF CONTENTS


   - [AIM](#aim)
   - [CONTENT](#content)
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

	1) basic quality control of initial file structures (genotypes, pedigree information, SNP allele frequencies and SNP positions on human reference genome)
	2) quality control analysis and file preparation by the Alohomora software (removal of uninformative SNPs and SNPs with Mendelian errors)
	3) linkage and information analysis by the Merlin software


<br /><br />
## CONTENT

**linkage.nf**: File that can be executed using a CLI (command line interface)
<br /><br />
**linkage.config**: Parameter settings for the linkage.nf file
<br /><br />
**dataset**: Folder containing some datasets (batch of fasta files) than can be used as examples
<br /><br />
**bin**: Folder containing script files that are used by the linkage.nf file


<br /><br />
## HOW TO RUN


### From local using local files

1) Mount a server if required:

```bash
DRIVE="C"
sudo mkdir /mnt/share
sudo mount -t drvfs $DRIVE: /mnt/share
```

Warning: if no mounting, it is possible that nextflow does nothing, or displays a message like
```
Launching `linkage.nf` [loving_morse] - revision: d5aabe528b
/mnt/share/Users
```

2) Run the following command from where the linkage.nf and linkage.config files are (example: \\wsl$\Ubuntu-20.04\home\gael):

```bash
nextflow run linkage.nf -c linkage.config
```

with -c to specify the name of the config file used.

<br /><br />
### From local using the committed version of a public gitlab repository

1) run the following command:

```bash
nextflow run -hub pasteur gmillot/genetic_linkage -r v1.0.0
```


2) If an error message appears, like:
```
WARN: Cannot read project manifest -- Cause: Remote resource not found: https://gitlab.pasteur.fr/api/v4/projects/gmillot%2Flinkage
```
	Make the distant repo public.
	In settings/General/Visibility, project features, permissions, check that every item is "on" with "Everyone With Access" and then save the changes.

<br /><br />
### From local using the committed version of a private gitlab repository

1) Create the scm file:

```bash
providers {
    pasteur {
        server = 'https://gitlab.pasteur.fr'
        platform = 'gitlab'
    }
}
```

And save it as 'scm' in the .nextflow folder. For instance in:
\\wsl$\Ubuntu-20.04\home\gael\.nextflow

Warning: ssh key must be set for gitlab, to be able to use this procedure.


2) Mount a server if required:

```bash
DRIVE="C"
sudo mkdir /mnt/share
sudo mount -t drvfs $DRIVE: /mnt/share
```

Warning: if no mounting, it is possible that nextflow does nothing, or displays a message like
```
Launching `linkage.nf` [loving_morse] - revision: d5aabe528b
/mnt/share/Users
```


3) Then run the following command (example: from here \\wsl$\Ubuntu-20.04\home\gael):

```bash
nextflow run -hub pasteur gmillot/genetic_linkage -r v1.0.0
```

<br /><br />
### From a cluster using a committed version on gitlab

Start with:

```bash
EXEC_PATH="/pasteur/zeus/projets/p01/BioIT/gmillot/genetic_linkage" # where the bin folder of the linkage.nf script is located
export CONF_BEFORE=/opt/gensoft/exe # on maestro

export JAVA_CONF=java/13.0.2
export JAVA_CONF_AFTER=bin/java # on maestro
export SINGU_CONF=apptainer/1.1.5
export SINGU_CONF_AFTER=bin/singularity # on maestro
export GIT_CONF=git/2.25.0
export GIT_CONF_AFTER=bin/git # on maestro

MODULES="${CONF_BEFORE}/${JAVA_CONF}/${JAVA_CONF_AFTER},${CONF_BEFORE}/${SINGU_CONF}/${SINGU_CONF_AFTER},${CONF_BEFORE}/${GIT_CONF}/${GIT_CONF_AFTER}"
cd ${EXEC_PATH}
chmod 755 ${EXEC_PATH}/bin/*.*
module load ${JAVA_CONF} ${SINGU_CONF} ${GIT_CONF}

```

Then run:

```bash
# distant linkage.nf file
HOME="${ZEUSHOME}/genetic_linkage/" ; trap '' SIGINT ; nextflow run --modules ${MODULES} -hub pasteur gmillot/genetic_linkage -r v1.0 -c $HOME/linkage.config ; HOME="/pasteur/appa/homes/gmillot/"  ; trap SIGINT

# local linkage.nf file ($HOME changed to allow the creation of .nextflow into /$ZEUSHOME/genetic_linkage/. See NFX_HOME in the nextflow soft script)
HOME="${ZEUSHOME}/genetic_linkage/" ; trap '' SIGINT ; nextflow run --modules ${MODULES} linkage.nf -c linkage.config ; HOME="/pasteur/appa/homes/gmillot/" ; trap SIGINT
```

<br /><br />
### Error messages

1)
```
Unknown error accessing project `gmillot/genetic_linkage` -- Repository may be corrupted: /pasteur/sonic/homes/gmillot/.nextflow/assets/gmillot/genetic_linkage
```
Purge using:
```
rm -rf /pasteur/sonic/homes/gmillot/.nextflow/assets/gmillot*
```

2)
```
WARN: Cannot read project manifest -- Cause: Remote resource not found: https://gitlab.pasteur.fr/api/v4/projects/gmillot%2Flinkage
```
Make the distant repo public.


3)

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

The mentioned softwares and packages developers & maintainers

Gitlab developers & maintainers

<br /><br />
## WHAT'S NEW IN


### v2.2

pdf debugged and .Rdata returned, for making nice graphs thenafter


### v2.1

Small improve of linkage.nf file + README file


### v2.0

Pipeline ok. The checking process output has to be debugged (a few error messages) but not critical for the analysis


### v1.0

Pipeline ok but lack the information assembly and the checking part has to be debugged





