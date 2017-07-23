function imp = importMPP(folder,filename)
% import MPP data of new setup (*.mpp)
% This function imports EQE data into struct imp.

% INPUT:
%   folder: string pointing to a folder
%   filename: string containing the name of the file
%
% OUTPUT:
%   imp: resulting struct with fields: dir, name, wavelength, rawSignal, and photonFlux

% Tested: Matlab 2014a, 2014b, 2015a, 2015b, Win8.1, Win10
% Author: Eugen Zimmermann, Konstanz, (C) 2016 eugen.zimmermann@uni-konstanz.de
% Last Modified on 2015-10-25

    imp = struct();
    
    fid = fopen([folder,'/',filename],'r');
        n1 = 1;
        %# read measured values from file ...
        try
            while n1<50
                tempHeader = textscan(fid,'#%s %s %s',1,'delimiter', '\t','MultipleDelimsAsOne',1);
                if isempty(tempHeader{1})
                    break;
                end
                header.(tempHeader{1}{1}) = tempHeader{2}{1};
                header.([tempHeader{1}{1},'_unit']) = tempHeader{3}{1};
                n1 = n1+1;
            end
            data = textscan(fid,'%f %f %f %f %f','delimiter', '\t','HeaderLines',2,'MultipleDelimsAsOne',1,'CollectOutput',1);
        catch e
            disp(e.message)
            return;
        end
    fclose(fid);
   
    %# ... and save in individual array
    imp.dir     = folder;
    imp.name    = filename;
    imp.header  = header;
    imp.time    = data{1}(:,1);
    imp.power   = data{1}(:,2);
    imp.V       = data{1}(:,3);
    imp.J       = data{1}(:,4);
    imp.I       = data{1}(:,5);
end