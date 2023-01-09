
library(tidyverse)
library(shiny)
library(readxl)
library(RMySQL)
library(gt)
library(rvest)
library(reactable)
library(janitor)

df_sentry <- readRDS("df_sentry.rds")

field_display <- function(player_tier_df){
  
  tiers_display <- player_tier_df %>%
    gt() %>%
    tab_header(title = md("**2023 Sentry TOC Tier List**")) %>%
    cols_hide(columns = c(Tier)) %>%
    cols_label(NAME = md("**Player**"),
               RANKING = md("**OWGR**")) %>%
    tab_row_group(label = md("**Tier 6**"),
                  rows = Tier == "Tier 6") %>%
    tab_row_group(label = md("**Tier 5**"),
                  rows = Tier == "Tier 5") %>%
    tab_row_group(label = md("**Tier 4**"),
                  rows = Tier == "Tier 4") %>%
    tab_row_group(label = md("**Tier 3**"),
                  rows = Tier == "Tier 3") %>%
    tab_row_group(label = md("**Tier 2**"),
                  rows = Tier == "Tier 2") %>%
    tab_row_group(label = md("**Tier 1**"),
                  rows = Tier == "Tier 1")
    
  
  return(tiers_display)

}



team_create <- function(team_name, tier1, tier2, tier3, tier4, tier5, tier6){
  
  mydb <- dbConnect(RMySQL::MySQL(),
                    host = "rk-first-mysql-cluster-do-user-13028418-0.b.db.ondigitalocean.com",
                    dbname = "defaultdb",
                    user = "doadmin",
                    password = "AVNS_pmapXHtmecypq-48A2U",
                    port = 25060)
  
  query <- paste0("INSERT INTO pool_teams VALUES('",
                  team_name,
                  "', '",
                  tier1,
                  "', '",
                  tier2,
                  "', '",
                  tier3,
                  "', '",
                  tier4,
                  "', '",
                  tier5,
                  "', '",
                  tier6,
                  "')")
  
  add_row <- dbSendQuery(mydb, query)
  
  dbDisconnect(mydb)
  
  text <- paste0(team_name, " is: ", tier1, ", ", tier2, ", ", tier3, ", ", tier4, ", ", tier5,
                 ", ", tier6)
  
  return(text)
  
  
  
}



team_display <- function(){
  
  mydb <- dbConnect(RMySQL::MySQL(),
                    host = "rk-first-mysql-cluster-do-user-13028418-0.b.db.ondigitalocean.com",
                    dbname = "defaultdb",
                    user = "doadmin",
                    password = "AVNS_pmapXHtmecypq-48A2U",
                    port = 25060)
  
  current <- fetch(dbSendQuery(mydb, "SELECT * FROM pool_teams"))
  
  dbDisconnect(mydb)
  
  colnames(current) <- c("Team Name", "Tier1", "Tier2", "Tier3", "Tier4", "Tier5", "Tier6")
  
  return(current)
  
}

tournament_leaderboard <- function(){
  
  html <- read_html("https://www.espn.com/golf/leaderboard")
  table <- html %>%
    html_table(fill = TRUE)
  
  leaderboard <- table[[1]]
  
  leaderboard <- leaderboard[, 2:9]
    
  return(leaderboard)
  
}

# During Round Live Team Scores Fcn

