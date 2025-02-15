# Data-Visualisation-and-Preparation-in-R
### Created By: João Vieira, João Soares, Manuel Silva

## 1. Introduction  
Energy consumption in Europe has seen significant shifts in recent years, driven by a growing focus on sustainable energy sources. Europe consumes roughly 13,000 TWh of energy annually, with renewable sources — such as wind, solar, and hydropower — accounting for 22% to 24% of this total.  
- **Sweden** leads with over 50% of its energy derived from renewables.  
- **Fossil fuel dependency** remains significant in some regions, reflecting the diverse energy landscape.  

The European Union has set a **target of 42.5% renewable energy consumption by 2030**. This project explores how different EU countries are progressing toward this target, comparing total energy consumption and population size to gain insights into their energy profiles.

---

## 2. Research Questions  
Our analysis addresses the following questions:  
- **How does energy consumption influence the proportion of renewable energy used?**  
- **How does population size impact renewable energy adoption?**  
- Which countries and regions have the highest/lowest percentages of renewable energy?  
- Which countries fall short of the EU's renewable energy target?  
- How do regions compare in terms of energy consumption and renewables adoption?

---

## 3. Methodology  

### 3.1 Data Understanding  
We used three datasets sourced from **Eurostat**:  
1. **Renewable Energy Data**: Share of renewables in total energy consumption (updated 19/09/2024).  
2. **Total Energy Consumption Data**: End-user energy consumption by country and year in TWh (updated 24/05/2024).  
3. **Population Size Data**: Population figures as of January 1 each year (updated 08/11/2024).  
4. **Sectoral Data**: Renewable energy usage across transport, electricity, and heating/cooling (2022 data).  

### 3.2 Data Preparation  
#### Data Cleaning  
- Replaced missing values (`":"`) with `NA`.  
- Renamed first column to `Country` for consistency.  
- Converted population values to numeric format.  

#### Data Transformation  
- Reshaped datasets into a **long format** using `pivot_longer`.  
- Merged datasets on `Country` and `Year` using `inner_join`.  
- Filtered to include EU countries and the most recent year of data.  

#### Data Reduction  
- Excluded non-EU countries, Luxembourg, Lithuania, Malta, and Slovakia.  
- Added a `Region` column to categorize countries into **Northern**, **Eastern**, **Western**, and **Southern Europe**.

---

## 4. Data Analysis and Visualizations  

### 4.1 Scatter Plot  
Visualizes the relationship between energy consumption, renewable energy share, population size, and region.  
- **X-axis**: Total energy consumption (TWh).  
- **Y-axis**: Renewable energy percentage.  
- **Color**: Differentiates European regions.  
- **Size**: Represents population size.  
- **Labels**: Highlights countries with extreme values (e.g., Sweden, Germany).  

**Additional Features**:  
- Dashed lines for **EU Renewable Energy Target (2030)** and **EU Average Renewable Energy Share**.  
- Animated version to show temporal dynamics and trends from 2020 to 2024.

---

### 4.2 Heatmap  
Displays renewable energy adoption across Europe using color intensity.  
- **High adoption**: Sweden leads with 66%.  
- **Low adoption**: Ireland lags with 13.1%.  
- Highlights regional disparities (e.g., Northern Europe outperforms Southern Europe).  

---

### 4.3 Stacked Bar Graph  
Analyzes sectoral distribution of renewable energy across countries.  
- **Sectors**: Electricity, transport (biofuels), and heating/cooling.  
- **X-axis**: Percentage of total renewable energy.  
- **Y-axis**: EU countries.  
- Highlights the dominance of renewable electricity and variation across sectors.

---

## 5. Insights  

### 5.1 Insights from Scatter Plot  
- **Sweden leads** with 66% renewables and relatively low total consumption.  
- **Germany consumes the most energy** but falls below the EU average for renewables.  
- **Northern Europe excels**, with countries like Finland and Latvia exceeding the 2030 target.  
- **Southern Europe lags**, particularly Spain and Italy.  
- **Eastern Europe shows promise** with Romania and Slovenia nearing the EU average.

**From the GIF Animation**:  
- Renewable energy adoption grew steadily from 2020 to 2024.  
- Energy consumption dipped in 2020 (COVID-19 impact) but rebounded with higher renewable shares post-pandemic.

---

### 5.2 Insights from Heatmap  
- **High performers**: Sweden (66%), Finland, and Denmark.  
- **Moderate performers**: France (20.3%), Germany (20.8%).  
- **Lagging regions**: Ireland (13.1%), Poland (16.9%).  

---

### 5.3 Insights from Stacked Bar Graph  
- Renewable electricity dominates most countries' energy profiles.  
- Sector-specific disparities reflect climatic and infrastructural factors.  
  - **Northern Europe**: Strong focus on heating/cooling.  
  - **Southern Europe**: Emphasis on solar electricity.

---

## 6. Conclusion  
This study highlights Europe's progress and challenges in adopting renewable energy:  
- **Northern Europe** leads in renewable adoption, while **Southern and Eastern Europe** show room for improvement.  
- The visualizations — scatter plot, heatmap, and stacked bar graph — provide a multi-faceted view of the dynamics influencing renewable energy.  
- Future work could integrate economic indicators for a deeper analysis.

Through effective data preparation and visualization, this project emphasizes the successes and areas requiring focus in Europe’s transition toward sustainable energy.



