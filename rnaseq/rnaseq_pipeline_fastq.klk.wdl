import "star.wdl" as star_wdl
import "markduplicates.wdl" as markduplicates_wdl
import "rsem.wdl" as rsem_wdl
import "rnaseqc1.wdl" as rnaseqc_wdl

workflow rnaseq_pipeline_fastq_workflow {

    String prefix
    Int memory
    Int disk_space
    Int num_threads
    Int num_preempt

    call star_wdl.star {
        input: prefix=prefix, memory=memory, disk_space=disk_space, num_threads=num_threads, num_preempt=num_preempt
    }

    call markduplicates_wdl.markduplicates {
        input: input_bam=star.bam_file, prefix=prefix, memory=memory, disk_space=disk_space, num_threads=num_threads, num_preempt=num_preempt
    }

    call rsem_wdl.rsem {
        input: transcriptome_bam=star.transcriptome_bam, prefix=prefix, memory=memory, disk_space=disk_space, num_threads=num_threads, num_preempt=num_preempt
    }

    # use RNA-SeQC 1 for backwards compatibility to GTEx v8
    call rnaseqc_wdl.rnaseqc1 {
        input: bam_file=markduplicates.bam_file, prefix=prefix, memory=memory, disk_space=disk_space, num_threads=num_threads, num_preempt=num_preempt
    }
}
