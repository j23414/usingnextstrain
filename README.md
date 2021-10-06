# Using Nextstrain

An attempt to setup and run Nextstrain on MacOS

```
# Install Augur
pip install nextstrain-augur

# Install nextstrain-ci, will need docker
python3 -m pip install nextstrain-cli
```

## Running the Zika tutorial

* https://nextstrain.org/docs/getting-started/zika-tutorial

```
# Fetch and Run
git clone https://github.com/nextstrain/zika-tutorial.git
cd zika-tutorial

mkdir -p results/

augur filter \
  --sequences data/sequences.fasta \
  --metadata data/metadata.tsv \
  --exclude config/dropped_strains.txt \
  --output results/filtered.fasta \
  --group-by country year month \
  --sequences-per-group 20 \
  --min-date 2012

augur align \
  --sequences results/filtered.fasta \
  --reference-sequence config/zika_outgroup.gb \
  --output results/aligned.fasta \
  --fill-gaps

PATH=$PATH:~/bin/

augur tree \
  --method fasttree
  --alignment results/aligned.fasta \
  --output results/tree_raw.nwk

augur refine \
  --tree results/tree_raw.nwk \
  --alignment results/aligned.fasta \
  --metadata data/metadata.tsv \
  --output-tree results/tree.nwk \
  --output-node-data results/branch_lengths.json \
  --timetree \
  --coalescent opt \
  --date-confidence \
  --date-inference marginal \
  --clock-filter-iqd 4

augur traits \
  --tree results/tree.nwk \
  --metadata data/metadata.tsv \
  --output results/traits.json \
  --columns region country \
  --confidence

augur ancestral \
  --tree results/tree.nwk \
  --alignment results/aligned.fasta \
  --output results/nt_muts.json \
  --inference joint

augur translate \
  --tree results/tree.nwk \
  --ancestral-sequences results/nt_muts.json \
  --reference-sequence config/zika_outgroup.gb \
  --output results/aa_muts.json

augur export \
  --tree results/tree.nwk \
  --metadata data/metadata.tsv \
  --node-data results/branch_lengths.json \
              results/traits.json \
              results/nt_muts.json \
              results/aa_muts.json \
  --colors config/colors.tsv \
  --auspice-config config/auspice_config.json \
  --output-tree auspice/zika_tree.json \
  --output-meta auspice/zika_meta.json

#nextstrain view auspice/
```

Copy the url into your browser to view the files

# Restart - 2021/10/06

* Neher, R.A. and Bedford, T., 2015. [Nextflu: real-time tracking of seasonal influenza virus evolution in humans](https://api.semanticscholar.org/CorpusID:880543). Bioinformatics, 31(21), pp.3546-3548.
* Hadfield, J., Megill, C., Bell, S.M., Huddleston, J., Potter, B., Callender, C., Sagulenko, P., Bedford, T. and Neher, R.A., 2018. [Nextstrain: real-time tracking of pathogen evolution](https://api.semanticscholar.org/CorpusID:8134099). Bioinformatics, 34(23), pp.4121-4123.
* Huddleston, J., Hadfield, J., Sibley, T.R., Lee, J., Fay, K., Ilcisin, M., Harkins, E., Bedford, T., Neher, R.A. and Hodcroft, E.B., 2021. [Augur: a bioinformatics toolkit for phylogenetic analyses of human pathogens](https://api.semanticscholar.org/CorpusID:233312899). Journal of Open Source Software, 6(57), p.2906.

* Other Papers: 
  [2020_Bedford](https://api.semanticscholar.org/CorpusID:215782250)
| [2020_Kim](https://api.semanticscholar.org/CorpusID:215718870)
| [2020_Chu](https://api.semanticscholar.org/CorpusID:222235769)

* Installation Instructions: https://docs.nextstrain.org/en/latest/install.html

```
# conda method on an 13in MacBook Pro 2016 (MacOS 11.6)
conda create -n nextstrain -c conda-forge -c bioconda \
  augur auspice nextstrain-cli nextalign snakemake awscli git pip
  
#hmm, conda is taking over an hour on my machine. Try mamba method
conda install -n base -c conda-forge mamba
mamba create -n nextstrain -c conda-forge -c bioconda \
  augur auspice nextstrain-cli nextalign snakemake awscli git pip
  
# Check install
conda activate nextstrain
nextstrain check-setup --set-default
```

<details><summary>see output</summary>

```
nextstrain-cli is up to date!

Testing your setup…

# docker is not supported
✘ no: docker is installed
✘ no: docker run works
? unknown: containers have access to >2 GiB of memory
✔ yes: image is new enough for this CLI version

# native is supported
✔ yes: snakemake is installed
✔ yes: augur is installed
✔ yes: auspice is installed

# aws-batch is not supported
✘ no: job description "nextstrain-job" exists
✘ no: job queue "nextstrain-job-queue" exists
✘ no: S3 bucket "nextstrain-jobs" exists

All good!  Supported Nextstrain environments: native

Setting default environment to native.
```

going to try avoiding docker (always end up with large containers), but if I need it will install

</details>

Run a demo

```
git clone https://github.com/nextstrain/ncov
```

data prep (scripted? I guess already prepped in the database download)

Preferred workflow language = snakemake

Snakemake's `defaults` and `my_profiles` probably equivalent to Nextflow's `nextflow.config` and `config` folder.

```
cd ncov
emacs builds.yaml
```

**build.yml**  defaults

```
# Define inputs

inputs:
  - name: exampleAUS
    metadata: data/example_metadata_aus.tsv.xz
    sequences: data/example_sequences_aus.fasta.xz
  - name: references
    metadata: data/references_metadata.tsv
    sequences: data/references_sequences.fasta
```

```
nextstrain build . --configfiles builds.yaml --cores 1 -n -p --dag | dot -Tpng > dag.png
```

![](dag.png)

