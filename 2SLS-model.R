# Data Cleaning #####
# Clear environment and set working directory
rm(list=ls())
setwd("~/Desktop/MARBLE Thesis/Econometrics/data")

# Load required libraries
library(AER)
library(stargazer)
library(ggplot2)
library(dplyr)
library(WDI)
library(pwt10)
library(tidyr)
library(tidyverse)
library(readxl)
library(plm)
library(fixest)
library(etable)
library(knitr)
library(kableExtra)
library(texreg)
## INSTITUTIONS

# Filter for specified countries and select relevant columns
# selected_countries <- c("Saudi Arabia", "Kuwait", "Iran", "Iraq", "Algeria", 
#                        "Nigeria", "Angola", "Gabon", "Equatorial Guinea", 
#                        "Ghana", "Venezuela", "Brazil", "Ecuador", "Mexico", 
#                        "Indonesia", "Malaysia", "Kazakhstan", "Azerbaijan")
selected_countries <- c("Saudi Arabia", "Kuwait", "Iran", "Iraq", "Algeria", 
                        "Nigeria", "Angola", "Gabon", "Equatorial Guinea", 
                        "Ghana", "Venezuela", "Brazil", "Ecuador", "Mexico", 
                        "Indonesia", "Malaysia", "Kazakhstan", "Azerbaijan", 
                        "Russia", "Norway", "United Arab Emirates", "Qatar", 
                        "Oman", "Libya", "Sudan", "Trinidad and Tobago", 
                        "Suriname", "Colombia", "Yemen", "Turkmenistan", "Uzbekistan", 
                        "Thailand", "Vietnam", "Cameroon", "South Sudan", 
                        "Myanmar", "Congo, Rep.", "Peru", "Bolivia", "Argentina", 
                        "Pakistan", "Syria", "United States", 
                        "Canada", "United Kingdom", "Denmark", "Italy", 
                        "Germany", "Poland", "China", "India", "Australia", 
                        "Egypt", "Turkey", "Romania", "Ukraine", "Mongolia")
# Define selected countries
# selected_countries_WB <- c("Saudi Arabia", "Kuwait", "Iran, Islamic Rep.", "Iraq", "Algeria", 
#                           "Nigeria", "Angola", "Gabon", "Equatorial Guinea", 
#                           "Ghana", "Venezuela, RB", "Brazil", "Ecuador", "Mexico", 
#                           "Indonesia", "Malaysia", "Kazakhstan", "Azerbaijan")
selected_countries_WB <- c("Saudi Arabia", "Kuwait", "Iran, Islamic Rep.", "Iraq", "Algeria", 
                           "Nigeria", "Angola", "Gabon", "Equatorial Guinea", 
                           "Ghana", "Venezuela, RB", "Brazil", "Ecuador", "Mexico", 
                           "Indonesia", "Malaysia", "Kazakhstan", "Azerbaijan", 
                           "Russian Federation", "Norway", "United Arab Emirates", "Qatar", 
                           "Oman", "Libya", "Sudan", "Trinidad and Tobago", 
                           "Suriname", "Colombia", "Yemen", "Turkmenistan", "Uzbekistan", 
                           "Thailand", "Vietnam", "Cameroon", "South Sudan", 
                           "Myanmar", "Congo, Rep.", "Peru", "Bolivia", "Argentina", 
                           "Pakistan", "Syrian Arab Republic", "United States", 
                           "Canada", "United Kingdom", "Denmark", "Italy", 
                           "Germany", "Poland", "China", "India", "Australia", 
                           "Egypt", "Turkey", "Romania", "Ukraine", "Mongolia")

# View available countries to find ISO codes
countries <- WDI_data$country

# Filter countries for the selected list and get ISO-3 codes
country_codes <- countries[countries$country %in% selected_countries_WB, ]
iso3_codes <- country_codes$iso3c

# Retrieve World Bank data, including natural capital for oil and total land area
wb_data <- WDI(country = iso3_codes, 
               indicator = c("NY.GDP.PCAP.KD", "NE.GDI.FTOT.CD", "SL.TLF.TOTL.IN", 
                             "NY.ADJ.DNGY.CD", "AG.LND.ARBL.HA", "SL.UEM.TOTL.ZS"), 
               start = 1960, end = 2020)

# Search for indicators related to capital formation
# capital_search <- WDIsearch('NY.ADJ.DNGY.CD')
# view(capital_search)

