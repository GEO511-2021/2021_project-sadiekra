#Load Spotify package and get access
library(spotifyr)

Sys.setenv(SPOTIFY_CLIENT_ID = CLIENT_ID)
Sys.setenv(SPOTIFY_CLIENT_SECRET = CLIENT_SECRET)

access_token <- get_spotify_access_token()

#load other needed packages
library(tidyverse)
library(dplyr)
library(ggplot2)
library(knitr)
library(purrr)
library (tidygeocoder)
library(leaflet)
library(kableExtra)
library(plotly)

#load touring data
touring_data <-read.csv('data/locations.csv')
view(touring_data)

#load spotify music data
#Find artist id to access artist information
tom_petty <- get_artist_audio_features("Tom Petty and the Heartbreakers")
View(tom_petty)

#Load album dataset
petty_albums <- get_artist_albums(
  id= "4tX2TplrkIP4v05BNC903e",
  include_groups = c("album", "single", "appears_on", "compilation"),
  market = NULL,
  limit = 20,
  offset = 0,
  authorization = get_spotify_access_token(),
  include_meta_info = FALSE
)
View(petty_albums)

#geocode locations and save as its own csv

touring_geo <- touring_data %>% geocode (City, method = 'osm', lat = latitude , long = longitude)%>% 
  write_csv(file="data/touring_geo.csv")
view(touring_geo)

#read in geocoded csv
touring_geo=read_csv("data/touring_geo.csv")

#Map the locations with leaflet
map_tour <- leaflet(touring_geo) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addCircleMarkers(radius = 1, popup = touring_geo$City,
                   color = "#7625be", clusterOptions = markerClusterOptions())
map_tour

#Find the top 5 most visited cities
top_5<-touring_geo%>%
  filter(City != "NA")%>%
  count(City)%>%
  arrange(desc(n))
top_5

kable(top_5, caption = "Top 5 Touring Locations") %>%
  row_spec(1:5, background = "#Cab5dc")%>%
  kable_styling(latex_options = "striped")%>%
  scroll_box(width = "600px", height="350px")

#Number of studio albums and when
album_filter <- petty_albums%>%
  filter(name!= c("Mojo Tour Edition", "Hard Promises (Reissue Remastered)", 
                  "Damn The Torpedoes (Remastered)", 
                   "Damn The Torpedoes (Deluxe Edition)"))%>%
  arrange(desc(release_date))%>%
  select(name, release_date)

kable(album_filter, caption = "Studio Albums")%>%
kable_styling(latex_options = "striped")%>%
  scroll_box(width = "600px", height="350px")
number_albums <- count(album_filter)
number_albums

#Positivity of songs
petty_valence <- tom_petty%>%
  arrange(-valence) %>% 
  select(.data$track_name, .data$valence) %>%
  distinct()%>%
  head(10)
petty_valence

valence_plot <- ggplot(petty_valence, aes(x = reorder(track_name, -valence), 
                                          valence,  text = paste(valence))) +
  geom_point(color="#7625be") +
  theme(axis.text.x = element_text(color="grey30", 
                                       size=8, angle=40),
            axis.text.y = element_text(face="bold", color="grey30", 
                                       size=10,),
        axis.title = element_text(color = "#7625be", face = "bold")) +
  ggtitle("Top 10 Positive Songs") +
  xlab("Track Name") +
  ylab("Valence")
ggplotly(valence_plot, tooltip=c("text"))

#Danceability Plot
var_width = 20

petty_filter <-tom_petty%>%
  select(album_name, danceability)%>%
  dplyr::mutate(album_wrap=str_wrap(album_name, width = var_width))


album_dance <- ggplot(petty_filter, aes(x=danceability, fill=album_wrap,
                      text = paste(album_name))) +
  geom_density(alpha=0.7, color=NA) +
  ggtitle("Danceability by Album") +
  labs(x="Danceability", y="Density") +
  guides(fill=guide_legend(title="Album Name")) +
  theme_minimal() +
    theme(legend.position="none",
          strip.text.x = element_text(size = 8)) +
    facet_wrap(~ album_wrap)
album_dance

#Top 10 hits of the career
top_ten <- get_artist_top_tracks(
  id= "4tX2TplrkIP4v05BNC903e",
  market = "US",
  authorization = get_spotify_access_token(),
  include_meta_info = FALSE
)%>%
  select(name, album.name)
colnames(top_ten) = c("Song", "Album")

kable(top_ten, caption = "Top 10 Tracks") %>%
  row_spec(c(1,3,5,7,9),background = "#Cab5dc")%>%
  kable_styling(latex_options = "striped")






