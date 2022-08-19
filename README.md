# biomeddashboard-neuro-trials

This repository is part of the [ScholCommLab-led project “Biomed OS
Dashboard”](https://docs.google.com/document/d/18zr1QBbvstYkXOXK2l-2OUyVhWExH54eeW8BGimYN98/).
It uses [data on a sample of The Neuro’s publication
records](https://www.dropbox.com/s/lxjsihhzys7h6r7/cleaned_y2021_oa_info_109.csv?dl=0)
and builds off [code developed for QUEST’s project
“IntoValue”](https://github.com/maia-sh/intovalue-data).

Here, we evaluate The Neuro’s publications for the presence of clinical
trial registration numbers (TRNs) in their PubMed abstracts and metadata
(“secondary identifier” field). Methods are described in detail
[Salholz-Hillel et al. 2022](https://doi.org/10.1177/17407745221087456).

PubMed records were downloaded on 2022-08-19.

## Results

In the sample of 536 The Neuro publications, we found 28 TRNs in the
PubMed abstracts and metadata of 22 publications.

Of PubMed records with TRNs, most had TRNs in both the abstract and
metadata:

| has_trn_secondary_id | has_trn_abstract |   n |
|:---------------------|:-----------------|----:|
| TRUE                 | TRUE             |  20 |
| TRUE                 | FALSE            |   5 |
| FALSE                | TRUE             |   3 |

ClinicalTrials.gov was by far the most common registry:

| registry           |   n |
|:-------------------|----:|
| ClinicalTrials.gov |  26 |
| EudraCT            |   2 |

Of PubMed records with TRNs, most include a single TRN:

| n_trns | n_pmids |
|-------:|--------:|
|      1 |      17 |
|      2 |       4 |
|      3 |       1 |

Get the csv of TRNs here!

how many have what (venn)/ discrepancies between types

how many have how many

## Quarto

Quarto enables you to weave together content and executable code into a
finished document. To learn more about Quarto see <https://quarto.org>.

## Running Code

When you click the **Render** button a document will be generated that
includes both content and the output of embedded code. You can embed
code like this:

    [1] 2

You can add options to executable code like this

    [1] 4

The `echo: false` option disables the printing of code (only output is
displayed).
