#install.packages("rgeos")
#install.packages("RNetCDF")
#install.packages("fields",repos="http://cran.us.r-project.org")
#install.packages("maptools")
#install.packages("spdep",repos="http://cran.us.r-project.org")
#install.packages("classInt",repos="http://cran.us.r-project.org")
#install.packages("RColorBrewer",repos="http://cran.us.r-project.org")
#install.packages("spatstat")
#install.packages("rgeos")
#install.packages("sp")
#install.packages("rgdal")
#install.packages("raster")
#install.packages("abind")

require(spgwr)
require(mgcv)

library(RNetCDF)
library(fields)
library(maps)
library(maptools)
library(spdep)
library(classInt)
library(RColorBrewer)
library(spatstat)

library(rgeos)
library(sp)
library(rgdal)
library(raster)
library(abind)

# Function to rotate a matrix (useful for plotting)
rotatemat <- function(x) t(apply(x, 2, rev))

# Function to extract last n characters
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}




##
## FUNCTION 1 ##
##
## Extract cell-by-cell statistics from NetCDF files 


Extract_Stat_from_NCDF = function(ncfolder,
						output_folder,
						file_name_pattern = "livneh_NAmerExt_15Oct2014.",
						var_ = "Tmax",
						NA_mask = TRUE,
						CSVreqd = TRUE,
						PDFreqd = TRUE,
						PDFname = "Monthly_stats",
						start_year_month = "1950-01",
						end_year_month = "1950-02")
{
	st_yrmo = as.Date(paste(start_year_month,"-01",sep=""), format = "%Y-%m-%d")
	en_yrmo = as.Date(paste(end_year_month,"-01",sep=""), format = "%Y-%m-%d")
	seq_yrmo = seq.Date(st_yrmo, en_yrmo, by = "1 month")
	yrs_ = unique(as.numeric(format(seq_yrmo, "%Y")))
	mons_ = as.numeric(format(seq_yrmo, "%m"))

	for (nyear in yrs_){
		if (PDFreqd){pdf(file = paste(output_folder,"/",PDFname,"_",var_,"_",nyear,".pdf",sep=""))}	
		for (nmon in mons_){
			if (nchar(nmon) == 1) {tr_zeros = "0"}
			if (nchar(nmon) == 2) {tr_zeros = ""}
			nmon_w_zeros = paste(tr_zeros, nmon, sep = "")
	
			ncfname = paste(file_name_pattern, nyear, nmon_w_zeros, ".nc", sep = "")
			nc_file = open.nc(paste(ncfolder,"/",ncfname,sep=""))
			nc_data = read.nc(nc_file)
	
			x_ = nc_data$lon
			y_ = nc_data$lat
			days_ = nc_data$time - nc_data$time[1] + 1
			##start_day = 1 # Change this if you know that start date is different!
			end_day = start_day + tail(days_,1)[1] - 1 
		
			st_time = as.Date(paste(nyear, "-", nmon, "-", start_day, sep =""), format = "%Y-%m-%d")
			en_time = as.Date(paste(nyear, "-", nmon, "-", end_day, sep =""), format = "%Y-%m-%d")
			
			#nday = 30
			#var_ = "Prec"
			if (var_ == "Prec"){nc_var = nc_data$Prec}
			if (var_ == "Tmax"){nc_var = nc_data$Tmax}
			if (var_ == "Tmin"){nc_var = nc_data$Tmin}
			if (var_ == "Wind"){nc_var = nc_data$wind}
		
			#image.plot(x_, y_, nc_var[,,nday])
			#map(col = "white", lwd=2, add = T)
			#grid()
			
			#
			# Monthly Stats
			#
	
			ini_var_stat = nc_var[,,1]-nc_var[,,1]
			rownames(ini_var_stat) = x_
			colnames(ini_var_stat) = y_
	
	
			is_NA_mat= matrix(NA, nrow = dim(ini_var_stat)[1], ncol = dim(ini_var_stat)[2])
			var_sum = ini_var_stat
			var_avg = ini_var_stat
			var_med = ini_var_stat
			var_min = ini_var_stat
			var_max = ini_var_stat
			var_q5 = ini_var_stat
			var_q95 = ini_var_stat
			var_sd = ini_var_stat
			var_sumnonNA = ini_var_stat
			
			
			for (i in 1:dim(ini_var_stat)[1]){
				for (j in 1:dim(ini_var_stat)[2]){
					is_NA_mat[i,j] = any(is.na(nc_var[i,j,]))
					var_sum[i,j] = sum(nc_var[i,j,], na.rm = T)
					var_avg[i,j] = mean(nc_var[i,j,], na.rm = T)
					var_med[i,j] = median(nc_var[i,j,], na.rm = T)
					var_min[i,j] = min(nc_var[i,j,], na.rm = T)
					var_max[i,j] = max(nc_var[i,j,], na.rm = T)
					var_q5[i,j] = quantile(nc_var[i,j,], probs = c(0.05), na.rm = T)
					var_q95[i,j] = quantile(nc_var[i,j,], probs = c(0.95), na.rm = T)
					var_sd[i,j] = sd(nc_var[i,j,], na.rm = T)
					var_sumnonNA[i,j] = sum(is.na(nc_var[i,j,])== T)
				}
			}
			if (NA_mask){
				isMasked = "Masked"
				var_sum[is_NA_mat] = NA
				var_avg[is_NA_mat] = NA
				var_med[is_NA_mat] = NA
				var_min[is_NA_mat] = NA
				var_max[is_NA_mat] = NA
				var_q5[is_NA_mat] = NA
				var_q95[is_NA_mat] = NA
				var_sd[is_NA_mat] = NA
				var_sumnonNA[is_NA_mat] = NA
			} else {
				isMasked = "UnMasked"
			}
			if (CSVreqd){
				if (!dir.exists(paste(output_folder, "/", var_, sep=""))){dir.create(paste(output_folder, "/", var_, sep=""))}
				if (!dir.exists(paste(output_folder, "/", var_, "/", isMasked, sep=""))){dir.create(paste(output_folder, "/", var_, "/", isMasked, sep=""))}
				
				write.csv(var_sum, file = paste(output_folder, "/", var_, "/", isMasked, "/Sum_",nyear,"_",nmon,".csv",sep=""))  
				write.csv(var_avg, file = paste(output_folder, "/", var_, "/", isMasked, "/Avg_",nyear,"_",nmon,".csv",sep="")) 
				write.csv(var_med, file = paste(output_folder, "/", var_, "/", isMasked, "/Med_",nyear,"_",nmon,".csv",sep="")) 
				write.csv(var_min, file = paste(output_folder, "/", var_, "/", isMasked, "/Min_",nyear,"_",nmon,".csv",sep="")) 
				write.csv(var_max, file = paste(output_folder, "/", var_, "/", isMasked, "/Max_",nyear,"_",nmon,".csv",sep="")) 
				write.csv(var_q5, file = paste(output_folder, "/", var_, "/", isMasked, "/q5_",nyear,"_",nmon,".csv",sep="")) 
				write.csv(var_q95, file = paste(output_folder, "/", var_, "/", isMasked, "/q95_",nyear,"_",nmon,".csv",sep="")) 
				write.csv(var_sd, file = paste(output_folder, "/", var_, "/", isMasked, "/sd_",nyear,"_",nmon,".csv",sep="")) 
				write.csv(var_sumnonNA, file = paste(output_folder, "/", var_, "/", isMasked, "/sumnonNA_",nyear,"_",nmon,".csv",sep="") )
			}
			if (PDFreqd){
				image.plot(x_, y_, var_sum, main = paste("Sum of ", var_, " ", nyear ,"_", nmon, sep =""), xlab = "Lon", ylab = "Lat")
				map("state", add=T, col = "black", lwd=1)
				image.plot(x_, y_, var_avg, main = paste("Avg of ", var_, " ", nyear ,"_", nmon, sep =""), xlab = "Lon", ylab = "Lat")
				map("state", add=T, col = "black", lwd=1)
					image.plot(x_, y_, var_med, main = paste("Median of ", var_, " ", nyear ,"_", nmon, sep =""), xlab = "Lon", ylab = "Lat")
				map("state", add=T, col = "black", lwd=1)
				image.plot(x_, y_, var_min, main = paste("Minimum of ", var_, " ", nyear ,"_", nmon, sep =""), xlab = "Lon", ylab = "Lat")
				map("state", add=T, col = "black", lwd=1)
				image.plot(x_, y_, var_max, main = paste("Maximum of ", var_, " ", nyear ,"_", nmon, sep =""), xlab = "Lon", ylab = "Lat")
				map("state", add=T, col = "black", lwd=1)
				image.plot(x_, y_, var_q5, main = paste("5 percentile of ", var_, " ", nyear ,"_", nmon, sep =""), xlab = "Lon", ylab = "Lat")
				map("state", add=T, col = "black", lwd=1)
				image.plot(x_, y_, var_q95, main = paste("95 percentile of ", var_, " ", nyear ,"_", nmon, sep =""), xlab = "Lon", ylab = "Lat")
				map("state", add=T, col = "black", lwd=1)
				image.plot(x_, y_, var_sd, main = paste("Std Dev of ", var_, " ", nyear ,"_", nmon, sep =""), xlab = "Lon", ylab = "Lat")
				map("state", add=T, col = "black", lwd=1)
				image.plot(x_, y_, var_sumnonNA, main = paste("Sum of non NA elems", var_, " ", nyear ,"_", nmon, sep =""), xlab = "Lon", ylab = "Lat")
				map("state", add=T, col = "black", lwd=1)
			}
		}
		dev.off()
	}
	return (0)	
}


