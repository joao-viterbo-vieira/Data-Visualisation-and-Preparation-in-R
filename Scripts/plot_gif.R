install.packages("gganimate")
install.packages("gifski")
install.packages("transformr")

# Load necessary libraries
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
  filter( Country %in% relevant_countries)

# Add Region column based on countries
filtered_data <- filtered_data %>%
  mutate(Region = case_when(
    Country %in% c("Denmark", "Estonia", "Finland", "Latvia", "Sweden") ~ "Northern Europe",
    Country %in% c("Bulgaria", "Czechia", "Hungary", "Poland", "Romania", "Slovakia", "Slovenia") ~ "Eastern Europe",
    Country %in% c("Austria", "Belgium", "France", "Germany", "Netherlands", "Ireland") ~ "Western Europe",
    Country %in% c("Italy", "Portugal", "Spain", "Croatia", "Greece", "Cyprus") ~ "Southern Europe",
    TRUE ~ "Other"  
  ))

# Extract European Union renewable share
eu_renewable <- renewable_long %>%
  filter(Country == "European Union") %>%
  pull(RenewableEnergyPercentage)


eu_target <- 42.5


# Calculate fixed positions for country labels based on the first year
fixed_positions <- filtered_data %>%
  filter(Year == min(Year, na.rm = TRUE)) %>%
  select(Country, TotalEnergyConsumption, RenewableEnergyPercentage)

# Join fixed positions with the full dataset
filtered_data <- filtered_data %>%
  left_join(fixed_positions, by = "Country", suffix = c("", "_fixed"))


#-------------------------Create Plots-----------------------------
palette_dark <- c(
  "Northern Europe" = "#1f78b4",  # Blue
  "Eastern Europe" = "#33a02c",   # Green
  "Western Europe" = "#e31a1c",   # Red
  "Southern Europe" = "#ff7f00",  # Orange
  "Other" = "#6a3d9a"             # Purple
)

# Create a custom legend for Population Density
legend_bubble <- data.frame(
  x = 180000,
  y = 45,
  label = "Country Population",
  size = max(filtered_data$PopulationDensity) * 0.6
)

# Find the minimum and maximum renewable energy percentages points
min_point <- filtered_data[which.min(filtered_data$RenewableEnergyPercentage), ]
max_point <- filtered_data[which.max(filtered_data$RenewableEnergyPercentage), ]


