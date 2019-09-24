library(tidyverse)
library(janitor)
library(summarytools)

# run step 01 to download new version
# source("01_load_impeach.R")

# OR

# load saved file from previous step 01
impeachdata <- readRDS("processed_data/impeachdata.rds")


  
# we'll remove Pelosi since the speaker doesn't really cosponsor bills
#that will give us 234 total dems
# impeachdata <- impeachdata %>% 
#   filter(id != "P000197")


#### BRING IN THE CONGRESSIONAL DISTRICT PROFILE DATA #### -----------
workingtable <- readRDS("processed_data/workingtable.rds")

impeachdata <- impeachdata %>% 
  rename(GEOID = geoid)

#join
working_joined <- inner_join(impeachdata, workingtable, by = "GEOID")

#add flag columns for margin categorization
working_joined <- working_joined %>% 
  mutate(
    margin_flag = case_when(
      live_margin <= 5 ~ "5_points_or_less", 
      live_margin > 5 ~ "more_than_5_points", 
      TRUE ~ "more_than_5_points" #note there are four disticts where to Dems ran against each other; captured here
    )
  ) 

working_joined %>% 
  filter(margin_flag == "other") 

working_joined %>% nrow()

working_joined %>% names() 

working_joined <- working_joined %>% 
  select(for_impeachment,
           last_name,
           first_name,
           middle_name,
           party,
           state,
           district,
           date_exact,
           date_approx_month,
           date_comb,
           date_month,
           date_year,
           D_pct_2018 = live_D_pct,
           R_pct_2018 = live_R_pct,
           winner_2018 = live_winning,
           margin_2018 = live_margin,
           margin_flag,
           flip_2018 = flips,
           house_dist,
           keyrace_rating,
           population = totalpop,
           median_income = medincome,
           median_income_compared_to_national = medincome.abovebelow.natl,
           median_age = medage,
           median_age_compared_to_national = medage.abovebelow.natl,
           pct_nonwhite = pct.race.nonwhite,
           pct_nonwhite_compared_to_national = pct.race.nonwhite.abovebelow.natl,
           pct_bachelors = pct.ed.college.all,
           pct_bachelors_compared_to_national = pct.ed.college.all.abovebelow.natl,
           rural_pop_above20pct = pct.rural.above20,
           gdp_above_national = gdp_abovebelow_natlavg,
           clinton_percent,
           trump_percent,
           obama_percent,
           romney_percent,
           p16winningparty,
           p12winningparty,
           cnn_blurb,
           GEOID,
           fec_candidate_id,
           id
          )


working_joined %>% 
  count(for_impeachment)


#save results
writexl::write_xlsx(working_joined, "output/joined_impeachment.xlsx")
saveRDS(working_joined, "output/joined_impeachment.rds")



# 
# ### ANALYSIS ####
# 
# #for crosstabs using summarytools
# # print(ctable(tobacco$smoker, tobacco$diseased, prop = "r"), method = "render")
# 
# # trump districts vs hillary
# summarytools::ctable(working_joined$p16winningparty, working_joined$stance, prop = "r")
# 
# #education
# ctable(working_joined$pct.ed.college.all.abovebelow.natl, working_joined$stance, prop = "r")
# ctable(working_joined$pct.ed.college.all.abovebelow.natl, working_joined$stance, prop = "c")
# 
# #GDP
# ctable(working_joined$gdp_abovebelow_natlavg, working_joined$stance, prop = "r")
# ctable(working_joined$gdp_abovebelow_natlavg, working_joined$stance, prop = "c")
# ctable(working_joined$gdp_abovebelow_natlavg, working_joined$stance, prop = "n")
# 
# 
# 
# # summarytools::tb()
# 
# glimpse(working_joined)
# 
# 
# # groupings for export to spreadsheet for gfx ####
# 
# prezresults2016 <- working_joined %>% 
#   count(p16winningparty, stance)
# 
# gdp <- working_joined %>% 
#   count(gdp_abovebelow_natlavg, stance)
# 
# college_degree <- working_joined %>% 
#   count(pct.ed.college.all.abovebelow.natl, stance)
# 
# nonwhite_pop <- working_joined %>% 
#   count(pct.race.nonwhite.abovebelow.natl, stance)
# 
# rural_area <- working_joined %>% 
#   count(pct.rural.above20, stance)
# 
# margin_5_or_less <- working_joined %>% 
#   count(margin_flag, stance)
# 
# 
# #the same with prezresults
# 
# gdp_andprezresults <- working_joined %>% 
#   count(p16winningparty, gdp_abovebelow_natlavg, stance)
# 
# college_degree_andprezresults <- working_joined %>% 
#   count(p16winningparty, pct.ed.college.all.abovebelow.natl, stance)
# 
# nonwhite_pop_andprezresults <- working_joined %>% 
#   count(p16winningparty, pct.race.nonwhite.abovebelow.natl, stance)
# 
# rural_area_andprezresults <- working_joined %>% 
#   count(p16winningparty, pct.rural.above20, stance)
# 
# margin_5_or_less_withprez <- working_joined %>% 
#   count(p16winningparty, margin_flag, stance)
# 
# 
# 
# #now make a list to feed to writexl
# list_of_breakdowns <- list(prezresults2016 = prezresults2016,
#                            gdp_vs_nationalavg = gdp,
#                            college_vs_nationalavg = college_degree,
#                            nonwhite_vs_nationalavg = nonwhite_pop,
#                            rural_morethanfifth = rural_area,
#                            margin_5_or_less = margin_5_or_less,
#                            gdp_andprezresults = gdp_andprezresults,
#                            college_degree_andprezresults = college_degree_andprezresults,
#                            nonwhite_pop_andprezresults = nonwhite_pop_andprezresults,
#                            rural_area_andprezresults = rural_area_andprezresults,
#                            margin_5_or_less_withprez = margin_5_or_less_withprez
#                            )
# 
# writexl::write_xlsx(list_of_breakdowns, "output/groupings_for_dems_hr1296.xlsx")
# 
# 
# 
# 
# working_joined %>% 
#   filter(margin_flag == "5_points_or_less") 
# 
# 
# ###
# 
# working_joined %>% 
#   count(position)
# 
# working_joined %>% 
#   count(p16winningparty)
# 
# working_joined %>% 
#   count(keyrace_rating)
# 
# working_joined %>% 
#   count(flips)
# 
# working_joined %>% 
#   count(pct.ed.college.all.abovebelow.natl)
# 
# working_joined %>% 
#   count(medincome.abovebelow.natl)
# 
# working_joined %>% 
#   count(pct.race.nonwhite.abovebelow.natl)
# 
# 
# working_joined %>% 
#   count(p16winningparty, pct.ed.college.all.abovebelow.natl)
# 
# 