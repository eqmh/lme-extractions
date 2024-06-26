# This script extracts and plots OBIS records inside Large Marine Ecosystems (LME)
# Written by E. Montes
# Aug 19, 2019

library(robis)
library(rgdal) # for `ogrInfo()` and `readOGR()`
library(tools) # for `file_path_sans_ext()`
library(dplyr) # for `inner_join()`, `filter()`, `summarise()`, and the pipe operator (%>%)
library(ggplot2) # for `fortify()` and for plotting
library(sp) # for `point.in.polygon()` and `spDists()`
library(tidyr) # for `gather()`
library(readr) # for `write_tsv()`
library(leaflet)
library(lubridate)

# Provide the function fortify.shape(), which puts the shapefile data in the object class data.frame, 
# so that it can be used by ggplot2

fortify.shape <- function(x){
  x@data$id <- rownames(x@data)
  x.f <- fortify(x, region = "id")
  x.join <- inner_join(x.f, x@data, by = "id")
}

# extract portions of the data (from the fortified data.frame object) for a smaller domain

subset.shape <- function(x, domain){
  x.subset <- filter(x, long > domain[1] & 
                       long < domain[2] & 
                       lat > domain[3] & 
                       lat < domain[4])
  x.subset
}

# Plotting the coastline and some animal observations

# Specify the local directory and name of the Natural Earth shapefile (previously downloaded) 
# and read its contents (global coastline data)
path.lme.coast <- ("~/lme-extractions/data")
fnam.lme.coast <- "LMEs66.shp"
dat.coast <- readOGR(dsn = path.lme.coast, 
                     layer = file_path_sans_ext(fnam.lme.coast))

# fortify the global data and then extract domain
dat.coast <- fortify.shape(dat.coast) # a 410951x8 dataframe

# Specify the desired LME:
dat.sel_1 <- subset(dat.coast, LME_NUMBER == 15) # S. Brazil. See numbers here: http://lme.edc.uri.edu/index.php/lme-introduction
dat.sel_2 <- subset(dat.coast, LME_NUMBER == 16) # E. Brazil
dat.sel_3 <- subset(dat.coast, LME_NUMBER == 17) # N. Brazil
dat.sel_4 <- subset(dat.coast, LME_NUMBER == 14) # Patagonia
dat.sel_5 <- subset(dat.coast, LME_NUMBER == 13) # Humboldt C.
dat.sel_6 <- subset(dat.coast, LME_NUMBER == 12) # Caribbean
dat.sel_7 <- subset(dat.coast, LME_NUMBER == 11) # P. Ctral A.
dat.sel_8 <- subset(dat.coast, LME_NUMBER == 5) # GoM
dat.sel_9 <- subset(dat.coast, LME_NUMBER == 4) # Gulf of California
dat.sel_10 <- subset(dat.coast, LME_NUMBER == 3) # CCS
dat.sel_11 <- subset(dat.coast, LME_NUMBER == 2) # G. Alaska
dat.sel_12 <- subset(dat.coast, LME_NUMBER == 1) # E. Bearing S.
dat.sel_13 <- subset(dat.coast, LME_NUMBER == 54) # Chukchi S.
dat.sel_14 <- subset(dat.coast, LME_NUMBER == 55) # Beauford S.
dat.sel_15 <- subset(dat.coast, LME_NUMBER == 66) # Canadian Arctic
dat.sel_16 <- subset(dat.coast, LME_NUMBER == 18) # Canadian E. Arctic
dat.sel_17 <- subset(dat.coast, LME_NUMBER == 9) # Labrador S.
dat.sel_18 <- subset(dat.coast, LME_NUMBER == 8) # Scotian Shelf
dat.sel_19 <- subset(dat.coast, LME_NUMBER == 7) # NE US
dat.sel_20 <- subset(dat.coast, LME_NUMBER == 6) # SE US
dat.sel_21 <- subset(dat.coast, LME_NUMBER == 10) # Hawaii
dat.sel_22 <- subset(dat.coast, LME_NUMBER == 63) # Hudson Bay Complex
dat.sel_23 <- subset(dat.coast, LME_NUMBER == 19) # Greenland Sea
dat.sel_24 <- subset(dat.coast, LME_NUMBER == 21) # Norwegian Sea
dat.sel_25 <- subset(dat.coast, LME_NUMBER == 20) # Barents Sea
dat.sel_26 <- subset(dat.coast, LME_NUMBER == 58) # Kara Sea
dat.sel_27 <- subset(dat.coast, LME_NUMBER == 57) # Laptev Sea
dat.sel_28 <- subset(dat.coast, LME_NUMBER == 56) # E. Sibarian Sea


xlims <- c(-150, -25)
ylims <- c(-60, 60)

# World map
mapWorld <- borders(database = "world", colour="gray50", fill="gray50")