# Modified plot with additional legend entry for Population Density
plot_dark <- ggplot(filtered_data, aes(x = TotalEnergyConsumption, y = RenewableEnergyPercentage)) +
  geom_point(aes(size = PopulationDensity, color = Region), alpha = 0.8) +
  
  geom_text_repel(aes(label = Country), size = 4,color = "white", box.padding = 0.5,point.padding = 0.5,
    max.overlaps = 15, segment.color = "grey50",fontface = "bold",bg.color = "black", bg.r = 0.15) +

  
  # EU Renewable Energy Target Area
  geom_hline(yintercept = eu_target, linetype = "dashed", color = "#7FDBFF", linewidth = 0.7) +
  annotate("text", x = max(filtered_data$TotalEnergyConsumption, na.rm = TRUE) * 0.7,
           y = eu_target + 2,label = "EU Renewable Target 2030",color = "#7FDBFF",size = 4,fontface = "italic") +
  
  # EU Average Renewable Energy Line
 geom_hline(data = renewable_long %>% filter(Country == "European Union"),
             aes(yintercept = RenewableEnergyPercentage, group = Year), linetype = "dashed", color = "#FFDC00", linewidth =  0.7) +
  geom_text(data = renewable_long %>% filter(Country == "European Union"),
            aes(x = max(filtered_data$TotalEnergyConsumption, na.rm = TRUE) * 0.8,
                y = RenewableEnergyPercentage + 1,
                label = "EU Share"),
            color = "#FFDC00", size = 4, hjust = 0, fontface = "italic") +

            
  
  # Add custom bubble legend for Country population
  geom_point(data = legend_bubble, aes(x = x, y = y, size = size), color = "white", alpha = 0.5) +
  annotate( "text",x = legend_bubble$x + 5000, y = legend_bubble$y,
    label = legend_bubble$label,size = 4,color = "white",hjust = 0) +
  
  # Size scale
  scale_size_continuous(range = c(4, 18), name = "Population Density") +
  
  # Y-axis formatting
  scale_y_continuous(labels = scales::label_percent(scale = 1), 
                     breaks = c(seq(10, min(100, max(filtered_data$RenewableEnergyPercentage, na.rm = TRUE)), by = 10)), 
                     limits = c(0, min(100, max(filtered_data$RenewableEnergyPercentage + 2 , na.rm = TRUE))), 
                     expand = c(0, 0)) + 
  
  # X-axis formatting
  scale_x_continuous(labels = scales::label_comma(),
                     limits = c(-3000, max(filtered_data$TotalEnergyConsumption + 6000, na.rm = TRUE)),  
                     breaks = seq(0, max(filtered_data$TotalEnergyConsumption, na.rm = TRUE), by = 20000),
                     expand = c(0, 0)) +  
  
  # Labels and titles
  labs(
    title = paste("Renewable Energy Consumption (%) vs. Total Energy Consumption (", relevant_year, ")", sep = ""),
    subtitle = "Comparison of EU Countries: Renewable Energy Patterns and Consumption",
    x = "Total Energy Consumption (TWh)",
    y = "Renewable Energy Consumption (%)",
    color = "Region",
    size = "Population Number",
    caption = "Data Source: Eurostat | Created on 16-11-2024 by João Soares, João Vieira and Manuel Silva") +
  
  # Custom color palette
  scale_color_manual(
    values = palette_dark,
    breaks = names(palette_dark),
    labels = names(palette_dark)
  ) +
  
  guides(
    color = guide_legend(
      override.aes = list(size = 5),
      title.position = "top",
      title.hjust = 0.5
    ),
    size = "none"  
  ) +

  theme(
    plot.background = element_rect(fill = "#2D2D2D", color = NA),  
    panel.background = element_rect(fill = "#4B4B4B", color = NA), 
    panel.grid.major = element_line(color = "#6E6E6E"), 
    panel.grid.minor = element_blank(), 
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5, color = "white"),
    plot.subtitle = element_text(size = 14, hjust = 0.5, color = "lightgrey"),
    axis.title = element_text(face = "bold", size = 14, color = "white"),
    axis.text = element_text(size = 12, color = "white"),
    axis.line = element_line(color = "white", size = 0.8),
    axis.ticks = element_line(color = "white", size = 0.8),
    legend.title = element_text(face = "bold", size = 12, color = "white"),
    legend.text = element_text(size = 10, color = "white"),
    legend.background = element_rect(fill = alpha("#2D2D2D", 0.7), color = "lightgrey"), 
    legend.box.background = element_rect(fill = alpha("#2D2D2D", 0.7), color = "lightgrey"),
    plot.caption = element_text(size = 11, hjust = 0, margin = margin(t = 10, b = 5), color = "lightgrey"),
    legend.position = c(0.95, 0.95),  
    legend.justification = c("right", "top"),  
    legend.direction = "vertical",
    legend.box = "vertical",
    legend.box.just = "left",
    legend.key = element_blank(),
    plot.margin = unit(c(0.3, 0.3, 0.3, 0.3), "cm")
  ) 


#Animation
animated_plot <- plot_dark +
  transition_time(as.integer(Year)) +  # Define the time variable for animation
  labs(title = "Renewable Energy Consumption (%) vs. Total Energy Consumption: Year {frame_time}")

animation <- animate(animated_plot, 
                     renderer = gifski_renderer(),  # Render as a GIF
                     duration = 15,                # Duration in seconds
                     fps = 15,                     # Frames per second
                     width = 800,                  # Width of the output
                     height = 600)                 # Height of the output

# Save the animation as a GIF
anim_save("output.gif", animation = animation)
# Display the plot