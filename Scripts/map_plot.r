library(ggplot2)
library(dplyr)
library(readxl)
library(tidyr)
library(ggrepel)
library(RColorBrewer)  # For color palettes
library(gganimate)
library(gifski)
library(transformr)
library(shiny)
library(rnaturalearth)
library(rnaturalearthdata)
library(sf)
library(scales)
library(stringr)
library(ggtext)  # For rich text in ggplot2 themes
#-------------------Data Preparation--------------------
# Load each dataset, skipping the first rows and treating ":" as NA
renewable <- read_excel("renewable.xlsx", skip = 8, na = ":") 
total <- read_excel("total.xlsx", skip = 9, na = ":")          
density <- read_excel("density.xlsx", skip = 7, na = ":") 

# Rename the first column to "Country" for each dataset
colnames(renewable)[1] <- "Country"
colnames(total)[1] <- "Country"
colnames(density)[1] <- "Country"

# Convert each dataset to long format and filter for 2022
renewable_long <- renewable %>%
  pivot_longer(cols = -Country, names_to = "Year", values_to = "RenewableEnergyPercentage") %>%
  mutate(Year = as.integer(Year))

total_long <- total %>%
  pivot_longer(cols = -Country, names_to = "Year", values_to = "TotalEnergyConsumption") %>%
  mutate(Year = as.integer(Year))

density_long <- density %>%
  pivot_longer(cols = -Country, names_to = "Year", values_to = "PopulationDensity") %>%
  mutate(Year = as.integer(Year)) %>%
  mutate(PopulationDensity = as.numeric(PopulationDensity))  # Convert to numeric

# Merge the datasets by Country and Year
data <- renewable_long %>%
  inner_join(total_long, by = c("Country", "Year")) %>%
  inner_join(density_long, by = c("Country", "Year"))

# Filter for relevant year and countries (EU)
#removed Luxembourg, Lithuania , Malta, Slovakia
relevant_year <- "2022"
relevant_countries <- c(
  "Austria", "Belgium", "Croatia", "Cyprus", "Czechia", 
  "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", 
  "Hungary", "Ireland", "Italy", "Latvia", "Netherlands", "Poland", "Portugal", "Romania", 
  "Slovenia", "Spain", "Sweden"
)

# Filter the data to include only the relevant year and countries
filtered_data <- data %>%
  filter(Year == relevant_year, Country %in% relevant_countries)

# Add Region column based on countries
filtered_data <- filtered_data %>%
  mutate(Region = case_when(
    Country %in% c("Denmark", "Estonia", "Finland", "Latvia", "Sweden") ~ "Northern Europe",
    Country %in% c("Bulgaria", "Czechia", "Hungary", "Poland", "Romania", "Slovakia", "Slovenia") ~ "Eastern Europe",
    Country %in% c("Austria", "Belgium", "France", "Germany", "Netherlands", "Ireland") ~ "Western Europe",
    Country %in% c("Italy", "Portugal", "Spain", "Croatia", "Greece", "Cyprus") ~ "Southern Europe",
    TRUE ~ "Other"  
  ))



# Save the file
#ggsave( filename = "RenewableEnergy_vs_TotalEnergy.png", plot = plot_dark,width = 11, height = 10, dpi = 600)


#-------------------------MAP----------------------------------------------------------------------------------------------------------
europe_map <- ne_countries(scale = "medium", continent = "Europe", returnclass = "sf")
europe_map <- europe_map %>%
  filter(!sovereignt %in% c("French Guiana", "Guadeloupe", "Martinique"))


europe_map <- europe_map %>%
  mutate(name = case_when(
    name == "Czech Republic" ~ "Czechia",
    name == "United Kingdom" ~ "United Kingdom",
    TRUE ~ name
  ))

map_data <- europe_map %>%
inner_join(filtered_data, by = c("name" = "Country"))

map_data$Region <- as.factor(map_data$Region)  

map_data <- map_data %>%
  mutate(ShowLabel = name %in% c("France", "Germany", "Spain", "Sweden", "Portugal","Ireland", "Poland", "Italy"))  # Add countries you want to label

# Map plot
map_plot <- ggplot() +
  # Base map of Europe with borders
  geom_sf(data = europe_map, fill = "white", color = "#000000", size = 0.5) +
  
  # Overlay countries with renewable energy data
  geom_sf(data = map_data, aes(fill = RenewableEnergyPercentage), color = "black", size = 0.5) +
  
  # Gradient scale for renewable energy percentage
  scale_fill_gradient(
    low = "#fff33b",
    high = "#e93e3a",
    name = "Renewable Energy \nConsumption (%)",
    labels = scales::percent_format(scale = 1),
    limits = c(0, 100),
    na.value = "white"  # Ensure unfilled countries are white
  ) +
  
  # Labels for selected countries
  geom_label_repel(
    data = map_data %>% filter(ShowLabel),
    aes(
      label = paste(
        name,
        "\nRenewable: ", sprintf("%.1f%%", RenewableEnergyPercentage),
        "\nTotal Consumption: ", scales::comma(TotalEnergyConsumption, accuracy = 1), "TWh"
      ),
      geometry = geometry
    ),
    stat = "sf_coordinates",
    size = 3,
    color = "#000000",
    fill = "#ffffff",
    fontface = "bold",
    label.size = 0.3,  # Border width of labels
    box.padding = 0.5,
    point.padding = 0.3,
    max.overlaps = 10  # Avoid excessive overlap
  ) +
  
  # Harmonious green theme with no axes
  theme_void() +
  theme(
    panel.background = element_rect(fill = "#e7f3ff", color = NA),  # Light green panel
    plot.background = element_rect(fill = "#e7f3ff", color = NA),   # Light green background
    legend.background = element_rect(fill = "#e7f3ff", color = NA),
    legend.text = element_text(color = "#000000"),
    legend.title = element_text(color = "#000000", face = "bold"),
    plot.title = element_text(face = "bold", size = 16, color = "#000000", hjust = 0.5),
    plot.subtitle = element_text(size = 12, color = "#000000", hjust = 0.5),
    plot.caption = element_text(size = 9, color = "#000000", hjust = 0),

    # Place the legend inside the plot
    legend.position = c(0.03, 0.4),  # Position it towards the right side
    legend.justification = c("left", "center")  # Adjust legend alignment to the center
  
  ) +
  
  # Focus on Europe with specific coordinates
  coord_sf(xlim = c(-20, 30), ylim = c(35, 70), expand = FALSE) +
  
  # Titles and captions
  labs(
    title = "Renewable Energy Consumption by Country in Europe (2022)",
    subtitle = "Gradient reflects renewable energy percentage. Selected countries are labeled with detailed info.",
    caption = "Data Source: Pordata | Created on 16-11-2024"
    )

# Print the plot
print(map_plot)

# Save the map plot
#ggsave( filename = "Map_Renewable_Energy_Consumption.png", plot = map_plot, width = 10, height = 12,dpi = 600 )

