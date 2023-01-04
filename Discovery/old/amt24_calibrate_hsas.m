# read hasa digital counts and apply calibration coefficients
clear all
close all
 
pkg load financial

graphics_toolkit("gnuplot");
addpath rad_functions



####
disp("NEXT TIME MAKE SURE THAT EACH JDAY IS STORED IN ITS OWN DIRECTORY");
keyboard

### parameters
    DIR_RAW_DATA = "../../../HSAS/Satcon_extracted/Digital_Counts/";
    DIR_CAL = "../2006_system/";
        ### which cals to use? Average or only one?
        # pre- and post- cruise cals are available
        din_cals = {"CAL_F/","CAL_G/"}; # these are the dirs containig the PRE and POST cals relative to AMT24

    SN = {"222", "223", "258"};
    CRUISE = "AMT24"; # string used in filenames



## compare pre- and post-cruise cals
for iSN = 2:length(SN)

     
    for ical = 1:length(din_cals)

        fncal = glob([DIR_CAL din_cals{ical} "*" SN{iSN} "*.cal"]);
        
        if length(fncal)>2 # this is for when there are more cal files for one instrument (e.g., CAL_G SN223)
            fncal = sort(fncal){1};
        elseif
            fncal = fncal{2}
        endif
        
        # read and store cal files
        cal{ical} = hsas_rd_satlantic_cal(fncal);
        
        offset_(ical,:) = cal{ical}.offset;
        gain_(ical,:) = cal{ical}.gain;
        wv_(ical,:) = cal{ical}.wv;
        int_time_(ical,:) = cal{ical}.int_time_wv;       

    endfor

    
    
    
        
    # plot  post/pre-1 cal coefficients
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
    
    
        
    ## compute and write average cal file (+ uncertainty)
        # compute stats of cal coeffs
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
            
        if ~exist([DIR_CAL CRUISE])    
            mkdir([DIR_CAL CRUISE]);  
        endif
        
        fnout_cal = [DIR_CAL CRUISE "/mean_" strsplit(fncal, {"/","."}){end-1}(1:end-1) ".cal"]   ;    
        save("-binary", fnout_cal, "cal", "gain", "offset", "wv", "int_time");
        
        
        ###### calibrate data from this instrument
        
            # these are the files to process
                fn = glob([DIR_RAW_DATA "*" SN{iSN} "?.dat"]);
        
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
                out.cal_file = fnout_cal;
                out.(ff) = hsas_calibrate(L_CountsLightDat=out.(out.instru), L_CalDarkDat=offset.mean, gain.mean, immers_coeff=1, it_1=int_time, it_2=out.int_time_sec);

                ### sort fields alphabetically
                out = orderfields(out);
                
                ### write calibrated files (which format?)       
                fnout = strrep(out.satcon_file, "Digital_Counts", "Physical_units");
                hsas_write_calibrated_Satlantic_file_format(fnout, out, DELIM=' ');
                
            endfor
        

endfor













