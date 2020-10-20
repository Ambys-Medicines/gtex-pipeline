task rnaseqc2 {

    ## NOTA BENE: this task relies on an archived version of RNA-SeQC: https://github.com/francois-a/rnaseqc
    ## wise to update to rnaseqc2 interface (commented) lines below, but that breaks technicaly compatibility with GTEx v8 
    ## will eventually ditch compatibility for simpler interface
    File bam_file
    File genes_gtf
    String sample_id
    File genome_fasta_tarball ## only necessary for RNA-SeQC 1, v2 does not use this
    String? strandedness 
    File? intervals_bed
    String? flags

    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

    command {
        set -euo pipefail
        touch ${sample_id}.fragmentSizes.txt

        #echo $(date +"[%b %d %H:%M:%S] Running RNA-SeQC 2")
        #rnaseqc ${genes_gtf} ${bam_file} . -s ${sample_id} ${"--bed " + intervals_bed} ${"--stranded " + strandedness} -vv ${flags}

        # pull and extract reference genome FASTA
        echo $(date +"[%b %d %H:%M:%S] Extract reference FASTA")
        mkdir genome_fasta 
        tar -xzvf ${genome_fasta_tarball} --directory=$(pwd)
        genome_fasta="$(basename ${genome_fasta_tarball} .tar.gz).fasta"

        # need to index BAM file before running rnaseqc
        echo $(date +"[%b %d %H:%M:%S] Indexing BAM file for input")
        samtools index ${bam_file}

        # now run rnaseqc
        echo $(date +"[%b %d %H:%M:%S] Running RNA-SeQC 1.1.9")
        ## BGI data are single-end reads, but this will eventually require removal of the flag
        ## must specify java 1.7: https://github.com/broadinstitute/gtex-pipeline/commit/da771af458c95b11953d8919547ebead8d09c4e1#diff-06b16a949e2b7bc3f6a8f58fdad95d3a
        /usr/lib/jvm/java-7-openjdk-amd64/bin/java -Xmx6g -jar /opt/RNA-SeQC_1.1.9/RNA-SeQC.jar -s ${sample_id},${bam_file},${sample_id} -t ${genes_gtf} -r $genome_fasta -o $(pwd) -singleEnd -noDoC -strictMode 

        echo "  * compressing outputs"
        gzip *.gct
        echo $(date +"[%b %d %H:%M:%S] done")
    }

    output {
        #File gene_tpm = "${sample_id}.gene_tpm.gct.gz"
        #File gene_counts = "${sample_id}.gene_reads.gct.gz"
        File exon_counts = "${sample_id}.exon_reads.gct.gz"
        File metrics = "${sample_id}.metrics.tsv"
        File insertsize_distr = "${sample_id}.fragmentSizes.txt"
        File gene_rpkm = "genes.rpkm.gct.gz"
    }

    runtime {
        #docker: "gcr.io/broad-cga-francois-gtex/gtex_rnaseq:V9"
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


workflow rnaseqc2_workflow {
    call rnaseqc2
}
