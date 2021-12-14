---
title: "Visualizing the Music of Tom Petty and the Heartbreakers Using R"
subtitle: GEO 511
author: Sadie Kratt
output:
  html_document:
    keep_md: true
---

# Introduction

Tom Petty is one of the greatest rock and roll artists of the 20th century. He tragically died in 2017 right after he finished up his final tour. Because Tom Petty is my favorite artist, I have decided to honor him by creating a data visualization of his work through R packages. Music and the information that comes with it is more accessible now than it ever has been. The medium for listening has changed over time from live to recorded, record to tape, and cd to iPod. Streaming services have now taken the lead, allowing users to pay a set amount of money for access to as much or as little music as they'd like at any time. Spotify has emerged as the leading streaming service with 172 million premium users as of mid 2021. Although we have moved away from hard copies, streaming allows artist data to be available and analyzed. Tom Petty and the Heartbreakers may not tour anymore, but their music can continue to present itself through listening, and now visualization.

Questions to be addressed:
* How many studio albums did they release and when?
* What is the danceability of his songs?
* How positive are their songs?
* What are the top 10 hits of their career?
* Where has the band toured?
* What are the top 5 places they have toured?

# Materials and Methods 
Using the Spotify API, I will be accessing the spotify database to get information about the band. Because Tom Petty produced music both with the band, and as a solo artist, it's important to note that this is not a comprehensive analysis of his music. This is only a look into the music produced as a band. The artist that is being referred to within the database is "Tom Petty and the Heartbreakers." Solo work can be found using the artist name "Tom Petty." All needed artist data will be accessed through this API including the following variables and information: artist name, album name, release date, danceability, valence (positivity), and lyrics.

The Spotifyr package allows you to access and analyze variables included in the API with specific functions. I will be using this package, along with the igraph and ggraph packages to answer the questions listed in the introduction. The graph packages allow users to create graphs from data frames and visualize it in many forms. The graphs that will specifically be shown are dendrograms because they can display a hierarchy of information. The hierarchy will be helpful in showing most often used lyrics per album. I will also be using ggplot2 to show the danceability and positivity of the band's music.

