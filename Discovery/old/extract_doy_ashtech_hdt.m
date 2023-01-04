# this script separates the seatex-htg.ACO file into files containing different doy 
clear all

DIN = "/data/datasets/cruise_data/active/AMT24/Ship_data/Compress/Compress/";
fn = "/data/datasets/cruise_data/active/AMT24/Ship_data/Compress/Compress/ashtech.ACO";

#id = load(fn);
for idoy =265:306
	disp(num2str(idoy));
	system(	sprintf(['grep 2014,%3u   %s > %s./days/ashtech/ashtech.%3u' ], idoy, fn, DIN, idoy)  );
	fflush(stdout);	
 	
endfor