##### Example for Function 1 ########

# INPUTS 

#####################

# Folder where the nc files are:
ncfolder = "C:/Users/Sulochan Dhungel/Sulochan/R codes/NetCDF_Wrangler/nc_files"

# Output folder
output_folder = "C:/Users/Sulochan Dhungel/Sulochan/R codes/NetCDF_Wrangler/Output"

# File name Pattern without year and month
file_name_pattern = "livneh_NAmerExt_15Oct2014."

# Which variable do you need?
# "Prec" or "Tmax" or "Tmin" or "Wind"
var_ = "Tmax"

#Do you need to mask areas without data?
NA_mask = TRUE

#Do you need CSVs?
CSVreqd = TRUE

#Do you need PDF?
PDFreqd = TRUE

start_day = 1 # Change this if you know that start date is different!


Extract_Stat_from_NCDF(ncfolder,
				output_folder,
				file_name_pattern = "livneh_NAmerExt_15Oct2014.",
				var_ = "Tmin",
				NA_mask = TRUE,
				CSVreqd = TRUE,
				PDFreqd = TRUE,
				PDFname = "Monthly_stats",
				start_year_month = "1950-01",
				end_year_month = "1950-02")


###############################################################################

##
## FUNCTION 2 ##
##
## Extract time series from NetCDF files at a point
	
