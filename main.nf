#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// include non-process modules
include { help_message; version_message; complete_message; error_message; pipeline_start_message } from './modules/messages.nf'
include { default_params; check_params } from './modules/params_parser.nf'
include { help_or_version } from './modules/params_utilities.nf'

// arrr maaannn, strict syntax is a pain
// version = '1.0dev'

// setup default params
//default_params = default_params()

// merge defaults with user params
//merged_params = default_params + params

// help and version messages
//help_or_version(merged_params, version)

//final_params = check_params(merged_params)

// starting pipeline
//pipeline_start_message(version, params)


// include processes
include { PROKKA; BAKTA } from './modules/processes.nf'

workflow {
    def pipeline_version = '1.0dev'
    def default_params_map = default_params()
    def merged_params = default_params_map + params
    help_or_version(merged_params, pipeline_version)
    def final_params = check_params(merged_params)
    pipeline_start_message(pipeline_version, final_params)

    if (final_params.assemblies && final_params.output_dir) {
        assemblies_ch = channel
        			.fromPath(final_params.assemblies)
        			.map { file -> tuple(file.simpleName, file) }
        			.ifEmpty { error "Cannot find any assembly fasta file matching: ${final_params.assemblies}" }

        if (final_params.prokka) {
            PROKKA(assemblies_ch)
        }
        if (final_params.bakta && final_params.bakta_db) {
            BAKTA(assemblies_ch, final_params.bakta_db)
        } else if (final_params.bakta && !final_params.bakta_db) {
            error "Please specify a path to the bakta database with the '--bakta_db' option to run bakta"
        }
        
    } else {
        error "Please specify a file path to the assembly directories '--assemblies fastas/*.fasta' and an output directory '--output_dir output'"
    }

    workflow.onComplete {
                        complete_message(final_params, workflow, pipeline_version)
                    }

    workflow.onError {
                        error_message(workflow)
                        }
}


