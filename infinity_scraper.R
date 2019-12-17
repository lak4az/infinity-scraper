library(RSelenium)
library(dplyr)
library(tidyr)
library(reshape2)
library(rvest)
library(stringr)


#create df for loops of each state
states_df <- cbind(state.name,state.abb) %>% as.data.frame()
DC_df <- matrix(c("District of Columbia", "DC"),nrow=1) %>% as.data.frame()
names(DC_df) <- c("state.name","state.abb")
states_df <- rbind(states_df,DC_df)
#assign id's to states based on 247 site
state.id <- c(2,31,42,36,24,40,48,50,44,3,41,12,18,43,26,10,30,4,7,11,20,27,28,5,37,22,17,45,47,23,21,25,13,33,14,
  29,34,1,49,6,15,35,9,46,32,19,16,38,8,39,52)
states_df <- cbind(states_df,state.id)
#subset to specific state
states_df <- states_df[states_df$state.abb=='VA',]
#set years for loop
year <- seq(2019,2019)

#read in csv for school data
sc_df <- read.csv('C:/Users/Student/Desktop/UVA Football Recruiting/Infinity Scraper/school_data_final.csv')

#initialize dataframe for data
final_df <- data.frame(class=numeric(0),
                            name=character(0),
                            school=character(0),
                            city=character(0),
                            state=character(0),
                            position=character(0),
                            height_in=numeric(0),
                            weight=numeric(0),
                            star_ct = numeric(0),
                            composite_rtg=numeric(0),
                            nat_rk=numeric(0),
                            pos_rk=numeric(0),
                            st_rk=numeric(0),
                            interest=numeric(0),
                            commit_link=character(0),
                            cs_class_rk=numeric(0),
                            commit_school=character(0),
                            cs_city=character(0),
                            cs_state=character(0),
                            cs_division=numeric(0),
                            cs_level=character(0),
                            cs_conf=character(0),
                            cs_conf_div=character(0),
                            cs_power_conf=numeric(0))

