# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **neuroscience research project** analyzing EEG data for prediction error and omission responses during sleep stages using adaptation and learning paradigms.

**Languages**: MATLAB (primary, 56+ files) + R (statistical analysis, 4 files)
**Domain**: Cognitive neuroscience, sleep research, EEG signal processing

## Architecture

### Configuration-Driven Pattern
Each experiment module has a `*_configuration.m` file that returns structs:
- `v` - variables (sleep stages, conditions, components)
- `subs` - subject list
- `dirs` - input/output paths
- `time`, `events` - timing parameters

All analysis scripts consume these configuration structs.

### Analysis Pipeline
```
Configuration → Data Importer (funcs/importers/) → Statistical Analysis → Visualization → Table Export → R LME Analysis
```

### Experiment Modules
- **AdaptationATO/**: Adaptation paradigm (auditory-to-omission)
- **OmissionATO/**: Omission and adaptation trials
- **OmissionGL/**: Global-Local paradigm
- **OffResponse/**: End-of-block response analysis

### Shared Functions (funcs/)
- `ADAM/` - MVPA toolbox wrapper
- `TCP_analysis/` - Time-domain cluster permutation
- `SpatioTemporalCP_Analysis/` - Spatio-temporal clustering
- `run_TFCP_dependent/` - Time-frequency analysis
- `importers/` - FieldTrip data loading
- `components/` - ERP component extraction
- `plotting/` - Visualization utilities

### Analysis Types
1. **TCP**: Time-domain cluster permutation (univariate ERP)
2. **STCP**: Spatio-temporal cluster permutation
3. **TFCP**: Time-frequency cluster permutation
4. **MVPA**: Multivariate pattern analysis (via ADAM toolbox)
5. **LME**: Linear mixed-effects models (R notebooks)

## Running Analysis

### MATLAB
Analysis scripts are run interactively. Each experiment folder contains:
- `analysis_CP.m` - Main cluster permutation analysis
- `analysis_components.m` - ERP component extraction
- `analysis_MVPA.m` - Multivariate decoding (where applicable)

To run an analysis:
1. Open MATLAB
2. Navigate to experiment folder (e.g., `AdaptationATO/`)
3. Run the configuration first: `[v, subs, dirs, time, events] = ADAPTATION_configuration()`
4. Run analysis scripts section-by-section (cell mode)

### R Statistical Analysis
R notebooks are in `AdaptationATO/lme/`:
- `LME_analy.Rmd` - Main mixed-effects analysis
- `LME_prevalence.Rmd` - Event prevalence analysis
- `LME_slope.Rmd` - Slope/trajectory analysis

Run via RStudio or `rmarkdown::render()`.

## Dependencies

### MATLAB Toolboxes
- FieldTrip (20241219)
- EEGLAB (2024.2)
- ADAM (1.14-beta)
- BayesFactor

Toolboxes are loaded via configuration files (check `dirs` struct for paths).

### R Packages
- lme4, lmtest, bayestestR (statistics)
- ggplot2, effects, gridExtra (visualization)
- caret, effectsize (modeling)

## Key Conventions

- **Data format**: FieldTrip structures (`.mat` files with `ft_data` variable)
- **Sampling rate**: 250 Hz
- **Electrode system**: GSN-HydroCel-129 (129-channel EEG)
- **Sleep stages**: N1, N2, N3, REM, wake (AASM scoring)
- **Subject filtering**: Use `sub_exclu_per_sov()` for subjects missing specific sleep stages

## Output

- Statistical results: `.mat` files with metadata
- Tables: Excel exports for reporting
- Figures: SVG/PNG for publication
