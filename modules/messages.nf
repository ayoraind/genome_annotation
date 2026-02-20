def help_message() {
  log.info """
        Usage:
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
        """
}



def version_message(def version) {
      println(
            """
            ==========================================================
             GENOME ANNOTATION: TAPIR Pipeline version ${version}
            ==========================================================
            """.stripIndent()
        )

}

def pipeline_start_message(def version, def params_map){
    log.info "======================================================================"
    log.info "      GENOME ANNOTATION: TAPIR Pipeline version ${version}            "
    log.info "======================================================================"
    log.info "Running version   : ${version}"
    log.info "Fasta inputs      : ${params.assemblies}"
    log.info ""
    log.info "-------------------------- Other parameters --------------------------"
    params_map.sort{ it.key }.each{ k, v ->
        if (v){
            log.info "${k}: ${v}"
        }
    }
    log.info "======================================================================"
    log.info "Outputs written to path '${params.output_dir}'"
    log.info "======================================================================"

    log.info ""
}


def complete_message(def _params_map, def wf, def version){
    // Display complete message
    log.info ""
    log.info "Ran the workflow: ${wf.scriptName} ${version}"
    log.info "Command line    : ${wf.commandLine}"
    log.info "Completed at    : ${wf.complete}"
    log.info "Duration        : ${wf.duration}"
    log.info "Success         : ${wf.success}"
    log.info "Work directory  : ${wf.workDir}"
    log.info "Exit status     : ${wf.exitStatus}"
    log.info ""
}

def error_message(def wf){
    // Display error message
    log.info ""
    log.info "Workflow execution stopped with the following message:"
    log.info "  " + wf.errorMessage
}
