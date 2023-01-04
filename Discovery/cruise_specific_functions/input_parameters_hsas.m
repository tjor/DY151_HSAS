# this is a script that contains all (I hope) the variables parameters for each cruise

# DY151 version is based on adding relavant sections of FICE HSAS code (which contains new sensor configuration) 
# with Discovery branch of AMT code


#Turn off/on verbose reporting
	VBS = true;

# year of dataset (e.g., 2019)
	DEF_YEAR = 2022;
	
# cruise name (e.g., AMT29)
	CRUISE = "DY151";

# HSAS instruments serial numbers - these are for 2022 deployments onwards
        INSTRUMENT = "hsas";
	radiometers = {"ES", "LI", "LT"};#  (similar instrument must be listed one after the other)
	sn = {"2027", "2054", "464"};
	file_ext = {"H[ES][DE]", "*H[LS][DL]", "*H[LS][DL]", "SAT"}; # wildcards to read files for each instrument
	cal_files_pre = {"SAT2027.cal", "SAT2054.cal", "SAT464.cal"};
	cal_files_post = {"SAT2027.cal", "SAT2054.cal", "SAT464.cal"};

# Set wavelength range
   wv = [350:2:860]';  #Consistent with JRC format

# main dir (e.g., /data/datasets/cruise_data/active/AMT29)
MAIN_DIR = "/data/datasets/cruise_data/active/DY151";   

DIN_HSAS = [MAIN_DIR "Hypersas/Raw/RawExtracted/"]; 
DOUT_HSAS = [MAIN_DIR "Hypersas/Processed/"];

### INSTRUMENT serial numbers for trios (at least) are hardcoded
### SINGLE HARDCODED PATH REMAINS TO THS DATA BELOW AND DEF_YEAR IS HARDCODED ###
OSX = 0;

# main directories
% DOUT_SUFFIX = "../Processed_final/"; # this is the supphix that is appended to the DATA_PATH dir to define the directory for the output processed files

DIR_GPS = [MAIN_DIR "Data/Ship_uway/GPS/"]; # updated for DY151 GPS and ATT file names
GLOB_GPS = '*position-POSMV_GPS*';

DIR_ATT = [MAIN_DIR "Data/Ship_uway/ATT/"]; # pitch and roll
GLOB_ATT = '*shipattitude-POSMV_ATT.att*';

DIR_WIND = [MAIN_DIR "Data/Ship_uway/SURFMETV3/"];
GLOB_WIND = "*MET*.SURFMETv3"; # glob pattern for Discovery wind data to concatenate after DATESTR

DIR_SURF = [MAIN_DIR "Data/Ship_uway/SURFMETV3/"];
GLOB_SURF = "*MET*.SURFMETv3"; # glob pattern for wind data to concatenate after DATESTR


DIR_TEMPCORR = [MAIN_DIR "Hypersas/HyperSAS_config/Temperature/"]; # 
FN_TEMPCORR_ES = "cp_thermal_SAT2027.txt"; # File name of temperature correction factors 
FN_TEMPCORR_LT = "cp_thermal_SAT2054.txt"
FN_TEMPCORR_LI = "cp_thermal_SAT0464.txt"

DIR_SLCORR = [MAIN_DIR "Hypersas/HyperSAS_config/Straylight/"];
FN_SLCORR_ES = "cp_straylight_SAT2027.txt"; # File names of Straylight correction
FN_SLCORR_LT = "cp_straylight_SAT0464.txt";
FN_SLCORR_LI = "cp_straylight_SAT2054.txt";

DIR_CAL = [MAIN_DIR "Hypersas/HyperSAS_config/"];
DIN_CALS_PRE = [DIR_CAL "Pre/"];
DIN_CALS_POST = [DIR_CAL "Post/"];

DIR_CAL = [MAIN_DIR "Hypersas/HyperSAS_config/"];
DIN_CALS_PRE = [MAIN_DIR "HyperSAS_config/Pre/"];
DIN_CALS_POST = [MAIN_DIR "HyperSAS_config/Post/"]; 

