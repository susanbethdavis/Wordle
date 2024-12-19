
library(shiny)
library(ggplot2)
library(dplyr)
library(lubridate)
library(plotly)
library(knitr)
library(shinyBS)
library(rsconnect)

server <- function(input, output, session) {
  
  # Dynamically populate checkboxes and select inputs
  observe({
    # Filter the player list to exclude "National Average"
    player_choices <- unique(df$Player)
    player_choices <- player_choices[!player_choices %in% "National Average"]  # Exclude "National Average"
    
    # Update UI elements with filtered choices
    updateCheckboxGroupInput(session, "selected_players_density", choices = player_choices)
    updateCheckboxGroupInput(session, "selected_players_leaderboard", choices = player_choices)
    updateSelectInput(session, "selected_player_board", choices = player_choices)  # Player Board Dropdown
    updateSelectInput(session, "time_player", choices = player_choices)
    updateSelectInput(session, "selected_individual_player", choices = player_choices)  # Individual Player Dropdown for new feature
  })

  
  # Load and preprocess the data
  df <- readRDS("df_ozark.rds")
  

  # Bar Plot
  # Bar Chart for Discrete Variable
  output$density_plot <- renderPlotly({
    req(input$selected_players_density)  # Ensure at least one player is selected
    
    # Filter data for the selected players
    filtered_df <- df %>%
      filter(Player %in% input$selected_players_density)
    
    # Calculate proportions of scores for each player
    normalized_df <- filtered_df %>%
      group_by(Player, Score) %>%
      summarise(Count = n(), .groups = "drop") %>%
      group_by(Player) %>%
      mutate(
        Proportion = Count / sum(Count),  # Normalize counts to proportions
        TotalDaysPlayed = sum(Count)      # Total number of days played by the player
      )
    
    # Create the ggplot object
    p <- ggplot(normalized_df, aes(x = Score, y = Proportion, fill = Player, text = paste(
      "Player:", Player,
      "<br>Total Days Played:", TotalDaysPlayed,
      "<br>Score Count:", Count
    ))) +
      geom_bar(stat = "identity", position = "dodge") +  # Dodge for side-by-side comparison
      labs(
        title = "Score Proportions Comparison",
        x = "Score",
        y = "Individual Players Proportion"
      ) +
      scale_y_continuous(labels = scales::percent) +  # Show y-axis as percentages
      theme_minimal() +
      theme(
        legend.title = element_blank(),
        axis.text = element_text(size = 12, color = "black"),   # Larger and darker axis labels
        axis.title = element_text(size = 14, face = "bold"),    # Larger and bold axis titles
        axis.ticks = element_line(size = 0.75),                # Make axis ticks thicker
        axis.ticks.length = unit(0.25, "cm"),                  # Extend tick length
        panel.grid.minor = element_blank()                     # Remove minor grid lines for clarity
      )
    
    # Convert ggplot to plotly for interactive tooltips
    ggplotly(p, tooltip = "text")
  })
  

  # Leader Board
  leaderboard <- reactive({
    req(input$selected_players_leaderboard)
    
    last_date <- as.Date("2024-12-18")
    
    assign_points_with_time <- function(data, selected_players, time_range = "all") {
      # Step 1: Filter for specific players
      filtered_data <- data %>%
        filter(Player %in% selected_players)
      
      # Step 2: Filter by time range
      if (time_range != "all") {
        date_cutoff <- case_when(
          time_range == "1 year" ~ last_date - years(1),
          time_range == "6 months" ~ last_date - months(6),
          time_range == "3 months" ~ last_date - months(3),
          time_range == "1 month" ~ last_date - months(1),
          time_range == "1 week" ~ last_date - days(7),
          TRUE ~ last_date # Default for unexpected input
        )
        filtered_data <- filtered_data %>%
          filter(`Message Date` >= date_cutoff)
      }
      
      # Step 3: Check if all selected players played on each date
      dates_with_all_players <- filtered_data %>%
        group_by(`Message Date`) %>%
        summarise(players_played = n_distinct(Player), .groups = "drop") %>%
        filter(players_played == length(selected_players)) %>%
        pull(`Message Date`)
      
      # Step 4: Filter data to include only dates where all players played
      valid_data <- filtered_data %>%
        filter(`Message Date` %in% dates_with_all_players)
      
      # Step 5: Assign points based on the lowest score for each valid date
      points_data <- valid_data %>%
        group_by(`Message Date`) %>%
        mutate(min_score = min(Score, na.rm = TRUE)) %>%  # Minimum score for the day
        filter(Score == min_score) %>%  # Players with the lowest score
        group_by(`Message Date`, Player) %>%
        summarise(points = 1, .groups = "drop")  # Each tied player gets 1 point
      
      # Step 6: Aggregate points by player
      total_points <- points_data %>%
        group_by(Player) %>%
        summarise(points = sum(points), .groups = "drop") %>%
        arrange(desc(points))  # Rank players by points
      
      return(total_points)
    }
    
    # Example usage
    # Assuming `df` is your input data with columns: Player, `Message Date`, and Score
    selected_players <- c("Tom", "Grant")
    time_range <- "1 week" # Options: "all", "1 year", "6 months", "3 months", "1 month", "1 week"
    player_points <- assign_points_with_time(df, selected_players, time_range)
    
    
    
    # Call the function to assign points over time
    leaderboard_data <- assign_points_with_time(df, input$selected_players_leaderboard, input$time_range)
    
    # Rename "Points" column to "Days on Top"
    leaderboard_data <- leaderboard_data %>%
      rename("Days on Top" = points)
    
    return(leaderboard_data)
  })
  
  # Leaderboard Table Output
  output$leaderboard_table <- renderTable({
    # Ensure at least two players are selected
    if (length(input$selected_players_leaderboard) < 2) {
      return(NULL)  # Return nothing if fewer than two players are selected
    }
    
    # Generate the leaderboard table
    leaderboard_data <- leaderboard()
    
    # Dynamically rename the second column to "Days on Top"
    colnames(leaderboard_data)[2] <- "Days on Top"
    
    # Return the updated leaderboard table
    return(leaderboard_data)
  })
  
  # Points Explanation Section
  output$points_explanation <- renderUI({
    HTML("
  <p><strong>Table Goal:</strong> Compare the performance of selected players over a chosen time period.</p>

  <p>Players earn points based on how consistently they outperform others. Points reflect the number of days a player achieved the <strong>best performance</strong> among all selected players.</p>

  <p><strong>How Points Are Awarded:</strong></p>
  <ul>
    <li><strong>1 point</strong> is awarded to a player for having the <strong>lowest score</strong> on a given day.</li>
    <li>In case of a tie, all tied players receive <strong>1 point</strong>.</li>
    <li>Points are only awarded on days when <strong>all selected players</strong> participated.</li>
  </ul>

  <p>This system ensures a fair comparison by focusing only on shared competition days.</p>
  ")
  })
  
  # Games Together Section
  games_together <- reactive({
    req(input$selected_players_leaderboard)
    
    # Check for minimum two players
    if (length(input$selected_players_leaderboard) < 2) {
      return(tags$div(style = "color: red; font-weight: bold;", 
                      "Please select at least two players."))
    }
    
    # Dynamically define date range based on selected time
    last_date <- max(df$`Message Date`, na.rm = TRUE)
    date_range <- if (input$time_range == "1 week") {
      seq.Date(last_date - days(6), last_date, by = "day")
    } else if (input$time_range == "1 month") {
      seq.Date(last_date - months(1) + days(1), last_date, by = "day")
    } else if (input$time_range == "3 months") {
      seq.Date(last_date - months(3) + days(1), last_date, by = "day")
    } else if (input$time_range == "6 months") {
      seq.Date(last_date - months(6) + days(1), last_date, by = "day")
    } else if (input$time_range == "1 year") {
      seq.Date(last_date - years(1) + days(1), last_date, by = "day")
    } else {
      seq.Date(min(df$`Message Date`), last_date, by = "day")
    }
    
    # Filter data for selected players and time range
    filtered_data <- df %>%
      filter(Player %in% input$selected_players_leaderboard,
             `Message Date` >= min(date_range),
             `Message Date` <= max(date_range)) %>%
      distinct(Player, `Message Date`)
    
    # Identify shared competition dates
    dates_with_all_players <- filtered_data %>%
      group_by(`Message Date`) %>%
      summarise(players_played = n_distinct(Player), .groups = "drop") %>%
      filter(players_played == length(input$selected_players_leaderboard)) %>%
      pull(`Message Date`)
    
    # Calculate the possible and actual days
    possible_days <- length(date_range)
    actual_days <- length(dates_with_all_players)
    
    # Display results
    return(HTML(paste0(
      "<p><strong>Games Played Together:</strong> The selected players played together on <strong>", 
      actual_days, 
      "</strong> out of <strong>", 
      possible_days, 
      "</strong> possible days in the selected time range.</p>"
    )))
  })
  
  output$games_together <- renderUI({
    games_together()
  })
  
  
  
  # Updated Player Board Logic: Unique Words with Correct Dates
  player_board_data <- reactive({
    req(input$selected_player_board, input$selected_score)
    
    df %>%
      filter(Player == input$selected_player_board, Score == input$selected_score, Player != "National Average") %>%
      distinct(wordle_answers, .keep_all = TRUE) %>%  # Keep only unique words
      mutate(`Message Date` = as.Date(`Message Date`)) %>%  # Explicitly ensure Date type
      arrange(`Message Date`) %>%  # Sort by date
      select(`Message Date`, Word = wordle_answers)
  })
  
  output$player_board <- renderTable({
    data <- player_board_data()
    data$`Message Date` <- as.character(data$`Message Date`)  # Force display as character for table
    data  # Pass the clean data to renderTable
  }, rownames = TRUE)
  
  # Starter Word Display (Place it right after player_board logic)
  output$starter_word_display <- renderUI({
    req(input$selected_player_board)  # Ensure a player is selected
    
    # Extract the starter word for the selected player
    if (input$selected_player_board == "Ruth") {
      starter_word_display <- "Starter Word: Grant"
    } else if (input$selected_player_board == "Tuck") {
      starter_word_display <- "Starter Word: Audio"
    } else {
      starter_word <- df %>%
        filter(Player == input$selected_player_board) %>%
        pull(Start_Words) %>%
        unique() 
      
      # Determine the display message
      starter_word_display <- if (is.na(starter_word) || length(starter_word) == 0) {
        "Starter word varies"
      } else {
        paste("Starter Word:", starter_word)
      }
    }
    
    # Create UI output
    tags$div(
      style = "font-size: 16px; font-style: italic; color: #555; margin-top: 10px;",
      starter_word_display
    )
  })
  

  # Scores Over Time
  output$scores_time_plot <- renderPlotly({
    req(input$time_player)
    
    # Filter data for the selected player and from the specified date onwards
    time_data <- df %>%
      filter(Player == input$time_player, `Message Date` >= as.Date("2023-09-20"))
    
    # Create the plotly object
    p <- ggplot(time_data, aes(x = `Message Date`, y = Score)) +
      geom_line(color = "blue") +
      geom_point(aes(text = paste("Word:", wordle_answers, "<br>Date:", `Message Date`)), color = "deeppink") +
      labs(title = paste("Scores Over Time for", input$time_player),
           x = "Date",
           y = "Score") +
      theme(
        axis.text = element_text(size = 12, color = "black"),   # Larger and darker axis labels
        axis.title = element_text(size = 14, face = "bold"),    # Larger and bold axis titles
        axis.ticks = element_line(size = 0.75),                # Make axis ticks thicker
        axis.ticks.length = unit(0.25, "cm"),                  # Extend tick length
        panel.grid.minor = element_blank()                     # Remove minor grid lines for clarity
      )
    
    # Convert ggplot to plotly for interactivity
    ggplotly(p, tooltip = "text")
  })
  
  # Group vs National Average
  # Reactive calculation for percentage of time group is the same or better than the national average
  group_vs_national_stats <- reactive({
    req(input$analysis_group)
    
    # Filter data based on the selected group
    if (input$analysis_group == "individual") {
      req(input$selected_individual_player)
      group_data <- df %>%
        filter(Player == input$selected_individual_player)
    } else if (input$analysis_group == "hard_mode") {
      group_data <- df %>%
        filter(Player != "National Average", mode == "hard")
    } else {
      group_data <- df %>%
        filter(Player != "National Average")
    }
    
    # Ensure `Message Date` is a Date and filter by date range
    group_data <- group_data %>%
      mutate(`Message Date` = as.Date(`Message Date`)) %>%
      filter(`Message Date` >= as.Date("2024-01-01"))
    
    # Calculate daily averages for the group
    daily_averages <- group_data %>%
      group_by(`Message Date`) %>%
      summarise(
        group_avg = mean(Score, na.rm = TRUE),
        num_players = n_distinct(Player),
        .groups = "drop"
      )
    
    # Aggregate `df` for National Average (one row per date)
    national_avg_data <- df %>%
      filter(Player == "National Average") %>%
      group_by(`Message Date`) %>%
      summarise(national_avg = mean(Score, na.rm = TRUE), .groups = "drop")
    
    # Aggregate `df` for Wordle Answers (one row per date)
    wordle_answers_data <- df %>%
      group_by(`Message Date`) %>%
      summarise(
        wordle_answers = paste(unique(wordle_answers), collapse = ", "),
        .groups = "drop"
      )
    
    # Perform left joins to combine data
    daily_averages <- daily_averages %>%
      left_join(national_avg_data, by = "Message Date") %>%
      left_join(wordle_answers_data, by = "Message Date") %>%
      mutate(difference = group_avg - national_avg) %>%
      arrange(`Message Date`) %>%
      filter(!is.na(difference)) %>%
      distinct()
    
    # Calculate statistics
    total_days <- nrow(daily_averages)
    better_or_equal_days <- sum(daily_averages$difference <= 0)
    percentage_better <- if (total_days > 0) (better_or_equal_days / total_days) * 100 else 0
    
    list(
      total_days = total_days,
      better_or_equal_days = better_or_equal_days,
      percentage_better = round(percentage_better, 2),
      daily_averages = daily_averages  # Pass daily averages for plotting
    )
  })
  
  
  output$group_vs_national_plot <- renderPlotly({
    stats <- group_vs_national_stats()
    daily_averages <- stats$daily_averages
    
    # Create ggplot with text aesthetic for hover
    p <- ggplot(daily_averages, aes(x = `Message Date`, y = difference)) +
      geom_line(color = "blue") +
      geom_point(aes(
        text = paste(
          "Date:", `Message Date`,
          "<br>Word:", wordle_answers, 
          "<br>Number Players:", num_players,
          "<br>Group Avg:", round(group_avg, 2),
          "<br>National Avg:", round(national_avg, 2),
          "<br>Difference:", round(difference, 2)
        )
      ), color = "deeppink") +
      geom_hline(yintercept = 0, color = "black", linetype = "dashed") +
      labs(
        title = "Difference Between Group and National Average Scores Over Time",
        x = "Date",
        y = "Score Difference"
      ) +
      theme_minimal() +
      theme(
        axis.text = element_text(size = 12, color = "black"),
        axis.title = element_text(size = 14, face = "bold"),
        panel.grid.minor = element_blank()
      ) 
    
    # Convert ggplot to plotly and enable hover text
    ggplotly(p, tooltip = "text") })
  
  output$percent_better_same <- renderUI({
    stats <- group_vs_national_stats()
    
    HTML(paste0(
  "<p><b><i>Performance summary:</i></b></p>",
  "<p>Total days compared: ", stats$total_days, "</p>",
  "<p>Days the group scored the same or better than the national average: ", stats$better_or_equal_days, "</p>",
  "<p>Percentage of days the group scored the same or better than the national average: ", stats$percentage_better, "%</p>"
))

    
    
  })
  
}
