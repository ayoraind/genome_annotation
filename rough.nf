params.assemblies = false
params.prokka = false
params.bakta = false
params.bakta_db = false
params.output_dir = false

process PROKKA {
    tag "$sample_id"
    
    publishDir params.output_dir, mode: 'copy'
    
    input:
        tuple val(sample_id), path(fastas)

    output:
     tuple val(sample_id), path("${sample_id}_prokka/${sample_id}.gff"), emit: gff_ch
     tuple val(sample_id), path("${sample_id}_prokka/${sample_id}.gbk"), emit: gbk_ch
     tuple val(sample_id), path("${sample_id}_prokka/${sample_id}.fna"), emit: fna_ch
     tuple val(sample_id), path("${sample_id}_prokka/${sample_id}.faa"), emit: faa_ch
     tuple val(sample_id), path("${sample_id}_prokka/${sample_id}.ffn"), emit: ffn_ch
     tuple val(sample_id), path("${sample_id}_prokka/${sample_id}.sqn"), emit: sqn_ch
     tuple val(sample_id), path("${sample_id}_prokka/${sample_id}.fsa"), emit: fsa_ch
     tuple val(sample_id), path("${sample_id}_prokka/${sample_id}.tbl"), emit: tbl_ch
     tuple val(sample_id), path("${sample_id}_prokka/${sample_id}.err"), emit: err_ch
     tuple val(sample_id), path("${sample_id}_prokka/${sample_id}.log"), emit: log_ch
     tuple val(sample_id), path("${sample_id}_prokka/${sample_id}.txt"), emit: txt_ch
     tuple val(sample_id), path("${sample_id}_prokka/${sample_id}.tsv"), emit: tsv_ch
     path "versions.yml"                                               , emit: versions_ch
     
    when:
    task.ext.when == null || task.ext.when
       
    script:
    def args = task.ext.args   ?: ''
    
    """
    prokka $args --cpus $task.cpus --outdir ${sample_id}_prokka --prefix ${sample_id} ${fastas} --metagenome
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prokka: \$(echo \$(prokka --version 2>&1) | sed 's/^.*prokka //')
    END_VERSIONS
    """
}

process BAKTA {
    tag "$sample_id"
    
    publishDir params.output_dir, mode: 'copy'
    
    input:
        tuple val(sample_id), path(fastas)
        path db
	
    output:
        tuple val(sample_id), path("${sample_id}_bakta/${sample_id}.embl")             , emit: embl_ch
    	tuple val(sample_id), path("${sample_id}_bakta/${sample_id}.faa")              , emit: faa_ch
    	tuple val(sample_id), path("${sample_id}_bakta/${sample_id}.ffn")              , emit: ffn_ch
    	tuple val(sample_id), path("${sample_id}_bakta/${sample_id}.fna")              , emit: fna_ch
    	tuple val(sample_id), path("${sample_id}_bakta/${sample_id}.gbff")             , emit: gbff_ch
    	tuple val(sample_id), path("${sample_id}_bakta/${sample_id}.gff3")             , emit: gff_ch
	tuple val(sample_id), path("${sample_id}_bakta/${sample_id}.json")             , emit: json_ch
	tuple val(sample_id), path("${sample_id}_bakta/${sample_id}.log")             , emit: log_ch
    	tuple val(sample_id), path("${sample_id}_bakta/${sample_id}.hypotheticals.tsv"), emit: hypotheticals_tsv_ch
    	tuple val(sample_id), path("${sample_id}_bakta/${sample_id}.hypotheticals.faa"), emit: hypotheticals_faa_ch
    	tuple val(sample_id), path("${sample_id}_bakta/${sample_id}.tsv")              , emit: tsv_ch
    	tuple val(sample_id), path("${sample_id}_bakta/${sample_id}.txt")              , emit: txt_ch
	path "versions.yml"                                                            , emit: versions_ch
	
	
    when:
    task.ext.when == null || task.ext.when
        
    script:
    def args = task.ext.args   ?: ''
    
    """
    bakta --db ${db} --keep-contig-headers --threads $task.cpus --prefix ${sample_id} --output ${sample_id}_bakta ${fastas}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bakta: \$(echo \$(bakta --version) 2>&1 | cut -f '2' -d ' ')
    END_VERSIONS
    """
}

workflow {
    assemblies_ch = Channel
                                .fromPath(params.assemblies)
                                .map { file -> tuple(file.simpleName, file) }
                                .ifEmpty { error "Cannot find any assembly fasta file matching: ${params.assemblies}" }

           BAKTA(assemblies_ch, params.bakta_db)
  
}
