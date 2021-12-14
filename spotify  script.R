install.packages("spotifyr")

library(spotifyr)
library(knitr)
library(ggplot2)
library(dplyr)
library(kableExtra)
Sys.setenv(SPOTIFY_CLIENT_ID = '097f7729a69e451da9624441ccdb54bd')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'd1b68552cb2843929b58db9b964f87e9')

access_token <- get_spotify_access_token()

killers <- get_artist_audio_features("The Killers")
View(killers)

k_albums <- get_artist_albums(
  id= "0C0XlULifJtAgn6ZNCW2eu",
  include_groups = c("album", "single", "appears_on", "compilation"),
  market = NULL,
  limit = 20,
  offset = 0,
  authorization = get_spotify_access_token(),
  include_meta_info = FALSE
)
View(k_albums)

k_table <- k_albums%>%
  select(name, release_date, total_tracks)
kable(k_table, caption = "Albums Released by The Killers")%>%
  kable_styling(latex_options = "striped")
count(k_albums)