# View the results to find the correct indicator code
# view(capital_search)

# Rename columns based on observed structure
colnames(wb_data) <- c("Country", "ISO2", "ISO3", "Year", "GDP_per_capita", "Capital_Formation", 
                       "Labor_Force", "Oil_Natural_Capital", "Total_Land", "Unemployment")
# Load VDEM dataset
DemocracyIndicators <- readRDS("V-Dem-CY-Full+Others-v14.rds")

# Select and rename relevant indicators
DemocracyIndicators <- DemocracyIndicators %>%
  mutate(
    corruption = v2x_corr,
    absence_political_violence = v2clkill,
    property_rights = rowMeans(select(., v2clprptym, v2clprptyw), na.rm = TRUE),
    bureaucratic_quality = rowMeans(select(., v2exbribe, v2exembez), na.rm = TRUE),
    transparent_laws = v2cltrnslw)

# Filter and select relevant columns for selected countries and years
institutions_data <- DemocracyIndicators %>%
  filter(country_name %in% selected_countries, year >= 1950) %>%
  select(country_name, year, corruption, absence_political_violence, 
         property_rights, bureaucratic_quality, transparent_laws)

# Step 1: Perform principle component analysis
# pca_results <- institutions_data %>%
#  select(-country_name, -year) %>%
#  prcomp(center = TRUE, scale. = TRUE)
# Step 1: Perform principle component analysis
pca_results <- institutions_data %>%
  select(-country_name, -year) %>%
  prcomp(center = TRUE, scale. = TRUE)

# Step 2: Extract the first principal component 
institutions_data <- institutions_data %>%
  mutate(institution_measure = pca_results$x[, 1])

# Step 3: Apply log-modulus transformation to mitigate negative values
institutions_data <- institutions_data %>%
  mutate(institution_measure_log = sign(institution_measure) * log(abs(institution_measure) + 1))

institutions_data <- institutions_data %>%
  select(country_name, year, institution_measure_log)
# view(institutions_data)

## INSTRUMENTAL VARIABLE
# IV_1: 10 year oil reserve lag
# To prove exogeneity, we will be using two instrumental variables

# Load the data for oil-proved reserves
oil_reserves <- read.csv("oil-proved-reserves.csv")

# Use your existing filtered data
oil_reserves_filtered <- oil_reserves[oil_reserves$Entity %in% selected_countries, ]
# view(oil_reserves_filtered)

# Add a 10-year lag to the relevant column, assuming the oil reserves column is named "Oil_Reserves"
oil_reserves_filtered <- oil_reserves_filtered %>%
  dplyr::mutate(Lagged_Oil_Reserves = dplyr::lag(Oil.proved.reserves...t, n = 10))

IV_1 <- oil_reserves_filtered %>%
  select(Entity, Year, Lagged_Oil_Reserves)
# view(IV_1)

# IV_2: Construction of oil pipelines (institutional quality)
# IV_2 <- wb_data[, c("Country", "Year", "Pipeline_Construction")]
# view(IV_2)

## GDP PER CAPITA
wb_data <- wb_data %>%
  group_by(Country, Year) %>%
  filter(!is.na(GDP_per_capita)) %>%  # Prioritize non-NA values
  slice(1) %>%  # Take the first row in case of ties
  ungroup()
gdp_per_capita <- wb_data[, c("Country", "Year", "GDP_per_capita")]

## CAPITAL
capital <- wb_data[, c("Country", "Year", "Capital_Formation")]

## LABOUR
labour <- wb_data[, c("Country", "Year", "Labor_Force")]
wb_data <- wb_data %>%
  mutate(Unemployment_Absolute = Labor_Force * (Unemployment / 100))  # Convert Unemployment rate (%) to absolute value

## EXHAUSTIBLE RESOURCES
exhaustible_resources <- wb_data[, c("Country", "Year", "Oil_Natural_Capital")]
# View(exhaustible_resources)

## LAND
land <- wb_data[, c("Country", "Year", "Total_Land")]
# View(land)

