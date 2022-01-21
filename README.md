# SamnSero (Nextflow)

## Installation
```bash
# Install Pre-requisites
 - Nextflow
 - Package distributor of choice (Conda, Docker, Singularity) 

# Clone repository
git clone https://github.com/jimmyliu1326/SamnSero_Nextflow.git
```
## Example Usage
1. Execute workflow using Conda
```bash
nextflow run /path/to/SamnSero.nf --input samples.csv --outdir results -profile conda
```

2. Execute workflow using Docker
```bash
nextflow run /path/to/SamnSero.nf --input samples.csv --outdir results -profile docker
```

3. Execute workflow using Slurm
```bash
nextflow run /path/to/SamnSero.nf --input samples.csv --outdir results -profile slurm
```