DIN_Non_Linearity = [MAIN_DIR "HyperSAS_config/Non-linearity/"]; 
NL_files_pre = {"Pre/cp_radcal_SAT2027.txt", "Pre/cp_radcal_SAT2054.txt", "Pre/cp_radcal_SAT0464.txt"};
NL_files_post = {"Post/cp_radcal_SAT2027.txt", "Post/cp_radcal_SAT2054.txt", "Post/cp_radcal_SAT0464.txt"};


#-ACS data Path
# FN_ACS = [MAIN_DIR, "ACSChl/ACStoHSAS_sentinel3a_olci_AMT29.txt"]; - commented out for now; is this ACS-derived chl?

# Define names of functions needed to read GPS, HDG, PITCH, ROLL, TILT
FNC_RD_ATT = @rd_DY_att;# function to read ptitch and roll 
FNC_RD_GPS = @rd_DY_gps;# function to read gps and heading 
FNC_RD_WIND = @rd_DY_wind; # function to read wind speed and direction 
FNC_RD_SURF = @rd_DY_surf; # function to read other met and surface data collected by the ship 


##########################################
## Parameters for L2 processing
#
# type of filtering applied to data
FILTERING  = 'continuous'; # 	L1_f = hsas_filter_sensors_using_Lt_data_v2(L1_f, L1_f, 'vaa_ths'); 
% FILTERING  = 'lowest'; # 		L1_f = hsas_filter_sensors_using_Lt_data(L1_f, L1_f, 25, 'vaa_ths')
% FILTERING  = 'both'; # 		L1_f = hsas_filter_sensors_using_Lt_data_v2(L1_f, L1_f, 'vaa_ths');
		  			   # 		L1_f = hsas_filter_sensors_using_Lt_data(L1_f, L1_f, 25, 'vaa_ths');

#
# directory where the ship's underway data are stored
% DIR_SHIP = "/data/datasets/cruise_data/active/AMT24/Ship_data/Compress/Compress/days/";
#
# base dir fir L1 files
DIN_L1 = [MAIN_DIR "Hypersas/Processed/L1/"];
#
# maximum tilt accepted 
MAX_TILT = 5; # [degrees]
#
# nominal viewing angle of Li sensor wrt zenith (depends on installation)
LI_VA = 50; # [degrees]


# directory with Discovery wind data





#----------------------------------
### Read THS data ###
%
% if OSX==1;
%    din_ths = ["/Volumes/Rivendell/AMT/raw_data/Hsas/SatCon_Extracted_oldcal/" num2str(doy) "/"];
% else
%    din_ths = [DATA_PATH "Hsas/Processed_final/Extracted/" num2str(doy) "/"];
% endif
%
% fnths   = glob( [din_ths "*SATTHS*dat"] );
% ths     = hsas_rd_ths(fnths);






% # above-water TRIOS instrument serial numbers
% 	sn = {"82C1", "ES"};
%     sn = {"8313", "LI"};
%     sn = {"8346", "LT"};
%
%
% # in-water TRIOS instrument serial numbers
%     sn = {"8508", "LU"};
%
% 	# Apply immersion factor for calibration in water vs air - currently uses factor calculated from default files provided by Marco
%     if_out = csvread('/data/datasets/cruise_data/active/AMT26/PML_optics/HEK_processing/code/inwater_cals/immersion_factors.csv');
	

# Method for interpolating to the same time step
TIME_INT_METHOD = "linear";

# Tilt filter
MAX_TILT_ACCEPTED_L1 = 5;

# SZA filter
MAX_SZA_L2 = 80; # degrees]
MIN_SZA_L2 = 10; # degrees]


# PHI filter
MAX_PHI_L2 = 170; # degrees]
MIN_PHI_L2 =  50; # degrees]
 



