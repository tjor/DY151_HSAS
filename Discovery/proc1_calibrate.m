# read hasa digital counts and apply calibration coefficients
clear all
close all
 
% pkg load financial

graphics_toolkit("gnuplot");

warning off #Turn off warnings

%addpath("~/Dropbox/Octave_functions/")
addpath("../Discovery")
addpath("../Discovery/cruise_specific_functions")
addpath("../Discovery/rad_functions/")
addpath("../Discovery/rad_functions/intwv")
addpath("../Discovery/rad_functions/DISTRIB_fQ_with_Raman")
addpath("../Discovery/rad_functions/DISTRIB_fQ_with_Raman/D_foQ_pa")


# read input parameters for this cruise
input_parameters_hsas;

fnin = argv();
disp(fnin)

disp('----------------------------------------------------------------------------------------------------------');
disp(fnin{1});
disp('----------------------------------------------------------------------------------------------------------');
fflush(stdout);

DATESTR = fnin{1};
		
## these are the dirs containig the PRE and POST cals 
	if isempty(DIN_CALS_POST) 
	    din_cals = {DIN_CALS_PRE}; 
	else
	    din_cals = {DIN_CALS_PRE, DIN_CALS_POST}; 
	endif



## compare pre- and post-cruise cals
for iSN = 1:length(sn)
	
	disp([ "processing SN = " num2str(iSN) ]);
	fflush(stdout);
     
	 
        
   	fn_cal = [DIR_CAL CRUISE "/mean_" radiometers{iSN} sn{iSN} ".cal"]   ;    
   	load(fn_cal);
        
   
   ####### Read non-linearity correction coefficients ##########
    pkg load io
    #---radiometer related to sn
    disp('Loading Non-linearity correction coefficients....')  
    rad_sn = cell2struct(sn,radiometers,2);
    sn_rad = cell2struct(radiometers, sn, 2);
    coeff_LI = xlsread(DIN_Non_Linearity,rad_sn.LI);
    coeff_LT = xlsread(DIN_Non_Linearity,rad_sn.LT);
    coeff_ES = xlsread(DIN_Non_Linearity,rad_sn.ES);
    non_linearity_coeff = struct('coeff_LI',coeff_LI(:,1:2),'coeff_LT',coeff_LT(:,1:2),'coeff_ES',coeff_ES(:,1:2));	
      
  		
    #----Read Straylight Distribution Matrix
    disp('Loading StrayLight Distribution Matrix....')  
    sensor_id = sn{iSN};
    if sn_rad.(sensor_id) == 'ES'
    fn=[DIR_SLCORR,FN_SLCORR_ES];
    end
    if sn_rad.(sensor_id) == 'LI'
    fn=[DIR_SLCORR,FN_SLCORR_LI];
    end
    if sn_rad.(sensor_id) == 'LT'
    fn=[DIR_SLCORR,FN_SLCORR_LT];
    end
  
    D = load(fn);
    D_SL = D / norm(D);

	###### calibrate data from this instrument

	# these are the files to process
	fn = glob([DIN_HSAS DATESTR "/" "*" sn{iSN} ".dat"]);
    disp(fn)

    for ifn = 1:length(fn)
    
		disp(sprintf("%u/%u", ifn, length(fn)));
		fflush(stdout);

        # read digital counts
        	out = hsas_rd_digital_counts(fn{ifn});
		    if isempty(out.time)
				continue;
		    endif            
	
        ### apply cal
            ff = [out.instru "cal"];
            out.cal_file = fn_cal;
            out.(ff) = hsas_calibrate_with_correction(sn{iSN}, out.wv, L_CountsLightDat=out.(out.instru), L_CalDarkDat=offset.mean, gain.mean,immers_coeff=1, it_1=int_time, it_2=out.int_time_sec, rad_sn, sn_rad, non_linearity_coeff,D_SL);
            #out.(ff) = hsas_calibrate(L_CountsLightDat=out.(out.instru), L_CalDarkDat=offset.mean, gain.mean, immers_coeff=1, it_1=int_time, it_2=out.int_time_sec);

        ### sort fields alphabetically
            out = orderfields(out);
            
        
        ### write calibrated files (which format?)       
			dout = [DOUT_HSAS "Calibrated/" DATESTR "/"]; # create dir for calibrated files
			if ~exist(dout)
				mkdir(dout);
			endif

            fnout = strrep(out.satcon_file, "RawExtracted", "Calibrated");
            fnout = strrep(fnout, "/Raw/", "/Processed/");
			
            hsas_write_calibrated_Satlantic_file_format(fnout, out, DELIM=' ');
        	
			disp(["Written calibrated file: " fnout]);
			fflush(stdout);
			
    endfor # fn
      
	  

endfor # sn













