function imp = importTRPS(folder,filename)
% import TRP and TRS data of new setup (*.trp,*.trs)
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
            data = textscan(fid,'%f %f %f %f','delimiter', '\t','HeaderLines',2,'MultipleDelimsAsOne',1,'CollectOutput',1);
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
    imp.J       = data{1}(:,2);
    imp.I       = data{1}(:,3);
    imp.V       = data{1}(:,4);
    
    [~,~,ext] = fileparts(filename);
    if strcmpi(ext,'.trs')
        imp.shortV = unique(imp.V);
        bool_sorted = issorted(imp.V);
        if ~bool_sorted
            imp.time = flipud(imp.time);
        end
        
        for n1 = 1:length(imp.shortV)
            index = find(imp.V==imp.shortV(n1));

            if ~bool_sorted
                imp.startJ(n1,1) = imp.J(index(1));
                imp.stopJ(n1,1) = imp.J(index(end));
            else
                imp.startJ(n1,1) = imp.J(index(end));
                imp.stopJ(n1,1) = imp.J(index(1));
            end
        end
    elseif strcmpi(ext,'.trp')
        imp.shortV = unique(imp.V);
        mFe = 1E5;
        mI = 1E4;
        ToF = 1e-18;
        ToX = 1e-18;
        var_display = 'off';
        options = optimoptions('lsqcurvefit','MaxFunEvals',mFe,'MaxIter',mI,'TolFun',ToF,'TolX',ToX,'Display',var_display);
        
        b = bwconncomp(imp.V);
        for n2 = 1:length(b.PixelIdxList)
            if length(b.PixelIdxList{n2})>1
                index = find(imp.V==imp.shortV(n2));
                x_for_fit = imp.time(index);
                y_for_fit = abs(imp.J(index));
                parameter = [max(y_for_fit) min(y_for_fit) 1];
                [parameterOut,resnorm,residual,exitflag] = lsqcurvefit(@fit_expDec,parameter,x_for_fit,y_for_fit,[0 0 0],[inf inf inf],options);
                imp.fit(n2).parameterOut = parameterOut;
                imp.fit(n2).resnorm = resnorm;
                imp.fit(n2).residual = residual;
                imp.fit(n2).exitflag = exitflag;
            end
        end
    end
end