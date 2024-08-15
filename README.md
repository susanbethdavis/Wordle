## README for Wordle Data Cleaning Script

**Author**: Susan Davis

### Repository Overview

- **`tidy_wordle` script**: focuses on reading text message data from CSV files, then cleaning and processing this data to prepare it for a suitable state for further analyses. 
- **Wordle Dictionary**: Contains all possible words that can be the word of the day in Wordle. Pulled from https://www.foregolfleague.com/wordlelist.htm
- **Raw Text Message Data**: The text messages dataset used in this project was not provided, as it contains not only Wordle text messages but also hundreds of personal text messages. If you have inquiries about specific information from these datasets, please contact me.
- **Cleaned Text Message Data**: named final_data, this is the data of only the wordle text messages after they have been cleaned. 
- **List of all Wordle answers so far**: [Wordle Answers](https://wordfinder.yourdictionary.com/wordle/answers/)
- **Final Texts Data Dictionary**: Data Dictionary for the cleaned messages dataset

### tidy_wordle Script Overview
#### Features
- **Data Import**: The script reads in text message data from two seperate CSV files.
- **Date Validation**: Custom functions ensure that dates are correctly formatted and valid.
- **Message Filtering**: The code identifies the last message of each day from specific senders.
- **Data Output**: The processed data is saved to new CSV files, summarizing the daily Wordle-related interactions.

### Contact
For any issues or inquiries, please contact Susan Davis at sedavis9@ncsu.edu.

