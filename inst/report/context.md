# Scope of project

## Objective 

Examine how water chemistry exceedances (values that are not within the range for the protection of aquatic life) varies with intensity of human activities

Note: While many other factors influence water chemistry, we’re only interested in relationships between the threat layers and water chemistry (fish habitat) at this time. 


## Specific questions

Interested in examining Theobald and Hirsh-Pearson separately because they’ve been used for different projects 
    
1. For each water chemistry parameter, what is the relationship between Theobald et al. 2025 cumulative threat summarized at different watershed scales and exceedances at national level (all sites). Is one scale better than another (hydrobasin 7 vs. 12)? 
    
2. For each water chemistry parameter, what is the relationship between Theobald et al. cumulative threat summarized at different watershed scales and exceedances regionally (group sites by primary watershed)? Theobald data are here: Theobald, D. M., Oakleaf, J., Moncrieff, G. & Kennedy, C.M. Global human modification datasets of terrestrial ecosystems for 2022, https://doi.org/10.5281/zenodo.14502573 (2024). interested in static 2022 data layer - 
    
3. For each water chemistry parameter, what are the relationships between Hirsh-Pearson et al. cumulative threat and individual threats (forestry, mining etc.) at different watershed scales on exceedances at national level (all sites). 
    
4. Repeat #3 at regional scale (group sites by primary watershed).
Hirsh data here: https://borealisdata.ca/dataset.xhtml?persistentId=doi:10.5683/SP2/EVKAVL


# Data 

- Map package with primary watersheds and hydrobasins 7 and 12 for each water chemistry site
- Water chemistry data – interested primarily in relationships between cumulative threats or individual threats and the proportion of record that water chemistry exceeds values to protect aquatic life but open to suggestions
- Zonal stats to be calculated for the different cumulative threat and individual threats layers for the H7 and H12 polygons 

Note:

1) Water chemistry sampling at the sites is not standardized, we selected any site that had at least 3 years of data between 2015-2024 and at least 10 samples per year (based on CCME water quality guidelines for ‘good’ amount of sampling for water chemistry characterization) 
2) Some sites are within the same watershed – could take average among them if timing of sampling overlaps?
3) The results could show no patterns at all i.e., other factors are driving water chemistry exceedances… but that is useful to know. 


# Deliverables:

1. Statistical analyses for proportion of exceedances of water chemistry parameters vs Theobald, and Hirsh-Pearson data 

2. Annotated R code 

3. Brief report describing the methods and results with graphs and models for all of Canada and primary watersheds.



# Background information 

Note: this is how the raw water quality data were prepared:

The data should fall within the years 2015-2024. Each water chemistry variable should have at least 10 samples per year per site and at least 3 years of data as per the CCME water quality guidelines for the protection of aquatic life (CCME, 2017).

## Workflow

### Data

- The data consist of two datasets, one from CICADA and the other from DataStream
- DataStream extraction:
    * Regions: Pacific, Mackenzie, Lake Winnipeg, Great Lakes, Atlantic
    * Explore Data tab ➡️ Explore Data ➡️ Custom Download
        - Step 1: select all
        - Step 2: Monitoring and Location Type: Lake/Pond, Pond-Stormwater, River/Stream, Wetland, Reservoir, Spring
        - Step 3: Activity Media Name: Surface Water
        - Step 4: Activity Group Type: Field
        - Step 5: Characteristic Name: Ammonia (mg/L), Chlorophyll a corrected (mg/L or μ/L), Chloride (mg/L), Conductivity μS/cm, Dissolved Oxygen (mg/L), pH (not lab option), Total phosohorous (mg/L or μg/L), mixed forms (mg/L), Nitrates, Nitrite (mg/L), Selenium (mg/L or μg/L), Total Dissolved Solids (mg/L), Total Suspended Solids (mg/L), Turbidity (NTU)
        - Step 6: Time Span: 2015-2024

