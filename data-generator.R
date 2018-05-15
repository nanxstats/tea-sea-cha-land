# Download and tidy the 'tea by sea, cha by land' data from the
# World Atlas of Language Structures (WALS) database
# http://wals.info/feature/138A#2/25.5/143.6

# geolocation data
download.file("http://wals.info/feature/138A.tab", "138A.tab")
# annotation data
download.file("https://raw.githubusercontent.com/clld/wals-data/master/cldf/feature-138A.cldf.csv", "feature-138A.cldf.csv")

df_geo <- read.table("138A.tab", sep = "\t", skip = 7, header = TRUE, quote = "", as.is = TRUE)
df_anno <- read.csv("feature-138A.cldf.csv", as.is = TRUE)

names(df_anno) <- tolower(names(df_anno))

# create index for both data frames
row.names(df_anno) <- substr(
  df_anno[, "id"], nchar(df_anno[, "id"]) - 2, nchar(df_anno[, "id"])
)
row.names(df_geo) <- df_geo[, "wals.code"]

# remove overlapped columns
df_anno[, c("value", "feature_id")] <- NULL
df_geo[, c("wals.code", "name", "area")] <- NULL

# merge two data frames
df <- merge(df_anno, df_geo, by = "row.names")

# rename columns
colnames(df) <- c(
  "id", "language", "source",
  "id_url", "language_url", "source_url",
  "value", "description", "latitude", "longitude", "genus", "family"
)

# replace blanks with NA
df[which(df[, "source"] == ""), "source"] <- NA
df[which(df[, "source_url"] == ""), "source_url"] <- NA

# create year column
year <- df[, "source"]
year[!grepl("\\[", df[, "source"])] <- NA
df[, "year"] <- sub(".*\\[ *(.*?) *\\].*", "\\1", year)

# remove [year] in source
df[, "source"] <- gsub("\\[.*\\]", "", df[, "source"])

# reorder columns
df <- df[c(
  "id", "language", "value", "description",
  "year", "latitude", "longitude",
  "genus", "family", "source",
  "id_url", "language_url", "source_url"
)]

write.csv(df, file = "tea-sea-cha-land.csv", quote = FALSE, row.names = FALSE)
