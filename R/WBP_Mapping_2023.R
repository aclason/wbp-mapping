# mapping whitebark pine in the Itcha Ilgachuz, Wells Gray, Bowron and Cariboo Mountain Parks

#load libraries
ls <- c("tidyverse", "data.table","sf") # Data Management and Manipulation
lapply(ls, library, character.only = TRUE) 

#base path
in_path <- "data/2023 cariboo surveys"
out_path <- "processed"

#read in waypoints:
day1_pts <- st_read(file.path(in_path, "Waypoints_17-OCT-23.gpx"), layer = "waypoints")
day2_pts <- st_read(file.path(in_path, "Waypoints_20-OCT-23.gpx"), layer = "waypoints")
day3_pts <- st_read(file.path(in_path, "Waypoints_21-OCT-23.gpx"), layer = "waypoints")
day4_pts <- st_read(file.path(in_path, "Waypoints_22-OCT-23.gpx"), layer = "waypoints")

all_pts <- rbind(day1_pts,day2_pts,day3_pts,day4_pts) %>%
  dplyr::select(c("name","geometry"))
all_pts <- st_transform(all_pts, crs = 3005)


#read in waypoint data:
pt_dat <- fread(file.path(in_path, "Cariboo_Survey.csv"))
pt_dat[, Pt := as.character(Pt)]

#merge data
pt_gps <- merge(all_pts,pt_dat, by.y = "Pt", by.x = "name")
wbp_pts <- pt_gps %>%
  dplyr::filter(SPECIES == "Pa"|SPECIES == "PaPos")
st_write(wbp_pts, file.path(out_path, "Cariboo_surv_23_pts.gpkg"))


#merge with other aerial surveys
stweeds <- st_read(file.path(out_path, "Aerial_surveys_clip.gpkg"))
stweeds <- stweeds %>%
  dplyr::select(c("name")) %>%
  dplyr::rename(., geometry = geom)


all_car_pts <- rbind(wbp_pts %>% select("name"), stweeds)
st_write(all_car_pts, file.path(out_path, "22_23_aerial_wbp_pts.gpkg"))

cols_vri <- bcdata::bcdc_describe_feature(record =  "2ebb35d8-c82f-4a17-9c96-612ac3532d55")

vri_pa <- bcdc_query_geodata(record =  "2ebb35d8-c82f-4a17-9c96-612ac3532d55") %>%
  filter(SPECIES_CD_1 == "PA" | SPECIES_CD_2 == "PA"| SPECIES_CD_3 == "PA" | 
           SPECIES_CD_4 == "PA" | SPECIES_CD_5 == "PA" | SPECIES_CD_6 == "PA") %>%
  collect()
