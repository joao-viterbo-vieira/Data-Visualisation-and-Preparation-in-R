# Load Necessary Libraries
library(ggplot2)
library(readxl)
library(dplyr)
library(stringr)
library(ggtext)  # For rich text in ggplot2 themes

# Load Data from Excel
file_path <- "4_SharesBreakFar_reorganized.xlsx" 
data <- read_excel(file_path)

# Rename Columns, If Necessary
colnames(data) <- c("Country_Name", "Energy_Type", "Country", "Value")

# Ensure Values Are Numeric
data$Value <- as.numeric(data$Value)

# Define Relevant Names
relevant_names <- c(
  "Austria", "Belgium", "Croatia", "Cyprus", "Czechia", 
  "Denmark", "Estonia", "Finland", "France", "Germany", "Greece", 
  "Ireland", "Italy", "Latvia", "Netherlands", "Poland", "Portugal", 
  "Romania", "Slovenia", "Spain", "Sweden", "European Values"
)

# Filter Data to Include Only Relevant Countries
data <- data %>%
  filter(Country_Name %in% relevant_names)

# Group and Sum Data by Country and Energy Type
data <- data %>%
  group_by(Country_Name, Energy_Type) %>%
  summarise(Value = sum(Value, na.rm = TRUE)) %>%
  ungroup()

# Calculate the Proportion of 'Heating and Cooling' for Each Country
heating_cooling_data <- data %>%
  filter(Energy_Type == "heating and cooling") %>%
  group_by(Country_Name) %>%
  summarise(Heating_Cooling_Value = sum(Value, na.rm = TRUE))

# Combine with Main Data to Retain All Energy Types
data <- data %>%
  left_join(heating_cooling_data, by = "Country_Name") %>%
  mutate(Heating_Cooling_Value = ifelse(is.na(Heating_Cooling_Value), 0, Heating_Cooling_Value))

# Reorder Countries Based on the Proportion of 'Heating and Cooling'
data$Country_Name <- reorder(data$Country_Name, -data$Heating_Cooling_Value)

# Highlight Specific Labels: "European Values" and "Portugal"
# Modify the Country_Name factor to include HTML styling for highlighted labels
data <- data %>%
  mutate(Country_Label = case_when(
    Country_Name == "European Values" ~ "<span style='color:blue'><b>European Values</b></span>",
    Country_Name == "Portugal" ~ "<span style='color:red'><b>Portugal</b></span>",
    TRUE ~ as.character(Country_Name)
  ))

# Create the Plot with Enhanced Title, Subtitle, and Caption
plot_bar <- ggplot(data, aes(x = Value, y = Country_Label, fill = Energy_Type)) +
  geom_bar(stat = "identity", position = "fill") +  # Stacked Normalized Bar Chart
  scale_x_continuous(labels = scales::percent_format()) +  # Percentage Scale on X-axis
  labs(
    title = "Distribution of Renewable Energy Consumption Across Sectors in 2022",
    subtitle = "Analyzing the Share of Renewable Electricity, Heating & Cooling, and Transport Biofuels\n in Final Energy Use Across EU Countries",
    x = "Percentage",
    y = "Country",
    fill = "Sectors",
    caption = "Data Source: EEA 2023; Eurostat 2023. | Authors: João Vieira, João Soares, and Manuel Silva"
  ) +
  theme_minimal() +
  theme(
    axis.text.y = element_markdown(size = 10),  # Use element_markdown for y-axis to render HTML
    legend.position = "bottom",
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5),
    plot.caption = element_text(size = 8, hjust = 0)
  )+
  # Optionally, add vertical reference lines at specific percentages
  geom_vline(xintercept = seq(0, 1, by = 0.25), color = "white", linetype = "dashed")

print(plot_bar)
# Salvando com fundo branco
#ggsave(filename = "renewable_energy_distribution_2022.png",width = 10,height = 6,dpi = 600, bg = "white")