# Combine all variables into a single data frame
data_panel <- institutions_data %>%
  left_join(gdp_per_capita, by = c("country_name" = "Country", "year" = "Year")) %>%
  left_join(capital, by = c("country_name" = "Country", "year" = "Year")) %>%
  left_join(wb_data[, c("Country", "Year", "Labor_Force", "Unemployment_Absolute")], 
            by = c("country_name" = "Country", "year" = "Year")) %>%
  left_join(land, by = c("country_name" = "Country", "year" = "Year")) %>%
  left_join(exhaustible_resources, by = c("country_name" = "Country", "year" = "Year")) %>%
  left_join(IV_1, by = c("country_name" = "Entity", "year" = "Year")) %>%
  rename(
    Country = country_name,
    Year = year,
    Institution_Log = institution_measure_log,
    GDP_pc = GDP_per_capita,
    Capital = Capital_Formation,
    Labour = Labor_Force,
    Unemployment = Unemployment_Absolute,
    Land = Total_Land,
    Resources = Oil_Natural_Capital,
    Oil_Reserves_Lagged = Lagged_Oil_Reserves
  )
# view(data_panel)

data_panel <- data_panel %>%
  mutate(
    log_Y = log(GDP_pc),
    log_K = log(Capital),
    log_L = log(Labour),
    log_U = log(Unemployment),  # Log absolute unemployment
    log_T = log(Land),
    log_R = log(Resources),
    log_I = Institution_Log,  # Create log_I
    log_IV_oil = log(Oil_Reserves_Lagged)
  )
# %>%
# select(-Institution_Log)  # Remove Institution_Log
# view(data_panel)

# Filter the data for consistency
filtered_panel <- data_panel %>%
  filter(
    !is.na(log_I),  
    !is.na(log_IV_oil),  
    !is.na(log_Y),  
    !is.na(log_K),  
    !is.na(log_L),  
    !is.na(log_U),  # Ensure Unemployment is non-missing
    !is.na(log_T),  
    !is.na(log_R)
  )
filtered_panel <- filtered_panel %>%
  mutate(
    log_IV_oil = ifelse(log_IV_oil == 0, NA, log(log_IV_oil)),
    log_K = ifelse(log_K == 0, NA, log(log_K)),
    log_L = ifelse(log_L == 0, NA, log(log_L)),
    log_T = ifelse(log_T == 0, NA, log(log_T)),
    log_R = ifelse(log_R == 0, NA, log(log_R))
  )
filtered_panel <- filtered_panel %>%
  filter(!is.na(log_IV_oil) & !is.na(log_K) & !is.na(log_L) &
           !is.na(log_T) & !is.na(log_R))
filtered_panel <- pdata.frame(filtered_panel, index = c("Country", "Year"))

log_Y <- filtered_panel$log_Y
log_K <- filtered_panel$log_K
log_L <- filtered_panel$log_L
log_T <- filtered_panel$log_T
log_R <- filtered_panel$log_R
log_I <- filtered_panel$log_I
log_IV_oil <- filtered_panel$log_IV_oil
log_U <- filtered_panel$log_U

# boot_ur(log_IV_oil)
# view(log_IV_oil)
# Regression ####

## First stage
first_stage <- feols(
  log_I ~ log_IV_oil + log_K + log_L + log_T + log_R | Year + Country, 
  data = filtered_panel
)

filtered_panel$fitted_iv <- first_stage$fitted.values

data_panel <- pdata.frame(data_panel, index = c("Country", "Year"))
merged_panel <- merge(data_panel, filtered_panel[, c("Country", "Year", "fitted_iv")], 
                      by = c("Country", "Year"), all.x = TRUE)

# Extract the t-statistic for the instrument (log_IV_oil)
t_stat_iv <- coef(summary(first_stage))["log_IV_oil", "t value"]
f_stat_iv <- t_stat_iv^2  # Calculate the F-statistic (square of the t-statistic)

second_stage <- feols(
  log_Y ~ fitted_iv + log_K + log_L + log_T + log_R | Year + Country,
  data = merged_panel
)
summary(second_stage)

# Etable format for regression results
etable(
  first_stage, 
  second_stage, 
  title = "First and Second Stage Regression Results",
  subtitles = c("First Stage: Instrument Validity Test", "Second Stage: Augmented Solow Model"),
  dict = c(
    "log_IV_oil" = "Proposed Instrument (log_IV_oil)",
    "log_I" = "Endogenous Variable (log_I)",
    "fitted_iv" = "Instrumented log_I (fitted_iv)",
    "log_K" = "Capital (log_K)",
    "log_L" = "Labor (log_L)",
    "log_T" = "Technology (log_T)",
    "log_R" = "Resources (log_R)"
  ),
  fitstat = c("n", "ivf", "r2", "adj.r2", "f.stat"),
  notes = "Note: First stage tests the validity of the proposed instrument (log_IV_oil). Second stage estimates the Solow model using the fitted instrumented values of log_I. Instrument strength (ivf) is reported as the first-stage F-statistic."
)