getTSfromNetCDF = function(ncfilename,
					xy_csvfilename,
					var_ = "Wind",
					plt = "FALSE")
{				
	year_ncf = substr(substrRight(strsplit(ncfilename, ".nc"),6),1,4)
	month_ncf = substr(substrRight(strsplit(ncfilename, ".nc"),6),5,6)

	nc_file = open.nc(paste(ncfolder,"/",ncfilename,sep=""))
	nc_data = read.nc(nc_file)

	all_lons = nc_data$lon
	all_lats = nc_data$lat

	if (var_ == "Prec"){nc_var = nc_data$Prec}
	if (var_ == "Tmax"){nc_var = nc_data$Tmax}
	if (var_ == "Tmin"){nc_var = nc_data$Tmin}
	if (var_ == "Wind"){nc_var = nc_data$wind}

	val = nc_var

	xy_df = read.csv(xy_csvfilename)
	x_ = xy_df$Lon
	y_ = xy_df$Lat
	xy_name = levels(xy_df$Loc)[xy_df$Loc]
	loc_names = paste("[", x_, " , ", y_, "] ", xy_name, sep = "")

	if (plt){
		# Check where the points are 
		image.plot(all_lons, all_lats, val[,,1],
				main = paste(var_, " ", year_ncf, "-", month_ncf, "-01", sep=""))
		#		xlim = c(-124, -123), ylim = c(44,46), zlim = c(6,9))
	
		points(x_,y_, lwd = 2, pch = 4, cex = 2)
		text(x_,y_,xy_name, pos = 4, cex = 1)
	}

	result_mat = matrix(NA,  ncol = length(loc_names), nrow = dim(val)[3])
	colnames(result_mat) = loc_names
	date_ = paste(year_ncf, "-", month_ncf, "-", seq(1, dim(val)[3],1), sep = "")
	dates_ = as.Date(date_, format = "%Y-%m-%d")
	rownames(result_mat) = date_

	for (i in 1:dim(val)[3]){
		obj = list(x = all_lons, y = all_lats, z = val[,,i])
	
		grid.list = list(x = x_, y = y_)
		interp_vals_list = interp.surface.grid(obj, grid.list) 
		result_mat[i,] = diag(interp_vals_list$z)
	}

	return (list(result_mat, dates_))
}

