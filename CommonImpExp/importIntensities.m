function imp = importIntensities(filename)
% import calculated intensities (*.txt)
% This function imports PL data into struct imp.

% INPUT:
%   folder: string pointing to a folder
%   filename: string containing the name of the file
%
% OUTPUT:
%   imp: resulting struct with fields: dir, name, wavelength, time, pl

% Tested: Matlab 2014a, 2014b, 2015a, Win8
% Author: Eugen Zimmermann, Konstanz, (C) 2015 eugen.zimmermann@uni-konstanz.de
% Last Modified on 2016-01-18
	imp = struct();
	
	if ~exist(filename,'file')
		return;
	end	  
    
    %# import data
    import = importdata(filename);
  
    %# ... and save in individual array
    imp.name      = filename;
    imp.a = import;
    imp.power     = import.data(:,1);
    imp.fluence   = import.data(:,2);
    
    for n1 = 1:length(import.textdata)
        if strcmp(import.textdata{n1,1}(1),'#')
            temp = regexp(import.textdata{n1,1}(2:end),' ','split');
            imp.(lower(temp{1})) = str2double(temp{2});
        end
    end
end

