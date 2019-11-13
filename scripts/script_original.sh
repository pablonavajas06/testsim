if ["$#" -eq 1]
then
	sampleid=$1
	echo "Running FastQC..."
	mkdir -p out/fastqc
	fastqc -o out/fastqc data/$(sampleid)*.fastq.gz
	echo
	echo "Running Cutadapt..."
	mkdir -p log/cutadapt
	mkdir -p out/cutadapt
	cutadapt -m 20 -a AGATCGGAAGAGCACACGTCTGAACTCCAGTCA -A AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT \
        -o out/cutadapt/${sampleid}_1.trimmed.fastq.gz \
        -p out/cutadapt/${sampleid}_2.trimmed.fastq.gz \
        data/${sampleid}_1.fastq.gz data/${sampleid}_2.fastq.gz > log/cutadapt/${sampleid}.log
	echo
	echo "Running STAR index..."
	mkdir -p res/genome/star_index
   	STAR --runThreadN 4 --runMode genomeGenerate \
         --genomeDir res/genome/star_index/ \
         --genomeFastaFiles res/genome/ecoli.fasta \
         --genomeSAindexNbases 9
	echo
	echo "Running STAR aligment..."
	mkdir -p out/star/${sampleid}
    	STAR --runThreadN 4 --genomeDir res/genome/star_index/ \
         --readFilesIn out/cutadapt/${sampleid}_1.trimmed.fastq.gz out/cutadapt/${sampleid}_2.trimmed.fastq.gz \
         --readFilesCommand zcat --outFileNamePrefix out/star/${sampleid}/
	echo
else
	echo "Usage: $0 <sampleid>"
	exit 1
fi
