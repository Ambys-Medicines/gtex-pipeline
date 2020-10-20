import "star.wdl" as star_wdl
import "markduplicates.wdl" as markduplicates_wdl
import "rsem.wdl" as rsem_wdl
#import "rnaseqc2.wdl" as rnaseqc_wdl
import "rnaseqc1.wdl" as rnaseqc_wdl

workflow rnaseq_pipeline_fastq_workflow {

    String prefix

#    call star_wdl.star {
#        input: prefix=prefix
#    }
#
#    call markduplicates_wdl.markduplicates {
#        #input: input_bam=star.bam_file, prefix=prefix
#        input: prefix=prefix
#    }
#
    call rsem_wdl.rsem {
        #input: transcriptome_bam=star.transcriptome_bam, prefix=prefix
        input: prefix=prefix
    }

#    call rnaseqc_wdl.rnaseqc2 {
#        #input: bam_file=markduplicates.bam_file, sample_id=prefix
#        input: sample_id=prefix
#    }
#    call rnaseqc_wdl.rnaseqc1 {
#        #input: bam_file=markduplicates.bam_file, sample_id=prefix
#        input: prefix=prefix ## prefix should be sample_id
#    }
}
