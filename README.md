## Workflow to annotate genomes using either bakta or prokka.
### Usage

```

===================================================================
 GENOME ANNOTATION: TAPIR Pipeline version 1.0dev
===================================================================
 The typical command for running the pipeline is as follows:
        nextflow run main.nf --assemblies "PathToAssembly(ies)" --output_dir "PathToOutputDir"

        Mandatory arguments:
         --assemblies                   Query genome assembly file(s) to be supplied as input (e.g., "/MIGE/01_DATA/03_ASSEMBLY/T055-8-*.fasta")
         --output_dir                   Output directory to place output reads (e.g., "/MIGE/01_DATA/04_ANNOTATION/")
	 --bakta			must be supplied to run bakta
	 --prokka			must be supplied to run prokka
         
        Optional arguments:
	 --bakta_db			Path to bakta database if the --bakta option is supplied
         --help                         This usage statement.
         --version                      Version statement
```


## Introduction
This pipeline annotates genomes using bakta (using the `--bakta` option) or prokka (using the `--prokka` option). This Nextflow pipeline was adapted from NF Core's [bakta module](https://github.com/nf-core/modules/tree/master/modules/nf-core/bakta/bakta) and NF Core's [prokka module](https://github.com/nf-core/modules/tree/master/modules/nf-core/prokka).  

Bakta databases (full or light) can be downloaded from the [bakta Github page](https://github.com/oschwengers/bakta#database-download), or from [here](https://zenodo.org/record/7669534).

## Sample command
An example of a command to run this pipeline for bakta is:

```
nextflow run main.nf --assemblies '*.fasta' --output_dir test3 --bakta --bakta_db /absolute/file/path/to/db

```

and for prokka is:
```
nextflow run main.nf --assemblies '*.fasta' --output_dir 'test4' --prokka

```


## Word of Note
This is an ongoing project at the Microbial Genome Analysis Group, Institute for Infection Prevention and Hospital Epidemiology, Üniversitätsklinikum, Freiburg. The project is funded by BMBF, Germany, and is led by [Dr. Sandra Reuter](https://www.uniklinik-freiburg.de/institute-for-infection-prevention-and-control/microbial-genome-analysis.html).


## Authors and acknowledgment
The TAPIR (Track Acquisition of Pathogens In Real-time) team.
