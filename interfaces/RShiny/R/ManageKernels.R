#' Get test/mock R kernels for development and testing
#'
#' Returns realistic test data when API is unavailable
#'
#' @return Character vector of kernel choices in format "kernel_name-version"
#' @keywords internal
get_test_r_kernels <- function() {
  # Realistic R kernel names and versions for testing
  c(
    "bioconductor-3.18",
    "bioconductor-3.19",
    "bioconductor-3.20",
    "pecan-1.0",
    "pecan-1.1",
    "pecan-2.0",
    "tidyverse-4.3",
    "tidyverse-4.4",
    "tidyverse-5.0",
    "datascience-1.0",
    "datascience-1.1",
    "rstudio-4.2",
    "rstudio-4.3",
    "base-r-4.2",
    "base-r-4.3",
    "base-r-4.4",
    "ml-r-1.0",
    "ml-r-1.1",
    "geospatial-1.0",
    "geospatial-1.1",
    "bioinformatics-2.0",
    "bioinformatics-2.1"
  )
}

#' Fetch R kernels from API
#'
#' Helper function to fetch available R kernels from the ICRN Kernel Manager API.
#' Falls back to test data if API is unavailable.
#'
#' @param api_base_url Base URL for the API
#' @param use_test_data Logical, if TRUE always returns test data (for development)
#' @return Character vector of kernel choices in format "kernel_name-version"
#' @keywords internal
fetch_r_kernels <- function(api_base_url = "https://kernels.cori-dev.ncsa.illinois.edu", use_test_data = FALSE) {
  # If use_test_data is TRUE, return test data immediately
  if (use_test_data) {
    return(get_test_r_kernels())
  }
  
  language <- "r"  # Hardcoded to R kernels only
  
  tryCatch({
    # Construct API endpoint URL
    url <- paste0(api_base_url, "/api/kernels/", language)
    
    # Make HTTP GET request with timeout
    response <- httr::GET(url, httr::timeout(10))
    
    # Check for HTTP errors
    httr::stop_for_status(response)
    
    # Parse JSON response
    data <- httr::content(response, as = "parsed", type = "application/json")
    
    # Validate response structure
    if (is.null(data$kernels) || length(data$kernels) == 0) {
      # API returned empty, fall back to test data
      return(get_test_r_kernels())
    }
    
    # Format kernels as "kernel_name-version" for radioButtons
    choices <- character(0)
    for (kernel in data$kernels) {
      kernel_name <- kernel$name
      versions <- kernel$versions
      if (!is.null(kernel_name) && !is.null(versions) && length(versions) > 0) {
        for (version in versions) {
          choices <- c(choices, paste0(kernel_name, "-", version))
        }
      }
    }
    
    # If we got kernels from API, return them; otherwise fall back to test data
    if (length(choices) > 0) {
      return(choices)
    } else {
      return(get_test_r_kernels())
    }
  }, error = function(e) {
    # On any error (network, parsing, etc.), fall back to test data
    return(get_test_r_kernels())
  })
}

