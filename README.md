# infinity-scraper

#Overview
Remote driver to scrape data from 247sports recruiting database.

The purpose of this project is to create a simple way to extract data for high school football recruits into an organized, workable format. This will make keeping track of recruits easier for both coaches and area recruiters and allow for consistency in recruit data while also ensuring that no data for any recruit is excluded from the output.

In the 247 player rankings, the only recruits that are visible are top recruits who have received an offer or expressed interest in a school. The only way to access all recorded recruits in a given state is via the 247 player search tool. The player search tool is very inefficient, as it requires scrolling through the entire list of recruits to view all available player data. Furthermore, there is no simple way to extract this data. This tool removes the need for manual data entry and the accompanying human error. 

The infinity scraper, appropriately named for its function, scrolls through the player search tool until data for all players has been revealed. Following this, data is scraped for all recruits shown and then stored in a .csv file. This tool ensures that data for all recruits within the requested criteria will be gathered, so that no single prospect will be excluded from the spreadsheet output. 

#Attachments

##infinity_scraper.R
This is the code that, when run in R, will output a .csv file for recruit data based on the user's specifications. It is customizable by state and year. Currently, the file is set to gather data for recruits from the 2019 class for the state of Virginia. The file is able to gather data for recruits from 2010-2019 classes for all 50 states and DC.

##recruit_data_final.csv
This is the final output for the 2010-2019 recruiting classes for all 50 states and DC, including players that signed and did not sign. The variables included are as follows:
class: player's recruiting class
name: player's name
school: player's high school
city: player's hometown
state: player's home state
position: player's recruited position 
height_in: player's height in inches
weight: player's weight
star_ct: player's star rating according to 247 composite rank
composite_rtg: player's 247 composite rating
nat_rk: player's overall rank in their recruiting class
pos_rk: player's overall rank at their position
st_rk: player's overall rank in their state
interest: displays number of schools a player has interest in if not committed
commit_link: variable used to merge recruit data with their college data
cs_class_rk: recruiting class rank of the college that the player committed to
commit_school: college that the player committed to 
cs_city: city of the college that the player committed to
cs_state: state of the college that the player committed to
cs_division: NCAA division of the college that the player committed to
cs_level: D1 level of the college that the player committed to (if applicable)
cs_conference: conference of the college that the player committed to
cs_conf_div: division in the conference of the college that the player committed to
cs_power_conf: binary variable designating whether the school is part of the Power 5

##school_data_final.csv
This .csv file contains data for the colleges that each recruit committed to, for each year. The data is merged with the recruit data  based on the unique link to each college's logo on the 247 website. The file contains data from 2010-2019 for each college that has committed players and contains all variables listed above, starting with commit_link and ending with cs_power_conf.
