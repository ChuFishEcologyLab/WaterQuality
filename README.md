# Water Quality 

## Objective

Examine how water chemistry exceedances (values that are not within the range for the protection of aquatic life) varies with intensity of human activities

## Data

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

⚠️ Some steps in the data preparation were done on raw data that are to large 
to be added in the repository. The datasets are available online and listed above.  


## TODO 

- [ ] extract for all features in Hirsh-Pearson.
- [ ] do all logistic regression for all stressor at different level of watershed and the different thresholds.
- [ ] generate report. 