# team_scores <- function(){
# 
#   html <- read_html("https://www.espn.com/golf/leaderboard")
#   table <- html %>%
#     html_table(fill = TRUE)
# 
#   leaderboard <- table[[1]]
# 
#   leaderboard <- leaderboard[, c(2, 4:12)]
# 
#   mydb <- dbConnect(RMySQL::MySQL(),
#                     host = "rk-first-mysql-cluster-do-user-13028418-0.b.db.ondigitalocean.com",
#                     dbname = "defaultdb",
#                     user = "doadmin",
#                     password = "AVNS_pmapXHtmecypq-48A2U",
#                     port = 25060)
# 
#   current <- fetch(dbSendQuery(mydb, "SELECT * FROM pool_teams"))
# 
#   dbDisconnect(mydb)
#   
#   current_t <- data.frame(t(current))
#   current_t <- row_to_names(current_t, row_number = 1)
# 
#   team_leaderboard <- data.frame(Team = c(), Score = c())
# 
#   for(i in 1:nrow(current)){
# 
#     team <- c()
#     for(j in 2:6){
#       team <- append(team, current[i, j])
#     }
# 
#     team_scores <- data.frame(team)
#     colnames(team_scores) <- c("PLAYER")
# 
#     team_scores <- team_scores %>%
#       left_join(leaderboard, by = "PLAYER")
# 
#     team_scores$TODAY[team_scores$TODAY == "-"] <- 0
#     team_scores$TODAY[team_scores$TODAY == "E"] <- 0
#     team_scores$TODAY <- as.numeric(team_scores$TODAY)
#     
#     team_scores$R1[team_scores$R1 == "--"] <- 100
#     team_scores$R2[team_scores$R2 == "--"] <- 100
#     team_scores$R3[team_scores$R3 == "--"] <- 100
#     # team_scores$R4[team_scores$R4 == "--"] <- NA
# 
#     team_scores$R1 <- as.numeric(team_scores$R1) - 73
#     team_scores$R2 <- as.numeric(team_scores$R2) - 73
#     team_scores$R3 <- as.numeric(team_scores$R3) - 73
#     # team_scores$R4 <- as.numeric(team_scores$R4) - 73
# 
#     team_score <- sum(team_scores$R1[order(team_scores$R1)][1:4])
#     team_score <- team_score + sum(team_scores$R2[order(team_scores$R2)][1:4])
#     team_score <- team_score + sum(team_scores$R3[order(team_scores$R3)][1:4])
#     # team_score <- team_score + sum(team_scores$R4[order(team_scores$R4)][1:4])
# 
#     team_score <- team_score + sum(team_scores$TODAY[order(team_scores$TODAY)][1:4]) 
# 
#     team_leaderboard_to_replace <- data.frame(Team = c(current[i, 1]), Score = c(team_score))
# 
#     team_leaderboard <- rbind(team_leaderboard, team_leaderboard_to_replace)
# 
# 
#   }
# 
#   team_leaderboard <- team_leaderboard[order(team_leaderboard$Score), ]
#   
#   
#   
#   detail_leaderboard <- reactable(team_leaderboard, details = function(index){
#     
#     team_players <- current_t[[team_leaderboard$Team[index]]]
#     
#     to_display <- leaderboard[leaderboard$PLAYER %in% team_players, ]
#     
#     htmltools::div(style = "padding: 1rem",
#                    reactable(to_display, outlined = TRUE))
#     
#   })
# 
#   return(detail_leaderboard)
# 
# 
# }


# Post Round Team Scores Fcn 

team_scores <- function(){

  html <- read_html("https://www.espn.com/golf/leaderboard")
  table <- html %>%
    html_table(fill = TRUE)

  leaderboard <- table[[1]]

  leaderboard <- leaderboard[, c(2:9)]

  mydb <- dbConnect(RMySQL::MySQL(),
                    host = "rk-first-mysql-cluster-do-user-13028418-0.b.db.ondigitalocean.com",
                    dbname = "defaultdb",
                    user = "doadmin",
                    password = "AVNS_pmapXHtmecypq-48A2U",
                    port = 25060)

  current <- fetch(dbSendQuery(mydb, "SELECT * FROM pool_teams"))

  dbDisconnect(mydb)
  
  current_t <- data.frame(t(current))
  current_t <- row_to_names(current_t, row_number = 1)

  team_leaderboard <- data.frame(Team = c(), Score = c())

  for(i in 1:nrow(current)){

    team <- c()
    for(j in 2:7){
      team <- append(team, current[i, j])
    }

    team_scores <- data.frame(team)
    colnames(team_scores) <- "PLAYER"
    team_scores <- team_scores %>%
      left_join(leaderboard, by = "PLAYER")

    team_scores$R1[team_scores$R1 == "--"] <- 100
    team_scores$R2[team_scores$R2 == "--"] <- 100
    team_scores$R3[team_scores$R3 == "--"] <- 100
    team_scores$R4[team_scores$R4 == "--"] <- NA

    team_scores$R1 <- as.numeric(team_scores$R1) - 73
    team_scores$R2 <- as.numeric(team_scores$R2) - 73
    team_scores$R3 <- as.numeric(team_scores$R3) - 73
    team_scores$R4 <- as.numeric(team_scores$R4) - 73

    team_score <- sum(team_scores$R1[order(team_scores$R1)][1:4])
    team_score <- team_score + sum(team_scores$R2[order(team_scores$R2)][1:4])
    team_score <- team_score + sum(team_scores$R3[order(team_scores$R3)][1:4])
    team_score <- team_score + sum(team_scores$R4[order(team_scores$R4)][1:4])

    team_leaderboard_to_replace <- data.frame(Team = c(current[i, 1]), Score = c(team_score))

    team_leaderboard <- rbind(team_leaderboard, team_leaderboard_to_replace)

  }

  team_leaderboard <- team_leaderboard[order(team_leaderboard$Score), ]
  
  detail_leaderboard <- reactable(team_leaderboard, details = function(index){
    
    team_players <- current_t[[team_leaderboard$Team[index]]]
    
    to_display <- leaderboard[leaderboard$PLAYER %in% team_players, ]
    
    htmltools::div(style = "padding: 1rem",
                   reactable(to_display, outlined = TRUE))
    
  })
  

  return(detail_leaderboard)


}








