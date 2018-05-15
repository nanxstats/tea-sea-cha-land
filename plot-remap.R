library("dplyr")
if (!require("REmap")) devtools::install_github("lchiffon/REmap")
library("REmap")

dat <- read.csv("https://raw.githubusercontent.com/road2stat/tea-sea-cha-land/master/tea-sea-cha-land.csv")

# remove missing data
rawDat <- dat %>% na.omit()

markPoint <- rawDat %>% select(id, value)
markPoint$color <- ifelse(
  markPoint$value == 1, "red",
  ifelse(markPoint$value == 2, "blue", "green")
)
geoData <- rawDat %>% select(longitude, latitude, id)

# first plot: without paths
data <- data.frame(country = mapNames("world"), value = 5 * sample(178) + 200)

head(data)
out <- remapC(
  data,
  maptype = "world", color = "white",
  markPointTheme = markPointControl(
    effect = FALSE, symbol = "pin", symbolSize = 5
  ),
  markPointData = markPoint,
  geoData = geoData
)
plot(out)

# second plot: with computed paths

# logic for computing the possible tea trade paths:
# type should be the same; year of the starting point
# is smaller than that of the ending point; with the shortest path

output <- list()
for (i in 1:nrow(rawDat)) {
  tmpLine <- rawDat[i, ]
  if (tmpLine$value == 3) next
  tmpDat <- rawDat %>%
    filter(value == tmpLine$value & year < tmpLine$year) %>%
    arrange((latitude - tmpLine$latitude)^2 + (longitude - tmpLine$longitude)^2)
  if (nrow(tmpDat) > 0) {
    output <- append(output, list(c(
      ori = as.character(tmpDat[1, ]$id),
      des = as.character(tmpLine$id),
      value = tmpLine$value
    )))
  }
}

markLineDat <- output %>% do.call(rbind, .) %>% as.data.frame()
markLineDat$color <- ifelse(
  markLineDat$value == 1, "red",
  ifelse(markLineDat$value == 2, "blue", "green")
)

out <- remapB(
  color = "Blue",
  markPointTheme = markPointControl(
    effect = FALSE, symbol = "pin", symbolSize = 5
  ),
  markPointData = markPoint,
  markLineData = markLineDat,
  markLineTheme = markLineControl(lineWidth = 2),
  geoData = geoData
)
plot(out)
