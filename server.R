# server.R

server <- function(input, output, session){
  
  # Create the background map
  
  output$mymap <- renderLeaflet({
    ny_districts <- readLines('nyc.geojson') %>% paste(collapse = "\n")
    # take a subset for now
    map <- leaflet(data=airbnb[1:700,]) %>% 
      setView(lng=-73.9969, lat=40.7061, zoom=10) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href=" ">Mapbox</a >') %>%
      addMarkers(lng= ~longitude,lat= ~latitude) %>%
      addGeoJSON(ny_districts, weight = 1, color = "#444444", fill = FALSE)
  })
  
  # section1
  # Add points according to input Year/Month/time
  observeEvent(input$radio, {
    #print(input$radio)
    if(input$radio == "Year")
    {
      filtered <- df %>% filter(year == input$slider1)
    }
    else if(input$radio == "Month")
    {
      filtered <- df %>% filter(month == input$slider2)
    }
    else
    {
      filtered <- df %>% filter(hour == input$slider3)
    }
    
    leafletProxy("mymap", data = filtered) %>%
      clearGroup(group = 'crime') %>%
      clearPopups() %>%
      addCircleMarkers(lng = filtered$longitude, lat = filtered$latitude,
                       radius=2, color='purple', group = 'crime',
                       clusterOptions = markerClusterOptions(removeOutsideVisibleBounds = TRUE),
                       stroke=FALSE, fillOpacity=0.4)
  })
  
  
  observeEvent(input$slider1, {
    if(input$radio == "Year")
    {
      filtered <- df %>% filter(year == input$slider1)
      leafletProxy("mymap", data = filtered) %>%
        clearGroup(group = 'crime') %>%
        clearPopups() %>%
        addCircleMarkers(lng = filtered$longitude, lat = filtered$latitude,
                         clusterOptions = markerClusterOptions(removeOutsideVisibleBounds = TRUE),
                         radius=2, color='purple', group = 'crime',
                         stroke=FALSE, fillOpacity=0.4)
    }
  })
  
  observeEvent(input$slider2, {
    if(input$radio == "Month")
    {
      filtered <- df %>% filter(month == input$slider2)
      leafletProxy("mymap", data = filtered) %>%
        clearGroup(group = 'crime') %>%
        clearPopups() %>%
        addCircleMarkers(lng = filtered$longitude, lat = filtered$latitude,
                         clusterOptions = markerClusterOptions(removeOutsideVisibleBounds = TRUE),
                         radius=2, color='purple', group = 'crime',
                         stroke=FALSE, fillOpacity=0.4)
    }
  })
  
  observeEvent(input$slider3, {
    if(input$radio == "Time")
    {
      filtered <- df %>% filter(hour == input$slider3)
      leafletProxy("mymap", data = filtered) %>%
        clearGroup(group = 'crime') %>%
        clearPopups() %>%
        addCircleMarkers(lng = filtered$longitude, lat = filtered$latitude,
                         clusterOptions = markerClusterOptions(removeOutsideVisibleBounds = TRUE),
                         radius=2, color='purple', group = 'crime',
                         stroke=FALSE, fillOpacity=0.4)
    }
  })
  
  # section2
  # Show a popup at the given location
  airbnbPopup <- function(lat, lng){  
    selected <- airbnb %>% filter(latitude == lat, longitude == lng)
    content <- as.character(tagList(
      # content of popup tags
      tags$h6(as.character(selected$name)),
      tags$h6("Price: $", as.numeric(selected$price)),
      sprintf("Include %d bathroom(s) %d bedroom(s)", 
              as.numeric(selected$bathrooms), 
              as.numeric(selected$bedrooms)), 
      tags$br(),
      sprintf("Accommendate maximum %d people", 
              as.numeric(selected$accommodates))
    ))
    leafletProxy("mymap") %>% addPopups(lng, lat, content)
  } 
  
  # When map is clicked, show a popup with airbnb info
  observe({
    leafletProxy("mymap") %>% clearPopups()
    event <- input$mymap_marker_click
    if (is.null(event)) 
      return()
    isolate({airbnbPopup(event$lat, event$lng)})   
  })
  
  
  #section 3
  # Display point according to selected boroughs
  ######################## TO DO ########################################
  observeEvent(input$select_borough, {
    if(input$select_borough == 'Manhattan'){
      setView(map = leafletProxy("mymap"), lng=-73.9712, lat=40.7831, zoom=12)
    }
    else if(input$select_borough == 'Queens'){
      setView(map = leafletProxy("mymap"), lng=-73.7949, lat=40.7282, zoom=12)
    }
    else if(input$select_borough == 'Brooklyn'){
      setView(map = leafletProxy("mymap"), lng=-73.9442, lat=40.6782, zoom=12)
    }
    else if(input$select_borough == "Staten Island"){
      setView(map = leafletProxy("mymap"), lng=-74.1502, lat=40.5795, zoom=12)
    }
    else{
      setView(map = leafletProxy("mymap"), lng=-73.8648, lat=40.8448, zoom=12)
    }
  })
  
  #section 4
  # Calculate distance between clicked point and a certain attraction
  observeEvent(input$mymap_click, {
    
    attr <- attractions %>% filter(places == input$select_attraction)
    attr_lng <- as.character(attr$longitude) 
    attr_lat <- as.character(attr$latitude)
    attr_str <- paste(c(attr_lat,'+',attr_lng), collapse='')
    
    click <- input$mymap_click
    lat <- as.character(click$lat)
    lng <- as.character(click$lng)
    input_str <- paste(c(lat,'+',lng), collapse='')
    
    goo_api_key <- "AIzaSyABKQj5-Tnrj_s423964IJsYMBqwnEVoWA"
    drive_info <- gmapsdistance(origin = input_str, destination = attr_str,
                                mode ="driving", key = goo_api_key)
    transit_info <- gmapsdistance(origin = input_str, destination = attr_str,
                                  mode ="transit", key = goo_api_key)
    bike_info <- gmapsdistance(origin = input_str, destination = attr_str,
                               mode ="bicycling", key = goo_api_key)
    walk_info <- gmapsdistance(origin = input_str, destination = attr_str,
                               mode ="walking", key = goo_api_key)
    
    drive_min <- as.character(as.integer(drive_info$Time/60))
    transit_min <- as.character(as.integer(transit_info$Time/60))
    bike_min <- as.character(as.integer(bike_info$Time/60))
    walk_min <- as.character(as.integer(walk_info$Time/60))
    
    output_text_drive <- paste("Estimated Driving Time: ", drive_min, " Minutes")
    output_text_transit <- paste("Estimated Subway Time: ", transit_min, " Minutes")
    output_text_bike <- paste("Estimated Biking Time: ", bike_min, " Minutes")
    output_walking_bike <- paste("Estimated Walking Time: ", walk_min, " Minutes")
    
    final_text <- paste(output_text_drive, "\n", output_text_transit, "\n", 
                        output_text_bike, "\n", output_walking_bike)
    
    
    output$output_time <- renderText(final_text)
  })
  
  observeEvent(input$select_attraction, {
    
    attr <- attractions %>% filter(places == input$select_attraction)
    attr_lng <- as.character(attr$longitude) 
    attr_lat <- as.character(attr$latitude)
    attr_str <- paste(c(attr_lat,'+',attr_lng), collapse='')
    
    click <- input$mymap_click
    lat <- as.character(click$lat)
    lng <- as.character(click$lng)
    input_str <- paste(c(lat,'+',lng), collapse='')
    
    goo_api_key <- "AIzaSyABKQj5-Tnrj_s423964IJsYMBqwnEVoWA"
    drive_info <- gmapsdistance(origin = input_str, destination = attr_str,
                                mode ="driving", key = goo_api_key)
    transit_info <- gmapsdistance(origin = input_str, destination = attr_str,
                                  mode ="transit", key = goo_api_key)
    bike_info <- gmapsdistance(origin = input_str, destination = attr_str,
                               mode ="bicycling", key = goo_api_key)
    walk_info <- gmapsdistance(origin = input_str, destination = attr_str,
                               mode ="walking", key = goo_api_key)
    
    drive_min <- as.character(as.integer(drive_info$Time/60))
    transit_min <- as.character(as.integer(transit_info$Time/60))
    bike_min <- as.character(as.integer(bike_info$Time/60))
    walk_min <- as.character(as.integer(walk_info$Time/60))
    
    output_text_drive <- paste("Estimated Driving Time: ", drive_min, " Minutes")
    output_text_transit <- paste("Estimated Subway Time: ", transit_min, " Minutes")
    output_text_bike <- paste("Estimated Biking Time: ", bike_min, " Minutes")
    output_walking_bike <- paste("Estimated Walking Time: ", walk_min, " Minutes")
    
    final_text <- paste(output_text_drive, "\n", output_text_transit, "\n", 
                        output_text_bike, "\n", output_walking_bike)
    
    
    output$output_time <- renderText(final_text)
  })
  
  
}