for(y in year){#loop for each year
for(row in 1:nrow(states_df)){#loop for each state (each state has unique abbrev & id)
  s <- states_df[row,"state.abb"] #set current state abbrev as s
  i <- states_df[row,"state.id"] #set current state id as i
#set url
url <- paste("https://247sports.com/Season/",y,
             "-Football/Recruits/?&Player.Hometown.State.Key=sa_",i,"",sep="")
#open web explorer and driver (note the version of chrome used)
driver <- rsDriver(browser=c("chrome"), chromever="79.0.3945.36")
remDr <- driver[["client"]]
#navigate to url
remDr$navigate(url)

# Keep scrolling down page, loading new content each time. 
last_height = 0 #
repeat {   
  remDr$executeScript("window.scrollTo(0,document.body.scrollHeight);")
  Sys.sleep(3) #delay by 3sec to give chance to load. Delay may need to be increased, depending on 
               #internet connection

  # Updated if statement which breaks if we can't scroll further 
  new_height = remDr$executeScript("return document.body.scrollHeight")
  if(unlist(last_height) == unlist(new_height)) {
    break
  } else {
    last_height = new_height
  }
}

#extract data from website, put in list

data <- remDr$findElements(using = 'css selector', ".results .player")
if(length(data)==0){
  remDr$close()
  driver$server$stop()
  driver$server$process
  next
  }
dl <- list()
dl <- sapply(data, function(x){x$getElementText()})


###convert data into dataframe
#make it into vector
dl <- unlist(dl,use.names = F)
#make into dataframe, split at city
d_0 <- as.data.frame(dl,stringsAsFactors = F) %>% separate(dl, into = c("name_school","city_rest"),
                                                          sep="\n[(]")
#make name and school columns, splitting on new line
d <- colsplit(d_0$name_school,"\n",c("name","school"))
#convert rest of data to vector
d_0v <- d_0$city_rest %>% as.vector()
#convert vector to dataframe, splitting on city_state and rest
f <- as.data.frame(d_0v,stringsAsFactors = F) %>% separate(d_0v,into = c("city_state","rest"),
                                                           sep="[)]\n")
#create dataframe for city and state, separated
city_state <- f$city_state
city_state_f <- colsplit(city_state,", ",c("city","state"))
#convert rest to vector
f_v <- f$rest %>% as.vector()

#create dataframe of rest data
g <- as.data.frame(f_v,stringsAsFactors = F) %>% separate(f_v,into = c("position","height_weight",
                                                          "composite_rtg","nat_rk","pos_rk","st_rk",
                                                          "interest"),
                                                          sep="\n")

##clean rest data
#fix this stuff (if cells are shifted wrong)
for(row in 1:nrow(g)){
  if(grepl("St:",g$st_rk[row])==F){
    g[row,7]<-g[row,6]
    g[row,6]<-g[row,5]
    g[row,5]<-g[row,4]
    g[row,4]<-g[row,3]
    g[row,3]<-g[row,2]
    g[row,2]<-g[row,1]
    g[row,1]<-NA
  }
}

#fix this stuff (if no height/wt data)
for(h in 1:length(g$height_weight)){
  if(str_detect(g$height_weight[h], ".*[0-9].*")==F){
    g[h,2]<-NA
  }
}

#combine name,school,city,state,rest
df <- cbind(d,city_state_f,g)
#make height/weight columns and add to df
height_weight_df <- colsplit(df$height_weight,"/",c("height","weight"))
height_weight_df$height <- height_weight_df$height %>% trimws()
height_weight_df$weight <- height_weight_df$weight %>% trimws()
height_df <- colsplit(height_weight_df$height, "-",c("feet","inches"))
height_in <- (height_df$feet*12)+height_df$inches
df$height_in <- height_in %>% as.numeric()
df$weight <- height_weight_df$weight %>% as.numeric()
df <- df[,c(1:5,12:13,7:11)]
#make composite rating numeric
df$composite_rtg <- df$composite_rtg %>% as.numeric()
#make national rank numeric
df$nat_rk <- substring(df$nat_rk,7) %>% as.numeric()
#make position rank numeric
df$pos_rk <- substring(df$pos_rk,6) %>% as.numeric()
#make state rank numeric
df$st_rk <- substring(df$st_rk,5) %>% as.numeric()
#make interest numeric
df$interest <- substring(df$interest,1,nchar(df$interest)-6) %>% as.numeric()
#add class year to df
class_data <- y %>% as.data.frame()
d <- class_data
n <- length(df$name)
class_data <- do.call("rbind", replicate(n,d,simplify = F))
df <- cbind(class_data,df)


#get star count and commit data
cl <- sapply(data, function(x){x$getElementAttribute("outerHTML")})
cl <- unlist(cl,use.names=F)
cl <- gsub('.*"stars','',cl)
star_count <- str_count(cl,"yellow") %>% as.numeric()
commit <- ifelse(grepl("img src=\"",cl),sub(".*img src=\"*(.*?) *\\?.*", "\\1", cl),NA)

#add data to df and rearrange
df <- cbind(df,star_count,commit)
df <- df[,c(1:8,14,9:13,15)]

#coerce columns and join to include school commit data
df$. <- df$. %>% as.numeric()
sc_df$Year <- sc_df$Year %>% as.numeric()
df$commit <- df$commit %>% as.character()
sc_df$Link <- sc_df$Link %>% as.character()
all_df <- left_join(df,sc_df,by=c('.'='Year','commit'='Link'))

#rename columns for current state df
names(all_df) <- colnames(final_df)

#combine dataframe for all states
final_df <- rbind(final_df,all_df)
###
remDr$close()
driver$server$stop()
driver$server$process
} #end of state/id loop
} #end of year loop
View(final_df)
remDr$close()
driver$server$stop()
driver$server$process

#write final_df as a csv
write.csv(final_df, 
          "C:/Users/Student/Desktop/UVA Football Recruiting/Infinity Scraper/recruit_data.csv", 
          row.names=F)
#read in csv to begin working with data
rc_final <- read.csv("C:/Users/Student/Desktop/UVA Football Recruiting/Infinity Scraper/recruit_data_final.csv")
