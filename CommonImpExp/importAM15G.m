function imp = importAM15G(constants)
% import AutoLab IS data (*.is)
% This function imports IS data into struct imp.

% INPUT:
%   folder: string pointing to a folder
%   filename: string containing the name of the file
%
% OUTPUT:
%   imp: resulting struct with fields: wavelength, power_W, power_mW, photons_M, and photons_CM

% Tested: Matlab 2014a, 2014b, 2015a, Win8
% Author: Eugen Zimmermann, Konstanz, (C) 2015 eugen.zimmermann@uni-konstanz.de
% Last Modified on 2015-10-25

    imp = struct();
    
    fid = fopen('AMG.txt','r');
        amg = textscan(fid, '%f %f %f %f', 'delimiter','\t','headerlines',2, 'CollectOutput',true);
        amg = amg{1,1};
    fclose(fid);

    %# ... and save in individual array
    imp.wavelength = amg(:,1);               	% nm
    imp.power_W = amg(:,3);                     % W/(m^2*nm)
    imp.power_mW = amg(:,3)./10;                % mW/(cm^2*nm)
    hmalnu_online = constants.h.*constants.c./(imp.wavelength);
    imp.photons_M = imp.power_W./(hmalnu_online);  	% photons/(m^2*s)
    imp.photons_CM = imp.power_mW./(hmalnu_online); % photons/(cm^2*s)
end