latex_table <- etable(
  first_stage, 
  second_stage, 
  tex = TRUE,
  dict = c(
    "log_IV_oil" = "Proposed Instrument (log_IV_oil)",
    "fitted_iv" = "Instrumented log_I (fitted_iv)",
    "log_K" = "Capital (log_K)",
    "log_L" = "Labor (log_L)",
    "log_T" = "Fixed Land (log_T)",
    "log_R" = "Resources (log_R)"
  ),
  fitstat = c("n", "ivf", "r2", "", "f.stat")
)

# OTHER????

etable_output <- etable(
  first_stage, 
  second_stage, 
  title = "First and Second Stage Regression Results",
  subtitles = c("First Stage: Instrument Validity Test", "Second Stage: Augmented Solow Model"),
  dict = c(
    "log_IV_oil" = "Proposed Instrument (log_IV_oil)",
    "log_I" = "Endogenous Variable (log_I)",
    "fitted_iv" = "Instrumented log_I (fitted_iv)",
    "log_K" = "Capital (log_K)",
    "log_L" = "Labor (log_L)",
    "log_T" = "Technology (log_T)",
    "log_R" = "Resources (log_R)"
  ),
  fitstat = c("n", "r2", "adj.r2", "f.stat"),
  custom_fitstat = list(
    "First Stage IV F-Statistic" = ~ .[[1]]$fstat_iv <- f_stat_iv
  ),
  notes = "Note: First stage tests the validity of the proposed instrument (log_IV_oil). Instrument strength (ivf) is the square of its t-statistic. Second stage estimates the Solow model using the fitted instrumented values of log_I."
)

# Generate LaTeX table for use in documents
latex_table <- etable(
  first_stage, 
  second_stage, 
  tex = TRUE,
  dict = c(
    "log_IV_oil" = "Proposed Instrument (log_IV_oil)",
    "fitted_iv" = "Instrumented log_I (fitted_iv)",
    "log_K" = "Capital (log_K)",
    "log_L" = "Labor (log_L)",
    "log_T" = "Fixed Land (log_T)",
    "log_R" = "Resources (log_R)"
  ),
  fitstat = c("n", "r2", "adj.r2", "f.stat"),
  custom_fitstat = list(
    "First Stage IV F-Statistic" = ~ .[[1]]$fstat_iv <- f_stat_iv
  )
)
# Apply custom line thickness
custom_table <- set_rules(latex_table, heavy = "0.12em", light = "0.05em")

# Print the LaTeX table directly in the RMarkdown output
cat(custom_table, sep = "\n")

# Further analysis ####
# Incorporate weather data to account for IV external effects
temperature_data <- read.csv("GDL-Yearly-Average-Surface-Temperature-(ºC)-data.csv")
precipitation_data <- read.csv("GDL-Total-Yearly-Precipitation-(m)-data.csv")

# Filter data
temperature_data_long <- temperature_data %>%
  pivot_longer(
    cols = starts_with("X"),       # Select columns starting with "X"
    names_to = "Year",             # Create a column named "Year"
    values_to = "Temperature"      # Create a column named "Temperature"
  ) %>%
  mutate(Year = as.integer(sub("X", "", Year)))  # Remove 'X' prefix and convert to integer

# Reshape precipitation data
precipitation_data_long <- precipitation_data %>%
  pivot_longer(
    cols = starts_with("X"),       # Select columns starting with "X"
    names_to = "Year",             # Create a column named "Year"
    values_to = "Precipitation"    # Create a column named "Precipitation"
  ) %>%
  mutate(Year = as.integer(sub("X", "", Year))) 

temperature_data_filtered <- temperature_data_long %>%
  filter(Country %in% selected_countries_WB, Region == "Total")

# Filter precipitation data
precipitation_data_filtered <- precipitation_data_long %>%
  filter(Country %in% selected_countries_WB, Region == "Total")

data_panel <- data_panel %>%
  mutate(Year = as.integer(as.character(Year))) # Convert from factor to integer

temperature_data_filtered <- temperature_data_filtered %>%
  mutate(Year = as.integer(Year)) # Ensure Year is integer

