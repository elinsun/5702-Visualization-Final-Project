# ui.R

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      
      radioButtons("radio", "Time Scales",
                   choices = c("Year", "Month","Time"), 
                   selected = "Year", inline = TRUE),
      
      
      sliderInput("slider1", h5("Year"),
                  min = 2013, max = 2017, value = 2013,
                  step = 1, animate = TRUE,
                  pre = 'Year'),
      
      sliderInput("slider2", h5("Month"),
                  min = 1, max = 12, value = 1,
                  step = 1, animate = TRUE),
      
      sliderInput("slider3", h5("Hour"),
                  min = 0, max = 23, value = 0,
                  step = 1, animate = TRUE),
      
      selectInput("select_borough", "Boroughs", 
                  choices = c("Manhattan", "Brooklyn", "Queens",
                                     "Staten Island", "The Bronx"), selected = "Manhattan"),
          
      selectInput("select_attraction", "Attractions",
                  choices = list("Empire State Building", "Museum of Modern Art", 
                                     "American Museum of Natural History", "Top of the Rock", 
                                     "Guggenheim Museum", "9/11 Memorial",
                                     "Intrepid Sea Air & Space Museum",
                                     "Central Park", "New York Public Library"), selected = "Empire State Building"),
          
      verbatimTextOutput("output_time")
    ),
    
    mainPanel(leafletOutput("mymap", height = 1000))
    
  )
)