# Generate a base map with the coastline:
p0 <- ggplot() + theme(text = element_text(size=18)) + 
  geom_path(data = dat.coast, aes(x = long, y = lat, group = group), 
            color = "black", size = 0.25) + 
  coord_map(projection = "mercator") + 
  scale_x_continuous(limits = xlims, expand = c(0, 0)) + 
  scale_y_continuous(limits = ylims, expand = c(0, 0)) + 
  labs(list(title = "", x = "Longitude", y = "Latitude"))

p0

# highlight LME of interest
p.sel <- p0 +
  # geom_path(data = dat.sel_1, 
  #           aes(x = long, y = lat, group = group), 
  #           colour = "goldenrod2", size = 0.75) 
  # geom_path(data = dat.sel_2,
  #           aes(x = long, y = lat, group = group),
  #           colour = "coral3", size = 0.75) 
  # geom_path(data = dat.sel_3,
  #           aes(x = long, y = lat, group = group),
  #           colour = "chocolate4", size = 0.75) 
  # geom_path(data = dat.sel_4,
  #         aes(x = long, y = lat, group = group),
  #         colour = "coral", size = 1) 
  # geom_path(data = dat.sel_5,
  #           aes(x = long, y = lat, group = group),
  #           colour = "chocolate1", size = 0.75) 
  geom_path(data = dat.sel_6,
            aes(x = long, y = lat, group = group),
            colour = "chartreuse4", size = 1) +
  # geom_path(data = dat.sel_7,
  #           aes(x = long, y = lat, group = group),
  #           colour = "chartreuse", size = 0.75) 
  geom_path(data = dat.sel_8,
            aes(x = long, y = lat, group = group),
            colour = "coral", size = 0.75)
  # geom_path(data = dat.sel_9,
  #           aes(x = long, y = lat, group = group),
  #           colour = "cadetblue4", size = 0.75) 
  # geom_path(data = dat.sel_10,
  #           aes(x = long, y = lat, group = group),
  #           colour = "brown3", size = 0.75) 
  # geom_path(data = dat.sel_11,
  #           aes(x = long, y = lat, group = group),
  #           colour = "red", size = 0.75) 
  # geom_path(data = dat.sel_12,
  #           aes(x = long, y = lat, group = group),
  #           colour = "blue", size = 0.75) 
  # geom_path(data = dat.sel_13,
  #           aes(x = long, y = lat, group = group),
  #           colour = "green", size = 0.75) 
  # geom_path(data = dat.sel_14,
  #           aes(x = long, y = lat, group = group),
  #           colour = "red", size = 0.75) 
  # geom_path(data = dat.sel_15,
  #           aes(x = long, y = lat, group = group),
  #           colour = "blue", size = 0.75) 
  # geom_path(data = dat.sel_16,
  #           aes(x = long, y = lat, group = group),
  #           colour = "green", size = 0.75) 
  # geom_path(data = dat.sel_17,
  #           aes(x = long, y = lat, group = group),
  #           colour = "red", size = 0.75) 
  # geom_path(data = dat.sel_18,
  #           aes(x = long, y = lat, group = group),
  #           colour = "blue", size = 0.75) +
  # geom_path(data = dat.sel_19,
  #           aes(x = long, y = lat, group = group),
  #           colour = "red", size = 0.75) 
  # geom_path(data = dat.sel_20,
  #           aes(x = long, y = lat, group = group),
  #           colour = "blue", size = 0.75)  
  # geom_path(data = dat.sel_21,
  #           aes(x = long, y = lat, group = group),
  #           colour = "red", size = 0.75)
  # geom_path(data = dat.sel_22,
  #           aes(x = long, y = lat, group = group),
  #           colour = "blue", size = 0.75) 
  # geom_path(data = dat.sel_23,
  #           aes(x = long, y = lat, group = group),
  #           colour = "green", size = 0.75) 
  # geom_path(data = dat.sel_24,
  #           aes(x = long, y = lat, group = group),
  #           colour = "red", size = 0.75) 
  # geom_path(data = dat.sel_25,
  #           aes(x = long, y = lat, group = group),
  #           colour = "blue", size = 0.75) 
  # geom_path(data = dat.sel_26,
  #           aes(x = long, y = lat, group = group),
  #           colour = "green", size = 0.75) 
  # geom_path(data = dat.sel_27,
  #           aes(x = long, y = lat, group = group),
  #           colour = "red", size = 0.75) 
  # geom_path(data = dat.sel_28,
  #           aes(x = long, y = lat, group = group),
  #           colour = "blue", size = 0.75)
p.sel

#######################################################################################################################
#######################################################################################################################

# This section extracts OBIS records of using the "occurrence" function or downloaded data, 
# and plots time series or pie charts with distributions of large groups (annelids, molluscs, plants and echinoderms) in the upper 100m
# Written by E. Montes
# Aug 19, 2019

