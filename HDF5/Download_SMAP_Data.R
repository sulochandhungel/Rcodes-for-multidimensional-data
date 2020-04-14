# Author: Sulochan Dhungel
# 4/14/2020
#wget --http-user=sulochandhungel --http-password=N*******_** --load-cookies mycookies.txt --save-cookies mycookies.txt --keep-session-cookies --no-check-certificate --auth-no-challenge -r --reject "index.html*" -np -e robots=off -O test.h5 https://n5eil01u.ecs.nsidc.org/SMAP/SPL3SMP.004/2016.03.30/SMAP_L3_SM_P_20160330_R14010_001.h5


######### THESE INSTRUCTIONS ARE FOR WINDOWS MACHINE ###################

# STEP 1 > Depending on whether your system is 32 bit or 64 bit,
#	download "wget.exe" or "wget64.exe" from 
# 	https://eternallybored.org/misc/wget/
#
# 	Side_Note: Although the webpage says that 'wget.exe' or 'wget64.exe' file doesn't require any other files to work,
#	I downloaded the corresponding ".zip" file and extracted it all to one folder. I preferred to copy the folder
# 	to "Program Files" directory but it also works from any other directories.


# STEP 2 >Using instructions below or from the link given below, add folder which contains 
#	'wget.exe' or 'wget64.exe' to list of environmental variable path
#
#	1. Right Click "My Computer" -> 2. Properties -> 3. Advanced System Settings ->
#	4. Environmental Variables... -> 5. Select Path under System Variables (LOWER PANEL) ->
#	6. Edit... -> 7. Add the path where "wget.exe" resides(e.g. "C:\Users\Sulochan\wget64\") to the list ->
# 	7. Click OK to close all the dialog boxes.

#	If you cannot follow the above instructions, follow the following link with
#	screenshots. Follow the steps for "How to Add a Folder to Your PATH"
#	https://www.howtogeek.com/118594/how-to-edit-your-system-path-for-easy-command-line-access/

# STEP 3 > Create a new text file in the same folder (where 'wget.exe' or 'wget64.exe' resides) and name it "mycookies.txt".

# STEP 4 > Register using the following link  
#	https://urs.earthdata.nasa.gov/users/new
#	to get an account. 
#
#	After the registration is active,
#	remember Username and Password




#################################################################
#
# ------------ DOWNLOAD A SINGLE SMAP FILE ---------------#######
#

# Inputs required to download data

# Change "\" to either "\\" or "/" 
download_dir = "C:/Users/Sulochan Dhungel/Desktop/junk/NASA"
#download_dir = "C:\\Users\\Sulochan Dhungel\\Desktop\\NASA\\SMAP\\Demo\\Data\\Data\\DOWNLOADED_DATA"


usrname = "sulochandhungel"
pswd = "N*******_**"

yr = 2016
mo = 4
da = 25



####----------- Which SAMP product do you want? ---------------##########
### This code lets you download 5 types of SMAP products at Global Scale

# 1 > SMAP L3 Radar/Radiometer Global Daily 9 km EASE-Grid Soil Moisture 
# Temproal coverage => 2015-04-13 to 2015-07-07

# 2 > SMAP L3 Radar Global Daily 3 km EASE-Grid Soil Moisture
# Temporal coverage => 2015-04-13 to 2015-07-07

# 3 > SMAP Enhanced L3 Radiometer Global Daily 9 km EASE-Grid Soil Moisture
# Temporal coverage => 2015-03-31 to continuous

# 4 > SMAP L3 Radiometer Global Daily 36 km EASE-Grid Soil Moisture
# Temporal coverage => 2015-03-31 to continuous

# 5 > SMAP L4 Global Daily 9 km Carbon Net Ecosystem Exchange
# Temporal Coverage => 2015-03-31 to continous

# Based on https://nsidc.org/data/search/#keywords=SMAP+soil+moisture+daily/facetFilters=Show Global Only



##### -------- Input Parameters for SMAP --------------------#############

# SELECT the value of "SMAP_Product_Number" and "SMAP_version" number 
# according to what you need!

SMAP_Product_Number = 2 

SMAP_version_number = "" # If left empty, defaults to the current
			       # version number on April 6, 2017
				# e.g ".003"



#### --------------- Select parts of link according to different products here ----- ###

# 1 -> SMAP L3 Radar/Radiometer Global Daily 9 km EASE-Grid Soil Moisture
#	http1://nsidc.org/data/SPL3SMAP

if (SMAP_Product_Number == 1){
	
	SMAP_product = "SPL3SMAP"

	if (SMAP_version_number == ""){
		SMAP_version = ".003"
	} else {
		SMAP_version = SMAP_version_number
	}

	prd_long = "SMAP_L3_SM_AP"
	fpath_end = "R13080_001.h5"
}


# 2 -> SMAP L3 Radar Global Daily 3 km EASE-Grid Soil Moisture
#	https://nsidc.org/data/SPL3SMA

if (SMAP_Product_Number == 2){
	
	SMAP_product = "SPL3SMA"

	if (SMAP_version_number == ""){
		SMAP_version = ".003"
	} else {
		SMAP_version = SMAP_version_number
	}

	prd_long = "SMAP_L3_SM_A"
	fpath_end = "R13080_001.h5"
}


# 3 -> SMAP Enhanced L3 Radiometer Global Daily 9 km EASE-Grid Soil Moisture
#	https://nsidc.org/data/SPL3SMP_E

if (SMAP_Product_Number == 3){
	
	SMAP_product = "SPL3SMP_E"

	if (SMAP_version_number == ""){
		SMAP_version = ".001"
	} else {
		SMAP_version = SMAP_version_number
	}

	prd_long = "SMAP_L3_SM_P_E"
	fpath_end = "R14010_001.h5"
}