The spatial component of this analysis will include mapping out the tour locations of the band over the span of their career. This will be used using a crowd sourced list of tour locations and dates found at [The Petty Archives] (https://www.thepettyarchives.com/archives/miscellany/performances/setlists). Using the leaflet package, I will be creating a map of everywhere he's been, along with a table of dates and how frequent each places was visited. Before creating the maps though, I will be geocoding the areas with the tidygeocoder package and "geocode" function.

Loading the Spotify API


```r
#Load Spotify package and get access
library(spotifyr)
Sys.setenv(SPOTIFY_CLIENT_ID = '097f7729a69e451da9624441ccdb54bd')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'd1b68552cb2843929b58db9b964f87e9')

access_token <- get_spotify_access_token()
```

### Load Required Packages


```r
library(tidyverse)
library(dplyr)
library(ggplot2)
library(knitr)
library(purrr)
library (tidygeocoder)
library(leaflet)
library(kableExtra)
library(plotly)
knitr::opts_chunk$set(cache=TRUE)  # cache the results for quick compiling
```

## Data Download and Preparation

```r
#load touring data
touring_data <-read.csv('data/locations.csv')
view(touring_data)

#load spotify music data
#Find artist id to access artist information
tom_petty <- get_artist_audio_features("Tom Petty and the Heartbreakers")

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
```


## Band Specifics
### Number of Albums Released 

```r
album_filter <- petty_albums%>%
  filter(name!= c("Mojo Tour Edition", "Hard Promises (Reissue Remastered)", 
                  "Damn The Torpedoes (Remastered)", 
                   "Damn The Torpedoes (Deluxe Edition)"))%>%
  arrange(desc(release_date))%>%
  select(name, release_date)

kable(album_filter, caption = "Studio Albums")%>%
kable_styling(latex_options = "striped")%>%
  scroll_box(width = "600px", height="350px")
```

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:350px; overflow-x: scroll; width:600px; "><table class="table" style="margin-left: auto; margin-right: auto;">
<caption>Studio Albums</caption>
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> release_date </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Angel Dream (Songs and Music From The Motion Picture "She’s The One") </td>
   <td style="text-align:left;"> 2021-06-12 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nobody's Children </td>
   <td style="text-align:left;"> 2015-12-18 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hypnotic Eye </td>
   <td style="text-align:left;"> 2014-07-29 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mojo </td>
   <td style="text-align:left;"> 2010-06-15 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mojo Tour Edition </td>
   <td style="text-align:left;"> 2010-06-15 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> The Last DJ </td>
   <td style="text-align:left;"> 2002-10-08 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Echo </td>
   <td style="text-align:left;"> 1999-04-13 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> She's the One (Songs and Music from the Motion Picture) </td>
   <td style="text-align:left;"> 1996-08-06 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Into The Great Wide Open </td>
   <td style="text-align:left;"> 1991-01-01 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Let Me Up (I've Had Enough) </td>
   <td style="text-align:left;"> 1987-04-21 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Pack Up The Plantation: Live! </td>
   <td style="text-align:left;"> 1985-11-26 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Southern Accents </td>
   <td style="text-align:left;"> 1985-03-26 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Long After Dark </td>
   <td style="text-align:left;"> 1982-11-02 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hard Promises (Reissue Remastered) </td>
   <td style="text-align:left;"> 1981-05-05 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hard Promises </td>
   <td style="text-align:left;"> 1981-05-05 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Damn The Torpedoes </td>
   <td style="text-align:left;"> 1979-10-19 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Damn The Torpedoes (Remastered) </td>
   <td style="text-align:left;"> 1979-10-19 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Damn The Torpedoes (Deluxe Edition) </td>
   <td style="text-align:left;"> 1979-10-19 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> You're Gonna Get it </td>
   <td style="text-align:left;"> 1978-05-02 </td>
  </tr>
</tbody>
</table></div>

```r
number_albums <- count(album_filter)
number_albums
```

```
##    n
## 1 19
```
The band put out a total of 19 studio albums which includes live and deluxe versions. This does not include solo albums put out by Tom Petty, though they should be considered due to band members playing on those albums and fans associating both band and solo work together.

### Danceability 

```r
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
```

![](index_files/figure-html/unnamed-chunk-6-1.png)<!-- -->

"Danceability describes how suitable a track is for dancing based on a combination of musical elements including tempo, rhythm stability, beat strength, and overall regularity. A value of 0.0 is least danceable and 1.0 is most danceable." (Plantinga, 2018). This one surprised me most because I expected "Damn The Torpedoes" to have the highest danceability. This album was a breakthrough album with many upbeat, well-known songs. But looking at this, it seems like "She's the One" and "Hypnotic Eye" have the highest throughout their albums. This reinforces the idea that there is more to songs than just being a fun or upbeat sound.

### Valence

```r
#Positivity of songs
petty_valence <- tom_petty%>%
  arrange(-valence) %>% 
  select(.data$track_name, .data$valence) %>%
  distinct()%>%
  head(10)
petty_valence
```

```
##                        track_name valence
## 1       Rockin' Around (With You)   0.970
## 2           Don't Do Me Like That   0.961
## 3   Anything That's Rock 'n' Roll   0.950
## 4                 Learning To Fly   0.949
## 5                 Change Of Heart   0.941
## 6                      Jammin' Me   0.938
## 7                The Same Old You   0.931
## 8  Don't Come Around Here No More   0.922
## 9                 Accused of Love   0.911
## 10              We Stand A Chance   0.903
```

```r
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
```

```{=html}
<div id="htmlwidget-11214ca8ab393d114612" style="width:672px;height:480px;" class="plotly html-widget"></div>
<script type="application/json" data-for="htmlwidget-11214ca8ab393d114612">{"x":{"data":[{"x":[1,2,3,4,5,6,7,8,9,10],"y":[0.97,0.961,0.95,0.949,0.941,0.938,0.931,0.922,0.911,0.903],"text":["0.97","0.961","0.95","0.949","0.941","0.938","0.931","0.922","0.911","0.903"],"type":"scatter","mode":"markers","marker":{"autocolorscale":false,"color":"rgba(118,37,190,1)","opacity":1,"size":5.66929133858268,"symbol":"circle","line":{"width":1.88976377952756,"color":"rgba(118,37,190,1)"}},"hoveron":"points","showlegend":false,"xaxis":"x","yaxis":"y","hoverinfo":"text","frame":null}],"layout":{"margin":{"t":43.7625570776256,"r":7.30593607305936,"b":182.652336951189,"l":52.1378165213782},"plot_bgcolor":"rgba(235,235,235,1)","paper_bgcolor":"rgba(255,255,255,1)","font":{"color":"rgba(0,0,0,1)","family":"","size":14.6118721461187},"title":{"text":"Top 10 Positive Songs","font":{"color":"rgba(0,0,0,1)","family":"","size":17.5342465753425},"x":0,"xref":"paper"},"xaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.4,10.6],"tickmode":"array","ticktext":["Rockin' Around (With You)","Don't Do Me Like That","Anything That's Rock 'n' Roll","Learning To Fly","Change Of Heart","Jammin' Me","The Same Old You","Don't Come Around Here No More","Accused of Love","We Stand A Chance"],"tickvals":[1,2,3,4,5,6,7,8,9,10],"categoryorder":"array","categoryarray":["Rockin' Around (With You)","Don't Do Me Like That","Anything That's Rock 'n' Roll","Learning To Fly","Change Of Heart","Jammin' Me","The Same Old You","Don't Come Around Here No More","Accused of Love","We Stand A Chance"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":10.6268161062682},"tickangle":-40,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(255,255,255,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"y","title":{"text":"<b> Track Name <\/b>","font":{"color":"rgba(118,37,190,1)","family":"","size":14.6118721461187}},"hoverformat":".2f"},"yaxis":{"domain":[0,1],"automargin":true,"type":"linear","autorange":false,"range":[0.89965,0.97335],"tickmode":"array","ticktext":["0.90","0.92","0.94","0.96"],"tickvals":[0.9,0.92,0.94,0.96],"categoryorder":"array","categoryarray":["0.90","0.92","0.94","0.96"],"nticks":null,"ticks":"outside","tickcolor":"rgba(51,51,51,1)","ticklen":3.65296803652968,"tickwidth":0.66417600664176,"showticklabels":true,"tickfont":{"color":"rgba(77,77,77,1)","family":"","size":13.2835201328352},"tickangle":-0,"showline":false,"linecolor":null,"linewidth":0,"showgrid":true,"gridcolor":"rgba(255,255,255,1)","gridwidth":0.66417600664176,"zeroline":false,"anchor":"x","title":{"text":"<b> Valence <\/b>","font":{"color":"rgba(118,37,190,1)","family":"","size":14.6118721461187}},"hoverformat":".2f"},"shapes":[{"type":"rect","fillcolor":null,"line":{"color":null,"width":0,"linetype":[]},"yref":"paper","xref":"paper","x0":0,"x1":1,"y0":0,"y1":1}],"showlegend":false,"legend":{"bgcolor":"rgba(255,255,255,1)","bordercolor":"transparent","borderwidth":1.88976377952756,"font":{"color":"rgba(0,0,0,1)","family":"","size":11.689497716895}},"hovermode":"closest","barmode":"relative"},"config":{"doubleClick":"reset","modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"source":"A","attrs":{"197864ce7e29":{"x":{},"y":{},"text":{},"type":"scatter"}},"cur_data":"197864ce7e29","visdat":{"197864ce7e29":["function (y) ","x"]},"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.2,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}</script>
```
Valence is "a measure from 0.0 to 1.0 describing the musical positiveness conveyed by a track. Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric), while tracks with low valence sound more negative (e.g. sad, depressed, angry)." (Plantinga, 2018) These results are not surprising because they all are upbeat tempos with generally happy lyrics.

### Top 10 Hits

```r
top_ten <- get_artist_top_tracks(
  id= "4tX2TplrkIP4v05BNC903e",
  market = "US",
  authorization = get_spotify_access_token(),
  include_meta_info = FALSE
)%>%
  select(name, album.name)
colnames(top_ten) = c("Song", "Album")
top_ten
```

```
##                              Song                               Album
## 1                   American Girl       Tom Petty & The Heartbreakers
## 2          Mary Jane's Last Dance                       Greatest Hits
## 3                 Learning To Fly            Into The Great Wide Open
## 4                         Refugee Damn The Torpedoes (Deluxe Edition)
## 5                       Breakdown       Tom Petty & The Heartbreakers
## 6        Christmas All Over Again          A Very Special Christmas 2
## 7           Don't Do Me Like That Damn The Torpedoes (Deluxe Edition)
## 8        Into The Great Wide Open            Into The Great Wide Open
## 9  Don't Come Around Here No More                    Southern Accents
## 10             Here Comes My Girl Damn The Torpedoes (Deluxe Edition)
```


```r
kable(top_ten, caption = "Top 10 Tracks") %>%
        row_spec(c(1,3,5,7,9),background = "#Cab5dc")%>%
        kable_styling(latex_options = "striped")
```

<table class="table" style="margin-left: auto; margin-right: auto;">
<caption>Top 10 Tracks</caption>
 <thead>
  <tr>
   <th style="text-align:left;"> Song </th>
   <th style="text-align:left;"> Album </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;background-color: #Cab5dc !important;"> American Girl </td>
   <td style="text-align:left;background-color: #Cab5dc !important;"> Tom Petty &amp; The Heartbreakers </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mary Jane's Last Dance </td>
   <td style="text-align:left;"> Greatest Hits </td>
  </tr>
  <tr>
   <td style="text-align:left;background-color: #Cab5dc !important;"> Learning To Fly </td>
   <td style="text-align:left;background-color: #Cab5dc !important;"> Into The Great Wide Open </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Refugee </td>
   <td style="text-align:left;"> Damn The Torpedoes (Deluxe Edition) </td>
  </tr>
  <tr>
   <td style="text-align:left;background-color: #Cab5dc !important;"> Breakdown </td>
   <td style="text-align:left;background-color: #Cab5dc !important;"> Tom Petty &amp; The Heartbreakers </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Christmas All Over Again </td>
   <td style="text-align:left;"> A Very Special Christmas 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;background-color: #Cab5dc !important;"> Don't Do Me Like That </td>
   <td style="text-align:left;background-color: #Cab5dc !important;"> Damn The Torpedoes (Deluxe Edition) </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Into The Great Wide Open </td>
   <td style="text-align:left;"> Into The Great Wide Open </td>
  </tr>
  <tr>
   <td style="text-align:left;background-color: #Cab5dc !important;"> Don't Come Around Here No More </td>
   <td style="text-align:left;background-color: #Cab5dc !important;"> Southern Accents </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Here Comes My Girl </td>
   <td style="text-align:left;"> Damn The Torpedoes (Deluxe Edition) </td>
  </tr>
</tbody>
</table>
The top 10 tracks to be found are what was expected. All songs except for "Christmas All Over Again" appear on the Greatest Hits album and were released as singles for their respective albums. 

## Where Did They Tour?

### Geocode locations

```r
touring_geo <- touring_data %>% geocode (City, method = 'osm', lat = latitude , long = longitude)%>% 
  write_csv(file="data/touring_geo.csv")
```


```r
touring_geo=read_csv("data/touring_geo.csv")
```

```
## Rows: 1434 Columns: 7
```

```
## -- Column specification --------------------------------------------------------
## Delimiter: ","
## chr (5): ï..Date, Venue, City, Extras, Notes
## dbl (2): latitude, longitude
```

```
## 
## i Use `spec()` to retrieve the full column specification for this data.
## i Specify the column types or set `show_col_types = FALSE` to quiet this message.
```
### Mapping Locations with Leaflet

```r
map_tour <- leaflet(touring_geo) %>%
  addProviderTiles("CartoDB.Positron") %>%
  addCircleMarkers(radius = 1, popup = touring_geo$City,
                   color = "#7625be", clusterOptions = markerClusterOptions())
```

```
## Assuming "longitude" and "latitude" are longitude and latitude, respectively
```

```
## Warning in validateCoords(lng, lat, funcName): Data contains 161 rows with
## either missing or invalid lat/lon values and will be ignored
```

```r
map_tour
```

```{=html}
<div id="htmlwidget-596c17d5aab5607450d5" style="width:672px;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-596c17d5aab5607450d5">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addProviderTiles","args":["CartoDB.Positron",null,null,{"errorTileUrl":"","noWrap":false,"detectRetina":false}]},{"method":"addCircleMarkers","args":[[32.4610708,42.3602534,40.7587979,40.7587979,34.0923014,34.0923014,34.0923014,34.0923014,37.4443293,37.4443293,37.8753497,37.8753497,37.8753497,41.8755616,41.5051613,42.4894801,40.7587979,40.7587979,40.7587979,41.5051613,39.1014537,41.083064,40.7495506,37.8590272,37.7790262,34.0923014,34.0923014,51.4816546,54.0484068,51.5073219,52.4796992,50.8214626,51.5073219,51.5073219,51.5073219,51.4538022,53.4794892,53.3806626,53.7974185,53.0162014,53.4071991,54.9738474,55.9533456,55.8609825,50.9673322,null,50.8465573,48.8588897,50.1106444,52.3727598,55.7029296,53.4794892,50.938361,null,52.4796992,51.4816546,51.8161412,51.5073219,52.5847651,50.6402809,50.7255794,53.7435722,45.5202471,37.7790262,37.7790262,34.0923014,34.0923014,45.5202471,37.7790262,36.7295295,37.050096,34.0194704,34.0194704,33.4484367,46.601557,34.0194704,41.5051613,41.7244885,40.7587979,40.7587979,40.4416941,39.9527237,40.7998227,42.6511674,41.8755616,37.050096,34.1816482,32.7174202,38.545379,33.9459413,37.050096,37.4443293,34.0194704,39.7284945,37.7790262,38.4404925,44.0505054,45.5202471,49.2608724,51.5073219,51.8400523,51.5073219,30.3321838,27.9477595,25.7741728,42.3315509,41.5051613,40.7587979,null,40.2203907,42.3602534,null,38.9074322,39.9527237,null,40.6399646,null,29.9499323,33.7489924,33.7489924,32.7762719,29.7589382,30.2711286,38.6529545,39.100105,38.2542376,39.7683331,41.8755616,44.9772995,null,40.5863563,37.7790262,34.0194704,null,36.6744117,null,37.050096,null,38.5810606,null,34.1419417,34.1419417,null,40.7587979,40.7587979,null,40.7587979,null,null,null,39.9527237,42.3315509,41.5051613,null,43.6534817,null,41.8755616,44.9497487,36.1622767,33.7489924,30.2711286,29.7589382,47.6038321,49.2608724,37.8044557,32.7762719,35.4729886,36.1556805,39.100105,38.6529545,41.2587459,32.7174202,33.9562003,null,34.0923014,33.4484367,32.3090726,34.4221319,52.4796992,53.4794892,51.5073219,51.5073219,48.8588897,51.7520131,34.6198813,35.1851045,35.6828387,35.6828387,35.6828387,-33.8548157,-33.8548157,-27.4689682,-37.8142176,-37.8142176,-34.9281805,-43.530955,-41.2887953,21.304547,34.0980031,39.7392364,41.0799898,42.5512648,42.0427256,41.1348213,39.1938429,43.0821793,40.8567663,44.310545,41.8239891,40.7587979,40.7587979,40.7587979,39.9527237,39.9527237,40.4416941,37.5385087,null,27.7703796,null,26.0031465,28.5421109,39.7683331,41.6529143,41.2397772,41.8755616,42.3315509,null,39.7392364,34.0980031,36.1672559,39.5261206,37.6904826,34.0536909,34.0536909,34.0536909,49.2608724,47.6038321,47.6038321,45.5202471,40.7587979,45.202075,45.4211435,45.5031824,43.6534817,41.3082138,43.0821793,39.9527237,43.157285,40.82046,39.1938429,36.8968052,40.6178915,40.4416941,null,40.7159385,42.3602534,41.8239891,42.8867166,39.7683331,38.6529545,44.9772995,null,41.2587459,42.7851871,null,null,39.100105,38.5810606,32.3090726,33.4255056,33.6856969,null,33.6856969,29.7589382,32.7762719,30.2711286,35.2225717,30.4459596,33.7489924,32.0809263,28.0394654,null,30.3321838,27.7703796,null,29.6519684,null,33.4255056,34.2000784,34.1476452,null,37.050096,37.050096,34.2163964,null,34.0923014,50.8465573,48.8388009,52.0809856,51.5073219,53.4794892,55.9533456,52.4081812,50.8214626,48.1371079,49.4892913,53.550341,51.5142273,52.5170365,50.1055002,49.453872,59.3251172,33.4484367,32.3090726,31.7754152,null,30.2711286,29.7589382,32.7762719,32.5221828,35.1490215,33.7489924,35.2272086,26.715364,27.7703796,29.6519684,36.1622767,38.2542376,40.6105983,null,40.4416941,40.7587979,null,37.2166779,38.6529545,40.0149856,37.7274692,39.100105,40.5325211,44.8322405,41.9758872,null,43.0349931,null,41.8755616,39.7683331,42.3315509,41.2397772,42.8867166,42.0987125,42.2625621,41.8239891,41.3082138,40.4416941,null,40.7159385,40.82046,null,39.9527237,47.6038321,37.6904826,37.7790262,36.7295295,34.1419417,34.1419417,32.7174202,34.1419417,35.3738712,38.0695732,null,38.0695732,null,39.7392364,33.6856969,null,40.7587979,38.6529545,39.9622601,39.1938429,null,39.9527237,40.82046,43.0821793,41.1348213,39.7683331,42.5512648,42.0427256,42.7851871,44.9497487,39.100105,41.2587459,36.1556805,35.2225717,30.2711286,32.7762719,29.4246002,29.7589382,36.1622767,33.7489924,27.9477595,null,39.9527237,null,40.6626375,39.5261206,38.5810606,47.6038321,37.8753497,37.9768525,null,33.4484367,34.0536909,null,34.1419417,33.6636611,34.0536909,34.0536909,null,null,34.1419417,null,32.3090726,40.1164841,null,null,-36.852095,-33.8548157,-33.8548157,-33.8548157,-33.8548157,-34.9281805,-31.9527121,-31.9527121,-37.8142176,-37.8142176,-37.8142176,-33.8548157,-33.8548157,-27.4689682,-27.4689682,35.6828387,34.6198813,35.1851045,35.6828387,34.0536909,null,32.7174202,null,null,39.5261206,38.5810606,37.8753497,37.8753497,33.6636611,33.6636611,33.4484367,29.7589382,30.2711286,32.7762719,39.7683331,44.9772995,42.7851871,42.0427256,42.5512648,42.5512648,41.083064,null,42.8867166,38.9074322,38.9074322,42.0334326,42.0334326,41.764582,43.0821793,40.7587979,40.7587979,40.7587979,null,39.9527237,null,42.0334326,39.059726,39.6422,39.6422,45.5202471,47.2495798,49.2608724,34.0536909,37.3893889,35.6267654,null,37.3893889,null,32.3090726,33.4255056,null,null,30.2711286,29.7589382,32.7762719,37.9768525,37.3893889,33.6636611,34.1419417,34.1419417,34.1419417,34.1419417,41.2587459,44.8322405,42.5512648,42.7851871,42.0427256,40.4416941,null,null,41.1348213,null,null,null,40.0455918,43.0821793,42.0334326,43.8595029,40.7587979,40.6626375,40.3451095,42.9956397,43.0481221,39.9527237,41.3082138,42.9011709,39.1938429,33.7489924,30.3321838,26.715364,27.9477595,null,32.0852997,31.7788242,47.5581077,41.630282,45.0677551,51.5130679,49.453872,52.4801425,51.9244424,53.80019565,55.6867243,60.1674881,null,59.3251172,50.1050925,48.7246279,48.1147179,45.4384958,41.8933203,45.4641943,46.1695112,48.8588897,50.8465573,52.4796992,52.4796992,52.4796992,51.5073219,51.5073219,51.5073219,51.5073219,null,37.8044557,null,40.7587979,null,25.7741728,27.7703796,28.5421109,43.0349931,null,29.7589382,30.2711286,32.7762719,38.8339578,47.6038321,37.3893889,38.5810606,32.7174202,33.4255056,33.6636611,34.1419417,34.1419417,34.1419417,33.7489924,42.5512648,41.1348213,42.0427256,null,39.1014537,null,40.6626375,40.8397222,40.82046,40.3451095,39.1938429,40.4416941,null,null,null,43.0481221,43.0821793,null,40.6022059,41.6735209,43.8595029,34.1419417,null,null,43.157285,39.9622601,35.9131542,null,37.3893889,null,34.1419417,null,27.9477595,29.6519684,null,null,35.2272086,40.7159385,41.8239891,42.6511674,38.8462236,39.9527237,null,null,null,null,40.7159385,41.764582,39.7589478,42.6875323,41.2397772,41.9941334,40.5092866,41.6612561,42.0267567,44.8322405,39.7683331,37.7274692,38.6529545,39.100105,34.0536909,33.6636611,38.5810606,37.8044557,39.7392364,39.100105,38.7150511,41.2587459,44.8322405,42.0427256,43.0349931,null,42.6875323,41.1348213,40.3820133,39.9527237,43.0481221,41.764582,42.6511674,43.6534817,38.92531295,37.2708788,40.7159385,40.82046,42.0987125,40.7587979,null,35.7803977,35.2272086,33.7489924,38.88974405,25.7741728,27.9477595,28.5421109,29.6519684,29.9499323,30.1734194,30.2711286,32.7762719,35.4729886,null,33.4484367,33.6636611,33.9562003,32.7174202,47.6038321,45.5202471,39.5261206,37.8044557,38.5810606,59.9133301,null,59.3251172,53.550341,52.5170365,51.4582235,55.8609825,54.596391,53.3497645,53.3497645,52.4796992,51.5073219,51.5073219,50.1106444,48.1371079,47.5581077,48.8588897,50.8465573,55.6052931,40.7587979,null,34.0923014,27.7703796,29.6519684,null,37.3893889,null,37.3893889,null,40.7587979,null,null,38.2542376,39.7683331,39.9885487,43.0349931,40.6938609,41.8755616,42.6875323,39.9622601,39.1014537,40.4416941,41.5051613,43.6534817,40.7587979,42.6511674,43.157285,41.3082138,40.7159385,null,null,39.9527237,38.8462236,37.5385087,35.7803977,35.2272086,33.7489924,30.1734194,30.2711286,30.2711286,32.7762719,33.4484367,32.7174202,34.2163964,37.3893889,38.5810606,45.5202471,null,47.0807166,49.2608724,25.7741728,25.7741728,27.9477595,28.5421109,30.421309,33.285669,35.756467,35.1490215,35.1490215,35.1490215,38.7150511,39.059726,35.4729886,35.4729886,34.0536909,34.0536909,39.5261206,37.3893889,40.7596198,39.6482059,42.0334326,43.0821793,40.6626375,41.764582,40.3451095,39.9448402,39.1938429,null,41.1348213,39.9622601,39.1014537,42.5512648,42.5512648,44.9772995,42.0267567,41.5067003,41.5733669,null,41.0799898,40.0455918,37.9747645,38.0464066,35.9603948,35.7803977,32.9131295,33.7489924,34.729847,34.2576067,32.2990021,33.2095614,29.9552815,40.7587979,null,null,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,37.7790262,40.7587979,null,40.7587979,40.7587979,40.7587979,51.5073219,51.5073219,53.550341,42.9632405,41.5051613,42.5512648,42.5512648,42.9011709,40.3820133,38.7233263,39.9448402,41.764582,40.3451095,40.6626375,40.6626375,40.2854881,43.6534817,null,null,40.884267,38.2542376,40.0455918,38.7150511,39.1014537,39.9622601,43.0349931,41.5733669,44.9772995,39.059726,35.756467,35.1490215,33.6856969,33.6856969,32.6400541,33.4484367,36.1672559,35.3738712,39.5261206,37.3893889,37.3893889,38.5810606,45.5202471,49.2608724,47.0807166,47.0807166,32.7762719,30.2711286,null,27.9477595,26.715364,33.7489924,35.2272086,34.851354,35.7803977,39.9527237,36.8529841,39.1938429,39.1670396,41.8755616,42.6875323,41.5067003,43.074761,36.1672559,34.0980031,44.5645659,43.6166163,47.0807166,39.6422,39.6422,30.1734194,29.4246002,32.7762719,34.4221319,38.5810606,37.9768525,32.7174202,36.1672559,36.1672559,41.4086874,39.9448402,38.7233263,40.3451095,43.0349931,40.6626375,43.0821793,null,40.4416941,42.5512648,33.7489924,36.1622767,39.9622601,39.100105,41.8755616,40.0455918,42.9632405,null,43.0349931,null,42.93194285,null,40.3451095,41.4345426,42.9956397,null,41.4086874,40.2854881,40.3820133,38.7233263,35.7803977,35.2272086,27.9477595,26.715364,33.7489924,33.285669,39.1014537,40.0455918,39.059726,38.7150511,39.6422,39.6422,35.21287095,34.2163964,32.6400541,43.5737361,39.5261206,null,37.9768525,34.0536909,34.0536909,34.4221319,32.7174202,37.3893889,36.1672559,33.4484367,40.696629,47.6571934,47.2495798,45.5202471,29.7589382,32.7762719,30.2711286,33.9562003,51.5073219,null,39.9527237,39.9622601,38.0464066,42.6875323,44.9497487,41.8755616,40.7587979,null,41.8755616,41.8755616,41.8755616,41.8755616,41.8755616,41.8755616,43.5460587,43.0349931,null,41.9758872,41.2621283,44.0869329,45.6794293,46.808327,46.7729322,44.1634663,40.6938609,40.3451095,40.3451095,36.8444196,33.7489924,32.7876012,36.1622767,35.1490215,35.1490215,29.2108147,26.640628,33.5206824,29.9499323,43.684017,39.1911128,null,33.4669721,null,26.4381474,26.715364,27.9477595,33.7489924,39.1014537,40.4416941,39.9527237,null,40.6626375,40.3451095,41.764582,42.93194285,42.9632405,41.1348213,43.0349931,null,38.7150511,39.100105,35.756467,41.5733669,null,41.5910323,42.3315509,39.7683331,41.4086874,39.3642852,39.1938429,null,43.0821793,35.6267654,33.4484367,33.6856969,36.1672559,39.6422,33.4484367,32.7174202,34.2163964,39.5261206,38.5810606,37.8753497,37.8753497,39.6422,39.6422,47.0807166,47.0807166,35.2272086,38.7233263,36.8444196,39.9622601,35.4817432,38.6529545,40.7587979,null,39.7683331,44.9497487,44.9497487,43.0349931,null,43.0349931,null,39.7392364,39.7392364,45.5202471,47.6038321,32.7762719,30.1734194,42.3315509,44.409707,41.764582,43.0821793,42.93194285,40.3820133,39.9448402,40.7975383,43.6534817,35.7803977,43.074761,41.8755616,41.8755616,30.2711286,29.6519684,33.7489924,34.0536909,32.7174202,37.8753497,37.8753497,33.4484367,38.5810606,33.7217965,36.1672559,null,null,40.9633868,null,34.035591,null,37.050096,37.7790262,37.7790262,34.4221319,34.4458248,38.5893934,34.0923014,34.0923014,34.0923014,34.0923014,34.0923014,34.0923014,34.035591,37.050096,37.7790262,37.7790262,34.4221319,34.4458248,38.5893934,34.0923014,34.0923014,34.0923014,34.0923014,34.0923014,34.0923014,42.9632405,42.6875323,43.6534817,39.9527237,39.9527237,38.7233263,40.3820133,41.7701847,42.3529327,42.0334326,40.735657,42.9011709,41.1348213,34.0536909,41.8755616,40.0455918,43.0349931,null,39.1014537,33.7489924,35.2272086,35.7803977,26.1666888,27.9477595,39.7392364,41.2587459,44.9772995,50.3203804,38.7150511,49.8955367,51.0460954,53.535411,47.0807166,47.0807166,33.5386858,33.6856969,37.7790262,29.5848923,32.7762719,30.1734194,38.2542376,39.100105,52.131802,27.9477595,39.7392364,39.7392364,37.8044557,49.2608724,47.6038321,47.6038321,51.0460954,53.535411,52.131802,49.8955367,44.9497487,41.2587459,43.0349931,null,43.0349931,null,39.7683331,39.100105,null,null,38.6529545,42.3315509,40.4416941,40.7587979,39.9527237,39.9527237,33.7489924,36.1622767,42.93194285,38.8950368,41.764582,42.3602534,42.3602534,40.82046,43.6534817,43.0821793,42.93194285,41.1348213,27.9477595,35.7803977,null,32.7762719,36.1556805,30.1734194,null,33.6856969,32.7174202,33.4484367,null,34.2345615,34.2345615,39.9203827,34.769536,null,35.21287095,37.6922361,null,29.9499323,null,34.0709576,26.4381474,null,null,null,28.5421109,null,30.2711286,44.648618,null,null,47.561701,null,47.561701,53.3497645,null,51.897077,53.550341,55.8611696,59.3251172,59.9133301,51.5073219,null,null,51.5073219,50.6913105,52.3727598,50.938361,48.8588897,44.0177639,49.4892913,37.9747645,30.2711224,40.7587979,40.7587979,40.7587979,40.7587979,40.7587979,34.0980031,34.0980031,34.0980031,34.0980031,34.0980031,34.0980031,40.0455918,35.4817432,42.9836747,40.4416941,39.158168,43.0821793,43.0349931,null,44.9772995,32.7174202,43.6166163,44.0505054,37.7790262,45.5202471,49.2608724,47.0807166,53.535411,51.0460954,49.8955367,41.8755616,42.5512648,43.6534817,45.5031824,42.3602534,43.6610277,37.6840306,42.93194285,40.7587979,40.3451095,41.764582,39.9527237,40.6022059,35.7803977,26.715364,27.9477595,36.1622767,29.7589382,32.7762719,36.1556805,39.6422,39.6422,39.6422,37.3361905,33.8347516,34.0536909,34.0536909,34.2345615,null,34.2345615,null,39.7392364,41.8755616,40.9161637,null,33.7489924,39.1014537,38.9074322,39.9527237,40.7587979,40.7587979,41.0017643,37.7790262,37.7790262,37.8044557,34.0536909,34.0536909,33.7494951,32.7174202,35.4729886,32.7762719,34.7464809,36.1622767,33.7489924,30.1734194,29.9552815,30.2711286,26.715364,27.9477595,35.1490215,40.1164841,38.6529545,40.0455918,38.2971367,39.6422,39.6422,39.100105,44.9497487,41.5910323,39.9622601,40.4416941,41.5051613,39.1014537,41.764582,40.735657,42.1778662,34.1476452,41.8755616,39.9527237,42.8858579,43.0349931,null,43.0349931,null,51.5073219,43.6534817,45.4211435,42.5512648,42.3602534,42.3602534,39.2908816,40.7195942,40.7195942,39.9527237,49.2608724,47.6038321,37.8753497,37.8753497,37.8753497,38.5810606,32.9594891,null,34.0536909,34.0536909,34.0536909],[-84.9880449,-71.0582912,-73.9623427,-73.9623427,-118.3692894,-118.3692894,-118.3692894,-118.3692894,-122.1598465,-122.1598465,-122.239633649188,-122.239633649188,-122.239633649188,-87.6244212,-81.6934446,-83.1446485,-73.9623427,-73.9623427,-73.9623427,-81.6934446,-84.5124602,-81.518485,-73.9517639894174,-122.485469,-122.419906,-118.3692894,-118.3692894,-3.1791934,-2.7990345,-0.1276474,-1.9026911,-0.1400561,-0.1276474,-0.1276474,-0.1276474,-2.5972985,-2.2451148,-1.4702278,-1.5437941,-2.1812607,-2.99168,-1.6131572,-3.1883749,-4.2488787,5.8277007,null,4.351697,2.32004102172008,8.6820917,4.8936041,13.1929449,-2.2451148,6.959974,null,-1.9026911,-3.1791934,-0.8130383,-0.1276474,-2.127567,4.6667145,-3.5269497,-0.3394758,-122.6741949,-122.419906,-122.419906,-118.3692894,-118.3692894,-122.6741949,-122.419906,-119.708861260756,-121.9905908,-118.4912273,-118.4912273,-112.0741417,-120.510842,-118.4912273,-81.6934446,-81.245657,-73.9623427,-73.9623427,-79.9900861,-75.1635262,-73.6509621,-73.754968,-87.6244212,-121.9905908,-118.3258554,-117.1627728,-121.744583,-117.410244424392,-121.9905908,-122.1598465,-118.4912273,-121.8374777,-122.419906,-122.7141049,-123.0950506,-122.6741949,-123.113952,-0.1276474,-0.0978551922452396,-0.1276474,-81.655651,-82.458444,-80.19362,-83.0466403,-81.6934446,-73.9623427,null,-74.0120817,-71.0582912,null,-77.0350922,-75.1635262,null,-73.6138556014226,null,-90.0701156,-84.3902644,-84.3902644,-96.7968559,-95.3676974,-97.7436995,-90.2411165602464,-94.5781416,-85.759407,-86.1583502,-87.6244212,-93.2654692,null,-122.391675,-122.419906,-118.4912273,null,-121.6550372,null,-121.9905908,null,-121.493895,null,-118.3584459,-118.3584459,null,-73.9623427,-73.9623427,null,-73.9623427,null,null,null,-75.1635262,-83.0466403,-81.6934446,null,-79.3839347,null,-87.6244212,-93.0931028,-86.7742984,-84.3902644,-97.7436995,-95.3676974,-122.3300624,-123.113952,-122.2713563,-96.7968559,-97.5170536,-95.9929113,-94.5781416,-90.2411165602464,-95.9383758,-117.1627728,-118.353132,null,-118.3692894,-112.0741417,-111.0827253,-119.7026673,-1.9026911,-2.2451148,-0.1276474,-0.1276474,2.32004102172008,-1.2578499,135.490357,136.8998438,139.7594549,139.7594549,139.7594549,151.2164539,151.2164539,153.0234991,144.9631608,144.9631608,138.5999312,172.6366455,174.7772114,-157.855676,-118.329523,-104.9848623,-85.1386015,-82.9586042,-88.0792782,-81.4848086,-76.8646091935336,-73.7853915,-74.1284764,-69.7792759,-71.4128343,-73.9623427,-73.9623427,-73.9623427,-75.1635262,-75.1635262,-79.9900861,-77.43428,null,-82.6695085,null,-80.223937,-81.3790304,-86.1583502,-83.5378173,-81.6381785,-87.6244212,-83.0466403,null,-104.9848623,-118.329523,-115.148516,-119.8126581,-122.47267,-118.242766,-118.242766,-118.242766,-123.113952,-122.3300624,-122.3300624,-122.6741949,-73.9623427,-84.9676387,-75.6900574,-73.5698065,-79.3839347,-72.9250518,-73.7853915,-75.1635262,-77.615214,-74.0830762172337,-76.8646091935336,-76.2602336,-75.3786521,-79.9900861,null,-73.5938478254278,-71.0582912,-71.4128343,-78.8783922,-86.1583502,-90.2411165602464,-93.2654692,null,-95.9383758,-88.4054374,null,null,-94.5781416,-121.493895,-111.0827253,-111.9400091,-117.8259819,null,-117.8259819,-95.3676974,-96.7968559,-97.7436995,-97.4394816,-91.18738,-84.3902644,-81.0911768,-81.9498042,null,-81.655651,-82.6695085,null,-82.3249846,null,-111.9400091,-118.5369884,-118.1444779,null,-121.9905908,-121.9905908,-117.4014365,null,-118.3692894,4.351697,2.4917292,5.12768396945229,-0.1276474,-2.2451148,-3.1883749,-1.510477,-0.1400561,11.5753822,8.4673098,10.000654,7.4652789,13.3888599,8.7610698,11.077298,18.0710935,-112.0741417,-111.0827253,-106.464634,null,-97.7436995,-95.3676974,-96.7968559,-93.7651944,-90.0516285,-84.3902644,-80.8430827,-80.0532942,-82.6695085,-82.3249846,-86.7742984,-85.759407,-75.3812491847628,null,-79.9900861,-73.9623427,null,-93.2920373,-90.2411165602464,-105.270545,-89.216655,-94.5781416,-92.8007536,-93.3204872,-91.6704053,null,-87.922497,null,-87.6244212,-86.1583502,-83.0466403,-81.6381785,-78.8783922,-75.9125262,-71.8018877,-71.4128343,-72.9250518,-79.9900861,null,-73.5938478254278,-74.0830762172337,null,-75.1635262,-122.3300624,-122.47267,-122.419906,-119.708861260756,-118.3584459,-118.3584459,-117.1627728,-118.3584459,-119.0194639,-120.5405039,null,-120.5405039,null,-104.9848623,-117.8259819,null,-73.9623427,-90.2411165602464,-83.0007065,-76.8646091935336,null,-75.1635262,-74.0830762172337,-73.7853915,-81.4848086,-86.1583502,-82.9586042,-88.0792782,-88.4054374,-93.0931028,-94.5781416,-95.9383758,-95.9929113,-97.4394816,-97.7436995,-96.7968559,-98.4951405,-95.3676974,-86.7742984,-84.3902644,-82.458444,null,-75.1635262,null,-73.5134383254398,-119.8126581,-121.493895,-122.3300624,-122.239633649188,-122.0335624,null,-112.0741417,-118.242766,null,-118.3584459,-117.919465184352,-118.242766,-118.242766,null,null,-118.3584459,null,-111.0827253,-88.2430932,null,null,174.7631803,151.2164539,151.2164539,151.2164539,151.2164539,138.5999312,115.8604796,115.8604796,144.9631608,144.9631608,144.9631608,151.2164539,151.2164539,153.0234991,153.0234991,139.7594549,135.490357,136.8998438,139.7594549,-118.242766,null,-117.1627728,null,null,-119.8126581,-121.493895,-122.239633649188,-122.239633649188,-117.919465184352,-117.919465184352,-112.0741417,-95.3676974,-97.7436995,-96.7968559,-86.1583502,-93.2654692,-88.4054374,-88.0792782,-82.9586042,-82.9586042,-81.518485,null,-78.8783922,-77.0350922,-77.0350922,-71.2189405,-71.2189405,-72.6908547,-73.7853915,-73.9623427,-73.9623427,-73.9623427,null,-75.1635262,null,-71.2189405,-94.8835754,-105.193323245069,-105.193323245069,-122.6741949,-122.4398746,-123.113952,-118.242766,-122.0832101,-120.6912456,null,-122.0832101,null,-111.0827253,-111.9400091,null,null,-97.7436995,-95.3676974,-96.7968559,-122.0335624,-122.0832101,-117.919465184352,-118.3584459,-118.3584459,-118.3584459,-118.3584459,-95.9383758,-93.3204872,-82.9586042,-88.4054374,-88.0792782,-79.9900861,null,null,-81.4848086,null,null,null,-86.0085955,-73.7853915,-71.2189405,-79.5068522,-73.9623427,-73.5134383254398,-74.1840322,-71.4547891,-76.1474244,-75.1635262,-72.9250518,-78.3886312,-76.8646091935336,-84.3902644,-81.655651,-80.0532942,-82.458444,null,34.7818064,35.2257626,7.5878261,15.91543,7.6824892,7.4689417,11.077298,13.3952556,4.47775,-1.76172708347738,12.5700724,24.9427473,null,18.0710935,8.5859703,9.1173268,11.5986183,10.9924122,12.4829321,9.1896346,8.7954217,2.32004102172008,4.351697,-1.9026911,-1.9026911,-1.9026911,-0.1276474,-0.1276474,-0.1276474,-0.1276474,null,-122.2713563,null,-73.9623427,null,-80.19362,-82.6695085,-81.3790304,-87.922497,null,-95.3676974,-97.7436995,-96.7968559,-104.8253485,-122.3300624,-122.0832101,-121.493895,-117.1627728,-111.9400091,-117.919465184352,-118.3584459,-118.3584459,-118.3584459,-84.3902644,-82.9586042,-81.4848086,-88.0792782,null,-84.5124602,null,-73.5134383254398,-73.8316667,-74.0830762172337,-74.1840322,-76.8646091935336,-79.9900861,null,null,null,-76.1474244,-73.7853915,null,-75.4712794,-72.9464859,-79.5068522,-118.3584459,null,null,-77.615214,-83.0007065,-79.05578,null,-122.0832101,null,-118.3584459,null,-82.458444,-82.3249846,null,null,-80.8430827,-73.5938478254278,-71.4128343,-73.754968,-77.3063733,-75.1635262,null,null,null,null,-73.5938478254278,-72.6908547,-84.1916069,-83.2341028,-81.6381785,-87.8756737,-88.9843795,-91.5299106,-93.6170448,-93.3204872,-86.1583502,-89.216655,-90.2411165602464,-94.5781416,-118.242766,-117.919465184352,-121.493895,-122.2713563,-104.9848623,-94.5781416,-90.435999,-95.9383758,-93.3204872,-88.0792782,-87.922497,null,-83.2341028,-81.4848086,-80.3928423,-75.1635262,-76.1474244,-72.6908547,-73.754968,-79.3839347,-76.8815433044285,-76.7074042,-73.5938478254278,-74.0830762172337,-75.9125262,-73.9623427,null,-78.6390989,-80.8430827,-84.3902644,-77.0408607551248,-80.19362,-82.458444,-81.3790304,-82.3249846,-90.0701156,-95.504686,-97.7436995,-96.7968559,-97.5170536,null,-112.0741417,-117.919465184352,-118.353132,-117.1627728,-122.3300624,-122.6741949,-119.8126581,-122.2713563,-121.493895,10.7389701,null,18.0710935,10.000654,13.3888599,7.0158171,-4.2488787,-5.9301829,-6.2602732,-6.2602732,-1.9026911,-0.1276474,-0.1276474,8.6820917,11.5753822,7.5878261,2.32004102172008,4.351697,13.0001566,-73.9623427,null,-118.3692894,-82.6695085,-82.3249846,null,-122.0832101,null,-122.0832101,null,-73.9623427,null,null,-85.759407,-86.1583502,-86.1224563,-87.922497,-89.5891008,-87.6244212,-83.2341028,-83.0007065,-84.5124602,-79.9900861,-81.6934446,-79.3839347,-73.9623427,-73.754968,-77.615214,-72.9250518,-73.5938478254278,null,null,-75.1635262,-77.3063733,-77.43428,-78.6390989,-80.8430827,-84.3902644,-95.504686,-97.7436995,-97.7436995,-96.7968559,-112.0741417,-117.1627728,-117.4014365,-122.0832101,-121.493895,-122.6741949,null,-119.8570901,-123.113952,-80.19362,-80.19362,-82.458444,-81.3790304,-87.2169149,-86.8099884,-84.2179718,-90.0516285,-90.0516285,-90.0516285,-90.435999,-94.8835754,-97.5170536,-97.5170536,-118.242766,-118.242766,-119.8126581,-122.0832101,-111.8867975,-104.9879641,-71.2189405,-73.7853915,-73.5134383254398,-72.6908547,-74.1840322,-75.1198911,-76.8646091935336,null,-81.4848086,-83.0007065,-84.5124602,-82.9586042,-82.9586042,-93.2654692,-93.6170448,-90.5151342,-87.7844944,null,-85.1386015,-86.0085955,-87.5558483,-84.4970393,-83.9210261,-78.6390989,-80.0629981965219,-84.3902644,-86.5859011,-88.7033859,-90.1847691,-87.5675258,-90.0654808,-73.9623427,null,null,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-122.419906,-73.9623427,null,-73.9623427,-73.9623427,-73.9623427,-0.1276474,-0.1276474,10.000654,-85.6678639,-81.6934446,-82.9586042,-82.9586042,-78.3886312,-80.3928423,-77.5365669,-75.1198911,-72.6908547,-74.1840322,-73.5134383254398,-73.5134383254398,-76.6506001,-79.3839347,null,null,-72.3895296,-85.759407,-86.0085955,-90.435999,-84.5124602,-83.0007065,-87.922497,-87.7844944,-93.2654692,-94.8835754,-84.2179718,-90.0516285,-117.8259819,-117.8259819,-117.0841955,-112.0741417,-115.148516,-119.0194639,-119.8126581,-122.0832101,-122.0832101,-121.493895,-122.6741949,-123.113952,-119.8570901,-119.8570901,-96.7968559,-97.7436995,null,-82.458444,-80.0532942,-84.3902644,-80.8430827,-82.3984882,-78.6390989,-75.1635262,-75.9774183,-76.8646091935336,-86.5342881,-87.6244212,-83.2341028,-90.5151342,-89.3837613,-115.148516,-118.329523,-123.2620435,-116.200886,-119.8570901,-105.193323245069,-105.193323245069,-95.504686,-98.4951405,-96.7968559,-119.7026673,-121.493895,-122.0335624,-117.1627728,-115.148516,-115.148516,-75.6621294,-75.1198911,-77.5365669,-74.1840322,-87.922497,-73.5134383254398,-73.7853915,null,-79.9900861,-82.9586042,-84.3902644,-86.7742984,-83.0007065,-94.5781416,-87.6244212,-86.0085955,-85.6678639,null,-87.922497,null,-78.3879396085486,null,-74.1840322,-72.1097996,-71.4547891,null,-75.6621294,-76.6506001,-80.3928423,-77.5365669,-78.6390989,-80.8430827,-82.458444,-80.0532942,-84.3902644,-86.8099884,-84.5124602,-86.0085955,-94.8835754,-90.435999,-105.193323245069,-105.193323245069,-106.713248495746,-117.4014365,-117.0841955,-116.559631,-119.8126581,null,-122.0335624,-118.242766,-118.242766,-119.7026673,-117.1627728,-122.0832101,-115.148516,-112.0741417,-111.9867271,-117.4235106,-122.4398746,-122.6741949,-95.3676974,-96.7968559,-97.7436995,-118.353132,-0.1276474,null,-75.1635262,-83.0007065,-84.4970393,-83.2341028,-93.0931028,-87.6244212,-73.9623427,null,-87.6244212,-87.6244212,-87.6244212,-87.6244212,-87.6244212,-87.6244212,-96.7313928,-87.922497,null,-91.6704053,-95.8613912,-103.2274481,-111.044047,-100.783739,-92.1251218,-93.9993505,-89.5891008,-74.1840322,-74.1840322,-76.3532998,-84.3902644,-79.9402728,-86.7742984,-90.0516285,-90.0516285,-81.0228331,-81.8723084,-86.8024326,-90.0701156,-110.443662926312,-106.8235606,null,-117.6981075,null,-81.8067537,-80.0532942,-82.458444,-84.3902644,-84.5124602,-79.9900861,-75.1635262,null,-73.5134383254398,-74.1840322,-72.6908547,-78.3879396085486,-85.6678639,-81.4848086,-87.922497,null,-90.435999,-94.5781416,-84.2179718,-87.7844944,null,-93.6046655,-83.0466403,-86.1583502,-75.6621294,-74.4229351,-76.8646091935336,null,-73.7853915,-120.6912456,-112.0741417,-117.8259819,-115.148516,-105.193323245069,-112.0741417,-117.1627728,-117.4014365,-119.8126581,-121.493895,-122.239633649188,-122.239633649188,-105.193323245069,-105.193323245069,-119.8570901,-119.8570901,-80.8430827,-77.5365669,-76.3532998,-83.0007065,-86.0885993,-90.2411165602464,-73.9623427,null,-86.1583502,-93.0931028,-93.0931028,-87.922497,null,-87.922497,null,-104.9848623,-104.9848623,-122.6741949,-122.3300624,-96.7968559,-95.504686,-83.0466403,-103.509079,-72.6908547,-73.7853915,-78.3879396085486,-80.3928423,-75.1198911,-73.9166611,-79.3839347,-78.6390989,-89.3837613,-87.6244212,-87.6244212,-97.7436995,-82.3249846,-84.3902644,-118.242766,-117.1627728,-122.239633649188,-122.239633649188,-112.0741417,-121.493895,-116.338303,-115.148516,null,null,-72.1847598,null,-118.689423,null,-121.9905908,-122.419906,-122.419906,-119.7026673,-119.0779359,-119.8345013,-118.3692894,-118.3692894,-118.3692894,-118.3692894,-118.3692894,-118.3692894,-118.689423,-121.9905908,-122.419906,-122.419906,-119.7026673,-119.0779359,-119.8345013,-118.3692894,-118.3692894,-118.3692894,-118.3692894,-118.3692894,-118.3692894,-85.6678639,-83.2341028,-79.3839347,-75.1635262,-75.1635262,-77.5365669,-80.3928423,-72.6771375,-71.0714884,-71.2189405,-74.1723667,-78.3886312,-81.4848086,-118.242766,-87.6244212,-86.0085955,-87.922497,null,-84.5124602,-84.3902644,-80.8430827,-78.6390989,-80.2787573,-82.458444,-104.9848623,-95.9383758,-93.2654692,-122.8080783,-90.435999,-97.1384584,-114.065465,-113.507996,-119.8570901,-119.8570901,-112.1859941,-117.8259819,-122.419906,-98.305779,-96.7968559,-95.504686,-85.759407,-94.5781416,-106.660767,-82.458444,-104.9848623,-104.9848623,-122.2713563,-123.113952,-122.3300624,-122.3300624,-114.065465,-113.507996,-106.660767,-97.1384584,-93.0931028,-95.9383758,-87.922497,null,-87.922497,null,-86.1583502,-94.5781416,null,null,-90.2411165602464,-83.0466403,-79.9900861,-73.9623427,-75.1635262,-75.1635262,-84.3902644,-86.7742984,-78.3879396085486,-77.0365427,-72.6908547,-71.0582912,-71.0582912,-74.0830762172337,-79.3839347,-73.7853915,-78.3879396085486,-81.4848086,-82.458444,-78.6390989,null,-96.7968559,-95.9929113,-95.504686,null,-117.8259819,-117.1627728,-112.0741417,null,-118.5369316,-118.5369316,-105.0691464,-92.2670941,null,-106.713248495746,-97.3375448,null,-90.0701156,null,-84.2747329,-81.8067537,null,null,null,-81.3790304,null,-97.7436995,-63.5859487,null,null,-52.715149,null,-52.715149,-6.2602732,null,-8.4654674,10.000654,9.8444774,18.0710935,10.7389701,-0.1276474,null,null,-0.1276474,-1.31635559782082,4.8936041,6.959974,2.32004102172008,10.4544300261926,8.4673098,-87.5558483,-87.6893826,-73.9623427,-73.9623427,-73.9623427,-73.9623427,-73.9623427,-118.329523,-118.329523,-118.329523,-118.329523,-118.329523,-118.329523,-86.0085955,-86.0885993,-81.2496068,-79.9900861,-75.5243682,-73.7853915,-87.922497,null,-93.2654692,-117.1627728,-116.200886,-123.0950506,-122.419906,-122.6741949,-123.113952,-119.8570901,-113.507996,-114.065465,-97.1384584,-87.6244212,-82.9586042,-79.3839347,-73.5698065,-71.0582912,-70.2548596,-78.9011326,-78.3879396085486,-73.9623427,-74.1840322,-72.6908547,-75.1635262,-75.4712794,-78.6390989,-80.0532942,-82.458444,-86.7742984,-95.3676974,-96.7968559,-95.9929113,-105.193323245069,-105.193323245069,-105.193323245069,-121.890583,-117.911732,-118.242766,-118.242766,-118.5369316,null,-118.5369316,null,-104.9848623,-87.6244212,-89.4884384,null,-84.3902644,-84.5124602,-77.0350922,-75.1635262,-73.9623427,-73.9623427,-73.6656834,-122.419906,-122.419906,-122.2713563,-118.242766,-118.242766,-117.8732213,-117.1627728,-97.5170536,-96.7968559,-92.2895948,-86.7742984,-84.3902644,-95.504686,-90.0654808,-97.7436995,-80.0532942,-82.458444,-90.0516285,-88.2430932,-90.2411165602464,-86.0085955,-122.2855293,-105.193323245069,-105.193323245069,-94.5781416,-93.0931028,-93.6046655,-83.0007065,-79.9900861,-81.6934446,-84.5124602,-72.6908547,-74.1723667,-74.2304216,-118.1444779,-87.6244212,-75.1635262,-77.2799761,-87.922497,null,-87.922497,null,-0.1276474,-79.3839347,-75.6900574,-82.9586042,-71.0582912,-71.0582912,-76.610759,-73.8448553,-73.8448553,-75.1635262,-123.113952,-122.3300624,-122.239633649188,-122.239633649188,-122.239633649188,-121.493895,-117.2653146,null,-118.242766,-118.242766,-118.242766],1,null,null,{"interactive":true,"className":"","stroke":true,"color":"#7625be","weight":5,"opacity":0.5,"fill":true,"fillColor":"#7625be","fillOpacity":0.2},{"showCoverageOnHover":true,"zoomToBoundsOnClick":true,"spiderfyOnMaxZoom":true,"removeOutsideVisibleBounds":true,"spiderLegPolylineOptions":{"weight":1.5,"color":"#222","opacity":0.5},"freezeAtZoom":false},null,["Columbus, Georgia","Boston, Massachusetts","New York City, New York","New York City, New York","West Hollywood, California","West Hollywood, California","West Hollywood, California","West Hollywood, California","Palo Alto, California","Palo Alto, California","Berkeley, California","Berkeley, California","Berkeley, California","Chicago, Illinois","Cleveland, Ohio","Royal Oak, Michigan","New York City, New York","New York City, New York","New York City, New York","Cleveland, Ohio","Cincinnati, Ohio","Akron, Ohio","Garden City, Long Island, New York","Sausalito, California","San Francisco, California","West Hollywood, California","West Hollywood, California","Cardiff, Wales","Lancaster, England","London, England","Birmingham, England","Brighton, England","London, England","London, England","London, England","Bristol, England","Manchester, England","Sheffield, England","Leeds, England","Stoke on Trent, England","Liverpool, England","Newcastle upon Tyne, England","Edinburgh, Scotland","Glasgow, Scotland","Geleen, Netherlands",null,"Brussels, Belgium","Paris, France","Frankfurt, Germany","Amsterdam, Netherlands","Lund, Sweden","Manchester, England","Cologne, Germany","--","Birmingham, England","Cardiff, Wales","Aylesbury, England","London, England","Wolverhampton, England","--, Belgium","Exeter, england","Kingston Upon Hull, England","Portland, Oregon","San Francisco, California","San Francisco, California","West Hollywood, California","West Hollywood, California","Portland, Oregon","San Francisco, California","Fresno, California","Santa Cruz, California","Santa Monica, California","Santa Monica, California","Phoenix, Arizona","Yakima, Washington","Santa Monica, California","Cleveland, Ohio","Painesville, Ohio","New York City, New York","New York City, New York","Pittsburgh, Pennsylvania","Philadelphia, Pennsylvania","Roslyn, New York","Albany, New York","Chicago, Illinois","Santa Cruz, California","Burbank, California","San Diego, California","Davis, California","Riverside, California","Santa Cruz, California","Palo Alto, California","Santa Monica, California","Chico, California","San Francisco, California","Santa Rosa, California","Eugene, Oregon","Portland, Oregon","Vancouver, Canada","London, England","Hertfordshire, England","London, England","Jacksonville, Florida","Tampa, Florida","Miami, Florida","Detroit, Michigan","Cleveland, Ohio","New York City, New York",null,"Asbury Park, New Jersey","Boston, Massachusetts",null,"Washington, D.C.","Philadelphia, Pennsylvania","South Yarmouth, Massachussetts","Hempstead, New York","Oklahome City, Oklahome","New Orleans, Louisiana","Atlanta, Georgia","Atlanta, Georgia","Dallas, Texas","Houston, Texas","Austin, Texas","St. Louis, Missouri","Kansas City, Missouri","Louisville, Kentucky","Indianapolis, Indiana","Chicago, Illinois","Minneapolis, Minnesota",null,"Redding, California","San Francisco, California","Santa Monica, California",null,"Salinas, California",null,"Santa Cruz, California",null,"Sacramento, California",null,"Universal City, California","Universal City, California",null,"New York City, New York","New York City, New York",null,"New York City, New York",null,null,null,"Philadelphia, Pennsylvania","Detroit, Michigan","Cleveland, Ohio",null,"Toronto, Ontario","Boston, Massachussets","Chicago, Illinois","St. Paul, Minnesota","Nashville, Tennessee","Atlanta, Georgia","Austin, Texas","Houston, Texas","Seattle, Washington","Vancouver, British Columbia","Oakland, California","Dallas, Texas","Oklahoma City, Oklahoma","Tulsa, Oklahoma","Kansas City, Missouri","St. Louis, Missouri","Omaha, Nebraska","San Diego, California","Inglewood, California",null,"West Hollywood, California","Phoenix, Arizona","Tuscon, Arizona","Santa Barbara, California","Birmingham, England","Manchester, England","London, England","London, England","Paris, France","Oxford, England","Osaka, Japan","Nagoya, Japan","Tokyo, Japan","Tokyo, Japan","Tokyo, Japan","Sydney, Australia","Sydney, Australia","Brisbane, Australia","Melbourne, Australia","Melbourne, Australia","Adelaide, Australia","Christchurch, New Zealand","Wellington, New Zealand","Honolulu, Hawaii","Hollywood, California","Denver, Colorado","Fort Wayne, Indiana","Clarkson, Michigan","Hoffman Estates, Illinois","Cuyahoga Falls, Ohio","Columbia, Maryland","Saratoga Springs, New York","Passaic, New Jersey","Augusta, Maine","Providence, Rhode Island","New York City, New York","New York City, New York","New York City, New York","Philadelphia, Pennsylvania","Philadelphia, Pennsylvania","Pittsburgh, Pennsylvania","Richmond, Virginia",null,"St. Petersburg, Florida",null,"Pembroke Pines, Florida","Orlando, Florida","Indianapolis, Indiana","Toledo, Ohio","Richfield, Ohio","Chicago, Illinois","Detroit, Michigan",null,"Denver, Colorado","Hollywood, California","Las Vegas, Nevada","Reno, Nevada","Daly City, California","Los Angeles, California","Los Angeles, California","Los Angeles, California","Vancouver, British Columbia","Seattle, Washington","Seattle, Washington","Portland, Oregon","New York City, New York","Charlevoix, Michigan","Ottawa, Ontario","Montreal, Quebec","Toronto, Ontario","New Haven, Connecticut","Saratoga Springs, New York","Philadelphia, Pennsylvania","Rochester, New York","East Rutherford, New Jersey","Columbia, Maryland","Norfolk, Virginia","Bethlehem, Pennsylvania","Pittsburgh, Pennsylvania",null,"Uniondale, New York","Boston, Massachusetts","Providence, Rhode Island","Buffalo, New York","Indianapolis, Indiana","St. Louis, Missouri","Minneapolis, Minnesota",null,"Omaha, Nebraska","East Troy, Wisconsin",null,null,"Kansas City, Missouri","Sacramento, California","Tuscon, Arizona","Tempe, Arizona","Irvine, California",null,"Irvine, California","Houston, Texas","Dallas, Texas","Austin, Texas","Norman, Oklahoma","Baton Rouge, Louisiana","Atlanta, Georgia","Savannah, Georgia","Lakeland, Florida",null,"Jacksonville, Florida","St. Petersburg, Florida",null,"Gainesville, Florida",null,"Tempe, Arizona","Reseda, California","Pasadena, California",null,"Santa Cruz, California","Santa Cruz, California","Devore, California",null,"West Hollywood, California","Brussels, Belgium","Nogent-sur-Marne, France","Utrecht, Netherlands","London, England","Manchester, England","Edinburgh, Scotland","Coventry, England","Brighton, England","Munich, Germany","Mannheim, Germany","Hamburg, Germany","Dortmund, Germany","Berlin, Germany","Offenbach, Germany","Nuremberg, Germany","Stockholm, Sweden","Phoenix, Arizona","Tuscon, Arizona","El Paso, Texas","Oklahome City, Oklahoma","Austin, Texas","Houston, Texas","Dallas, Texas","Shreveport, Louisiana","Memphis, Tennessee","Atlanta, Georgia","Charlotte, North Carolina","West Palm Beach, Florida","St. Petersburg, Florida","Gainesville, Florida","Nashville, Tennessee","Louisville, Kentucky","Bethehem, Pennsylvania",null,"Pittsburgh, Pennsylvania","New York City, New York",null,"Springfield, Missouri","St. Louis, Missouri","Boulder, Colorado","Carbondale, Illinois","Kansas City, Missouri","Omaha, Missouri","Bloomington, Minnesota","Cedar Rapids, Iowa",null,"Milwaukee, Wisconsin",null,"Chicago, Illinois","Indianapolis, Indiana","Detroit, Michigan","Richfield, Ohio","Buffalo, New York","Binghamton, New York","Worcester,Â Massachusetts","Providence, Rhode Island","New Haven, Connecticut","Pittsburgh, Pennsylvania","Willamsburg, Virginia","Uniondale, New York","East Rutherford, New Jersey",null,"Philadelphia, Pennsylvania","Seattle, Washington","Daly City, California","San Francisco, California","Fresno, California","Universal City, California","Universal City, California","San Diego, California","Universal City, California","Bakersfield, California","Angels Camp, California",null,"Angels Camp, California",null,"Denver, Colorado","Irvine, California",null,"New York City, New York","St. Louis, Missouri","Columbus, Ohio","Columbia, Maryland","Worchester, Massachussetts","Philadelphia, Pennsylvania","East Rutherford, New Jersey","Saratoga Springs, New York","Cuyahoga Falls, Ohio","Indianapolis, Indiana","Clarkson, Michigan","Hoffman Estates, Illinois","East Troy, Wisconsin","St. Paul, Minnesota","Kansas City, Missouri","Omaha, Nebraska","Tulsa, Oklahoma","Norman, Oklahoma","Austin, Texas","Dallas, Texas","San Antonio, Texas","Houston, Texas","Nashville, Tennessee","Atlanta, Georgia","Tampa, Florida",null,"Philadelphia, Pennsylvania",null,"Wantagh, New York","Reno, Nevada","Sacramento, California","Seattle, Washington","Berkeley, California","Concord, California",null,"Phoenix, Arizona","Los Angeles, California",null,"Universal City, California","Costa Mesa, California","Los Angeles, California","Los Angeles, California","San Diego, Calfornia",null,"Universal City, California",null,"Tuscon, Arizona","Champaign, Illinois",null,"Wellington, New ZealandÂ ","Auckland, New Zealand","Sydney, Australia","Sydney, Australia","Sydney, Australia","Sydney, Australia","Adelaide, Australia","Perth, Australia","Perth, Australia","Melbourne, Australia","Melbourne, Australia","Melbourne, Australia","Sydney, Australia","Sydney, Australia","Brisbane, Australia","Brisbane, Australia","Tokyo, Japan","Osaka, Japan","Nagoya, Japan","Tokyo, Japan","Los Angeles, California",null,"San Diego, California",null,null,"Reno, Nevada","Sacramento, California","Berkeley, California","Berkeley, California","Costa Mesa, California","Costa Mesa, California","Phoenix, Arizona","Houston, Texas","Austin, Texas","Dallas, Texas","Indianapolis, Indiana","Minneapolis, Minnesota","East Troy, Wisconsin","Hoffman Estates, Illinois","Clarkson, Michigan","Clarkson, Michigan","Akron, Ohio",null,"Buffalo, New York","Washington, D.C.","Washington, D.C.","Mansfield, Massachusetts","Mansfield, Massachusetts","Hartford, Connecticut","Saratoga Springs, New York","New York City, New York","New York City, New York","New York City, New York","Philadelphia, PennsylvaniaÂ ","Philadelphia, Pennsylvania","East Rutherford, New JerseyÂ ","Mansfield, Massachusetts","Bonner Springs, Kansas","Morrison, Colorado","Morrison, Colorado","Portland, Oregon","Tacoma, Washington","Vancouver, British Columbia","Los Angeles, California","Mountain View, California","Paso Robles, California",null,"Mountain View, California",null,"Tuscon, Arizona","Tempe, Arizona",null,null,"Austin, Texas","Houston, Texas","Dallas, Texas","Concord, California","Mountain View, California","Costa Mesa, California","Universal City, California","Universal City, California","Universal City, California","Universal City, California","Omaha, Nebraska","Bloomington, Minnesota","Clarkson, Michigan","East Troy, Wisconsin","Hoffman Estates, Illinois","Pittsburgh, Pennsylvania",null,null,"Cuyahoga Falls, Ohio",null,null,null,"Noblesville, Indiana","Saratoga Springs, New York","Mansfield, Massachusetts","Maple, Ontario","New York City, New York","Wantagh, New York","Holmdel, New Jersey","Manchester, New Hampshire","Syracuse, New York","Philadelphia, Pennsylvania","New Haven, Connecticut","Darien Center, New York","Columbia, Maryland","Atlanta, Georgia","Jacksonville, Florida","West Palm Beach, Florida","Tampa, Florida",null,"Tel-Aviv, Israel","Jerusalem, Israel","Basel, Switzerland","Moderna, Italy","Turin, Italy","Dortmund, West Germany","Nuremberg, West Germany","East Berlin, East Germany","Rotterdam, The Netherlands","Hanover, West Germany","Copenhagen, Denmark","Helsinki, Finland","Gothernbeg, Sweden","Stockholm, Sweden","Frankfurt, West Germany","Stuttgart, West Germany","Munich, West Germany","Verona, Italy","Rome, Italy","Milano, Italy","Locarno, Switzerland","Paris, France","Brussels, Belgium","Birmingham, England","Birmingham, England","Birmingham, England","London, England","London, England","London, England","London, England",null,"Oakland, California",null,"New York City, New York",null,"Miami, Florida","St. Petersburg, Florida","Orlando, Florida","Milwaukee, Wisconsin",null,"Houston, Texas","Austin, Texas","Dallas, Texas","Colorado Springs, Colorado","Seattle, Washington","Mountain View, California","Sacramento, California","San Diego, California","Tempe, Arizona","Costa Mesa, California","Universal City, California","Universal City, California","Universal City, California","Atlanta, Georgia","Clarkson, Michigan","Cuyahoga Falls, Ohio","Hoffman Estates, Illinois","Noblesville, Illinois","Cincinnati, Ohio","Philadelphia, Pennslylvania","Wantagh, New York","Middletown, New York","East Rutherford, New Jersey","Holmdel, New Jersey","Columbia, Maryland","Pittsburgh, Pennsylvania",null,null,null,"Syracuse, New York","Saratoga Springs, New York","Mansfield, Massachussets","Allentown, Pennsylvania","Bristol, Connecticut","Maple, Ontario","Universal City, California",null,"Mansfield, Massachussets","Rochester, New York","Columbus, Ohio","Chapel Hill, North Carolina",null,"Mountain View, California",null,"Universal City, Los Angeles",null,"Tampa, Florida","Gainesville, Florida",null,null,"Charlotte, North Carolina","Uniondale, New York","Providence, Rhode Island","Albany, New York","Fairfax, Virginia","Philadelphia, Pennsylvania",null,null,null,null,"Uniondale, New York","Hartford, Connecticut","Dayton, Ohio","Auburn Hills, Michigan","Richfield, Ohio","Rosemont, Illinois","Normal, Illinois","Iowa City, Iowa","Ames, Iowa","Bloomington, Minnesota","Indianapolis, Indiana","Carbondale, Illinois","St. Louis, Missouri","Kansas City, Missouri","Los Angeles, California","Costa Mesa, California","Sacramento, California","Oakland, California","Denver, Colorado","Kansas City, Missouri","Maryland Heights, Missouri","Omaha, Nebraska","Bloomington, Minnesota","Hoffman Estates, Illinois","Milwaukee, Wisconsin","Noblesville, Illinois","Auburn Hills, Michigan","Cuyahoga Falls, Ohio","Burgettstown, Pennsylvania","Philadelphia, Pennsylvania","Syracuse, New York","Hartford, Connecticut","Albany, New York","Toronto, Ontario","Landover, Maryland","Williamsburg, Virginia","Uniondale, New York","East Rutherford, New Jersey","Binghamton, New York","New York City, New York",null,"Raleigh, North Carolina","Charlotte, North Carolina","Atlanta, Georgia","Columbia, South Carolina","Miami, Florida","Tampa, Florida","Orlando, Florida","Gainesville, Florida","New Orleans, Louisiana","The Woodlands, Texas","Austin, Texas","Dallas, Texas","Oklahoma City, Oklahoma","Las Cruches, New Mexico","Phoenix, Arizona","Costa Mesa, California","Inglewood, California","San Diego, California","Seattle, Washington","Portland, Oregon","Reno, Nevada","Oakland, California","Sacramento, California","Oslo, Norway","Gothenburgh, Sweden","Stockholm, Sweden","Hamburg, Germany","Berlin, Germany","Essen, Germany","Glasgow, Scotland","Belfast, Ireland","Dublin, Ireland","Dublin, Ireland","Birmingham, England","London, England","London, England","Frankfurt, Germany","Munich, Germany","Basel, Switzerland","Paris, France","Brussels, Belgium","Malmo, Sweden","New York City, New York",null,"West Hollywood, California","St. Petersburg, Florida","Gainesville, Florida",null,"Mountain View, California",null,"Mountain View, California",null,"New York City, New York",null,null,"Louisville, Kentucky","Indianapolis, Indiana","South Bard, Indiana","Milwaukee, Wisconsin","Peoria, Illinois","Chicago, Illinois","Auburn Hills, Michigan","Columbus, Ohio","Cincinnati, Ohio","Pittsburgh, Pennsylvania","Cleveland, Ohio","Toronto, Ontario","New York City, New York","Albany, New York","Rochester, New York","New Haven, Connecticut","Uniondale, New York","Boston, Massachussetts","Boston, Massachussetts","Philadelphia, Pennsylvania","Fairfax, Virginia","Richmond. Virginia","Raleigh, North Carolina","Charlotte, North Carolina","Atlanta, Georgia","The Woodlands, Texas","Austin, Texas","Austin, Texas","Dallas, Texas","Phoenix, Arizona","San Diego, California","Devore, California","Mountain View, California","Sacramento, California","Portland, Oregon","George, Washingon","George, Washington","Vancouver, Canada","Miami, Florida","Miami, Florida","Tampa, Florida","Orlando, Florida","Pensacola, Florida","Pelham, Alabama","Antioch, Tennessee","Memphis, Tennessee","Memphis, Tennessee","Memphis, Tennessee","Maryland Heights, Missouri","Bonner Springs, Kansas","Oklahoma City, Oklahoma","Oklahoma City, Oklahoma","Los Angeles, California","Los Angeles, California","Reno, Nevada","Mountain View, California","Salt Lake City, Utah","Englewood, Colorado","Mansfield, Massachusetts","Saratoga Springs, New York","Wantagh, New York","Hartford, Connecticut","Holmdel, New Jersey","Camden, New Jersey","Columbia, Maryland","Burggetstown, Pennsylvania","Cuyahoga Falls, Ohio","Columbus, Ohio","Cincinnati, Ohio","Clarkson, Michigan","Clarkson, Michigan","Minneapolis, Minnesota","Ames, Iowa","Moline, Illinois","Tinley Park, Illinois","Easy Troy, Wisconsin","Fort Wayne, Indiana","Noblesville, Indiana","Evansville, Indiana","Lexington, Kentucky","Knoxville, Tennessee","Raleigh, North Carolina","North Charleston, South Carolina","Atlanta, Georgia","Huntsville, Alabama","Tupelo, Mississippi","Jackson, Mississippi","Tuscaloosa, Alabama","New Orleans, Lousiana","New York City, New York",null,null,"San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","San Francisco, California","New York City, New York",null,"New York City, New York","New York City, New York","New York City, New York","London, England","London, England","Hamburg, Germany","Grand Rapids, Michigan","Cleveland, Ohio","Clarkson, Michigan","Clarkson, Michigan","Darien Center, New York","Burgettstown, Pennsylvania","Bristow, Virginia","Camden, New Jersey","Hartford, Connecticut","Holmdel, New Jersey","Wantagh, New York","Wantagh, New York","Hershey, Pennsylvania","Toronto, Ontario","Mansfield, Massachussetts","Mansfield, Massachussetts","Southampton, New York","Louisville, Kentucky","Noblesville, Indiana","Maryland Heights, Missouri","Cincinnati, Ohio","Columbus, Ohio","Milwaukee, Wisconsin","Tinley Park, Illinois","Minneapolis, Minnesota","Bonner Springs, Kansas","Antioch, Tennessee","Memphis, Tennessee","Irvine, California","Irvine, California","Chula Vista, California","Phoenix, Arizona","Las Vegas, Nevada","Bakersfield, California","Reno, Nevada","Mountain View, California","Mountain View, California","Sacramento, California","Portland, Oregon","Vancouver, British Columbia","George, Washington","George, Washington","Dallas, Texas","Austin, Texas","The Woodslads, Texas","Tampa, Florida","West Palm Beach, Florida","Atlanta, Georgia","Charlotte, North Carolina","Greenville, South Carolina","Raleigh, North Carolina","Philadelphia, Pennsylvania","Virginia Beach, Virginia","Columbia, Maryland","Bloomington, Indiana","Chicago, Illinois","Auburn Hills, Michigan","Moline, Illinois","Madison, Wisconsin","Las Vegas, Nevada","Hollywood, California","Corvallis, Oregon","Boise, Idaho","George, Washington","Morrison, Colorado","Morrison, Colorado","The Woodlands, Texas","San Antonio, Texas","Dallas, Texas","Santa Barbara, California","Sacramento, California","Concord, California","San Diego, California","Las Vegas, Nevada","Las Vegas, Nevada","Scranton, Pennsylvania","Camden, New Jersey","Bristow, Virginia","Holmdel, New Jersey","Milwaukee, Wisconsin","Wantagh, New York","Saratoga Springs, New York","Boston, Massachussetts","Pittsburgh, Pennsylvania","Clarkson, Michigan","Atlanta, Georgia","Nashville, Tennessee","Columbus, Ohio","Kansas City, Missouri","Chicago, Illinois","Noblesville, Indiana","Grand Rapids, Michigan","Cuyahoga Fals, Ohio","Milwaukee, Wisconsin",null,"Darien Lake, New York","Saratofa Springs, New York","Holmdel, New Jersey","Uncasville, Connecticut","Manchester, New Hampshire","Boston, Massachussetts","Scranton, Pennsylvania","Hershey, Pennsylvania","Burgettstown, Pennsylvania","Bristow, Virginia","Raleigh, North Carolina","Charlotte, North Carolina","Tampa, Florida","West Palm Beach, Florida","Atlanta, Georgia","Pelham, Alabama","Cincinnati, Ohio","Noblesville, Indiana","Bonner Springs, Kansas","Maryland Heights, Missouri","Morrison, Colorado","Morrison, Colorado","Albuquerque, New Mexico","Devore, California","Chula Vista, California","Nampa, Idaho","Reno, Nevada","Marsyville, California","Concord, California","Los Angeles, California","Los Angeles, California","Santa Barbara, California","San Diego, California","Mountain View, California","Las Vegas, Nevada","Phoenix, Arizona","West Valley City, Utah","Spokane, Washington","Tacoma, Washington","Portland, Oregon","Houston, Texas","Dallas, Texas","Austin, Texas","Inglewood, California","London, England",null,"Philadelphia, Pennsylvania","Columbus, Ohio","Lexington, Kentucky","Auburn Hills, Michigan","St. Paul, Minnesota","Chicago, Illinois","New York City, New York","Boston, Massachussetts","Chicago, Illinois","Chicago, Ilinois","Chicago, Illinois","Chicago, Illinois","Chicago, Illinois","Chicago, Illinois","Sioux Falls, South Dakota","Milwaukee, Wisconsin",null,"Cedar Rapids, Iowa","Council Bluffs, Iowa","Rapid City, South Dakota","Bozeman, Montana","Bismarck, North Dakota","Duluth, Minnesota","Mankato, Minnesota","Peoria, Illinois","Holmdel, New Jersey","Holmdel, New Jersey","Portsmouth, Virginia","Atlanta, Georgia","Charleston, South Carolina","Nashville, Tennessee","Memphis, Tennessee","Memphis, Tennessee","Daytona Beach, Florida","Fort Myers, Florida","Birmingham, Alabama","New Orleans, Louisiana","Jackson Hole, Wyoming","Aspen, Colorado",null,"Dana Point, California",null,"Estero, Florida","West Palm Beach, Florida","Tampa, Florida","Atlanta, Georgia","Cincinnati, Ohio","Pittsburgh, Pennsylvania","Philadelphia, Pennsylvania","Mansfield, Massachussetts","Wantagh, New York","Holmdel, New Jersey","Hartford, Connecticut","Darien Lake, New York","Grand Rapids, Michigan","Cuyahoga Falls, Ohio","Milwaukee, Wisconsin",null,"Maryland Heights, Missouri","Kansas City, Kansas","Antioch, Tennessee","Tinley Park, Illinois","Caddot, Wisconsin","Des Moines, Iowa","Detroit, Michigan","Indianapolis, Indiana","Scranton, Pennsylvania","Atlantic City, New Jersey","Columbia, Maryland","Mansfield, Massachussetts","Saratoga Springs, New York","Paso Robles, California","Phoenix, Arizona","Irvine, California","Las Vegas, Nevada","Morrison, Colorado","Phoenix, Arizona","San Diego, California","Devore, California","Reno, Nevada","Sacramento, California","Berkeley, California","Berkeley, California","Morrison, Colorado","Morrison, Colorado","George, Washington","George, Washington","Charlotte, North Carolina","Bristow, Virginia","Portsmouth, Virginia","Columbus, Ohio","Manchester, Tennessee","St. Louis, Missouri","New York City, New York","Mansfield, Massachussetts","Indianapolis, Indiana","St. Paul, Minnesota","St. Paul, Minnesota","Milwaukee, Wisconsin",null,"Milwaukee, Wisconsin",null,"Denver, Colorado","Denver, Colorado","Portland, Oregon","Seattle, Washington","Dallas, Texas","The Woodlands, Texas","Detroit, Michigan","Sturgis, South Dakota","Hartford, Connecticut","Saratoga Springs, New York","Darien Lake, New York","Burgettstown, Pennsylvania","Camden, New Jersey","Randall's Island, New York","Toronto, Ontario","Raleigh, North Carolina","Madison, Wisconsin","Chicago, Illinois","Chicago, Illinois","Austin, Texas","Gainesville, Florida","Atlanta, Georgia","Los Angeles, California","San Diego, California","Berkeley, California","Berkeley, California","Phoenix, Arizona","Sacramento, California","Indian Wells, California","Las Vegas, Nevada",null,null,"East Hampton, New York",null,"Malibu, California",null,"Santa Cruz, California","San Francisco, California","San Francisco, California","Santa Barbara, California","Ventura, California","Alpine, California","West Hollywood, California","West Hollywood, California","West Hollywood, California","West Hollywood, California","West Hollywood, California","West Hollywood, California","Malibu, California","Santa Cruz, California","San Francisco, California","San Francisco, California","Santa Barbara, California","Ventura, California","Alpine, California","West Hollywood, California","West Hollywood, California","West Hollywood, California","West Hollywood, California","West Hollywood, California","West Hollywood, California","Grand Rapids, Michigan","Auburn Hills, Michigan","Toronto, Ontario","Philadelphia,Â Pennsylvania","Philadelphia,Â Pennsylvania","Bristow, Virginia","Burgettstown,Â Pennsylvania","Hartford,Â Connecticut","Boston,Â Massachusetts","Mansfield,Â Massachusetts","Newark, New Jersey","Darien Center, New York","Cuyahoga Falls, Ohio","Los Angeles, California","Chicago, Illinois","Noblesville, Indiana","Milwaukee, Wisconsin",null,"Cincinnati, Ohio","Atlanta, Georgia","Charlotte, North Carolina","Raleigh, North Carolina","Sunrise, Florida","Tampa, Florida","Denver, Colorado","Omaha, Nebraska","Minneapolis, Minnesota","Pemberton, British Columbia","Maryland Heights, Missouri","Winnipeg, Manitoba","Calgary, Alberta","Edmonton, Alberta","George, Washington","George, Washington","Glendale, Arizona","Irvine, California","San Francisco, California","Selma, Texas","Dallas, Texas","The Woodlands, Texas","Louisville, Kentucky","Kansas City, Missouri","Saskatoon, Saskatchewan","Tampa, Florida","Denver, Colorado","Denver, Colorado","Oakland, California","Vancouver, British Columbia","Seattle, Washington","Seattle, Washington","Calgary, Alberta","Edmonton, Alberta","Saskatoon, Saskatchewan","Winnipeg, Manitoba","St. Paul, Minnesota","Omaha, Nebraska","Milwaukee, Wisconsin",null,"Milwaukee, Wisconsin",null,"Indianapolis, Indiana","Kansas City, Missouri","Cincinnati, Ohio.Â Liberty went!","Chicao, Illinois","St. Louis, Missouri","Detroit, Michigan","Pittsburgh, Pennsylvania","New York City, New York","Philadelphia, Pennsylvania","Philadelphia, Pennsylvania","Atlanta, Georgia","Nashville, Tennessee","Darien Lake, New York","Washington, DC","Hartford, Connecticut","Boston, Massachusetts","Boston, Massachusetts","East Rutherford, New Jersey","Toronto, Ontario","Saratoga Springs, New York","Darien Lake, New York","Cuyahoga Falls, Ohio","Tampa, Florida","Raleigh, North Carolina","Charlotte, Noorth Carolina","Dallas, Texas","Tulsa, Oklahoma","The Woodlands, Texas","Los Angeles, CaliforniaÂ ","Irvine, California","San Diego, California","Phoenix, Arizona",null,"Northridge, California","Northridge, California","Broomfield, Colorado","North Little Rock, Arkansas",null,"Albuquerque, New Mexico","Wichita, Kansas",null,"New Orleans, Louisiana",null,"Alpharetta, Georgia","Estero, Florida",null,null,null,"Orlando, Florida",null,"Austin, Texas","Halifax, Nova Scotia",null,null,"St. John's, Newfoundland",null,"St. John's, Newfoundland","Dublin, Ireland",null,"Cork, Ireland","Hamburg, Germany","Horsens, Denmark","Stockholm, Sweden","Oslo, Norway","London, England",null,null,"London, England","Newport, England","Amsterdam, The Netherlands","Cologne, Germany","Paris, France","Lucca, Italy","Mannheim, Germany","Evansville, Indiana","Gulf Shores, Alabama","New York City, New York","New York City, New York","New York City, New York","New York City, New York","New York City, New York","Hollywood, California","Hollywood, California","Hollywood, California","Hollywood, California","Hollywood, California","Hollywood, California","Noblesville, Indiana","Manchester, Tennessee","London, Ontario","Pittsburgh, Pennsylvania","Dover, Delaware","Saratoga Springs, New York","Milwaukee, Wisconsin",null,"Minneapolis, Minnesota","San Diego, California","Boise, Idaho","Eugene, Oregon","San Francisco, California","Portland, Oregon","Vancouver, British Columbia","George, Washington","Edmonton, Alberta","Calgary, Alberta","Winnipeg, Manitoba","Chicago, Illinois","Clarkson, Michigan","Toronto, Ontario","Montreal, Quebec","Boston, Massachusetts","Portland, Maine","Arrington, Virginia","Darien Lake, New York","New York City, New York","Holmdel, New Jersey","Hartford, Connecticut","Philadelphia, Pennsylvania","Allentown, Pennsylvania","Raleigh, North Carolina","West Palm Beach, Florida","Tampa, Florida","Nashville, Tennessee","Houston, Texas","Dallas, Texas","Tulsa, Oklahoma","Morrison, Colorado","Morrison, Colorado","Morrison, Colorado","San Jose, California","Anaheim, California","Los Angeles, California","Los Angeles, California","Northridge, California",null,"Northridge, California",null,"Denver, Colorado","Chicago, Illinois","Chillicothe, Illinois","Nashville, Tennesee","Atlanta, Georgia","Cincinnati, Ohio","Washington, D.C.","Philadelphia, Pennsylvania","New York City, New York","New York City, New York","Port Chester, New York","San Francisco, California","San Francisco, California","Oakland, California","Los Angeles, California","Los Angeles, California","Santa Ana, California","San Diego, California","Oklahoma City, Oklahoma","Dallas, Texas","Little Rock, Arkansas","Nashville, Tennessee","Atlanta, Georgia","The Woodlands, Texas","New Orleans, Lousiana","Austin, Texas","West Palm Beach, Florida","Tampa, Florida","Memphis, Tennessee","Champaign, Illinois","St. Louis, Missouri","Noblesville, Indiana","Napa, California","Morrison, Colorado","Morrison, Colorado","Kansas City, Missouri","St. Paul, Minnesota","Des Moines, Iowa","Columbus, Ohio","Pittsburgh, Pennsylvania","Cleveland, Ohio","Cincinnati, Ohio","Hartford, Connecticut","Newark, New Jersey","Hunter Mountain, New York","Pasadena, California","Chicago, Illinois","Philadelphia, Pennsylvania","Canandaigua, New York","Milwaukee, Wisconsin",null,"Milwaukee, Wisconsin",null,"London, England","Toronto, Ontario","Ottawa, Ontario","Clarkson, Michigan","Boston, Massachusetts","Boston, Massachusetts","Baltimore, Maryland","Forest Hills, New York","Forest Hills, New York","Philadelphia, Pennsylvania","Vancouver, British Columbia","Seattle, Washington","Berkeley, California","Berkeley, California","Berkeley, California","Sacramento, California","Del Mar, California",null,"Los Angeles, California","Los Angeles, California","Los Angeles, California"],null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[-43.530955,60.1674881],"lng":[-157.855676,174.7772114]}},"evals":[],"jsHooks":[]}</script>
```

## Where are the top 5 locations visited while touring?

```r
top_5<-touring_geo%>%
  filter(City != "NA")%>%
  count(City)%>%
  arrange(desc(n))
top_5
```

```
## # A tibble: 382 x 2
##    City                           n
##    <chr>                      <int>
##  1 New York City, New York       42
##  2 San Francisco, California     41
##  3 Philadelphia, Pennsylvania    23
##  4 West Hollywood, California    23
##  5 London, England               22
##  6 Los Angeles, California       22
##  7 Atlanta, Georgia              21
##  8 Chicago, Illinois             21
##  9 Dallas, Texas                 18
## 10 Milwaukee, Wisconsin          17
## # ... with 372 more rows
```


```r
kable(top_5, caption = "Top 5 Touring Locations") %>%
  kable_styling(latex_options = "striped")%>%
  row_spec(1:5, background = "#Cab5dc")%>%
  scroll_box(width = "600px", height="350px")
```

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:350px; overflow-x: scroll; width:600px; "><table class="table" style="margin-left: auto; margin-right: auto;">
<caption>Top 5 Touring Locations</caption>
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> City </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> n </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;background-color: #Cab5dc !important;"> New York City, New York </td>
   <td style="text-align:right;background-color: #Cab5dc !important;"> 42 </td>
  </tr>
  <tr>
   <td style="text-align:left;background-color: #Cab5dc !important;"> San Francisco, California </td>
   <td style="text-align:right;background-color: #Cab5dc !important;"> 41 </td>
  </tr>
  <tr>
   <td style="text-align:left;background-color: #Cab5dc !important;"> Philadelphia, Pennsylvania </td>
   <td style="text-align:right;background-color: #Cab5dc !important;"> 23 </td>
  </tr>
  <tr>
   <td style="text-align:left;background-color: #Cab5dc !important;"> West Hollywood, California </td>
   <td style="text-align:right;background-color: #Cab5dc !important;"> 23 </td>
  </tr>
  <tr>
   <td style="text-align:left;background-color: #Cab5dc !important;"> London, England </td>
   <td style="text-align:right;background-color: #Cab5dc !important;"> 22 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Los Angeles, California </td>
   <td style="text-align:right;"> 22 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Atlanta, Georgia </td>
   <td style="text-align:right;"> 21 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Chicago, Illinois </td>
   <td style="text-align:right;"> 21 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Dallas, Texas </td>
   <td style="text-align:right;"> 18 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Milwaukee, Wisconsin </td>
   <td style="text-align:right;"> 17 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Austin, Texas </td>
   <td style="text-align:right;"> 16 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Universal City, California </td>
   <td style="text-align:right;"> 15 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Morrison, Colorado </td>
   <td style="text-align:right;"> 14 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> San Diego, California </td>
   <td style="text-align:right;"> 14 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tampa, Florida </td>
   <td style="text-align:right;"> 14 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Berkeley, California </td>
   <td style="text-align:right;"> 13 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Clarkson, Michigan </td>
   <td style="text-align:right;"> 13 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Phoenix, Arizona </td>
   <td style="text-align:right;"> 13 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Pittsburgh, Pennsylvania </td>
   <td style="text-align:right;"> 13 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sacramento, California </td>
   <td style="text-align:right;"> 13 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mountain View, California </td>
   <td style="text-align:right;"> 12 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Saratoga Springs, New York </td>
   <td style="text-align:right;"> 12 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Indianapolis, Indiana </td>
   <td style="text-align:right;"> 11 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Kansas City, Missouri </td>
   <td style="text-align:right;"> 11 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Portland, Oregon </td>
   <td style="text-align:right;"> 11 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Seattle, Washington </td>
   <td style="text-align:right;"> 11 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cincinnati, Ohio </td>
   <td style="text-align:right;"> 10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Denver, Colorado </td>
   <td style="text-align:right;"> 10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hartford, Connecticut </td>
   <td style="text-align:right;"> 10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Holmdel, New Jersey </td>
   <td style="text-align:right;"> 10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Houston, Texas </td>
   <td style="text-align:right;"> 10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Toronto, Ontario </td>
   <td style="text-align:right;"> 10 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Columbus, Ohio </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cuyahoga Falls, Ohio </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> George, Washington </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hollywood, California </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Raleigh, North Carolina </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> St. Louis, Missouri </td>
   <td style="text-align:right;"> 9 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Boston, Massachusetts </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Charlotte, North Carolina </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cleveland, Ohio </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Columbia, Maryland </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Irvine, California </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Las Vegas, Nevada </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Memphis, Tennessee </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nashville, Tennessee </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Noblesville, Indiana </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Reno, Nevada </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Santa Cruz, California </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sydney, Australia </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wantagh, New York </td>
   <td style="text-align:right;"> 8 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Birmingham, England </td>
   <td style="text-align:right;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Costa Mesa, California </td>
   <td style="text-align:right;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Detroit, Michigan </td>
   <td style="text-align:right;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Minneapolis, Minnesota </td>
   <td style="text-align:right;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Omaha, Nebraska </td>
   <td style="text-align:right;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> St. Paul, Minnesota </td>
   <td style="text-align:right;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> The Woodlands, Texas </td>
   <td style="text-align:right;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Vancouver, British Columbia </td>
   <td style="text-align:right;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> West Palm Beach, Florida </td>
   <td style="text-align:right;"> 7 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Auburn Hills, Michigan </td>
   <td style="text-align:right;"> 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Darien Lake, New York </td>
   <td style="text-align:right;"> 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> East Rutherford, New Jersey </td>
   <td style="text-align:right;"> 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Gainesville, Florida </td>
   <td style="text-align:right;"> 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hoffman Estates, Illinois </td>
   <td style="text-align:right;"> 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Maryland Heights, Missouri </td>
   <td style="text-align:right;"> 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Oakland, California </td>
   <td style="text-align:right;"> 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Uniondale, New York </td>
   <td style="text-align:right;"> 6 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Boston, Massachussetts </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bristow, Virginia </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Louisville, Kentucky </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mansfield, Massachusetts </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mansfield, Massachussetts </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Melbourne, Australia </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Miami, Florida </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Oklahoma City, Oklahoma </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Orlando, Florida </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Paris, France </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Santa Barbara, California </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Santa Monica, California </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> St. Petersburg, Florida </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tokyo, Japan </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tuscon, Arizona </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Albany, New York </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bloomington, Minnesota </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bonner Springs, Kansas </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Brussels, Belgium </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Burgettstown, Pennsylvania </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Camden, New Jersey </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Concord, California </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Devore, California </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> East Troy, Wisconsin </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Grand Rapids, Michigan </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hamburg, Germany </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Manchester, England </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> New Haven, Connecticut </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> New Orleans, Louisiana </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Northridge, California </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Providence, Rhode Island </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Stockholm, Sweden </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tempe, Arizona </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tulsa, Oklahoma </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Washington, D.C. </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Antioch, Tennessee </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Brisbane, Australia </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Buffalo, New York </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Calgary, Alberta </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Darien Center, New York </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Dublin, Ireland </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Edmonton, Alberta </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Inglewood, California </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Jacksonville, Florida </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Palo Alto, California </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Richfield, Ohio </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Rochester, New York </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Scranton, Pennsylvania </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Syracuse, New York </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tinley Park, Illinois </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Winnipeg, Manitoba </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Adelaide, Australia </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Akron, Ohio </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Albuquerque, New Mexico </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Allentown, Pennsylvania </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alpine, California </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ames, Iowa </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Angels Camp, California </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bakersfield, California </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Basel, Switzerland </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Berlin, Germany </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Binghamton, New York </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Boise, Idaho </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Brighton, England </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Carbondale, Illinois </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cardiff, Wales </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cedar Rapids, Iowa </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Champaign, Illinois </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Chula Vista, California </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cologne, Germany </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Daly City, California </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Des Moines, Iowa </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Edinburgh, Scotland </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Estero, Florida </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Eugene, Oregon </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Evansville, Indiana </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Fairfax, Virginia </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Forest Hills, New York </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Fort Wayne, Indiana </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Frankfurt, Germany </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Fresno, California </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Glasgow, Scotland </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hershey, Pennsylvania </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lexington, Kentucky </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Madison, Wisconsin </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Malibu, California </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Manchester, New Hampshire </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Manchester, Tennessee </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mannheim, Germany </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mansfield, Massachussets </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Maple, Ontario </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Moline, Illinois </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Montreal, Quebec </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Munich, Germany </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nagoya, Japan </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> New Orleans, Lousiana </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Newark, New Jersey </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Noblesville, Illinois </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Norman, Oklahoma </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Osaka, Japan </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Oslo, Norway </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ottawa, Ontario </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Pasadena, California </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Paso Robles, California </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Pelham, Alabama </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Peoria, Illinois </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Perth, Australia </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Philadelphia,Â Pennsylvania </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Portsmouth, Virginia </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> San Antonio, Texas </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Saskatoon, Saskatchewan </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> St. John's, Newfoundland </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tacoma, Washington </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Vancouver, Canada </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Ventura, California </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> -- </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> --, Belgium </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Alpharetta, Georgia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Amsterdam, Netherlands </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Amsterdam, The Netherlands </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Anaheim, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Arrington, Virginia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Asbury Park, New Jersey </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Aspen, Colorado </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Atlantic City, New Jersey </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Auckland, New Zealand </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Augusta, Maine </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Aylesbury, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Baltimore, Maryland </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Baton Rouge, Louisiana </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Belfast, Ireland </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bethehem, Pennsylvania </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bethlehem, Pennsylvania </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Birmingham, Alabama </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bismarck, North Dakota </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bloomington, Indiana </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Boston, Massachussets </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Boston,Â Massachusetts </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Boulder, Colorado </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bozeman, Montana </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bristol, Connecticut </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bristol, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Broomfield, Colorado </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Burbank, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Burgettstown,Â Pennsylvania </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Burggetstown, Pennsylvania </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Caddot, Wisconsin </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Canandaigua, New York </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Chapel Hill, North Carolina </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Charleston, South Carolina </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Charlevoix, Michigan </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Charlotte, Noorth Carolina </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Chicago, Ilinois </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Chicao, Illinois </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Chico, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Chillicothe, Illinois </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Christchurch, New Zealand </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cincinnati, Ohio.Â Liberty went! </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Colorado Springs, Colorado </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Columbia, South Carolina </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Columbus, Georgia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Copenhagen, Denmark </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cork, Ireland </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Corvallis, Oregon </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Council Bluffs, Iowa </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Coventry, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Cuyahoga Fals, Ohio </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Dana Point, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Davis, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Dayton, Ohio </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Daytona Beach, Florida </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Del Mar, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Dortmund, Germany </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Dortmund, West Germany </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Dover, Delaware </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Duluth, Minnesota </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> East Berlin, East Germany </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> East Hampton, New York </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> East Rutherford, New JerseyÂ  </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Easy Troy, Wisconsin </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> El Paso, Texas </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Englewood, Colorado </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Essen, Germany </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Exeter, england </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Fort Myers, Florida </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Frankfurt, West Germany </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Garden City, Long Island, New York </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Geleen, Netherlands </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> George, Washingon </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Glendale, Arizona </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Gothenburgh, Sweden </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Gothernbeg, Sweden </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Greenville, South Carolina </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Gulf Shores, Alabama </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Halifax, Nova Scotia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hanover, West Germany </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hartford,Â Connecticut </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Helsinki, Finland </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hempstead, New York </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hertfordshire, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Honolulu, Hawaii </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Horsens, Denmark </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hunter Mountain, New York </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Huntsville, Alabama </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Indian Wells, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Iowa City, Iowa </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Jackson Hole, Wyoming </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Jackson, Mississippi </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Jerusalem, Israel </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Kansas City, Kansas </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Kingston Upon Hull, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Knoxville, Tennessee </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lakeland, Florida </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lancaster, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Landover, Maryland </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Las Cruches, New Mexico </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Leeds, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Little Rock, Arkansas </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Liverpool, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Locarno, Switzerland </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> London, Ontario </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Los Angeles, CaliforniaÂ  </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lucca, Italy </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lund, Sweden </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Malmo, Sweden </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mankato, Minnesota </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mansfield,Â Massachusetts </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Marsyville, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Middletown, New York </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Milano, Italy </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Moderna, Italy </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Munich, West Germany </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nampa, Idaho </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Napa, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nashville, Tennesee </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Newcastle upon Tyne, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Newport, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nogent-sur-Marne, France </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Norfolk, Virginia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Normal, Illinois </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> North Charleston, South Carolina </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> North Little Rock, Arkansas </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nuremberg, Germany </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Nuremberg, West Germany </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Offenbach, Germany </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Oklahome City, Oklahoma </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Oklahome City, Oklahome </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Omaha, Missouri </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Oxford, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Painesville, Ohio </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Passaic, New Jersey </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Pemberton, British Columbia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Pembroke Pines, Florida </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Pensacola, Florida </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Philadelphia, Pennslylvania </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Philadelphia, PennsylvaniaÂ  </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Port Chester, New York </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Portland, Maine </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Randall's Island, New York </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Rapid City, South Dakota </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Redding, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Reseda, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Richmond, Virginia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Richmond. Virginia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Riverside, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Rome, Italy </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Rosemont, Illinois </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Roslyn, New York </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Rotterdam, The Netherlands </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Royal Oak, Michigan </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Salinas, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Salt Lake City, Utah </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> San Diego, Calfornia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> San Jose, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Santa Ana, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Santa Rosa, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Saratofa Springs, New York </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sausalito, California </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Savannah, Georgia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Selma, Texas </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sheffield, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Shreveport, Louisiana </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sioux Falls, South Dakota </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> South Bard, Indiana </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> South Yarmouth, Massachussetts </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Southampton, New York </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Spokane, Washington </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Springfield, Missouri </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Stoke on Trent, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sturgis, South Dakota </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Stuttgart, West Germany </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sunrise, Florida </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tel-Aviv, Israel </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> The Woodslads, Texas </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Toledo, Ohio </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tupelo, Mississippi </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Turin, Italy </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tuscaloosa, Alabama </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Uncasville, Connecticut </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Universal City, Los Angeles </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Utrecht, Netherlands </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Verona, Italy </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Virginia Beach, Virginia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Washington, DC </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wellington, New Zealand </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wellington, New ZealandÂ  </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> West Valley City, Utah </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wichita, Kansas </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Willamsburg, Virginia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Williamsburg, Virginia </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wolverhampton, England </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Worcester,Â Massachusetts </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Worchester, Massachussetts </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Yakima, Washington </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table></div>
The top touring locations were found to be NYC, San Francisco, Philadelphia, West Hollywood, and London. One of the interesting parts of this information is that the two top cities were visited twice as many times as the next three. This would make sense though due to New York's large population and many concert venues. As for California, the band became what they were there after relocating from Gainsville, Florida. You can hear this place influence in many of their songs, and now see that they always toured back home.

# Conclusions

The Spotify API allows for a better understanding of the artists we love in more ways than just listening. By using R, I was able to gain a new understanding of my favorite artist and learn ways to interpret data. Visualizing the places Tom Petty toured allows fans to see how far his influence reached. Making playlists for new listeners also becomes easier by assessing what kind of listener they are. If they like hits that make you happy, I would recommend them to listen to "Don't do me Like That." One of the drawbacks of this project though is the singularity of artists. Tom Petty, and many other artists, put out music under a solo label in addition to their band. Unless you merge the data frames, you only get a view of part of their work. In order to get a full look at Tom's music, you would have to merge his solo work, band work, and "Mudcrutch" work. Overall though, this API is very useful and very unique to work with. 

# References

*Aimee, W. (n.d.). Tour Dates and Setlists - The Petty Archives. Retrieved December 9, 2021, from www.thepettyarchives.com website: https://www.thepettyarchives.com/archives/miscellany/performances/setlists
*charlie86. (2021, December 2). spotifyr. Retrieved December 9, 2021, from GitHub website: https://github.com/charlie86/spotifyr
*DataCamp. (n.d.). spotifyr package - RDocumentation. Retrieved December 9, 2021, from www.rdocumentation.org website: https://www.rdocumentation.org/packages/spotifyr/versions/2.2.1
*Holtz, Y. (2018). Dendrogram customization with R and ggraph. Retrieved December 9, 2021, from www.r-graph-gallery.com website: https://www.r-graph-gallery.com/335-custom-ggraph-dendrogram.html
*Pedersen, T. L. (2021, December 2). ggraph. Retrieved December 9, 2021, from GitHub website: https://github.com/thomasp85/ggraph
*Plantinga, B. (2018, April 29). What do Spotify’s audio features tell us about this year’s Eurovision Song Contest? Retrieved from Medium website: https://medium.com/@boplantinga/what-do-spotifys-audio-features-tell-us-about-this-year-s-eurovision-song-contest-66ad188e112a
*Statista. (2018). Spotify users - subscribers in 2018 | Statista. Retrieved from Statista website: https://www.statista.com/statistics/244995/number-of-paying-spotify-subscribers/

