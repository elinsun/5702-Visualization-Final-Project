# server.R

server <- function(input, output, session){
  
  # Create the background map
  output$mymap <- renderLeaflet({
    
    # take a subset for now
    map <- leaflet(data=airbnb[1:30,]) %>% 
      setView(lng=-73.9969, lat=40.7061, zoom=10) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href=" ">Mapbox</a >') %>%
      addMarkers(lng= ~longitude,lat= ~latitude)
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
      clearShapes() %>%
      clearPopups() %>%
      addCircles(lng = filtered$longitude, lat = filtered$latitude,
                 radius=50, color='purple',
                 stroke=FALSE, fillOpacity=0.4)
  })
  
  observeEvent(input$slider1, {
    if(input$radio == "Year")
    {
      filtered <- df %>% filter(year == input$slider1)
      leafletProxy("mymap", data = filtered) %>%
        clearShapes() %>%
        clearPopups() %>%
        addCircles(lng = filtered$longitude, lat = filtered$latitude,
                   radius=50, color='purple',
                   stroke=FALSE, fillOpacity=0.4)
    }
  })
  
  observeEvent(input$slider2, {
    if(input$radio == "Month")
    {
      filtered <- df %>% filter(month == input$slider2)
      leafletProxy("mymap", data = filtered) %>%
        clearShapes() %>%
        clearPopups() %>%
        addCircles(lng = filtered$longitude, lat = filtered$latitude,
                   radius=50, color='purple',
                   stroke=FALSE, fillOpacity=0.4)
    }
  })
  
  observeEvent(input$slider3, {
    if(input$radio == "Time")
    {
      filtered <- df %>% filter(hour == input$slider3)
      leafletProxy("mymap", data = filtered) %>%
        clearShapes() %>%
        clearPopups() %>%
        addCircles(lng = filtered$longitude, lat = filtered$latitude,
                   radius=50, color='purple',
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
}