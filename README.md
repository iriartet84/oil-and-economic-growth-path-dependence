# Oil Price Shocks and Democratisation
## Overview

This project examines whether long-run dependence on oil resources affects economic development through institutional and political channels.

The analysis investigates the relationship between natural-resource abundance, institutional quality, and economic growth across developing economies. The central question is whether oil wealth is associated with weaker institutions and whether differences in institutional quality help explain variation in long-run growth outcomes.

The empirical framework combines an augmented Solow growth model with instrumental variables and panel fixed effects. Oil-resource abundance is instrumented using its lagged value to address concerns about reverse causality and the endogenous relationship between economic development and resource extraction.

## Research Question

How does oil-resource abundance affect long-run economic growth, and to what extent is this relationship mediated by institutional quality?

The analysis focuses on four dimensions of institutional quality:

Control of corruption
Protection of property rights
Absence of political violence
Bureaucratic quality and rule-based governance

It also examines whether historical colonial institutions condition the relationship between oil resources and institutional outcomes.

## Methodology

The empirical strategy combines an augmented Solow growth framework with panel-data methods.

## Baseline specification

The growth model incorporates physical capital, human capital, population growth, and oil-resource abundance alongside institutional measures.

Country and year fixed effects are included to account for unobserved time-invariant country characteristics and common time shocks.

## Instrumental Variables

Oil-resource abundance is potentially endogenous to economic development and institutional outcomes. To address this, the analysis uses the 10-year lag of oil resources as an instrument for contemporary oil-resource abundance.

The estimation proceeds using two-stage least squares (2SLS).

## Institutional quality

Institutional measures are constructed from the Varieties of Democracy (V-Dem) dataset. The institutional variables capture dimensions including:

Corruption
Property rights
Political violence
Bureaucratic quality
Rule of law

Principal component analysis is used where appropriate to construct composite measures of institutional quality.

## Colonial legacy

The analysis also examines interactions between oil resources and historical colonial backgrounds, with particular attention to French and Portuguese colonial legacies.

## Data

The analysis combines several international datasets:

Dataset	Variables
V-Dem	Institutional and political indicators
World Bank	Macroeconomic and development indicators
Penn World Table	GDP, capital, labour and productivity measures
S&P Global	Oil-resource and petroleum data

The sample covers developing economies over multiple decades, allowing the analysis to exploit both cross-country and within-country variation.

## Empirical Approach

The main workflow is:

Oil-resource abundance
          │
          ▼
   Institutional quality
          │
          ▼
     Economic growth

The empirical analysis tests whether oil-resource abundance is systematically associated with institutional outcomes and whether these institutional channels are relevant for long-run economic performance.

The analysis also separates the overall institutional relationship into specific mechanisms, allowing the results to distinguish between corruption, property rights, political stability, and other institutional dimensions.

## Main Findings

The baseline estimates indicate a negative relationship between institutional quality and the oil-resource variable in the empirical specification, with the estimated coefficient remaining negative across robustness specifications.

The baseline institutional coefficient is approximately −0.55, while the main robustness specification produces an estimate of approximately −0.49.

The interaction analysis finds stronger estimated relationships for countries with French and Portuguese colonial histories, with coefficients of approximately −1.27 and −1.23, respectively.

Among the institutional channels examined, corruption provides the clearest evidence of a potential mechanism linking resource abundance to institutional outcomes. The evidence for property rights is weaker, including an insignificant first-stage relationship in the relevant specification.

These results should be interpreted as evidence from the specified empirical framework rather than as a definitive causal decomposition of the resource-growth relationship.
