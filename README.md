# Twitter Sentiment Studio 
# Real-Time Mood Analytics  |  R Shiny + syuzhet NLP 
# Chandigarh University – Mini Project 2024-25 
  
## Project Structure 
  twitter-sentiment-studio/ 
  |-- app.R          <- Single-file Shiny app (UI + Server + Helpers) 
  |-- README.md 
  
## Step 1 – Install Packages  (run once in R console) 
  install.packages(c("shiny", "shinyjs", "syuzhet")) 
  
## Step 2 – Clone 
  git clone https://github.com/ayushixx/twitter-sentiment-studio.git 
  
## Step 3 – Run 
  library(shiny); runApp(".", launch.browser = TRUE) 
  
## Step 4 – Using the Dashboard 
  1. Click START   — tweets stream every 2 seconds 
  2. Click STOP    — pauses the stream (data retained) 
  3. Click RESET   — clears all data 
  
