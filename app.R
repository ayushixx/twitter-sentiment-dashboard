# ============================================
# REAL-TIME SENTIMENT DASHBOARD
# SIMPLE WORKING VERSION - NO ERRORS
# ============================================

library(shiny)
library(shinyjs)
library(syuzhet)

# Generate tweets
generate_tweet <- function() {
  tweets <- c(
    "I love this product! Amazing!",
    "This is terrible, worst experience",
    "Pretty good, not bad",
    "Feeling neutral about this",
    "Wow! Incredible work!",
    "Disappointed, waste of money",
    "Could be better",
    "I hate this so annoying",
    "Best day ever! So happy!",
    "This makes me angry"
  )
  return(sample(tweets, 1))
}

# Get sentiment score
get_score <- function(text) {
  score <- get_sentiment(text, method = "syuzhet")
  return(round(score, 2))
}

# Get sentiment label
get_label <- function(score) {
  if(score > 0.2) return("Positive")
  if(score < -0.2) return("Negative")
  return("Neutral")
}

# UI
ui <- fluidPage(
  useShinyjs(),
  
  tags$style(HTML("
    body { background: #faf8f5; font-family: Arial; }
    .header { text-align: center; padding: 30px; background: white; border-radius: 20px; margin-bottom: 20px; }
    .stats { display: flex; gap: 20px; margin-bottom: 20px; }
    .stat { background: white; padding: 20px; border-radius: 15px; text-align: center; flex: 1; }
    .stat h2 { margin: 10px 0; font-size: 2em; }
    .charts { display: flex; gap: 20px; margin-bottom: 20px; }
    .chart { background: white; padding: 20px; border-radius: 15px; flex: 1; }
    .feed { background: white; padding: 20px; border-radius: 15px; margin-bottom: 20px; }
    .buttons { text-align: center; margin-top: 20px; }
    button { padding: 10px 20px; margin: 0 10px; border: none; border-radius: 25px; cursor: pointer; font-weight: bold; }
    .btn-start { background: #4caf50; color: white; }
    .btn-stop { background: #f44336; color: white; }
    .btn-reset { background: #9e9e9e; color: white; }
    .tweet-row { border-bottom: 1px solid #eee; padding: 10px; }
    .positive { color: #4caf50; }
    .negative { color: #f44336; }
    .neutral { color: #9e9e9e; }
  ")),
  
  div(style = "max-width: 1200px; margin: 0 auto; padding: 20px;",
      div(class = "header",
          h1("Twitter Sentiment Studio"),
          p("Real-time mood analytics")
      ),
      
      div(class = "stats",
          div(class = "stat", h4("📝 Total Tweets"), h2(textOutput("total"))),
          div(class = "stat", h4("📊 Avg Score"), h2(textOutput("avg"))),
          div(class = "stat", h4("🎭 Mood"), h2(textOutput("mood"))),
          div(class = "stat", h4("⚡ Status"), h2(textOutput("status")))
      ),
      
      div(class = "charts",
          div(class = "chart", h4("🎯 Sentiment Gauge"), plotOutput("gauge", height = "150px")),
          div(class = "chart", h4("📈 Trend"), plotOutput("trend", height = "150px"))
      ),
      
      div(class = "feed",
          h4("🐦 Live Feed"),
          uiOutput("tweets_list")
      ),
      
      div(class = "buttons",
          actionButton("start", "▶ START", class = "btn-start"),
          actionButton("stop", "⏹ STOP", class = "btn-stop"),
          actionButton("reset", "🔄 RESET", class = "btn-reset")
      )
  )
)

# Server
server <- function(input, output, session) {
  
  # Store tweets
  tweet_data <- reactiveVal(data.frame(
    time = character(),
    text = character(),
    score = numeric(),
    stringsAsFactors = FALSE
  ))
  
  # Running status
  running <- reactiveVal(FALSE)
  
  # Add a tweet
  add_tweet <- function() {
    text <- generate_tweet()
    score <- get_score(text)
    new_row <- data.frame(
      time = format(Sys.time(), "%H:%M:%S"),
      text = text,
      score = score,
      stringsAsFactors = FALSE
    )
    
    current <- tweet_data()
    current <- rbind(current, new_row)
    
    # Keep last 30 tweets
    if(nrow(current) > 30) {
      current <- tail(current, 30)
    }
    
    tweet_data(current)
  }
  
  # Start streaming
  observeEvent(input$start, {
    running(TRUE)
    shinyjs::disable("start")
    shinyjs::enable("stop")
  })
  
  # Stop streaming
  observeEvent(input$stop, {
    running(FALSE)
    shinyjs::enable("start")
    shinyjs::disable("stop")
  })
  
  # Reset
  observeEvent(input$reset, {
    tweet_data(data.frame(time = character(), text = character(), score = numeric(), stringsAsFactors = FALSE))
    running(FALSE)
    shinyjs::enable("start")
    shinyjs::disable("stop")
  })
  
  # Auto-add tweets
  observe({
    invalidateLater(2000)
    if(running()) {
      isolate(add_tweet())
    }
  })
  
  # Outputs
  output$total <- renderText({ nrow(tweet_data()) })
  
  output$avg <- renderText({
    data <- tweet_data()
    if(nrow(data) == 0) return("0.00")
    sprintf("%.2f", mean(data$score))
  })
  
  output$mood <- renderText({
    data <- tweet_data()
    if(nrow(data) == 0) return("---")
    avg <- mean(data$score)
    if(avg > 0.2) return("Positive 😊")
    if(avg < -0.2) return("Negative 😔")
    return("Neutral 😐")
  })
  
  output$status <- renderText({
    if(running()) return("🟢 LIVE")
    return("⏸ PAUSED")
  })
  
  # Gauge plot
  output$gauge <- renderPlot({
    data <- tweet_data()
    avg <- if(nrow(data) > 0) mean(data$score) else 0
    
    par(bg = "white", mar = c(1, 1, 1, 1))
    plot(0, 0, type = "n", xlim = c(-1.2, 1.2), ylim = c(-1.2, 1.2), axes = FALSE)
    
    # Colored arc
    for(i in seq(-0.9, 0.9, length.out = 11)) {
      color <- if(i < -0.3) "#ffcdd2" else if(i < 0.3) "#fff9c4" else "#c8e6c9"
      lines(c(i, i*0.8), c(sqrt(1-i^2)*0.8, sqrt(1-(i*0.8)^2)*0.8), col = color, lwd = 4)
    }
    
    # Needle
    angle <- avg * pi/2
    arrows(0, 0, cos(angle)*0.7, sin(angle)*0.7, col = if(avg>0) "#4caf50" else "#f44336", lwd = 2)
    points(0, 0, pch = 19)
    
    text(0, -0.5, paste("Score:", round(avg, 2)), col = "#666", cex = 0.9)
  })
  
  # Trend plot
  output$trend <- renderPlot({
    data <- tweet_data()
    if(nrow(data) == 0) {
      plot(0, 0, type = "n", main = "No data yet", axes = FALSE)
      text(0, 0, "Click START to begin", col = "#999")
      return()
    }
    
    par(bg = "white", mar = c(2, 2, 1, 1))
    plot(1:nrow(data), data$score, type = "b", 
         xlab = "", ylab = "", ylim = c(-1, 1),
         col = "#4caf50", pch = 19)
    abline(h = 0, col = "#f44336", lty = 2)
    grid(col = "#eee")
  })
  
  # Tweet list
  output$tweets_list <- renderUI({
    data <- tweet_data()
    if(nrow(data) == 0) {
      return(div(class = "tweet-row", "✨ Click START to see tweets ✨"))
    }
    
    # Reverse to show newest first
    data <- data[rev(1:nrow(data)), ]
    
    tweet_divs <- list()
    for(i in 1:nrow(data)) {
      score_class <- if(data$score[i] > 0) "positive" else if(data$score[i] < 0) "negative" else "neutral"
      tweet_divs[[i]] <- div(class = "tweet-row",
                             span(data$time[i], style = "color: #999; margin-right: 15px;"),
                             span(data$text[i]),
                             span(class = score_class, style = "float: right;", paste("Score:", data$score[i]))
      )
    }
    
    do.call(tagList, tweet_divs)
  })
}

# Run
shinyApp(ui = ui, server = server)