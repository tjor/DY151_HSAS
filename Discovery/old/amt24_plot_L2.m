# plot L@ files to make sure everything is OK
clear all
close all



DIN = "/data/lazarev1/backup/cruise_data/AMT24/DallOlmo/HSAS/Processed_final/L2/";
DOUT_PLOT = "~/Dropbox/tmp/";
#DOUT_PLOT = "/data/lazarev1/backup/cruise_data/AMT24/DallOlmo/HSAS/Processed_final/plots/L2/";

XLIMS = [350 750];

fn = glob([DIN "*mat"]);

for ifn =1:length(fn)

   clear L2 L1_f

   load(fn{ifn});

   figure(1, 'visible', 'off')

   clf
      subplot(241)
         hold on
            plot(L1_f.time, L1_f.instr.Es.data(:,L1_f.wv==550), "ko-")
            plot(L2.time, L2.instr.Es.data(:,L2.wv==550), "ro")
         datetick("x", "HH");
         xlabel ("hour")
         ylabel ("Es(550) [uW/cm^2/nm]")

      subplot(242)
         hold on
            plot(L1_f.time, L1_f.phi, "ko-")
            plot(L2.time, L2.phi, "ro")
         datetick("x", "HH");
         xlabel ("hour")
         ylabel ("\Delta Azimuth(sensor-sun) [degrees]")

      subplot(243)
         hold on
            plot(L2.wv, L2.Rrs.data, "r-")
            plot(L2.wv, L2.wv*0, 'k')
            plot(L2.wv, L2.Rrs.data(L2.phi<90,:), 'k')
         xlabel("wavelength [nm]")
         ylabel("Rrs [1/sr]")
         set(gca, 'pos', [0.55699   0.58682   0.30   0.33818])

         ylim([-0.0025 0.020])


      #subplot(244)


      subplot(245)
         hold on
            plot(L2.wv, L2.instr.Lt.data, "r-")
         xlabel("wavelength [nm]")
         ylabel("Lt [uW/cm^2/nm/sr]")

      subplot(246)
         hold on  
#            plot(L1_f.wv, L1_f.instr.Lt.data, "k-")
            plot(L2.wv, L2.instr.Es.data, "r-")
         xlabel("wavelength [nm]")
         ylabel("Es [uW/cm^2/nm]")

      subplot(247)
         hold on
#            plot(L1_f.wv, L1_f.instr.Li.data, "k-")
            plot(L2.wv, L2.instr.Lt.data, "r-")
         xlabel("wavelength [nm]")
         ylabel("Li [uW/cm^2/nm/sr]")

      subplot(248)
         hold on
            plot(L1_f.time, L1_f.instr.Lt.data(:,L1_f.wv==440), "ko-")
            plot(L2.time, L2.instr.Lt.data(:,L2.wv==440), "ro")
         datetick("x", "HH")
         xlabel("hour")
         ylabel("Lt(440) [uW/cm^2/nm/sr]")

set(gcf, 'paperposition', [0.25 0.25 14 6])

[tmp,ff] = fileparts(fn{ifn});
fnout = [DOUT_PLOT, ff ".png"];
print("-dpng", fnout)

endfor



