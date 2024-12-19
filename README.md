## README for Wordle Data Cleaning Script

**Author**: Susan Davis

**R Shiny Live Application**: https://susanbethdavis.shinyapps.io/Ozark/

### Repository Overview

- **`tidy_wordle` script**: focuses on reading text message data from CSV files, then cleaning and processing this data to prepare it for a suitable state for further analyses. 
- **Wordle Dictionary**: Contains all possible words that can be the word of the day in Wordle. Pulled from https://www.foregolfleague.com/wordlelist.htm
- **Raw Text Message Data**: The text messages dataset used in this project was not provided, as it contains not only Wordle text messages but also hundreds of personal text messages. If you have inquiries about specific information from these datasets, please contact me.
- **Cleaned Text Message Data**: named df_ozark, this is the data of only the wordle text messages after they have been cleaned. Players have been renamed to Ozark characters to protect their privacy. 
- **List of all Wordle answers so far**: [Wordle Answers](https://wordfinder.yourdictionary.com/wordle/answers/)
- **Data Dictionary**: Data Dictionary for the cleaned messages dataset

### tidy_wordle Script Overview
#### Features
- **Data Import**: The script reads in text message data from two seperate CSV files.
- **Date Validation**: Custom functions ensure that dates are correctly formatted and valid.
- **Message Filtering**: The code identifies the last message of each day from specific senders.
- **Data Output**: The processed data is saved to new CSV files, summarizing the daily Wordle-related interactions.

### Shiny Dashboard Overview
- **Server Script**:The server script processes the cleaned Wordle data reactively. It dynamically filters, aggregates, and visualizes data based on user input. Key components include rendering interactive plots with plotly, generating leaderboards with custom point calculations, and providing summaries such as "Days on Top" for players. 
- **UI Script**:The UI script defines the layout and structure of the dashboard using shiny. It incorporates dropdowns, sliders, and checkboxes for interactive filtering. Tabs organize the content into sections such as Leaderboard, Player Board, and Scores Over Time. 
- **Shiny Apps io**:The dashboard is hosted on Shiny Apps.io, enabling easy sharing and accessibility. The app leverages the platform's capabilities to handle user interactions and render visualizations in real time.

### Contact
For any issues or inquiries, please contact Susan Davis at sedavis9@ncsu.edu.

