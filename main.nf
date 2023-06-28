#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// include non-process modules
include { help_message; version_message; complete_message; error_message; pipeline_start_message } from './modules/messages.nf'
include { default_params; check_params } from './modules/params_parser.nf'
include { help_or_version } from './modules/params_utilities.nf'

version = '1.0dev'

// setup default params
default_params = default_params()

// merge defaults with user params
merged_params = default_params + params

// help and version messages
help_or_version(merged_params, version)

final_params = check_params(merged_params)

// starting pipeline
pipeline_start_message(version, final_params)


// include processes
include { PROKKA; BAKTA } from './modules/processes.nf' addParams(final_params)

workflow {
    if (final_params.assemblies && final_params.output_dir) {
        assemblies_ch = Channel
        			.fromPath(final_params.assemblies)
        			.map { file -> tuple(file.simpleName, file) }
        			.ifEmpty { error "Cannot find any assembly fasta file matching: ${final_params.assemblies}" }

        if (final_params.prokka) {
            PROKKA(assemblies_ch)
    }
        if (final_params.bakta && final_params.bakta_db) {
            BAKTA(assemblies_ch, final_params.bakta_db)
    }
        
    } else {
        error "Please specify a file path to the assembly directories '--assemblies fastas/*.fasta' and an output directory '--output_dir output'"
    }
}

workflow.onComplete {
    complete_message(final_params, workflow, version)
}

workflow.onError {
    error_message(workflow)
}
