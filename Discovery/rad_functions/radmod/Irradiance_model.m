%this code will provide the scalar irradiance at any depth given the time;


%##############  Atmospheric model inputs ##################
	dectime=(200:20/1440:201)'; %decimal time (days); Jan 1 = 1
    latinput=60; %decimal latitude (degrees)
	hemisinput=1;% Hemisphere 1=N -1=S
    longinput=24; %decimal longitude (degrees)
    Pspinput=0; %pyranometer readings (W m-2)
    slvpinput=1013.25; %sea-level pressure (mb)
    Drytinput=0; %dry air temperature (deg C)
    relhuminput=80; %relative humidity (%)
    windspdinput=0; %wind speed (m s-1)
    windavginput=0; %24hr mean wind speed (m s-1)
    Ozoneinput=350; %Ozone level (Dobson units)
    %testing z_mat
    
    z_mat=repmat([0:200]',1,length(dectime));
    
% ################### in water input #################
%This will use the Morel 2001 model for Kd so only chlorophyll is needed
chl =1;

    
    %Now runs the Gregg and Carder model plus arrigo plus Bird Riordan
    %model for all the time and parameters above.
    %This provides the irradiance just below the sea_surface
    [IT,IS,ID,PAR,PARW,wave,zenang]=radmod_func(dectime,hemisinput,latinput,longinput,Pspinput,slvpinput,Drytinput,relhuminput,windspdinput,windavginput,Ozoneinput);
 %Keeping only the PAR wavelength for nor
 IT=IT(:,wave>=400&wave<=700);
 IS=IS(:,wave>=400&wave<=700);
 ID=ID(:,wave>=400&wave<=700);
 wave=wave(wave>=400&wave<=700);
 Ezero = escalarcalc(dectime,ID,IS,IT,zenang);
 %changin to umol m-2 s-1
 
 Ezero=Ezero.*repmat(wave,size(Ezero,1),1)*1e-9./(6.022e23*1e-6*6.626e-34*3e8);
    
fid=fopen('morel2001_kds.txt','r');
out=read_databin(fid);
lambda=out{2}(:,1);
Kw=out{2}(:,2);
epsilon=out{2}(:,3);
xsi=out{2}(:,4);

%Bricaud stuff
fid=fopen('bricaud1995_table_2')
out=read_databin(fid);
lambda_bricaud=out{2}(:,1);
A_bricaud=out{2}(:,2);
B_bricaud=out{2}(:,3);
%interpolating at all wavelength
A_bricaud=interp1(lambda_bricaud, A_bricaud,wave);
B_bricaud=interp1(lambda_bricaud, B_bricaud,wave);
%Creating the a* vectors
a_star_bricaud=repmat(A_bricaud',1,length(chl)).*(repmat(chl,length(A_bricaud),1).^repmat(-B_bricaud',1,length(chl)));

% Morel biological K
Kbio=repmat(xsi,1,length(chl)).*(repmat(chl,length(epsilon),1).^repmat(epsilon,1,length(chl)));
%Total K
Ktot=repmat(Kw,1,length(chl))+Kbio;

% What I need is to compute PUR at these depths.
% So I need to interpolate the Kd to the wavelength

Ktot=interp1(lambda,Ktot,wave);
a_star_bricaud=ones(size(a_star_bricaud));
for ii=1:size(z_mat,1) %going by particles (rows are for a particle, columns for times)
PUR(ii,:)=(1/mean(a_star_bricaud)).*a_star_bricaud'*(Ezero'.*exp(-repmat(Ktot',1,length(z_mat(ii,:))).*repmat(z_mat(ii,:),length(Ktot),1)));
end

figure
semilogx(PUR(:,30),-z_mat(:,30))

