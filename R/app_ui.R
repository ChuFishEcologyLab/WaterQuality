#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    golem_add_external_resources(),
    fluidPage(
      titlePanel("Water Quality Logistic Regression Explorer"),

      sidebarLayout(
        sidebarPanel(
          width = 3,
          h4("Model Specification"),

          selectInput(
            "response_var",
            "Response Variable (Y):",
            choices = NULL
          ),

          selectInput(
            "predictor_vars",
            "Predictor Variables (X):",
            choices = NULL,
            multiple = TRUE
          ),

          checkboxInput(
            "include_intercept",
            "Include Intercept",
            value = TRUE
          ),

          actionButton(
            "run_model",
            "Run Logistic Regression",
            class = "btn-primary",
            width = "100%"
          ),

          hr(),

          downloadButton(
            "download_results",
            "Download Results",
            width = "100%"
          )
        ),

        mainPanel(
          width = 9,
          tabsetPanel(
            tabPanel(
              "Model Summary",
              verbatimTextOutput("model_summary")
            ),
            tabPanel(
              "Coefficients",
              tableOutput("coefficients_table")
            ),
            tabPanel(
              "Relationships",
              plotOutput("plot_relationships", height = "600px")
            ),
            tabPanel(
              "Diagnostic Plots",
              fluidRow(
                column(6, plotOutput("plot_residuals_fitted")),
                column(6, plotOutput("plot_qq"))
              ),
              fluidRow(
                column(6, plotOutput("plot_scale_location")),
                column(6, plotOutput("plot_residuals_leverage"))
              )
            )
          )
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "WaterQuality"
    )
  )
}