##### Example for Function 2 ########

# INPUTS 

#####################

ncfolder = "C:/Users/Sulochan Dhungel/Sulochan/R codes/NetCDF_Wrangler/nc_files"
ncfilenames = list.files(ncfolder)
var_ = "Wind"
plt = FALSE

xy_csvfilename = "C:/Users/Sulochan Dhungel/Sulochan/R codes/NetCDF_Wrangler/xy_coords.csv"
ncfilename = ncfilenames[2]

xx = getTSfromNetCDF(ncfilename = ncfilename,
				xy_csvfilename,
				var_ = "Wind",
				plt = FALSE)[[1]]


#plot(xx[[2]], xx[[1]][,1], 'b')




#############################################################
##
## FUNCTION 3 ##
##
## Function to combine data from all NetCDFs

getTSfromALLnetCDF = function(ncfolder,
					xy_csvfilename, 
					var_ = "Wind",
					plt = FALSE)
{
	ncfilenames = list.files(ncfolder)
	for (i in 1:length(ncfilenames)){
		TS1 = getTSfromNetCDF(ncfilename = ncfilenames[i],
					xy_csvfilename,
					var_ = "Wind",
					plt = FALSE)[[1]]
		if (i == 1){
			Result_mat = TS1
		} else {
			Result_mat = rbind(Result_mat, TS1)
		}
	}
	return (Result_mat)
}


##### Example for Function 3 ########

# INPUTS 

#####################

ncfolder = "C:/Users/Sulochan Dhungel/Sulochan/R codes/NetCDF_Wrangler/nc_files"
xy_csvfilename = "C:/Users/Sulochan Dhungel/Sulochan/R codes/NetCDF_Wrangler/xy_coords.csv"
var_ = "Wind"
tt = getTSfromALLnetCDF(ncfolder,
				xy_csvfilename, 
				var_ = var_,
				plt = FALSE)

write.csv(tt, file = "C:/Users/Sulochan Dhungel/Sulochan/R codes/NetCDF_Wrangler/results.csv")



############################################################
##
## FUNCTION 4 ##
##
## Get data within extent of 1 shapefile


GetDataExtentFromSHP_allfiles = function(ncfolder,
							shp_filename,  
							var_ = "Wind",
							shp_ext = c(NA, NA, NA, NA)) 
## shp_ext = c(xmin, xmax, ymin, ymax)
{
	ncfilenames = list.files(ncfolder)
	ctr = 0
	for (ncfilename in ncfilenames){
		year_ncf = substr(substrRight(strsplit(ncfilename, ".nc"),6),1,4)
		month_ncf = substr(substrRight(strsplit(ncfilename, ".nc"),6),5,6)

		nc_file = open.nc(paste(ncfolder,"/",ncfilename,sep=""))
		nc_data = read.nc(nc_file)
	
		all_lons = nc_data$lon
		all_lats = nc_data$lat
	
		if (var_ == "Prec"){nc_var = nc_data$Prec}
		if (var_ == "Tmax"){nc_var = nc_data$Tmax}
		if (var_ == "Tmin"){nc_var = nc_data$Tmin}
		if (var_ == "Wind"){nc_var = nc_data$wind}

		val = nc_var

		if (ctr == 0){
			if (is.na(shp_ext[1])){
				shp_f <- readOGR(shp_filename)
				shp_ext = c(shp_f@bbox[1,1], shp_f@bbox[1,2],
						shp_f@bbox[2,1], shp_f@bbox[2,2])
			}	
	
			ind_x = all_lons>=shp_ext[1] & all_lons<=shp_ext[2]
			ind_y = all_lats>=shp_ext[3] & all_lats<=shp_ext[4]
	
			ind_x_ = which(ind_x)
			ind_y_ = which(ind_y)

		}

		res_mat = val[ind_x_, ind_y_,]
		dimnames(res_mat)[[1]] = all_lons[ind_x_]
		dimnames(res_mat)[[2]] = all_lats[ind_y_]
		
		all_dates = format(as.Date(paste(year_ncf, "-", month_ncf, "-", seq(1,dim(val)[3],1), sep =""), format = "%Y-%m-%d"), "%Y-%m-%d")
		dimnames(res_mat)[[3]] = all_dates	
		
		if (ctr == 0){
			ans_mat = res_mat
			ctr = 1
			res_dates = all_dates
		} else {
			ans_mat = abind(ans_mat, res_mat, along = 3)
			res_dates = c(res_dates, all_dates)
		}
		
	}
	return (list(ans_mat, res_dates))
}

