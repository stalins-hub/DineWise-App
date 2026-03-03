# DineWise — Restaurant Discovery Shiny App

DineWise is an interactive **R Shiny** web application that helps users discover restaurants by **cuisine**, **city**, and **minimum rating**, then explore details and locations on an interactive map.

## Demo
- Live app: (https://stalinsan.shinyapps.io/DineWise/)
- Repository: https://github.com/stalins-hub/DineWise-App

## Features
- **Landing page** with “Get Started” flow
- Filter restaurants by **Cuisine**, **City**, and **Minimum Rating**
- Results displayed in an interactive **DT** table
- Restaurant detail view with:
  - rating display
  - popular dishes
  - external website link (if available)
  - interactive **Leaflet** map

## Tech Stack
- **R** (Shiny)
- **DT** for searchable/sortable tables
- **leaflet** for interactive mapping
- **dplyr** for data manipulation

## Project Structure
.
├── app.R
├── restaurants.csv
└── www/
└── image.png

## Getting Started (Run Locally)

### 1) Install R packages
```r
install.packages(c("shiny", "dplyr", "DT", "leaflet", "shinythemes"))
Run the app
From the project directory:
shiny::runApp()
Data
restaurants.csv contains restaurant metadata (name, cuisine, city, rating, dishes, website, latitude/longitude).
You can replace it with your own dataset as long as the column names match those used in app.R.
Deployment
This app is deployed using rsconnect to shinyapps.io.

Author
Sandhya Stalin
GitHub: https://github.com/stalins-hub





