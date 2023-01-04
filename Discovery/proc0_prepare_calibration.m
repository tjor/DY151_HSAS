# read hasa digital counts and apply calibration coefficients
clear all
close all
 
% pkg load financial

graphics_toolkit("gnuplot");

warning off #Turn off warnings

addpath("../Discovery")
addpath("../Discovery/cruise_specific_functions")
addpath("../Discovery/rad_functions/")
addpath("../Discovery/rad_functions/intwv")
addpath("../Discovery/rad_functions/DISTRIB_fQ_with_Raman")
addpath("../Discovery/rad_functions/DISTRIB_fQ_with_Raman/D_foQ_pa")


# read input parameters for this cruise
input_parameters_hsas


		
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
     
	 
	#initialize variables
	clear fncal cal offset_ gain_ wv_ int_time_
	 
    for ical = 1:length(din_cals)

        % fncal = glob([DIR_CAL din_cals{ical} "*" SN{iSN} "*.cal"]);
        fncal = glob([din_cals{ical} "*" sn{iSN} "*.cal"]);
        
        if length(fncal)>2 # this is for when there are more cal files for one instrument (e.g., CAL_G SN223)
            fncal = sort(fncal){1};
        elseif
            fncal = fncal{2};
        endif
        
        # read and store cal files
        cal{ical} = hsas_rd_satlantic_cal(fncal);
        
        offset_(ical,:) = cal{ical}.offset;
        gain_(ical,:) = cal{ical}.gain;
        wv_(ical,:) = cal{ical}.wv;
        int_time_(ical,:) = cal{ical}.int_time_wv;       

    endfor

    
    
    # plot  post/pre-1 cal coefficients    
	if length(cal)==2    

       figure(1, 'visible', 'off');
        clf
        hold on
        subplot(121)
            plot(cal{1}.wv, cal{2}.offset./cal{1}.offset-1, [";" datestr(cal{1}.date, "yyyy/mmm/dd") "\n" datestr(cal{2}.date, "yyyy/mmm/dd") ";"])
            ylim([-1 1]*mean(abs(cal{2}.offset./cal{1}.offset-1))*1.5)
            set(gca, 'ygrid', 'on', 'gridlinestyle', ':');
            hold on, plot(cal{1}.wv, cal{1}.wv*0, 'k')
            xlim([350 850])
            
            xlabel('wavelength [nm]')
            ylabel('POST/PRE -1 ')
            title('offset')
            
        subplot(122)
            plot(cal{1}.wv, cal{2}.gain./cal{1}.gain-1, [";" datestr(cal{1}.date, "yyyy/mmm/dd") "\n" datestr(cal{2}.date, "yyyy/mmm/dd") ";"])
            ylim([-1 1]*0.05)
            set(gca, 'ygrid', 'on', 'gridlinestyle', ':');
            hold on, plot(cal{1}.wv, cal{1}.wv*0, 'k')
            xlim([350 850])
               
            xlabel('wavelength [nm]')
            #ylabel('ppost/pre -1 [-]')
            title('gain')

        
        set(gcf, 'paperposition', [0.25 0.25 12 4])
        fnout = [DIR_CAL CRUISE "/rel_change_in_cal_coeffs_" strsplit(fncal, {"/","."}){end-1}(1:end-1) ".png"]   ;
        print("-dpng", fnout);
	endif 
    
        
    ## compute and write average cal file (+ uncertainty) for this instrument SN
        # compute stats of cal coeffs
		if length(cal)==2
            gain.mean = mean(gain_);
            gain.unc = std(gain_);
            gain.n = size(gain_,1);
            
            offset.mean = mean(offset_) ;
            offset.unc = std(offset_);
            offset.n = size(offset_,1);
            
            int_time = mean(int_time_);
            
            if ical>1 & ~all(std(int_time_,[],1)<=eps)
                disp('integration time has changed beytween calibrations!!!');
                keyboard
            endif
            
            wv = mean(wv_);
            
            if ical>1 & ~all(std(wv_,[],1)<=eps)
                disp('wavelengths have changed beytween calibrations!!!');
                keyboard
            endif
			
		elseif length(cal)==1
			
            gain.mean = gain_;
            gain.unc = gain_*nan;
            gain.n = size(gain_,1);
            
            offset.mean = offset_ ;
            offset.unc = offset_*nan;
            offset.n = size(offset_,1);
            
            int_time = mean(int_time_);
  
            wv = wv_;
			
		endif	
			
			
			
	# save existing calibrations in octave binary format
       	if ~exist([DIR_CAL CRUISE])    
            mkdir([DIR_CAL CRUISE]);  
        endif
        
       	fnout_cal = [DIR_CAL CRUISE "/mean_" radiometers{iSN} sn{iSN} ".cal"]   ;    
       	save("-binary", fnout_cal, "cal", "gain", "offset", "wv", "int_time");
        
        
	    

endfor # sn













