#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Load master data
  master_data <- reactive({
    wq_prepare_data("master_data")
  })

  # Update column choices based on loaded data
  observe({
    data <- master_data()
    numeric_cols <- names(data)[sapply(data, is.numeric)]

    # Filter response variables (those starting with "thr_")
    response_choices <- numeric_cols[grepl("^thr_", numeric_cols)]

    # Filter predictor variables (those containing "_lvl")
    predictor_choices <- numeric_cols[grepl("_lvl", numeric_cols)]

    updateSelectInput(
      session,
      "response_var",
      choices = response_choices
    )

    updateSelectInput(
      session,
      "predictor_vars",
      choices = predictor_choices
    )
  })

  # Reactive value to store the fitted model
  fitted_model <- eventReactive(input$run_model, {
    req(input$response_var, input$predictor_vars)

    data <- master_data()

    # Remove rows with NA in selected columns
    selected_cols <- c(input$response_var, input$predictor_vars)
    data_clean <- data[complete.cases(data[, selected_cols]), ]

    # Build formula
    if (input$include_intercept) {
      formula_str <- paste(
        input$response_var,
        "~",
        paste(input$predictor_vars, collapse = " + ")
      )
    } else {
      formula_str <- paste(
        input$response_var,
        "~ -1 +",
        paste(input$predictor_vars, collapse = " + ")
      )
    }

    # Fit model
    tryCatch(
      {
        stats::glm(
          as.formula(formula_str),
          data = data_clean,
          family = binomial(link = "logit")
        )
      },
      error = function(e) {
        showNotification(
          paste("Error fitting model:", e$message),
          type = "error",
          duration = NULL
        )
        NULL
      }
    )
  })

  # Model summary output
  output$model_summary <- renderPrint({
    req(fitted_model())
    summary(fitted_model())
  })

  # Coefficients table
  output$coefficients_table <- renderTable(
    {
      req(fitted_model())
      model <- fitted_model()
      coef_summary <- summary(model)$coefficients
      coef_df <- as.data.frame(coef_summary)
      coef_df$Variable <- rownames(coef_df)
      coef_df <- coef_df[, c("Variable", names(coef_df)[1:4])]
      coef_df
    },
    rownames = FALSE,
    digits = 4
  )

  # Diagnostic plots
  output$plot_residuals_fitted <- renderPlot({
    req(fitted_model())
    plot(fitted_model(), which = 1, main = "Residuals vs Fitted")
  })

  output$plot_qq <- renderPlot({
    req(fitted_model())
    plot(fitted_model(), which = 2, main = "Normal Q-Q")
  })

  output$plot_scale_location <- renderPlot({
    req(fitted_model())
    plot(fitted_model(), which = 3, main = "Scale-Location")
  })

  output$plot_residuals_leverage <- renderPlot({
    req(fitted_model())
    plot(fitted_model(), which = 5, main = "Residuals vs Leverage")
  })

  # Relationships plot
  output$plot_relationships <- renderPlot({
    req(fitted_model())
    req(input$response_var, input$predictor_vars)

    data <- master_data()
    model <- fitted_model()

    # Get model data (removes NAs)
    model_data <- model$model

    # Create plots for each predictor
    plot_list <- lapply(input$predictor_vars, function(pred) {
      # Create data frame with response, predictor, and fitted values (probabilities)
      plot_df <- data.frame(
        x = model_data[[pred]],
        y = model_data[[input$response_var]],
        fitted = fitted(model, type = "response")
      )

      # Sort by predictor for smooth curve
      plot_df <- plot_df[order(plot_df$x), ]

      # Create scatter plot with fitted logistic curve
      ggplot2::ggplot(plot_df, ggplot2::aes(x = x, y = y)) +
        ggplot2::geom_point(alpha = 0.5, color = "steelblue") +
        ggplot2::geom_line(ggplot2::aes(y = fitted), color = "red", linewidth = 1) +
        ggplot2::labs(
          x = pred,
          y = paste(input$response_var, "(Probability)"),
          title = paste(input$response_var, "vs", pred)
        ) +
        ggplot2::theme_minimal() +
        ggplot2::theme(
          plot.title = ggplot2::element_text(hjust = 0.5, face = "bold")
        )
    })

    # Combine plots using patchwork
    if (length(plot_list) == 1) {
      plot_list[[1]]
    } else {
      patchwork::wrap_plots(plot_list, ncol = 2)
    }
  })

  # Download handler
  output$download_results <- downloadHandler(
    filename = function() {
      paste0("model_results_", Sys.Date(), ".txt")
    },
    content = function(file) {
      req(fitted_model())
      sink(file)
      print(summary(fitted_model()))
      sink()
    }
  )
}
