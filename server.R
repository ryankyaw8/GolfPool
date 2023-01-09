
library(tidyverse)
library(shiny)
library(readxl)
library(RMySQL)

df_sentry <- readRDS("df_sentry.rds")

source("pool_functions.R")

function(input, output, session){
  
  # Display Player Tiers 
  output$tiers <- render_gt(field_display(df_sentry))
  
  # "Submit Your Team" Button Action
  team_upload <- eventReactive(input$create_team, {team_create(input$team_name, input$tier1, input$tier2,
                                                                input$tier3, input$tier4, input$tier5, input$tier6)})
  
  # Display Team Details 
  output$test <- renderText(team_upload())
  
  # Display All Teams 
  output$teams <- renderDataTable(expr = team_display())
  
  # Display Leaderboard
  output$leaderboard <- renderReactable(expr = team_scores())
  
  # Display Tournament Leaderboard
  output$tournament <- renderDataTable(expr = tournament_leaderboard())

  
}