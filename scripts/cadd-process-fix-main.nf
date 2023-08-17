process CADD {

    // Modified CADD process:
    // - Remove chr prefix from vcf
    // - Use a custom singularity image
    // - Change the path of the bind mount for the annotations, and apply no-home option

    tag "$meta.id"
    label 'process_small'

    conda "bioconda::cadd-scripts=1.6 anaconda::conda=4.14.0 conda-forge::mamba=1.4.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        "$baseDir/../../singularity/local-cadd-v1.6.sif":
        'biocontainers/mulled-v2-8d145e7b16a8ca4bf920e6ca464763df6f0a56a2:d4e457a2edecb2b10e915c01d8f46e29e236b648-0' }"

    containerOptions {
        (workflow.containerEngine == 'singularity') ?
            "--no-home --env XDG_CACHE_HOME=/tmp/.cache -B $launchDir/ref/CADD-v1.6:/opt/conda/share/cadd-scripts-1.6-1/data/annotations" :
            "--privileged -v ${annotation_dir}:/opt/conda/share/cadd-scripts-1.6-1/data/annotations"
        }

    input:
    tuple val(meta), path(vcf)
    path(annotation_dir)

    output:
    tuple val(meta), path("*.tsv.gz"), emit: tsv
    path "versions.yml"              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = "1.6" // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    """
    # Remove chr prefix from vcf
    gunzip -c $vcf | awk  '{gsub(/^chr/,""); print}' > cadd_in.vcf
    # Run CADD
    cadd.sh \\
        -o cadd_out.tsv.gz \\
        $args \\
        cadd_in.vcf
    # Add back chr prefix
    gunzip -c cadd_out.tsv.gz | awk '{if(\$0 !~ /^#/) print "chr"\$0; else print \$0}' | bgzip > ${prefix}.tsv.gz
    rm cadd_out.tsv.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cadd: $VERSION
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def VERSION = "1.6" // WARN: Version information not provided by tool on CLI. Please update version string below when bumping container versions.
    """
    touch ${prefix}.tsv.gz

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cadd: $VERSION
    END_VERSIONS
    """
}
