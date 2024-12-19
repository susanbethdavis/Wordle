library(plotly)
ui <- fluidPage(
  titlePanel("Wordle Dashboard"),
  
  fluidRow(
    column(2, # Smaller sidebar for widgets
           wellPanel(
             # Conditional panel for Bar Chart widgets
             conditionalPanel(
               condition = "input.tabs == 'Bar Chart'",
               checkboxGroupInput(
                 inputId = "selected_players_density", 
                 label = "Select Players to Compare:",
                 choices = NULL
               ),
               p(HTML("Select players to compare their score distributions.<br><br>
        <b>WARNING:</b> Not all players have played a similar number of games. Hover over distributions to see games played."))
             ),
             
             # Conditional panel for Leader Board
             conditionalPanel(
               condition = "input.tabs == 'Leader Board'",
               checkboxGroupInput(
                 inputId = "selected_players_leaderboard", 
                 label = "Select Players to Compare:",
                 choices = NULL
               ),
               selectInput("time_range", 
                           "Select Time Range:",
                           choices = c("All" = "all",
                                       "1 Year" = "1 year",
                                       "6 Months" = "6 months",
                                       "3 Months" = "3 months",
                                       "1 Month" = "1 month",
                                       "1 Week" = "1 week"),
                           selected = "all")
             ),
             
             # Updated Conditional panel for Player Board
             conditionalPanel(
               condition = "input.tabs == 'Player Board'",
               selectInput(
                 inputId = "selected_player_board",
                 label = "Select a Player:",
                 choices = NULL
               ),
               sliderInput(
                 inputId = "selected_score",
                 label = "Select a Score:",
                 min = 1, max = 7, value = 1, step = 1
               ),
               uiOutput("starter_word_display")  # Moved here to be under the widgets
             ),
             
             # Conditional panel for Scores Over Time
             conditionalPanel(
               condition = "input.tabs == 'Scores Over Time'",
               selectInput(
                 inputId = "time_player",
                 label = "Select a Player:",
                 choices = NULL
               )
             ),
             
             # Conditional panel for Group vs National Average
             conditionalPanel(
               condition = "input.tabs == 'Group vs National Average'",
               radioButtons(
                 inputId = "analysis_group",
                 label = "Select Analysis Group:",
                 choices = c(
                   "Whole Group" = "whole_group",
                   "Hard Mode Players Only" = "hard_mode",
                   "Individual Player" = "individual"
                 ),
                 selected = "whole_group"
               ),
               selectInput(
                 inputId = "selected_individual_player",
                 label = "Select Player (for Individual Analysis):",
                 choices = NULL
               )
             )
           )
    ),
    
    column(10, # Main panel for wider graphs
           tabsetPanel(
             id = "tabs",
             tabPanel("Leader Board", 
                      tableOutput("leaderboard_table"),
                      htmlOutput("games_together"),
                      htmlOutput("points_explanation")),
             
             tabPanel("Player Board", 
                      tableOutput("player_board")  # Table remains in the main display area
             ),
             tabPanel("Bar Chart", 
                      plotlyOutput("density_plot", height = "600px")),
             
             tabPanel("Scores Over Time", 
                      plotlyOutput("scores_time_plot", height = "600px", width = "100%")),
             
             tabPanel("Group vs National Average", 
                      fluidRow(
                        column(3, 
                               uiOutput("percent_better_same")  # Display percentage info
                        ),
                        column(9, 
                               plotlyOutput("group_vs_national_plot", height = "600px", width = "100%"))
                      )  # Close the fluidRow
             )  # Close the tabPanel
           )  # Close the tabsetPanel
    )  # Close the column
  )  # Close the fluidRow
)  # Close the fluidPage
