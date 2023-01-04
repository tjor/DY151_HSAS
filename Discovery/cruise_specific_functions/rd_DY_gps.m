function out = rd_DY_gps(fn)
% function out = rd_DY_gps(fn)
% 
% read gps data generated by Discovery instrumentation
% (should work for Applanix, Phins and Seapath)
%
% out contains time, lat, long, true_heading, ground speed, ground course
%
pkg load netcdf

out.time = ncread(fn, 'time'); #"days since 1899-12-30 00:00:00 UTC"
out.time = out.time + datenum([1899 12 30 00 00 00]);
out.lat = ncread(fn, 'lat');
out.lon = ncread(fn, 'long');
out.hdg = ncread(fn, 'heading');
out.cog_deg = ncread(fn, 'gndcourse');
out.sog_m2s = ncread(fn, 'gndspeed');
	
	
endfunction