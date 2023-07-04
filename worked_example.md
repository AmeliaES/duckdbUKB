## Extract UK Biobank data using the duckdb R package to create a flat table for analysis

1. Get an interactive node on Eddie.
```
qlogin -l h_vmem=32G
cd /exports/eddie/scratch/$USER
module load igmm/apps/R/4.1.0
R
```

2. Now work through [`worked_example.R`](worked_example.R)

3. Transfer your flat table from your scratch space on Eddie to datastore:
*Change the path on datastore to your own folder, not mine!*
```
qlogin -q staging
cp /exports/eddie/scratch/$USER/UKB_flat.csv /exports/igmm/datastore/GenScotDepression/users/amelia/
```