precipitation_data_filtered <- precipitation_data_filtered %>%
  mutate(Year = as.integer(Year)) # Ensure Year is integer

# Merge temperature and precipitation data into the main panel
 data_panel <- data_panel %>%
  left_join(temperature_data_filtered, by = c("Country", "Year")) %>%
  left_join(precipitation_data_filtered, by = c("Country", "Year"))

data_panel <- data_panel %>%
  mutate(
    log_Temperature = log(Temperature),
    log_Precipitation = log(Precipitation)
  )

# Filter for extended dataset with additional variables
 filtered_panel2 <- data_panel %>%
  filter(
    !is.na(log_I),  
    !is.na(log_IV_oil),  
    !is.na(log_Y),  
    !is.na(log_K),  
    !is.na(log_L),  
    !is.na(log_T),  
    !is.na(log_R),  
    !is.na(log_Temperature),  
    !is.na(log_Precipitation),
    !is.na(log_U)  # Ensure Unemployment log is non-missing
  )

 data_panel <- data_panel %>%
   mutate(across(c(log_I, log_IV_oil, log_K, log_L, log_T, log_R, log_Temperature, log_Precipitation, log_U), 
                 ~ifelse(is.infinite(.), NA, .)))
 
 filtered_panel2 <- data_panel %>%
   filter(
     !is.na(log_I),  
     !is.na(log_IV_oil),  
     !is.na(log_Y),  
     !is.na(log_K),  
     !is.na(log_L),  
     !is.na(log_T),  
     !is.na(log_R),  
     !is.na(log_Temperature),  
     !is.na(log_Precipitation),
     !is.na(log_U)
   )
 
# First-stage regression with extended variables
first_stage_extended <- feols(
  log_I ~ log_IV_oil + log_K + log_L + log_T + log_R + log_Temperature + log_Precipitation + log_U | Year + Country, 
  data = filtered_panel2
)

# Add the new fitted values from the extended first stage
filtered_panel2 <- filtered_panel2 %>%
  mutate(fitted_iv = first_stage_extended$fitted.values)

# Extract the t-statistic for the instrument (log_IV_oil)


# Second-stage regression with extended variables
second_stage_extended <- feols(
  log_Y ~ fitted_iv + log_K + log_L + log_T + log_R + log_Temperature + log_Precipitation + log_U | Year + Country, 
  data = filtered_panel2
)
summary(second_stage_extended)

# Construct a formatted regression table with etable
etable_output <- etable(
  first_stage_extended, 
  second_stage_extended, 
  title = "First and Second Stage Regression Results",
  subtitles = c("First Stage: Instrument Validity Test", "Second Stage: Augmented Solow Model"),
  dict = c(
    "log_IV_oil" = "Proposed Instrument (log_IV_oil)",
    "log_I" = "Endogenous Variable (log_I)",
    "fitted_iv" = "Instrumented log_I (fitted_iv)",
    "log_K" = "Capital (log_K)",
    "log_L" = "Labor (log_L)",
    "log_T" = "Technology (log_T)",
    "log_R" = "Resources (log_R)",
    "log_Temperature" = "Temperature (log_Temperature)",
    "log_Precipitation" = "Precipitation (log_Precipitation)",
    "log_U" = "Urbanization (log_U)"
  ),
  fitstat = c("n", "r2", "adj.r2", "f.stat"),
  custom_fitstat = list(
    "First Stage IV F-Statistic" = ~ .[[1]]$fstat_iv <- f_stat_iv
  ),
  notes = "Note: First stage reports the F-statistic for the instrument (log_IV_oil), calculated as the square of its t-statistic. Second stage estimates the Solow model using the fitted instrumented values of log_I."
)

# Generate LaTeX table for use in documents
latex_table <- etable(
  first_stage_extended, 
  second_stage_extended, 
  tex = TRUE,
  dict = c(
    "log_IV_oil" = "Proposed Instrument (log_IV_oil)",
    "fitted_iv" = "Instrumented log_I (fitted_iv)",
    "log_K" = "Capital (log_K)",
    "log_L" = "Labor (log_L)",
    "log_T" = "Technology (log_T)",
    "log_R" = "Resources (log_R)",
    "log_Temperature" = "Temperature (log_Temperature)",
    "log_Precipitation" = "Precipitation (log_Precipitation)",
    "log_U" = "Urbanization (log_U)"
  ),
  fitstat = c("n", "r2", "adj.r2", "f.stat"),
  custom_fitstat = list(
    "First Stage IV F-Statistic" = ~ .[[1]]$fstat_iv <- f_stat_iv
  )
)

