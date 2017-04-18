# word blobs

if (!require(wordcloud)) {
  install.packages("wordcloud", repos="http://cran.us.r-project.org")
}
if (!require(tm)) {
  install.packages("tm", repos="http://cran.us.r-project.org")
}
if (!require(slam)) {
  install.packages("slam", repos="http://cran.us.r-project.org")
}
if (!require(SnowballC)) {
  install.packages("SnowballC", repos="http://cran.us.r-project.org")
}
if (!require(ggplot2)) {
  install.packages("ggplot2", repos="http://cran.us.r-project.org")
}

library(slam)
library(tm)
library(wordcloud)
library(SnowballC)
library(ggplot2)

workingDir = '/Users/michaeltauberg/NYT'
csvName = "fiction_bestsellers_5yr.csv"
data_name = "fiction_bestsellers_5yr"
setwd(workingDir)


dt = read.csv('fiction_bestsellers_5yr.csv')
dt_uniq = dt[!duplicated(dt[,c('title','author')], fromLast=FALSE),] #fromlast to get highest value in "weeks_on_list" field
# remove puctuation that can screw up word processing
dt_uniq$title = gsub("'", "", dt_uniq$title)
dt_uniq$title = gsub("\x89۪", "", dt_uniq$title)
dt_uniq$title = gsub("\xcc\xe4", "", dt_uniq$title)
dt_uniq$title = gsub(":", "", dt_uniq$title)
dt_uniq$title = gsub("#", "", dt_uniq$title)
dt_uniq$title = gsub(",", "", dt_uniq$title)
dt_uniq$title = gsub("\x89\xdb\xd3", "", dt_uniq$title)

# add number of words in the title (for analysis later)
dt_uniq$num_words_in_title = sapply(gregexpr("\\S+", dt_uniq$title), length)


GenerateWordClouds <- function(dt_uniq, data_name) {
  words = Corpus(VectorSource(dt_uniq$title)) 
  corpus <- tm_map(words, content_transformer(tolower))
  
  # Generate wordcloud only removing 'the', 'and', 'a'
  words = tm_map(words, stripWhitespace)
  words = tm_map(words, tolower)
  badwords = c("the", "and", "a")
  words = tm_map(words, removeWords, badwords)
  png(sprintf("%s_simple_wordcloud.png", data_name))
  wordcloud(words, max.words = 120, random.order=FALSE, colors=brewer.pal(nrow(dt_uniq),"Dark2"))
  dev.off()
  
  # Generate wordcloud removing all stop words
  png(sprintf("%s_stopwords_wordcloud.png", data_name))
  words = tm_map(words, removeWords, stopwords('english'))
  wordcloud(words, max.words = 120, random.order=FALSE)
  
  dev.off()
}

# Generate word clouds
GenerateWordClouds(dt_uniq, data_name)

# Count some popular words 
darks = dt_uniq[grep("\\bDARK", dt_uniq$title, perl=TRUE), ]
girls = dt_uniq[grep("\\bGIRL", dt_uniq$title, perl=TRUE), ]
loves = dt_uniq[grep("\\bLOVE", dt_uniq$title, perl=TRUE), ]
ones = dt_uniq[grepl("\\bONE", dt_uniq$title, perl=TRUE), ]
twos = dt_uniq[grepl("\\bTWO", dt_uniq$title, perl=TRUE), ]
threes = dt_uniq[grepl("\\bTHREE", dt_uniq$title, perl=TRUE), ]
fours = dt_uniq[grepl("\\bFOUR", dt_uniq$title, perl=TRUE), ]
fifties = dt_uniq[grepl("\\bFIFTY", dt_uniq$title, perl=TRUE), ]
games = dt_uniq[grepl("\\bGAME", dt_uniq$title, perl=TRUE), ]
nights = dt_uniq[grep("\\bNIGHT", dt_uniq$title, perl=TRUE), ]
secrets = dt_uniq[grep("\\bSECRET", dt_uniq$title, perl=TRUE), ]
fires = dt_uniq[grep("\\bFIRE", dt_uniq$title, perl=TRUE), ]
bloods = dt_uniq[grep("\\bBLOOD", dt_uniq$title, perl=TRUE), ]
shadows = dt_uniq[grep("\\bSHADOW", dt_uniq$title, perl=TRUE), ]
men = dt_uniq[grep("\\bMAN", dt_uniq$title, perl=TRUE), ]
yous = dt_uniq[grep("\\bYOU\\b", dt_uniq$title, perl=TRUE), ]
deaths = dt_uniq[grep("\\bDEATH", dt_uniq$title, perl=TRUE), ]
lifes = dt_uniq[grep("\\bLIFE", dt_uniq$title, perl=TRUE), ]
islands = dt_uniq[grep("\\bISLAND", dt_uniq$title, perl=TRUE), ]
houses = dt_uniq[grep("\\bHOUSE", dt_uniq$title, perl=TRUE), ]
trains = dt_uniq[grep("\\bTRAIN", dt_uniq$title, perl=TRUE), ]
homes = dt_uniq[grep("\\bHOME", dt_uniq$title, perl=TRUE), ]
nights = dt_uniq[grep("\\bNIGHT", dt_uniq$title, perl=TRUE), ]
days = dt_uniq[grep("\\bDAY", dt_uniq$title, perl=TRUE), ]
secrets = dt_uniq[grep("\\bSECRET", dt_uniq$title, perl=TRUE), ]
storms = dt_uniq[grep("\\bSTORM", dt_uniq$title, perl=TRUE), ]
gones = dt_uniq[grep("\\bGONE", dt_uniq$title, perl=TRUE), ]
summers = dt_uniq[grep("\\bSUMMER", dt_uniq$title, perl=TRUE), ]
xmases = dt_uniq[grep("\\bCHRISTMAS", dt_uniq$title, perl=TRUE), ]
beauties = dt_uniq[grep("\\bBEAUT", dt_uniq$title, perl=TRUE), ]

girl_weeks_on_list = sum(girls$weeks_on_list)
dark_weeks_on_list = sum(darks$weeks_on_list)
night_weeks_on_list = sum(nights$weeks_on_list)
game_weeks_on_list = sum(games$weeks_on_list)
love_weeks_on_list = sum(loves$weeks_on_list)
men_weeks_on_list = sum(men$weeks_on_list)
yous_weeks_on_list = sum(yous$weeks_on_list)

# order list to show the most popular books
dt_uniq = dt_uniq[order(dt_uniq$weeks_on_list, decreasing=TRUE),]
head(dt_uniq)

# create a histogram of the number of words in the title
hist(dt_uniq$num_words_in_title)
top_books = head(dt_uniq, 25)
hist(top_books$num_words_in_title)
p = ggplot(dt_uniq, aes(x=num_words_in_title, fill=num_words_in_title)) + geom_histogram(binwidth=0.5) 
p = p + theme(axis.text.x=element_text(angle=75, hjust=1))
p = p + theme(axis.text=element_text(size=12), axis.title=element_text(size=14,face="bold"))
p = p + xlab("Num Words in Title") + ylab("Num Titles") 
p = p + scale_x_continuous(breaks = c(0,1,2,3,4,5,6,7,8,9,10))
ggsave(filename = "./Histogram.png", plot=p, width=4, height=4) 




