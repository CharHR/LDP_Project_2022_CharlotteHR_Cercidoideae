# This script uses previously cleaned occurrence data dowloaded from GBIF
# This script is used to determine which species occurrences occur in the rainforest biome 
# We are considering the rainforest biome map from Corlett & Primack (2011)
# We then calculate for each species the percentage of occurrences occurring in the rainforest biome.

# Set the working directory.
working.directory <- "~/Desktop/Productivity and Reproducibility F2022/Maps"
setwd(working.directory)  

# Setting up the script
list.of.packages <- c("raster", "sp", "maptools", "rworldmap", "rworldxtra", "data.table")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]

if(length(new.packages)) install.packages(new.packages)

lapply(list.of.packages, library, character.only = TRUE)
data(list="countriesHigh", "wrld_simpl")

# Load the required packages.
library(raster)
library(maptools)
data("wrld_simpl")

# Load the binary rainforest biome map
rainforest=raster("Rainforest.tif")
plot(rainforest)

# Load the species dataframe.
species <- read.csv("CheniellaEdited_Oct_2021.csv")
dim(species)
head(species)
table(species$SpeciesEdited) ; paste("Number of species: ", length(table(species$SpeciesEdited)), sep="")
plot(wrld_simpl)
points(species$decimalLongitude, species$decimalLatitude, pch=20, col='red')

# It's possible there are occurrences of the same species at the exact same location. These occurrences could represent copies of the same collection in different herbaria, rather than multiple independent collections at the same spot, it's better to remove them, so as to not bias the biome assignment. That's done in the following lines.
xySp <- paste(species$decimalLongitude, species$decimalLatitude, species$SpeciesEdited)
double <- duplicated(xySp) ; paste("Duplicate rows: ", sum(double), sep="")
# Now we can remove all extra occurrences of identical species with identical coordinates (leaving only one record per species - coordinates combination). 
species <- species[!double,] ; paste("Records left: ", dim(species)[1], sep="")

# Add a new column to the species dataframe, "occurs_in_biome": score of 1 means occurrence is in the biome, 0 means not in the biome.
species$decimalLatitude<-as.numeric(species$decimalLatitude)
species$decimalLongitude<-as.numeric(species$decimalLongitude)
species$occurs_in_biome <- extract(rainforest, cbind(species$decimalLongitude, species$decimalLatitude), method="simple")
hist(species$occurs_in_biome)

#Now we create a new table summarizing for each species the number of occurrences in the rainforest biome, the total number of occurrences and the percentage of occurrences in the rainforest biome.
biomeProb <- aggregate(species$occurs_in_biome, by = list(species$SpeciesEdited), FUN = sum, na.rm = TRUE)
biomeProb$Total <- table(species$SpeciesEdited)
colnames(biomeProb) <- c("Species", "Number_In_Rainforest", "Total_Occurrences")
biomeProb
biomeProb$Percentage_In_Rainforest <- (biomeProb$Number_In_Rainforest/biomeProb$Total_Occurrences)*100

# Save these results.
write.csv(biomeProb, "Cheniella_Rainforest_Occurrences_27_09_2022.csv", row.names=FALSE)

# The next step is to plot the species on the biome map.
speciesNames <- as.vector(biomeProb$Species)
speciesNames
# Zooming in on these maps in R shifts the points relative to the raster, which apparently is not an easy issue to solve. The easiest workaround is probably to automatically save a map of the points of each species, which may be a useful thing to do anyway.
for (i in 1:length(speciesNames)) {
  sp <- speciesNames[i]
  png(paste(filename=sp, ".png", sep=""), width=1500, height=955)
  plot(rainforest, main=sp)
  mtext(paste("Mean: ", round(biomeProb[which(biomeProb$Species==sp),2],2), " Median: ", round(biomeProb[which(biomeProb$Species==sp),3],2   ), sep=""))
  points(species[which(species$SpeciesEdited == sp),]$decimalLongitude, species[which(species$SpeciesEdited == sp),]$decimalLatitude, col    ='red', pch=20, cex=1)
  dev.off()
}
