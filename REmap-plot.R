library(dplyr)
if(!require(REmap)){
  devtools::install_github('lchiffon/REmap')
  library(REmap)
}

dat = read.csv('https://raw.githubusercontent.com/road2stat/tea-sea-cha-land/master/tea-sea-cha-land.csv')

# 删除缺失数据
rawDat = dat %>% na.omit

markPoint = rawDat %>% select(id,value) 
markPoint$color = ifelse(markPoint$value==1,'red',ifelse(markPoint$value==2,'blue','green'))
geoData = rawDat %>% select(longitude,latitude,id)

# 第一次绘制，不带路线
data = data.frame(country = mapNames("world"),
                  value = 5*sample(178)+200)

head(data)
out = remapC(data,maptype = "world",color = 'white',
            markPointTheme = markPointControl(effect  = F, symbol = 'pin',symbolSize = 5),
             markPointData = markPoint,
             geoData = geoData)
plot(out)


# 第二次绘制，计算路线
# 逻辑:类型相同，起始点年份比终点少，取最短路径
output = list()
for(i in 1:nrow(rawDat)){
  tmpLine = rawDat[i,]
  if(tmpLine$value == 3) next
  tmpDat = rawDat %>% filter(value == tmpLine$value & year < tmpLine$year) %>% 
    arrange((latitude-tmpLine$latitude)^2+(longitude-tmpLine$longitude)^2)
  if(nrow(tmpDat)>0){
    output = append(output,list(c(ori = as.character(tmpDat[1,]$id), 
                                  des = as.character(tmpLine$id),
                                  value = tmpLine$value)))
  }
}

markLineDat = output %>% do.call(rbind,.) %>% as.data.frame
markLineDat$color = ifelse(markLineDat$value==1,'red',ifelse(markLineDat$value==2,'blue','green'))

out = remapB(color = 'Blue',
             markPointTheme = markPointControl(effect  = F, symbol = 'pin',symbolSize = 5),
             markPointData = markPoint,
             markLineData = markLineDat,
             markLineTheme = markLineControl(lineWidth = 2),
             geoData = geoData)
plot(out)