### Import data

- CICADA
    * “Nat_WQ_data_0_10_2023_v2.csv”
    * Converted Sample_data to date format
- DataStream
    * Atlantic, Great Lakes, Lake Winnipeg, and Mackenzie data had to be downloaded from Data Stream in two files due to size limits
        - These files were combined and then filtered for correct units (indicated above)
    * File names:
        - Data_Stream/Atlantic_2015-2024_DataStream_filtered.csv
        - Data_Stream/GreatLakes_2015-2024_DataStream_filtered.csv
        - Data_Stream/Winnipeg_2015-2024_DataStream_filtered.csv
        - Data_Stream/Mackenzie_2015-2024_DataStream_filtered.csv
        - Data_Stream/Pacific_2015-2024_DataStream_filtered.csv


### Organise data

- CICADA
    * Split data into separate data frames for each water chemistry variable
    * Filtered data to include only years 2015+
    * Edited columns so that all water chemistry variable data frames could be re-merged in long-form
    * Merged CICADA data back together (long-form/vertical bind)
- DataStream
    * Removed unnecessary columns 
    * Merged data from all regions (long-form/vertical bind)
    * Added single coordinates column for unique site identification 
    * Added site IDs based on unique coordinates (CE_Site_ID [X1, X2, etc.])
        - Some sites had different MonitoringLocationID or MonitoringLocationName but the same coordinates
    * Removed duplicate samples
        - Some sites were listed under two different regions (i.e., LSL-12 had duplicate data in the Atlantic and Great Lakes regions)
        - Kept the first occurrence of each duplicate; therefore, “Region” is no longer informative
Merge data
- Prepped both data sets for merging by matching column names and adding an “Origin” column to identify whether the data came from CICADA or DataStream
- Merged CICADA and DataStream data sets (long-form)
- Removed duplicate samples
    * Similar to above (within DataStream data), there were duplicate samples from the DataStream and CICADA data sets
    * Identified by a single location having the same sample date, water chemistry variable, and result value, but from different “Origins”
    * Kept the first occurrence of each sample and changed “Origin” to “CICADA_DataStream” 
    * Created separate data frame of just the duplicates, kept first occurrence only, merged back with original data frame
        - Note that after daily means are calculated, “Origin” won’t be informative anymore anyway

### Clean data

- Noticed that there are impossible water chemistry levels—orders of magnitude higher than upper thresholds, and negative values.

- Asked Microsoft CoPilot365 what highly implausible levels would be for each water chemistry variable in freshwater bodies, then discussed with Cindy Chu:
    * Ammonia: ≥ 20 mg/L
    * Chlorophyll A: ≥ 500 mg/L
    * Conductivity: ≥ 3000 μS/cm (brackish water ranges from 1,500–15,000 μS/cm)
    * Dissolved Chloride: ≥ 500 μg/L
    * Dissolved oxygen: ≥ 30 mg/L
    * Nitrate: ≥ 30 mg NO3/L
    * Nitrite: ≥ 2 mg NO2/L
    * pH: ≥ 10
    * Total dissolved solids: ≥ 3000 mg/L
    * Total phosphorous: ≥ 2000 μg/L
    * Total Selenium: ≥ 100 mg/L
    * Total suspended solids: ≥ 2000 mg/L
    * Turbidity: ≥ 2000 NTU

- Removed implausible values (limits defined above and negative values)
Filter data

- Created a new set of unique site IDs (LJ_Site_ID) based on unique coordinates
    * Necessary after combining CICADA and DataStream data and removing duplicate samples

- Data were filtered as per the CCME water quality guidelines: each water quality variable must be sampled at least 10 times (10 sample days) per year per site, and there must be at least three years of data (not consecutive)