# Set extraction params
# LME codes (from OBIS URL)
# N Brazil=40017; E Brazil=40016; S Brazil=40015; Patagonia=40014; Humboldt=40013; Caribbean=40012; 
# P Ctral A=40011; CCS=40003; GoA=40002; NE USA=40007; E Bearing=40001; Canada E Arctic=40018; GoM=40005; 
# Chukchi=40054; SE USA=40006; Labrador=40009; Scotian S=40008

area = 40005  
depth = 100
mol_code = 51
echi_code = 1806
anne_code = 882
plan_code = 3

## read data
# fileID = list.files(path = "C:/Users/Enrique/obis_extractions/obis_data/obis_e_bra", pattern="*.csv")
# all_records = read_csv(file = fileID)
# 
# ## Molluscs (up to 100 m)
# mollusc.100 <- filter(all_records, maximumDepthInMeters <= 100, phylumid == 51)
# mollusc.100 <- mollusc.100[order(mollusc.100$date_start),]

# Directly from OBIS
mollusc.100_2 = occurrence(areaid = area, taxonid = mol_code, enddepth = depth) 

## Ehinoderms
# echino.100 <- filter(all_records, maximumDepthInMeters <= 100, phylumid == 1806)
# echino.100 <- echino.100[order(echino.100$date_start),]

# Directly from OBIS
echino.100_2 = occurrence(areaid = area, taxonid = echi_code, enddepth = depth)

## Annelida
# anne.100 <- filter(all_records, maximumDepthInMeters <= 100, phylumid == 882)
# anne.100 <- anne.100[order(anne.100$date_start),]

# Directly from OBIS
anne.100_2 = occurrence(areaid = area, taxonid = anne_code, enddepth = depth)

## Platae
# plant.100 <- filter(all_records, maximumDepthInMeters <= 100, phylumid == 3)
# plant.100 <- plant.100[order(plant.100$date_start),]

# Directly from OBIS
plant.100_2 = occurrence(areaid = area, taxonid = plan_code, enddepth = depth)

## Merge the data frames
#subset data (year and phylum)
sub_mollusc <- data.frame(mollusc.100_2$date_year, mollusc.100_2$phylum) 
# rename column headers
names(sub_mollusc)[names(sub_mollusc) == "mollusc.100_2.date_year"] <- "year"
names(sub_mollusc)[names(sub_mollusc) == "mollusc.100_2.phylum"] <- "phylum"

sub_echino <- data.frame(echino.100_2$date_year, echino.100_2$phylum)
names(sub_echino)[names(sub_echino) == "echino.100_2.date_year"] <- "year"
names(sub_echino)[names(sub_echino) == "echino.100_2.phylum"] <- "phylum"

sub_anne <- data.frame(anne.100_2$date_year, anne.100_2$phylum)
names(sub_anne)[names(sub_anne) == "anne.100_2.date_year"] <- "year"
names(sub_anne)[names(sub_anne) == "anne.100_2.phylum"] <- "phylum"

sub_plant <- data.frame(plant.100_2$date_year, plant.100_2$phylum)
names(sub_plant)[names(sub_plant) == "plant.100_2.date_year"] <- "year"
names(sub_plant)[names(sub_plant) == "plant.100_2.phylum"] <- "phylum"

total.100 <- bind_rows(sub_mollusc, sub_echino, sub_anne, sub_plant)

## Plot the data
ts_plot <- ggplot() +
  geom_histogram(data = total.100, aes(x = year, fill = phylum), binwidth = 2) + 
  scale_fill_brewer(palette = "Spectral") + 
  xlim(c(1960, 2017)) + 
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14,face="bold")) +
  theme(axis.text.x = element_text(size=14, angle=0), 
        axis.text.y = element_text(size=14, angle=0))
ts_plot

# ggsave(ts_plot, filename = "test.png", device = "png", width = 20, height = 10,  dpi=300)

## Plot pie chart 
# Group plants in a single group
all_tbl <- table(total.100$phylum)
all_df <- as.data.frame(all_tbl)
p_list = c("Chlorophyta", "Rhodophyta", "Tracheophyta")
rest_list = c("Annelida", "Echinodermata", "Mollusca")
p_idx = match(p_list, rownames(all_tbl))
rest_idx = match(rest_list, rownames(all_tbl))
p_sum = sum(all_df$Freq[p_idx], na.rm = TRUE)
freq_val <- c(all_df$Freq[rest_idx], p_sum)
group_id <- c(c(rest_list), "Plants")
f_tbl <- data.frame(group = group_id, freq = freq_val)
  
cols <- rainbow(nrow(f_tbl))
groups_pie <- pie(f_tbl$freq, labels = f_tbl$group, col = cols)
  
