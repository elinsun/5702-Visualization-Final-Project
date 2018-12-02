# server.R

server <- function(input, output, session){
  
  # create the background map
  output$mymap <- renderLeaflet({
    
    leaflet(df) %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href=" ">Mapbox</a >') %>%
      addCircleMarkers(radius = 1, color = 'purple', fill = TRUE) %>%
      setView(lng=-74.0445, lat=40.6892, zoom=10)
  })
  
  # choose Year/Month/Time
  # selected <- reactive({
  #   if(!is.null(input$slider_year)){df = df[df$Year == input$slider_year,]}
  #   if(!is.null(input$slider_month)){df = df[df$Month == input$slider_month,]}
  #   if(!is.null(input$slider_time)){df = df[df$Time == input$slider_time,]}
  # })

  observe({
    leafletProxy("mymap", data = df) %>%
      clearShapes() %>%
      addCircles(~Longitude, ~Latitude, radius=.6, stroke=FALSE, fillOpacity=0.4)
  })

}

#layerId=~zipcode,
#fillColor=pal(colorData)

    # if (colorBy == "superzip") {
    #   # Color and palette are treated specially in the "superzip" case, because
    #   # the values are categorical instead of continuous.
    #   colorData <- ifelse(zipdata$centile >= (100 - input$threshold), "yes", "no")
    #   pal <- colorFactor("viridis", colorData)
    # } else {
    #   colorData <- zipdata[[colorBy]]
    #   pal <- colorBin("viridis", colorData, 7, pretty = FALSE)
    # }
    # 
    # if (sizeBy == "superzip") {
    #   # Radius is treated specially in the "superzip" case.
    #   radius <- ifelse(zipdata$centile >= (100 - input$threshold), 30000, 3000)
    # } else {
    #   radius <- zipdata[[sizeBy]] / max(zipdata[[sizeBy]]) * 30000
    # }
    
  
  # # Show a popup at the given location
  # showZipcodePopup <- function(zipcode, lat, lng) {
  #   selectedZip <- allzips[allzips$zipcode == zipcode,]
  #   content <- as.character(tagList(
  #     tags$h4("Score:", as.integer(selectedZip$centile)),
  #     tags$strong(HTML(sprintf("%s, %s %s",
  #                              selectedZip$city.x, selectedZip$state.x, selectedZip$zipcode
  #     ))), tags$br(),
  #     sprintf("Median household income: %s", dollar(selectedZip$income * 1000)), tags$br(),
  #     sprintf("Percent of adults with BA: %s%%", as.integer(selectedZip$college)), tags$br(),
  #     sprintf("Adult population: %s", selectedZip$adultpop)
  #   ))
  #   leafletProxy("map") %>% addPopups(lng, lat, content, layerId = zipcode)
  # }