- Data were grouped by site (LJ_Site_ID), water chemistry variable, and year
    * Daily means (and standard deviations) were calculated
        - Some sites took more than one sample/day (sometimes hundreds)—some were the exact same value, some were different 
        - Duplicate days were removed (now that there is a daily mean; “Origin” and “ResultValue” no longer informative)
    * Number of sample days per water chemistry variable per year per site were counted
    * Data were filtered to only include sites that had ≥ 10 samples per year per water chemistry variable
    * Number of sample months per water chemistry variable per year per site were counted
        - This was more to look at the seasonal distribution of samples—not required by the CCME water quality guidelines
- Data were grouped by site and water chemistry variable
    * Number of sample years per water chemistry variable per site were counted
    * Data were filtered to only include sites that had ≥ 3 years of data per water chemistry variable per site
Calculate means
- Data were grouped by site, water chemistry variable, year, and month
- Monthly means (and standard deviations)  were calculated (mean of daily means)
- Data were grouped by site, water chemistry variable, and year
- Yearly means (and standard deviations) were calculated (mean of daily means)
Thresholds
- Added daily, monthly, and yearly threshold columns that indicate whether or not a specific site’s level for a specific water chemistry variable exceeded the upper or lower guideline thresholds as per the CCME water quality guidelines for the protection of aquatic life.
- Threshold columns were binary (1 = failed [exceeds guidelines]; 0 = passed [within guidelines])
    * chose “1” as failure to count proportion of failed sample days per year for each site
- Note: where CCME guidelines were not available, values from other sources were sought out
- Guideline thresholds were as follows:
    * Conductivity < 500 uS/cm (Dey et al. 2023; Carr and Rickwood 2008)
    * Dissolved chloride < 120 mg/L (long-term; Chu et al. 2025, CCME 2011)
    * Dissolved oxygen > 6.5 mg/L (long-term; cold water other life stage; Dey and Chu 2-25, CCME 1999)
    * Nitrate < 3 mg/L (long-term; CCME 2012)
    * 6.5 < pH < 9 (long-term; Chu et al. 2025, CCME 1987)
    * Total phosphorous < 30 ug/L (0.03 mg/L; Chu et al. 2025, ECCC 2023)
    * Total dissolved solids < 500 mg/L (Health Canada 1991; no CCME guidelines)
    * Turbidity < 10 NTU (Chu et al. 2025, ECCC 2023) 
- Note: ammonia, nitrite, total suspended solids, and total selenium were filtered out for not having the minimum required sample days and/or years
- Daily, monthly, and yearly threshold pass/fails were based on the daily, monthly, and yearly means
- Added column for the proportion of sample days that failed (i.e., exceeded thresholds) per year
Export data
- Exported data as, “WaterQuality2025.csv”
Water chemistry variables (shortforms)
Conductivity (Con)
Dissolved chloride (DCl)
Dissolved oxygen (DO)
Nitrates (Nit)
pH 
Total dissolved solids (TDS)
Total phosphorous (TP)
Turbidity (Tur)




