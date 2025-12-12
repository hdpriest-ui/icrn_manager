#' Fetch R kernels from API
#'
#' Helper function to fetch available R kernels from the ICRN Kernel Manager API
#'
#' @param api_base_url Base URL for the API (default: https://kernels.cori-dev.ncsa.illinois.edu)
#' @return Character vector of kernel choices in format "kernel_name-version", or empty vector on error
#' @keywords internal
fetch_r_kernels <- function(api_base_url = "https://kernels.cori-dev.ncsa.illinois.edu") {
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
      return(character(0))
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
    
    return(choices)
  }, error = function(e) {
    # Return empty vector on any error (network, parsing, etc.)
    return(character(0))
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
      shiny::uiOutput("kernel_ui")
    )
  )
  
  server <- function(input, output, session) {
    # Reactive value to trigger refresh
    refresh_trigger <- shiny::reactiveVal(0)
    
    # Reactive expression to fetch kernels
    kernels_data <- shiny::reactive({
      refresh_trigger()  # Depend on refresh trigger
      fetch_r_kernels(api_base_url)
    })
    
    # Render the kernel UI based on fetch result
    output$kernel_ui <- shiny::renderUI({
      kernels_choices <- kernels_data()
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
      refresh_trigger(refresh_trigger() + 1)
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