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
#' @return List with 'kernels' (character vector) and 'is_test_data' (logical)
#' @keywords internal
fetch_r_kernels <- function(api_base_url = "https://kernels.cori-dev.ncsa.illinois.edu", use_test_data = FALSE) {
  # If use_test_data is TRUE, return test data immediately
  if (use_test_data) {
    return(list(kernels = get_test_r_kernels(), is_test_data = TRUE))
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
      return(list(kernels = get_test_r_kernels(), is_test_data = TRUE))
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
      return(list(kernels = choices, is_test_data = FALSE))
    } else {
      return(list(kernels = get_test_r_kernels(), is_test_data = TRUE))
    }
  }, error = function(e) {
    # On any error (network, parsing, etc.), fall back to test data
    return(list(kernels = get_test_r_kernels(), is_test_data = TRUE))
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
        style = "text-align: center; max-width: 800px; margin: 0 auto;",
        shiny::div(
          style = "margin-bottom: 15px; padding: 10px; background-color: #f8f9fa; border-radius: 4px;",
          shiny::tags$p(
            style = "margin: 0; font-size: 0.9em;",
            "For more detailed information and advanced search, please visit the ",
            shiny::a(href = kernel_web_url, target = "_blank", "kernel information page"),
            "."
          )
        ),
        shiny::uiOutput("kernel_ui"),
        shiny::uiOutput("commands_ui")
      )
    )
  )
  
  server <- function(input, output, session) {
    # Reactive value to store kernels data
    # NULL = not loaded yet, list with kernels and is_test_data = loaded
    kernels_data <- shiny::reactiveVal(NULL)
    
    # Reactive values to store command execution results
    get_command_result <- shiny::reactiveVal(NULL)
    use_command_result <- shiny::reactiveVal(NULL)
    command_executing <- shiny::reactiveVal(FALSE)
    
    # Function to fetch kernels and update reactive value
    fetch_kernels <- function() {
      kernels_data(NULL)  # Set to loading state
      result <- fetch_r_kernels(api_base_url)
      kernels_data(result)
    }
    
    # Function to execute a command and return result
    execute_command <- function(cmd) {
      command_executing(TRUE)
      on.exit(command_executing(FALSE))
      
      result <- tryCatch({
        # Parse command: "icrn_manager kernels get R name version"
        # Split into command and arguments
        cmd_parts <- strsplit(cmd, " ")[[1]]
        if (length(cmd_parts) < 2 || cmd_parts[1] != "icrn_manager") {
          return(list(success = FALSE, output = "Invalid command format"))
        }
        
        # Execute command and capture both stdout and stderr
        # system2 will merge stdout and stderr
        output <- system2(
          cmd_parts[1],
          args = cmd_parts[-1],
          stdout = TRUE,
          stderr = TRUE,
          wait = TRUE
        )
        
        # Check exit status
        exit_status <- attr(output, "status")
        if (!is.null(exit_status) && exit_status != 0) {
          return(list(success = FALSE, output = paste(output, collapse = "\n")))
        }
        
        list(success = TRUE, output = paste(output, collapse = "\n"))
      }, error = function(e) {
        list(success = FALSE, output = paste("Error:", conditionMessage(e)))
      })
      
      return(result)
    }
    
    # Initial fetch after UI renders
    shiny::observe({
      fetch_kernels()
    })
    
    # Render the kernel UI based on fetch result
    output$kernel_ui <- shiny::renderUI({
      data <- kernels_data()
      
      # Loading state (NULL = not fetched yet)
      if (is.null(data)) {
        return(shiny::div(
          style = "text-align: center; padding: 20px;",
          shiny::tags$div(
            style = "display: inline-block; width: 40px; height: 40px; border: 4px solid #f3f3f3; border-top: 4px solid #3498db; border-radius: 50%; animation: spin 1s linear infinite; margin-bottom: 15px;",
            shiny::tags$style(HTML("
              @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
              }
            "))
          ),
          shiny::tags$p(
            style = "margin-top: 15px; font-size: 1.1em;",
            shiny::tags$strong("Loading kernels...")
          ),
          shiny::tags$p(
            style = "margin-top: 5px; color: #666;",
            shiny::tags$em("Fetching data from API...")
          )
        ))
      }
      
      kernels_choices <- data$kernels
      is_test_data <- data$is_test_data
      
      # Success state (has kernels)
      has_kernels <- length(kernels_choices) > 0
      if (has_kernels) {
        # Add test data indicator to choices if needed
        warning_msg <- if (is_test_data) {
          shiny::div(
            style = "margin-bottom: 10px; padding: 8px; background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 4px; text-align: center;",
            shiny::tags$p(
              style = "margin: 0; font-size: 0.9em; color: #856404;",
              shiny::tags$strong("⚠ ERROR STATE: "),
              "Using test data. API connection unavailable."
            )
          )
        } else {
          NULL
        }
        
        shiny::tagList(
          warning_msg,
          shiny::div(
            style = "text-align: center; margin-bottom: 20px;",
            shiny::selectizeInput(
              "kernel_choice",
              "Search and select an R kernel:",
              choices = kernels_choices,
              selected = NULL,
              options = list(
                placeholder = "Click to see available kernels...",
                maxOptions = length(kernels_choices),
                searchField = c("text", "value")
              )
            )
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
    
    # Render commands UI when kernel is selected
    output$commands_ui <- shiny::renderUI({
      if (is.null(input$kernel_choice) || input$kernel_choice == "") {
        return(NULL)
      }
      
      # Parse kernel name and version from selection (format: "kernel_name-version")
      parts <- strsplit(input$kernel_choice, "-", fixed = TRUE)[[1]]
      if (length(parts) < 2) {
        return(NULL)
      }
      
      version <- parts[length(parts)]
      name <- paste(parts[-length(parts)], collapse = "-")
      
      get_cmd <- paste0("icrn_manager kernels get R ", name, " ", version)
      use_cmd <- paste0("icrn_manager kernels use R ", name, " ", version)
      
      # Get command execution results
      get_result <- get_command_result()
      use_result <- use_command_result()
      is_executing <- command_executing()
      
      shiny::div(
        style = "margin-top: 20px; padding: 15px; background-color: #e7f3ff; border-radius: 4px; text-align: center;",
        shiny::tags$h4(style = "margin-top: 0;", "Commands for selected kernel:"),
        shiny::div(
          style = "margin-bottom: 15px;",
          shiny::tags$strong("Get kernel:"),
          shiny::div(
            style = "display: flex; align-items: center; margin-top: 5px;",
            shiny::tags$code(
              style = "flex: 1; padding: 8px; background-color: white; border: 1px solid #ccc; border-radius: 4px; font-family: monospace;",
              get_cmd
            ),
            shiny::actionButton(
              "copy_get",
              "Copy",
              style = "margin-left: 5px;",
              onclick = paste0("navigator.clipboard.writeText('", get_cmd, "').then(() => alert('Command copied to clipboard!'))")
            ),
            shiny::actionButton(
              "execute_get",
              if (is_executing) {
                shiny::tagList(
                  shiny::tags$span(
                    style = "display: inline-block; width: 12px; height: 12px; border: 2px solid #ffffff; border-top: 2px solid transparent; border-radius: 50%; animation: spin 0.6s linear infinite; margin-right: 5px;",
                    shiny::tags$style(HTML("
                      @keyframes spin {
                        0% { transform: rotate(0deg); }
                        100% { transform: rotate(360deg); }
                      }
                    "))
                  ),
                  "Executing..."
                )
              } else {
                "Execute"
              },
              style = "margin-left: 5px;",
              disabled = is_executing
            )
          ),
          # Show result if available
          if (!is.null(get_result)) {
            shiny::div(
              style = paste0(
                "margin-top: 8px; padding: 8px; border-radius: 4px; font-family: monospace; font-size: 0.85em; ",
                if (get_result$success) "background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724;" 
                else "background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24;"
              ),
              shiny::tags$pre(
                style = "margin: 0; white-space: pre-wrap; word-wrap: break-word;",
                get_result$output
              )
            )
          }
        ),
        shiny::div(
          style = "margin-bottom: 15px;",
          shiny::tags$strong("Use kernel:"),
          shiny::div(
            style = "display: flex; align-items: center; margin-top: 5px;",
            shiny::tags$code(
              style = "flex: 1; padding: 8px; background-color: white; border: 1px solid #ccc; border-radius: 4px; font-family: monospace;",
              use_cmd
            ),
            shiny::actionButton(
              "copy_use",
              "Copy",
              style = "margin-left: 5px;",
              onclick = paste0("navigator.clipboard.writeText('", use_cmd, "').then(() => alert('Command copied to clipboard!'))")
            ),
            shiny::actionButton(
              "execute_use",
              if (is_executing) {
                shiny::tagList(
                  shiny::tags$span(
                    style = "display: inline-block; width: 12px; height: 12px; border: 2px solid #ffffff; border-top: 2px solid transparent; border-radius: 50%; animation: spin 0.6s linear infinite; margin-right: 5px;",
                    shiny::tags$style(HTML("
                      @keyframes spin {
                        0% { transform: rotate(0deg); }
                        100% { transform: rotate(360deg); }
                      }
                    "))
                  ),
                  "Executing..."
                )
              } else {
                "Execute"
              },
              style = "margin-left: 5px;",
              disabled = is_executing
            )
          ),
          # Show result if available
          if (!is.null(use_result)) {
            shiny::div(
              style = paste0(
                "margin-top: 8px; padding: 8px; border-radius: 4px; font-family: monospace; font-size: 0.85em; ",
                if (use_result$success) "background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724;" 
                else "background-color: #f8d7da; border: 1px solid #f5c6cb; color: #721c24;"
              ),
              shiny::tags$pre(
                style = "margin: 0; white-space: pre-wrap; word-wrap: break-word;",
                use_result$output
              )
            )
          }
        )
      )
    })
    
    # Handle execute get button
    shiny::observeEvent(input$execute_get, {
      if (is.null(input$kernel_choice) || input$kernel_choice == "") {
        return()
      }
      
      parts <- strsplit(input$kernel_choice, "-", fixed = TRUE)[[1]]
      if (length(parts) < 2) {
        return()
      }
      
      version <- parts[length(parts)]
      name <- paste(parts[-length(parts)], collapse = "-")
      get_cmd <- paste0("icrn_manager kernels get R ", name, " ", version)
      
      result <- execute_command(get_cmd)
      get_command_result(result)
    })
    
    # Handle execute use button
    shiny::observeEvent(input$execute_use, {
      if (is.null(input$kernel_choice) || input$kernel_choice == "") {
        return()
      }
      
      parts <- strsplit(input$kernel_choice, "-", fixed = TRUE)[[1]]
      if (length(parts) < 2) {
        return()
      }
      
      version <- parts[length(parts)]
      name <- paste(parts[-length(parts)], collapse = "-")
      use_cmd <- paste0("icrn_manager kernels use R ", name, " ", version)
      
      result <- execute_command(use_cmd)
      use_command_result(result)
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