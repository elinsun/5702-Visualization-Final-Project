# server.R

server <- function(input, output, session){
  
  # create the background map
  output$mymap <- renderLeaflet({
    #dataset <- Dataset()
    map <- leaflet(data=airbnb[1:10,]) %>% 
      setView(lng=-74.0445, lat=40.6892, zoom=10) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href=" ">Mapbox</a >') %>%
      addMarkers(lng= ~longitude,lat= ~latitude)
    })
  
  # # choose Year, Month, time according to radio buton
  # timescale <- switch(input$radio, Year = 'Year', Month = 'Month', time = 'time')
  # # paste the chosen value to input 
  # slider <- paste('input$',timescale)
  # # get the subset of data we want
  # filtered <- reactive({df %>% filter(timescale = slider)}) 
  # # add points
  # observeEvent(timescale, {
  # 
  #   leafletProxy("mymap", data = filtered) %>%
  #     clearShapes() %>%
  #     addCircleMakers(lng= ~Longitude,lat= ~Latitude,
  #                radius=.6, color='purple',
  #                stroke=FALSE, fillOpacity=0.4)
  # })


  # Show a popup at the given location
  airbnbPopup <- function(lat, lng){  
    selected <- airbnb %>% filter(latitude == lat, longitude == lng)
    content <- as.character(tagList(
      tags$h6(as.character(selected$name)),
      tags$h6("Price: $", as.numeric(selected$price)),
      sprintf("Include %d bathroom(s) %d bedroom(s)", as.numeric(selected$bathrooms), as.numeric(selected$bedrooms)), tags$br(),
      sprintf("Accommendate maximum %d people", as.numeric(selected$accommodates))
      ))
    leafletProxy("mymap") %>% addPopups(lng, lat, content, layerId = 'airbnbprice')
    } 
  
    # When map is clicked, show a popup with city info
    observe({
      leafletProxy("mymap") %>% clearPopups()
      event <- input$mymap_marker_click
      if (is.null(event)) return()
      isolate({airbnbPopup(event$lat, event$lng)}) #(event$id, 
    })
    
}