# Colonial dummies ####
Colony <- data.frame(
  Country = selected_countries_WB,
  Colony = c(
    0,  # Saudi Arabia
    1,  # Kuwait (British)
    0,  # Iran
    1,  # Iraq (British)
    1,  # Algeria (France)
    1,  # Nigeria (British)
    1,  # Angola (Portuguese)
    1,  # Gabon (France)
    1,  # Equatorial Guinea (Spain)
    1,  # Ghana (British)
    1,  # Venezuela (Spain)
    1,  # Brazil (Portuguese)
    1,  # Ecuador (Spain)
    1,  # Mexico (Spain)
    1,  # Indonesia (Dutch)
    1,  # Malaysia (Dutch)
    1,  # Kazakhstan (Russian Empire)
    1   # Azerbaijan (Russian Empire)
  )
)

data_panel <- data_panel %>%
  left_join(Colony, by = c("Country" = "Country"))

country_colonial_data <- data.frame(
  Country = selected_countries_WB,
  Colonial_Type = c(
    "None",        # Saudi Arabia
    "British",     # Kuwait
    "None",        # Iran
    "British",     # Iraq
    "French",      # Algeria
    "British",     # Nigeria
    "Portuguese",  # Angola
    "French",      # Gabon
    "Spanish",     # Equatorial Guinea
    "British",     # Ghana
    "Spanish",     # Venezuela
    "Portuguese",  # Brazil
    "Spanish",     # Ecuador
    "Spanish",     # Mexico
    "Dutch",       # Indonesia
    "Dutch",       # Malaysia
    "Russian",     # Kazakhstan
    "Russian"      # Azerbaijan
  )
)

country_colonial_data$Colonial_Type <- factor(country_colonial_data$Colonial_Type)

data_panel <- data_panel %>%
  left_join(country_colonial_data, by = c("Country" = "Country"))

# Second stage binary
regression_binary_interaction <- feols(
  log_Y ~ log_IV_oil * Colony + log_K + log_L + log_T + log_R | Year + Country,
  data = filtered_panel2
)
view(data_panel)
summary(regression_binary_interaction)


# Second stage binary + interaction
# Conditions and Data Tests ####
x
# Graphical Results ####
dsadsa
# Extensions ####
dsadsa

fixed_model <- plm(
  log_I ~ log_IV_oil,   # Dependent and independent variables
  data = filtered_panel, # Panel data
  model = "within"      # Fixed effect OLS model
)

pooled_model <- plm(
  log_I ~ log_IV_oil,   # Dependent and independent variables
  data = filtered_panel, # Panel data
  model = "pooling"      # Pooled OLS model
)

# Display the summary of the Pooled OLS model
summary(fixed_model)
summary(pooled_model)

hausman_test <- phtest(fixed_model, pooled_model)
print(hausman_test)

# Extract fitted values from the first stage
filtered_panel$fitted_iv <- fitted(iv_model)

# Display first-stage results with stargazer
stargazer(
  iv_model,
  type = "text",
  title = "First Stage Instrumental Variable Results",
  dep.var.labels = "Institutions (log)",
  covariate.labels = "Oil Resource t-10 (log)"
)

# Second-stage regression with plm
second_stage <- plm(
  log_Y ~ log_K + log_L + log_T + log_R + fixed_model <- plm(
  log_I ~ log_IV_oil,   # Dependent and independent variables
  data = filtered_panel, # Panel data
  model = "within"      # Fixed effect OLS model
)

pooled_model <- plm(
  log_I ~ log_IV_oil,   # Dependent and independent variables
  data = filtered_panel, # Panel data
  model = "pooling"      # Pooled OLS model
)

# Display the summary of the Pooled OLS model
summary(fixed_model)
summary(pooled_model),
  data = data_panel,
  model = "within"  # Fixed-effects model
)

# Display second-stage results with stargazer
stargazer(
  second_stage,
  type = "text",
  title = "2SLS Regression Results",
  dep.var.labels = "Output (log)",
  covariate.labels = c("Capital (log)", "Labor (log)", "Land (log)", "Resources (log)", "Fitted IV")
)