# 4 -> SMAP L3 Radiometer Global Daily 36 km EASE-Grid Soil Moisture
#	https://nsidc.org/data/SPL3SMP

if (SMAP_Product_Number == 4){
	
	SMAP_product = "SPL3SMP"

	if (SMAP_version_number == ""){
		SMAP_version = ".004"
	} else {
		SMAP_version = SMAP_version_number
	}

	prd_long = "SMAP_L3_SM_P"
	fpath_end = "R14010_001.h5"
}


# 5 -> SMAP L4 Global Daily 9 km Carbon Net Ecosystem Exchange
#	http://nsidc.org/data/SPL4CMDL

if (SMAP_Product_Number == 5){
	
	SMAP_product = "SPL4CMDL"

	if (SMAP_version_number == ""){
		SMAP_version = ".002"
	} else {
		SMAP_version = SMAP_version_number
	}

	prd_long = "SMAP_L4_C_mdl"
	fpath_end = "T000000_Vv2040_001.h5"
}

##

################ END OF DIFFERENT SMAP PRODUCTS SELECTION #################

###



# FUNCTION: Download_single_SMAP
#
# This function downloads SMAP data for a day

Download_single_SMAP = function(download_dir, yr, mo, da, SMAP_product, SMAP_version, prd_long, fpath_end){
 
	# FUNCTION: get_lead_zero
	#
	# This function is used to add leading zeros to the month and days
	#
	get_lead_zero = function(n){
		if (n<10){
			n_ = sprintf("0%d", n)
		} else {
			n_ = sprintf("%d", n)}
		return (n_)
	}
	# 
	# get_lead_zero function end

	mo_ = get_lead_zero(mo) #Add leading zero to month -> e.g Converting "5" to "05"
	da_ = get_lead_zero(da) #Add leading zero to days -> e.g. Converting "9" to "09"

	org_dir = getwd() # Get the current directory

	setwd(download_dir) # Set the current directory to the path where files get downloaded

	out_file_name = paste(prd_long,
				"_",
				yr,mo_,da_,
				"_",
				fpath_end, sep="")

	# Following is the command which when used in command prompt downloads the file
	#
	download_link = paste("wget --http-user=",
				usrname,
				" --http-password=",
				pswd,
				" --load-cookies mycookies.txt --save-cookies mycookies.txt --keep-session-cookies --no-check-certificate --auth-no-challenge -r --reject \"","index.html*","\"",
				" -np -e robots=off -O ",
				out_file_name,
				" https://n5eil01u.ecs.nsidc.org/",
				"SMAP",
				"/",
				SMAP_product,
				SMAP_version,
				"/",
				yr,".",mo_,".",da_,
				"/",
				prd_long,
				"_",
				yr,mo_,da_,
				"_",
				fpath_end,
				sep="")
	# If the SMAP_product is Number 5 (SMAP L4 Global Daily 9 km Carbon Net Ecosystem Exchange)
	# the download link is a bit different so,

	if (SMAP_product == "SPL4CMDL"){
		download_link = paste("wget --http-user=",
				usrname,
				" --http-password=",
				pswd,
				" --load-cookies mycookies.txt --save-cookies mycookies.txt --keep-session-cookies --no-check-certificate --auth-no-challenge -r --reject \"","index.html*","\"",
				" -np -e robots=off -O ",
				out_file_name,
				" https://n5eil01u.ecs.nsidc.org/",
				"SMAP",
				"/",
				SMAP_product,
				SMAP_version,
				"/",
				yr,".",mo_,".",da_,
				"/",
				prd_long,
				"_",
				yr,mo_,da_,
				"", # This is the line where an "_" is not needed!
				fpath_end,
				sep="")
	}
	print (download_link)

	system(download_link,intern=TRUE) # Send "download_link" to command prompt
	#system("taskkill /IM wget64.exe") #Closes Wget64.exe if the file needs to be deleted
	
	setwd(org_dir) # Change the directory back to where it was 
}


###################################################################################################
###
## -------------------- BULK DOWNLOAD OF SMAP DATA BY DATE RANGE ---------------------------#######
##


# USING THE FUNCTION ABOVE WE DOWNLOAD A LIST OF SMAP FILES FOR A SEQUENCE OF DATES

# Inputs required to download data

# Change "\" (default path notation) to - either "\\" or "/" for R 
#download_dir = "C:/Users/Sulochan Dhungel/Desktop/NASA/SMAP/Demo/Data/Data/DOWNLOADED_DATA"
#download_dir = "C:\\Users\\Sulochan Dhungel\\Desktop\\NASA\\SMAP\\Demo\\Data\\Data\\DOWNLOADED_DATA"


usrname = "sulochandhungel"
pswd = "N*******_**"

#SMAP_product = "SPL3SMP"
#SMAP_version = ".004/"

#prd_long = "SMAP_L3_SM_P"
#fpath_end = "R14010_001.h5"

Start_Date = "2015-04-25"
End_Date = "2015-04-25"

seq_Dates = as.character(seq(as.Date(Start_Date, format = "%Y-%m-%d"), 
				as.Date(End_Date, format = "%Y-%m-%d"), 
				by = "days"))

for (myDate in seq_Dates){
	yr = as.numeric(strsplit(myDate,"-")[[1]][1])
	mo = as.numeric(strsplit(myDate,"-")[[1]][2])
	da = as.numeric(strsplit(myDate,"-")[[1]][3])

	Download_single_SMAP(download_dir, yr, mo, da, SMAP_product, SMAP_version, prd_long, fpath_end)
}

