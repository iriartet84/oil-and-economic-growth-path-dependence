# Path Dependence and Growth: The Role of Oil in Developing Economies

## Overview

This Bachelor's thesis examines the relationship between natural-resource dependence, institutional quality, and long-run economic growth in developing economies.

The analysis investigates whether the effects of oil resources on economic performance depend on the institutional environment in which those resources are managed.

The empirical strategy combines panel-data methods with instrumental variables to address the potential endogeneity between institutions, natural resources, and economic growth.

## Research Question

> **How does institutional quality shape the relationship between oil resources and economic growth in developing economies?**

The analysis focuses on whether oil resources are associated with different growth outcomes depending on institutional conditions and historical characteristics.

## Methodology

The empirical framework is based on an **Augmented Solow growth model** estimated using instrumental variables and two-stage least squares (2SLS).

The baseline specification incorporates:

* Physical capital
* Human capital
* Labour-market variables
* Land and geographic characteristics
* Institutional quality
* Oil resources

Country and year fixed effects are included to account for unobserved country characteristics and common time effects.

### Instrumental Variables

Oil resources are instrumented using **lagged oil reserves**, exploiting the persistence of resource endowments while reducing concerns about contemporaneous reverse causality.

The IV strategy is used to investigate the relationship between institutional quality and economic growth while accounting for potential endogeneity.

The instrument should be interpreted as an identification strategy rather than as proof that oil reserves are fully exogenous.

## Institutional Quality

Institutional quality is measured using indicators from the **V-Dem dataset**.

The institutional measure combines several dimensions of political and institutional quality, including:

* Control of corruption
* Absence of political violence
* Property rights
* Bureaucratic quality
* Transparent and predictable laws

Principal Component Analysis (PCA) is used to construct a composite institutional-quality measure from these indicators.

The resulting index provides a multidimensional measure of institutional conditions while reducing the dimensionality of the individual indicators.

## Empirical Framework

The analysis proceeds in two stages.

### First stage

The first stage estimates the relationship between the proposed instrument for oil resources and the endogenous resource variable.

### Second stage

The predicted component of oil resources is then incorporated into the augmented growth regression alongside institutional quality and other controls.

The baseline analysis is estimated using country and year fixed effects.

The analysis also examines whether the relationship varies according to historical and institutional characteristics.

## Data

The analysis combines several international datasets.

### V-Dem

Provides measures of:

* Institutional quality
* Corruption
* Political violence
* Property rights
* Bureaucratic quality
* Rule of law and related institutional characteristics

### World Bank

Provides macroeconomic and development indicators used in the growth regressions.

### Penn World Table

Provides measures of:

* Economic output
* Capital
* Labour
* Productivity
* Other national-account variables

### S&P Global

Provides information on oil reserves and natural-resource endowments used in the empirical analysis.

## Main Results

The baseline estimates indicate a negative association between the institutional measure and economic growth conditional on the model specification and identification strategy.

The estimated institutional coefficient is approximately:

* **−0.55** in the baseline specification
* **−0.49** in the robustness specification

The analysis also examines whether historical institutional characteristics modify this relationship.

The estimated interaction effects for countries with French and Portuguese colonial histories are approximately:

* French: **−1.27**
* Portuguese: **−1.23**

These estimates should be interpreted within the specific sample, model, and identification strategy used in the thesis rather than as universal effects of colonial history.

## Mechanisms

The thesis examines individual institutional dimensions to investigate potential channels behind the aggregate institutional relationship.

Among the institutional components, **corruption** provides the clearest empirical channel in the analysis.

The property-rights component, in contrast, does not produce a statistically strong first-stage relationship with the relevant resource measure in the specifications examined.

These results suggest that different dimensions of institutional quality may operate differently rather than representing a single homogeneous institutional mechanism.

## Empirical Workflow

```text
International Data
        ↓
Country-Year Panel
        ↓
Oil Resources + Development Variables
        ↓
Institutional Quality Indicators
        ↓
PCA Institutional Index
        ↓
Augmented Solow Model
        ↓
Instrumental Variables / 2SLS
        ↓
Country + Year Fixed Effects
        ↓
Robustness & Institutional Channels
        ↓
Economic Growth Results
```