####### Example of FUNCTION 4 #######

##### INPUTS ##

ncfolder = "C:/Users/Sulochan Dhungel/Sulochan/R codes/NetCDF_Wrangler/nc_files"
shp_filename = "C:/Users/Sulochan Dhungel/Sulochan/R codes/NetCDF_Wrangler/Shapefile/download/layers/globalwatershed.shp"
var_ = "Wind"

ans = GetDataExtentFromSHP_allfiles(ncfolder, 
						shp_filename, 
						var_,
						shp_ext = c(NA, NA, NA, NA)) 

ans_mean = apply(ans[[1]], c(3), mean) 
ans_sd = apply(ans[[1]], c(3), sd) 

plot(as.Date(ans[[2]]), ans_mean, 'l', xlab = "Date", ylab = var_, main = "Mean")
plot(as.Date(ans[[2]]), ans_sd, 'l', xlab = "Date", ylab = var_, main = "Std Dev")



############################################################
##
## FUNCTION 5 ##
##
## Extract data from NetCDF from Future climate data file

GetFutureDataExtentFromSHP_allfiles = function(ncfolder,
							shp_filename,  
							var_ = "Wind",
							shp_ext = c(NA, NA, NA, NA)) 
## shp_ext = c(xmin, xmax, ymin, ymax)
{

	ncfilenames = list.files(ncfolder)
	ctr = 0
	for (ncfilename in ncfilenames){
		nc_st_date = as.Date(substr(ncfilename,27,34), format = "%Y%m%d")
		nc_en_date = as.Date(substr(ncfilename,36,43), format = "%Y%m%d")

		all_dates = seq.Date(nc_st_date, nc_en_date, by = "1 day")
		
		nc_file = open.nc(paste(ncfolder,"/",ncfilename,sep=""))
		nc_data = read.nc(nc_file)

		all_lons = nc_data$lon-360
		all_lats = nc_data$lat
		if (var_ == "Precip"){
			val = nc_data$pr
		}
		if (var_ == "Wind"){
			val = nc_data$pr ### Change variable name for wind
		}
		if (var_ == "Temp"){
			val = nc_data$pr ### Change variable name for temp
		}

		
		if (ctr == 0){
			if (is.na(shp_ext[1])){
				shp_f <- readOGR(shp_filename)
				shp_ext = c(shp_f@bbox[1,1], shp_f@bbox[1,2],
						shp_f@bbox[2,1], shp_f@bbox[2,2])
			}	
	
			ind_x = all_lons>=shp_ext[1] & all_lons<=shp_ext[2]
			ind_y = all_lats>=shp_ext[3] & all_lats<=shp_ext[4]
	
			ind_x_ = which(ind_x)
			ind_y_ = which(ind_y)

		}

		res_mat = val[ind_x_, ind_y_,]
		dimnames(res_mat)[[1]] = all_lons[ind_x_]
		dimnames(res_mat)[[2]] = all_lats[ind_y_]
		
		dimnames(res_mat)[[3]] = all_dates	
		
		if (ctr == 0){
			ans_mat = res_mat
			ctr = 1
			res_dates = all_dates
		} else {
			ans_mat = abind(ans_mat, res_mat, along = 3)
			res_dates = c(res_dates, all_dates)
		}
	}
	return (list(ans_mat, res_dates))
}



####### Example of FUNCTION 5 #######

##### INPUTS ##

ncfolder = "C:/Users/Sulochan Dhungel/Sulochan/R codes/NetCDF_Wrangler/nc_files_Future"
shp_filename = "C:/Users/Sulochan Dhungel/Sulochan/R codes/NetCDF_Wrangler/Shapefile/download/layers/globalwatershed.shp"
var_ = "Precip"

ans = GetFutureDataExtentFromSHP_allfiles(ncfolder, 
						shp_filename, 
						var_,
						shp_ext = c(NA, NA, NA, NA)) 

ans_mean = apply(ans[[1]], c(3), mean) 
ans_sd = apply(ans[[1]], c(3), sd) 

plot(as.Date(ans[[2]]), ans_mean*1000, 'l', xlab = "Date", ylab = paste("Future ", var_, " (mm)", sep=""), main = "Mean")
plot(as.Date(ans[[2]]), ans_sd*1000, 'l', xlab = "Date", ylab = paste("Future ", var_, " (mm)", sep=""), main = "Std Dev")



















