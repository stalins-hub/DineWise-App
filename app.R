library(shiny)
library(dplyr)
library(DT)
library(leaflet)
library(shinythemes)

restaurant_data <- read.csv("restaurants.csv", stringsAsFactors = FALSE)

renderStars <- function(rating) {
  full_stars <- floor(rating)
  half_star <- ifelse((rating - full_stars) >= 0.5, TRUE, FALSE)
  stars <- paste(rep("★", full_stars), collapse = "")
  if (half_star) stars <- paste0(stars, "½")
  return(stars)
}

ui <- fluidPage(
  theme = shinytheme("flatly"),
  tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap');

      body {
        background: url('image.png') center center / cover no-repeat fixed;
        font-family: 'Poppins', sans-serif;
        color: #ffffff;
      }

      .welcome-section {
        height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        text-align: center;
      }

      .welcome-section > div {
        backdrop-filter: blur(12px);
        background-color: rgba(0, 0, 0, 0.4);
        padding: 50px;
        border-radius: 16px;
        box-shadow: 0px 8px 20px rgba(0, 0, 0, 0.3);
        max-width: 700px;
        width: 90%;
        border: 1px solid rgba(255, 255, 255, 0.2);
      }

      .welcome-section h1 {
        color: #ffffff;
        font-size: 42px;
        font-weight: 600;
        margin-bottom: 20px;
      }

      .welcome-section p {
        color: #e0e0e0;
        font-size: 18px;
        font-weight: 300;
        margin-bottom: 30px;
      }

      .get-started-btn {
        background-color: #e76f51;
        color: white;
        font-size: 20px;
        padding: 10px 30px;
        border-radius: 8px;
        border: none;
        font-weight: 500;
      }

      .container-fluid, .row, .form-control, label, select, .dataTables_wrapper {
        color: #fff !important;
      }

      input, select, .form-control {
        background-color: rgba(255,255,255,0.15);
        color: #ffffff !important;
        border: 1px solid #ccc;
        font-weight: 300;
      }

      .btn, .btn-success {
        background-color: #28a745;
        color: #fff;
        border: none;
        font-weight: 500;
      }

      .btn-success:hover {
        background-color: #218838;
        box-shadow: 0 0 10px #28a745;
      }

      .dataTables_wrapper {
        background-color: rgba(0, 0, 0, 0.5);
        padding: 15px;
        border-radius: 10px;
      }

      table.dataTable thead {
        color: #fff;
      }

      table.dataTable tbody tr {
        color: #fff;
      }

      table.dataTable tbody td a {
        color: #fca17d !important;
        font-weight: 500;
        cursor: pointer;
        text-decoration: none;
      }

      table.dataTable tbody td a:hover {
        color: #ffb088 !important;
        text-decoration: underline;
      }

      .slider-animate-container, .irs--shiny .irs-bar {
        background-color: #ffffff !important;
      }

      .irs--shiny .irs-single {
        color: #000000 !important;
      }

      .irs--shiny .irs-min,
      .irs--shiny .irs-max {
        color: #ffffff !important;
      }

      .details-panel {
        backdrop-filter: blur(12px);
        background-color: rgba(0, 0, 0, 0.4);
        padding: 40px;
        border-radius: 16px;
        box-shadow: 0 8px 20px rgba(0,0,0,0.3);
        max-width: 750px;
        margin: 0 auto;
        color: #ffffff;
        font-family: 'Poppins', sans-serif;
      }

      .details-panel h2 {
        font-weight: 600;
        font-size: 28px;
        color: #fff;
      }

      .details-panel p {
        font-size: 16px;
        margin-bottom: 10px;
        color: #f2f2f2;
      }

      .details-panel strong {
        color: #ffffff;
      }

      .details-panel a {
        color: #fca17d !important;
        font-weight: 500;
        text-decoration: none;
      }

      .details-panel a:hover {
        text-decoration: underline;
        color: #ffb088 !important;
      }
    "))
  ),
  uiOutput("mainUI")
)

server <- function(input, output, session) {
  selected_restaurant <- reactiveVal(NULL)
  user_step <- reactiveVal("home")
  
  observeEvent(input$startBtn, { user_step("search") })
  observeEvent(input$backBtn, { user_step("search") })
  
  observeEvent(input$restaurantClick, {
    selected <- restaurant_data %>% filter(id == input$restaurantClick)
    if (nrow(selected) == 1) {
      selected_restaurant(selected)
      user_step("details")
    }
  })
  
  results_data <- eventReactive(input$searchBtn, {
    restaurant_data %>%
      filter(
        cuisine == input$cuisine,
        city == input$city,
        rating >= input$rating
      )
  })
  
  output$mainUI <- renderUI({
    step <- user_step()
    
    if (step == "home") {
      tagList(
        div(class = "welcome-section",
            div(
              h1("Welcome to DineWise"),
              p("🍷 Find the perfect place to dine, guided by your cravings and city vibes."),
              actionButton("startBtn", "Get Started", class = "get-started-btn")
            )
        )
      )
    } else if (step == "search") {
      tagList(
        fluidRow(
          column(4, selectInput("cuisine", "Choose Cuisine:", choices = unique(restaurant_data$cuisine))),
          column(4, selectInput("city", "Select City:", choices = unique(restaurant_data$city))),
          column(4, sliderInput("rating", "Minimum Rating:", min = 1, max = 5, value = 4, step = 0.1))
        ),
        actionButton("searchBtn", "Search", class = "btn btn-success"),
        br(), br(),
        DTOutput("restaurantTable")
      )
    } else if (step == "details") {
      r <- selected_restaurant()
      if (is.null(r)) return(NULL)
      tagList(
        actionButton("backBtn", "← Back to Search", class = "btn btn-success"),
        br(), br(),
        div(class = "details-panel",
            h2(r[["name"]]),
            p(strong("Cuisine: "), r[["cuisine"]]),
            p(strong("City: "), r[["city"]]),
            p(strong("Rating: "), renderStars(r[["rating"]])),
            p(strong("Popular Dishes: "), r[["dishes"]]),
            p(strong("Website: "), a("Visit", href = r[["website"]], target = "_blank")),
            leafletOutput("detailMap", height = 500)
        )
      )
    }
  })
  
  output$restaurantTable <- renderDT({
    df <- results_data()
    if (nrow(df) == 0) return(NULL)
    
    df_display <- df %>%
      mutate(Name = paste0(
        "<a href='#' onclick='Shiny.setInputValue(\"restaurantClick\", ", 
        id, 
        ", {priority: \"event\"}); return false;'>", 
        name, 
        "</a>"
      )) %>%
      select(Name, rating)
    
    datatable(df_display, escape = FALSE, options = list(pageLength = 5))
  })
  
  output$detailMap <- renderLeaflet({
    r <- selected_restaurant()
    if (is.null(r)) return(NULL)
    leaflet() %>%
      addTiles() %>%
      addMarkers(lng = r$longitude, lat = r$latitude, popup = r$name)
  })
}

shinyApp(ui, server)