Variable definitions (DataStream variable name, if applicable)
    1. Coordinates: (latitude, longitude); just merged the LATITUDE and LONGITUDE columns for organizational purposes.
    2. LJ_Site_ID: unique site identifier, based on “Coordinates”; added by LJ after CICADA and DataStream data were merged and duplicates were removed
    3. CE_Site_ID : unique site identifier ; pre-existing in CICADA dataset, but added by LJ in the Data Stream dataset
    4. Datasource (DatasetName): source of the data, reported by creators of CICADA/DataStream datasets
    5. Source_SiteID (MonitoringLocationID): location identifier (sometimes missing)
    6. Source_Site_name (MonitoringLocationName): name of location (sometimes missing)
    7. LATITUDE: latitude in decimal degrees
    8. LONGITUDE: longitude in decimal degrees
    9. Projection (MonitoringLocationHorizontalCoordinateReferenceSystem): reference frame for coordinates
    10. Sample_date : date the sample was taken
    11. WC_variable: water chemistry variable that was measured (Conductivity, Dissolved_Chloride, Dissolved_Oxygen, Nitrate, pH, Total_Dissolved_Solids, Total_Phosphorous, Turbidity)
    12. Units: measurement units for associated water chemistry value
    13. DD : day
    14. MM : month
    15. YYYY : year
    16. mean_day: the mean daily value. Sometimes, multiple samples of each water chemistry variable were taken per day, so this is a mean of those values per site
    17. sd_day: standard deviation of mean daily value. sd = NA (only one sample/day); sd = 0 (multiple samples with the same value); sd = X (multiple samples with different values) per site
    18. sample_days: number of days that were sampled per water chemistry variable per site per year 
    19. sample_months: number of months that were sampled per water chemistry variable per site per year
    20. sample_years: number of years that were sampled per water chemistry variable per site
    21. mean_month: mean of daily means for each month for each water chemistry variable per site
    22. sd_month: sd of daily means for each month for each water chemistry variable per site
    23. mean_year: mean of daily means for each year for each water chemistry variable per site
    24. sd_year: sd of daily means for each year for each water chemistry variable per site
    25. Thr_day: whether or not the measured value passed (0) or failed (1) the water quality threshold according to CCME guidelines (see guidelines in workflow); based on daily mean (mean_day)
    26. Thr_month: whether or not the measured value passed (0) or failed (1) the water quality threshold for the given sampling month, according to CCME guidelines (see guidelines in workflow); based on monthly mean (mean_month)
    27. Thr_year: whether or not the measured value passed (0) or failed (1) the water quality threshold for the given sampling year, according to CCME guidelines (see guidelines in workflow); based on yearly mean (mean_year)
    28. prop_fail_year: the proportion of daily failures per year


# References

- Canadian Council of Ministers of the Environment. 2017. Canadian Water Quality Guidelines for the Protection of Aquatic Life: CCME water quality index user’s manual 2017 update. Canadian Water Quality Guideline for the Protection of Aquatic Life CCME Water Quality Index User's Manual 2017 Update
- Canadian Council of Ministers of the Environment. 1987. CCME water quality guidelines for the protection of aquatic life: pH. Available from https://ccme.ca/en/chemical/162#_aql_fresh_concentration [accessed 8 October 2025].
- Canadian Council of Ministers of the Environment. 1999. Canadian water quality guidelines for the protection of aquatic life: dissolved oxygen (Freshwater). In Canadian environmental quality guidelines. Winnipeg. Excerpt from Publication No. 1299.
- Canadian Council of Ministers of the Environment. 2011. Canadian water quality guidelines for the protection of aquatic life: chloride. In Canadian environmental quality guidelines. Winnipeg. Excerpt from Publication No. 1299.
- Canadian Council of Ministers of the Environment. 2012. Canadian water quality guidelines for the protection of aquatic life: nitrate ion. In Canadian environmental quality guidelines. Winnipeg. Excerpt from Publication No. 1299.
- Carr G, and Rickwood C. 2008. Water quality: development of an index to assess country performance". UNEP GEMS/Water Program. 351.
- Chu C, Dey CJ, and Rudolph C. 2025. CICADA: Cumulative Effects Spatial Data. Can. Data Rep. Fish. Aquat. Sci. 1447: iii + 25 p.
- Dey CJ, Matchett S, Doolittle A, Jung J, Kavanagh R, Sobowale R, Schwartz T, and Chu C. 2023. Preliminary assessment of the State of Fish and Fish Habitat in Fisheries and Oceans Canada’s Ontario and Prairie Region. DFO Can. Sci. Advis. Sec. Res. Doc. 2023/054. v + 72 p. 
- Environment and Climate Change Canada. 2023. Water Quality in Canadian Rivers: Canadian Environmental Sustainability Indicators. https://www.canada.ca/en/environment-climate-change/services/environmental-indicators/water-quality-canadian-rivers.html 
