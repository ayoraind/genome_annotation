params.assemblies = false
params.prokka = false
params.bakta = false
params.bakta_db = false
params.output_dir = false

nextflow.preview.types = true

process PROKKA {
    tag "${sample_id}"

    publishDir params.output_dir, mode: 'copy'

    input:
    (sample_id, fastas): Tuple<?, Path>

    output:
    gff_ch = tuple(sample_id, file("${sample_id}_prokka/${sample_id}.gff"))
    gbk_ch = tuple(sample_id, file("${sample_id}_prokka/${sample_id}.gbk"))
    fna_ch = tuple(sample_id, file("${sample_id}_prokka/${sample_id}.fna"))
    faa_ch = tuple(sample_id, file("${sample_id}_prokka/${sample_id}.faa"))
    ffn_ch = tuple(sample_id, file("${sample_id}_prokka/${sample_id}.ffn"))
    sqn_ch = tuple(sample_id, file("${sample_id}_prokka/${sample_id}.sqn"))
    fsa_ch = tuple(sample_id, file("${sample_id}_prokka/${sample_id}.fsa"))
    tbl_ch = tuple(sample_id, file("${sample_id}_prokka/${sample_id}.tbl"))
    err_ch = tuple(sample_id, file("${sample_id}_prokka/${sample_id}.err"))
    log_ch = tuple(sample_id, file("${sample_id}_prokka/${sample_id}.log"))
    txt_ch = tuple(sample_id, file("${sample_id}_prokka/${sample_id}.txt"))
    tsv_ch = tuple(sample_id, file("${sample_id}_prokka/${sample_id}.tsv"))
    versions_ch = file("versions.yml")

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    prokka ${args} --cpus ${task.cpus} --outdir ${sample_id}_prokka --prefix ${sample_id} ${fastas} --metagenome
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        prokka: \$(echo \$(prokka --version 2>&1) | sed 's/^.*prokka //')
    END_VERSIONS
    """
}

process BAKTA {
    tag "${sample_id}"

    publishDir params.output_dir, mode: 'copy'

    input:
    (sample_id, fastas): Tuple<?, Path>
    db: Path

    output:
    embl_ch = tuple(sample_id, file("${sample_id}_bakta/${sample_id}.embl"))
    faa_ch = tuple(sample_id, file("${sample_id}_bakta/${sample_id}.faa"))
    ffn_ch = tuple(sample_id, file("${sample_id}_bakta/${sample_id}.ffn"))
    fna_ch = tuple(sample_id, file("${sample_id}_bakta/${sample_id}.fna"))
    gbff_ch = tuple(sample_id, file("${sample_id}_bakta/${sample_id}.gbff"))
    gff_ch = tuple(sample_id, file("${sample_id}_bakta/${sample_id}.gff3"))
    json_ch = tuple(sample_id, file("${sample_id}_bakta/${sample_id}.json"))
    log_ch = tuple(sample_id, file("${sample_id}_bakta/${sample_id}.log"))
    hypotheticals_tsv_ch = tuple(sample_id, file("${sample_id}_bakta/${sample_id}.hypotheticals.tsv"))
    hypotheticals_faa_ch = tuple(sample_id, file("${sample_id}_bakta/${sample_id}.hypotheticals.faa"))
    tsv_ch = tuple(sample_id, file("${sample_id}_bakta/${sample_id}.tsv"))
    txt_ch = tuple(sample_id, file("${sample_id}_bakta/${sample_id}.txt"))
    versions_ch = file("versions.yml")

    when:
    task.ext.when == null || task.ext.when

    script:
    def _args = task.ext.args ?: ''

    """
    bakta --db ${db} --keep-contig-headers --threads ${task.cpus} --prefix ${sample_id} --output ${sample_id}_bakta ${fastas}
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bakta: \$(echo \$(bakta --version) 2>&1 | cut -f '2' -d ' ')
    END_VERSIONS
    """
}

workflow {
    assemblies_ch = channel
                                .fromPath(params.assemblies)
                                .map { file -> tuple(file.simpleName, file) }
                                .ifEmpty { error "Cannot find any assembly fasta file matching: ${params.assemblies}" }

           BAKTA(assemblies_ch, params.bakta_db)
  
}
