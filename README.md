## README for Winne et al. (2026)
This repository contains MATLAB code used to process, analyze, and visualize the behavioral and histological data reported in Winne et al. (2026). All outputs are saved as CSV tables and vectorized PDF figures. The data to be used with these pipelines are archived separately on UMD DRUM and distributed as a compressed .zip file. 

## Software Requirements
- MATLAB R2019b or newer
	- Statistics and Machine Learning Toolbox  

The repository is organized around two primary analysis pipelines:

_____________________________

## Winne_2026_IHC_pipeline.m
1. _Behavioral metric extraction_
   - Thresholds across training days
   - Learning rate (slope of threshold vs. log10(day))
   - Percent improvement
   - False alarm rates
   - Number of trials per session

2. _Group-level summaries_
   - Aggregation by treatment (e.g., Saline, chABC, Penicillinase)
   - Optional exclusion based on WFA area cutoffs for ablation groups

3. _Visualization_
   - Learning trajectories
   - Group mean ± SEM plots with individual data points
   - Psychometric function examples
   - Correlations between behavioral and histological measures

_____________________________

## Winne_2026_IHC_pipeline.m
1. _Profile aggregation_
   - Depth-wise intensity profiles aggregated across hemispheres and slices

2. _Normalization_
   - Normalization to Untrained controls
   - Normalization by batch and/or cortical depth

3. _PNN and NeuN quantification_
   - Compilation of per-PNN measurements across subjects
   - Normalization of PNN intensity values
   - Conversion of cell counts to densities

4. _Visualization_
   - Group mean ± SEM plots with overlaid individual values
   - Depth-resolved normalized profiles

_____________________________

## Notes for Reuse
File paths need to be modified to match local systems.

## Citation
If you use this code, please cite:   Winne et al. (2026). *[Full article title]*. *Journal name*.

## Contact
Melissa L. Caras
Department of Biology  
University of Maryland
mcaras@umd.edu 
