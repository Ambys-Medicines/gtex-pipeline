task rnaseqc1 {
    File bam_file
    File genes_gtf
    File genome_fasta_tarball ## only necessary for RNA-SeQC 1 workflow, v2 just uses FASTA file 
	File rnaseq1_script

    String prefix
    String? gatk_flags
    String? rnaseqc_flags 

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

    command {
        set -euo pipefail

        # pull and extract reference genome FASTA
        echo $(date +"[%b %d %H:%M:%S] Extract reference FASTA")
        tar -xzvf ${genome_fasta_tarball} --directory=$(pwd)
        genome_fasta="$(basename ${genome_fasta_tarball} .tar.gz).fasta"
		genome_fasta_index="$(echo genome_fasta).fai"

		# ensure that reference genome index is newer than reference genome file 
        touch $genome_fasta_index

        # need to index BAM file before running rnaseqc
        echo $(date +"[%b %d %H:%M:%S] Indexing BAM file for input")
        samtools index ${bam_file}

		# note presence of singleEnd flag!
        python3 ${rnaseq1_script} ${bam_file} ${genes_gtf} $genome_fasta ${prefix} \
            --java_path /usr/lib/jvm/java-1.7.0-openjdk-amd64/bin/java \
            --jar /opt/RNA-SeQC_1.1.9/RNA-SeQC.jar \
            --memory ${memory} \
            ${" --rnaseqc_flags " + rnaseqc_flags} \
            ${" --gatk_flags " + gatk_flags}
            # --rnaseqc_flags noDoC strictMode singleEnd \
    }

    output {
        File gene_rpkm = "${prefix}.gene_rpkm.gct.gz"
        File gene_counts = "${prefix}.gene_reads.gct.gz"
        File exon_counts = "${prefix}.exon_reads.gct.gz"
        File count_metrics = "${prefix}.metrics.tsv"
        File count_outputs = "${prefix}.tar.gz"
    }

    runtime {
        #docker: "gcr.io/broad-cga-francois-gtex/gtex_rnaseq:V8"
        docker: "broadinstitute/gtex_rnaseq:V8" 
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${num_threads}"
        preemptible: "${num_preempt}"
    }

    meta {
        author: "Francois Aguet"
    }
}


workflow rnaseqc1_workflow {
    call rnaseqc1
}
