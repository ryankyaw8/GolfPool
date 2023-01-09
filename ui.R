
library(tidyverse)
library(shiny)
library(readxl)
library(RMySQL)

df_sentry <- readRDS("df_sentry.rds")

source("pool_functions.R")

ui <- navbarPage("Golf Pool Test",
                 
                 # tabPanel("Team Selection",
                 #          
                 #          sidebarLayout(
                 #            
                 #            sidebarPanel(gt_output(outputId = "tiers")),
                 #          
                 #            mainPanel(h1("Make Your Team Selections"),
                 #                      h5("Please submit your team once only. If you encounter
                 #                         any errors or issues, please contact Ryan."),
                 #                      textInput("team_name", "Enter Team Name"),
                 #                      selectInput("tier1", "Tier 1 Selection", choices = c(df_sentry$NAME[df_sentry$Tier == "Tier 1"])),
                 #                      selectInput("tier2", "Tier 2 Selection", choices = c(df_sentry$NAME[df_sentry$Tier == "Tier 2"])),
                 #                      selectInput("tier3", "Tier 3 Selection", choices = c(df_sentry$NAME[df_sentry$Tier == "Tier 3"])),
                 #                      selectInput("tier4", "Tier 4 Selection", choices = c(df_sentry$NAME[df_sentry$Tier == "Tier 4"])),
                 #                      selectInput("tier5", "Tier 5 Selection", choices = c(df_sentry$NAME[df_sentry$Tier == "Tier 5"])),
                 #                      selectInput("tier6", "Tier 6 Selection", choice = c(df_sentry$NAME[df_sentry$Tier == "Tier 6"])),
                 #                      br(),
                 #                      actionButton("create_team", "Submit Your Team"),
                 #                      br(),
                 #                      textOutput(outputId = "test", container = tags$h3)))),
                          
                      
                 
                 tabPanel("Teams",
                          mainPanel(h1("Teams"),
                                    dataTableOutput(outputId = "teams"),
                                    br(),
                                    h4("To refresh the team list, please refresh your browser")))
                 ,

                 tabPanel("Results",
                          mainPanel(h1("Team Leaderboard"),
                                    reactableOutput(outputId = "leaderboard"))),
                 
                 tabPanel("Tournament Leaderboard",
                          mainPanel(h1("Tournament Leaderboard"),
                                    dataTableOutput(outputId = "tournament")))
                 
                 )

