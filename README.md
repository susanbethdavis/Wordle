## README for Wordle Data Cleaning Script

### Overview
This repository contains a script designed to clean Wordle data from a CSV file. The cleaned data will then be imported into R for further analysis.

### Contents
- `Wordle_Project.ipynb`: Jupyter Notebook containing the data cleaning script.
- `wordle_texts.csv`: Input CSV file with raw Wordle data.
- `filtered_wordle_scores_per_day.csv`: Output CSV file with cleaned Wordle data.

### Requirements
- Python 3.x
- pandas
- csv
- collections
- datetime
- requests
- bs4

### Script Workflow
1. **Import Libraries**: The script imports necessary libraries including pandas, csv, and datetime.
2. **Define File Paths**: Sets the input and output file paths.
3. **Initialize Data Structures**: Initializes data structures to store filtered data.
4. **Read and Filter Data**: Reads the input CSV file, filters messages containing specific keywords, and retains the last message of each day.
5. **Write Filtered Data**: Writes the filtered data to an output CSV file.
6. **Process Data with pandas**: Loads the output CSV into a pandas DataFrame, processes the date and time components, and reorganizes the columns.
7. **Save Modified Data**: Saves the cleaned and processed DataFrame to a new CSV file.

### Usage
1. Ensure all required libraries are installed.
2. Place the input CSV file (`wordle_texts.csv`) in the same directory as the script.
3. Run the Jupyter Notebook to execute the script.
4. The cleaned data will be saved to `cleaned_wordle_data.csv`.

### Next Steps
After cleaning the data using this script, import the cleaned CSV file into R for further analysis.

For any questions or issues, feel free to reach out!
