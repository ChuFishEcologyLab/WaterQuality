# Water Quality 


## Objective

Examine how water chemistry exceedances (values that are not within the range for the protection of aquatic life) vary with intensity of human activities.


## Data

### Water chemistry data

Surface-water chemistry data were compiled from two national databases: **CICADA** and **DataStream**.

### Human footprint 

Two sources were used. 

- Theobald, D. M., Oakleaf, J., Moncrieff, G. & Kennedy, C.M. Global human modification datasets of terrestrial ecosystems for 2022, https://doi.org/10.5281/zenodo.14502573 (2024) https://zenodo.org/records/14502573
    - Using HMv20240801_2022s_AA_300.tif
- Hirsh-Pearson, Kristen; Johnson, Chris; Schuster, Richard; Wheate, Roger; Venter, Oscar, 2022, "The Canadian Human Footprint", https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP2/EVKAVL



## Running the analysis

### Installation 

```R
remotes::install_github("ChuFishEcologyLab/WaterQuality")
# or with pak
pak::pak("ChuFishEcologyLab/WaterQuality")
```



### Accessing data 

Once installed, load the package: 

```R
library("WaterQuality")
```

Data can be accessed via the `wq_prepare_data()` function, the data files are found in `extdata`. For instance to access the main dataset, `master_data`, used for the main analyses so:

```R
wq_prepare_data("master_data")
```

⚠️ Some steps in the data preparation were done on raw data that are too large 
to be added in the repository. The datasets are available online and listed above.  The details of the extraction can be found in `inst/extdata/prepare_data.R`.


#### Statistical analyses 

The statistical analyses can be run as follows

```R
# a dataset with the entire set of results is returned. 
res_main <- run_analysis()
```

By default, figures will be saved in the folder `figs/`. 


Similarly, the analyses for the different components of the Hirsh datasets are done with 


```R
res_components <- run_analysis_components()
```

Finally, the check plot for the correlation between the two datasets is done using 

```R
plot_hirsh_vs_theobald()
```

