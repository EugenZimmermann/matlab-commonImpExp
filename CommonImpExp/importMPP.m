function imp = importMPP(folder,filename)
% import steady state MPP data of new setup (*.mpp)
% This function imports steady state MPP data into struct imp.

% INPUT:
%   folder: string pointing to a folder
%   filename: string containing the name of the file
%
% OUTPUT:
%   imp: resulting struct with fields: dir, name, wavelength, rawSignal, and photonFlux

% Tested: Matlab 2014a, 2014b, 2015a, 2015b, 2017a, Win8.1, Win10
% Author: Eugen Zimmermann, Konstanz, (C) 2016 eugen.zimmermann@uni-konstanz.de
% Last Modified on 2018-03-16

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
    imp.V80     = mean(imp.V(floor(length(imp.V)*0.8):end));
    imp.V90     = mean(imp.V(floor(length(imp.V)*0.9):end));
    imp.J80     = mean(imp.J(floor(length(imp.J)*0.8):end));
    imp.J90     = mean(imp.J(floor(length(imp.J)*0.9):end));
    imp.power80 = mean(imp.power(floor(length(imp.power)*0.8):end));
    imp.power90 = mean(imp.power(floor(length(imp.power)*0.9):end));
    
    numbers = {'Cell' 'Sample' 'Repetition' 'Group' 'LI (mW/cm2)' 'MPP (mW/cm2)' 'MPPV (V)' 'MPPJ (mA/cm2)' 'JSC (mA/cm2)' 'VOC (V)' 'FF (%)' 'PCE (%)' 'RSH (Ohm/cm2)' 'RS (Ohm/cm2)' 'Integrationrate' 'Delay' 'LightSoaking' 'VoltageStabilization' 'ActiveArea'};
    text = {'Description' 'Filename' 'Date' 'Time' 'Type' 'ScanDirection' 'IlluminationDirection' 'Geometry' 'Filepath'};
    
    fnames = fieldnames(header);
    for n1 = 1:length(fnames)
        if ismember(lower(fnames{n1}),lower(numbers))
            imp.header.(fnames{n1}) = str2double(imp.header.(fnames{n1}));
        end
    end
end