#' Manage ICRN R Kernels
#'
#' Shiny gadget to select and manage ICRN R kernels from the web API.
#' Displays available R kernels fetched from the ICRN Kernel Manager API.
#'
#' @export
manageKernels <- function() {
  # nocov start
  
  # Hardcoded API configuration
  # Using internal Kubernetes service - accessible from within the cluster
  # Server-side R process makes the request, so CORS is not needed
  api_base_url <- "http://icrn-web-service.kernels:80"
  
  # Public web URL for the kernel information page
  # Detect environment based on hostname or use dev as default
  # Production: https://kernels.ncsa.illinois.edu
  # Development: https://kernels.cori-dev.ncsa.illinois.edu
  kernel_web_url <- if (grepl("cori-dev", Sys.getenv("HOSTNAME", ""), ignore.case = TRUE)) {
    "https://kernels.cori-dev.ncsa.illinois.edu"
  } else {
    "https://kernels.ncsa.illinois.edu"
  }
  
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar(
      shiny::p(
        "Select an ICRN R kernel from",
        shiny::a(href = "https://github.com/hdpriest-ui/icrn_manager", "icrn manager")
      ),
      left = miniUI::miniTitleBarButton("refresh", "Refresh", primary = FALSE),
      right = miniUI::miniTitleBarButton("done", "Done", primary = TRUE)
    ),
    miniUI::miniContentPanel(
      shiny::div(
        style = "margin-bottom: 15px; padding: 10px; background-color: #f8f9fa; border-radius: 4px;",
        shiny::tags$p(
          style = "margin: 0; font-size: 0.9em;",
          "For more detailed information and advanced search, please visit the ",
          shiny::a(href = kernel_web_url, target = "_blank", "kernel information page"),
          "."
        )
      ),
      shiny::uiOutput("kernel_ui")
    )
  )
  
  server <- function(input, output, session) {
    # Reactive value to store kernels data
    # NULL = not loaded yet, character(0) = error/empty, character vector = kernels
    kernels_data <- shiny::reactiveVal(NULL)
    
    # Function to fetch kernels and update reactive value
    fetch_kernels <- function() {
      kernels_data(NULL)  # Set to loading state
      result <- fetch_r_kernels(api_base_url)
      kernels_data(result)
    }
    
    # Initial fetch after UI renders
    shiny::observe({
      fetch_kernels()
    })
    
    # Render the kernel UI based on fetch result
    output$kernel_ui <- shiny::renderUI({
      kernels_choices <- kernels_data()
      
      # Loading state (NULL = not fetched yet)
      if (is.null(kernels_choices)) {
        return(shiny::div(
          shiny::tags$p(
            shiny::tags$strong("Loading kernels...")
          ),
          shiny::tags$p(
            shiny::tags$em("Fetching data from API...")
          )
        ))
      }
      
      # Success state (has kernels)
      has_kernels <- length(kernels_choices) > 0
      if (has_kernels) {
        shiny::selectizeInput(
          "kernel_choice",
          "Search and select an R kernel:",
          choices = kernels_choices,
          selected = NULL,
          options = list(
            placeholder = "Type to search for a kernel...",
            maxOptions = length(kernels_choices),
            searchField = c("text", "value")
          )
        )
      } else {
        # Error/empty state
        shiny::div(
          shiny::tags$p(
            shiny::tags$strong("Error: "),
            "Unable to fetch R kernels from the API. Please check your connection and try again."
          ),
          shiny::tags$p(
            "API URL: ",
            shiny::tags$code(api_base_url)
          ),
          shiny::tags$p(
            shiny::tags$em("Click 'Refresh' to retry.")
          )
        )
      }
    })
    
    # Handle refresh button
    shiny::observeEvent(input$refresh, {
      fetch_kernels()
    })
    
    # Handle done button
    shiny::observeEvent(input$done, {
      shiny::stopApp(input$kernel_choice)
    })
  }
  
  app <- shiny::shinyApp(ui, server, options = list(quiet = TRUE))
  shiny::runGadget(app, viewer = shiny::dialogViewer("Manage Kernels"))
}


reprex_guess <- function(
    source,
    venue = "gh",
    source_file = NULL,
    session_info = FALSE,
    html_preview = FALSE
) {
  reprex_input <- switch(
    source,
    clipboard = NULL,
    cur_sel = rstudio_selection(),
    cur_file = rstudio_file(),
    input_file = source_file$datapath
  )
  
  reprex(
    input = reprex_input,
    venue = venue,
    session_info = session_info,
    html_preview = html_preview
  )
}


# RStudio helpers ---------------------------------------------------------

rstudio_file <- function(context = rstudio_context()) {
  rstudio_text_tidy(context$contents)
}

rstudio_selection <- function(context = rstudio_context()) {
  text <- rstudioapi::primary_selection(context)[["text"]]
  rstudio_text_tidy(text)
}

rstudio_context <- function() {
  rstudioapi::getSourceEditorContext()
}