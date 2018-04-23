function imp = importSummary(folder,filename)
% import summary data of new setup (*.summary)
% This function imports summary data into struct imp.

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
        %# read measured values from file ...
        try
            tempheader = textscan(fid,'%s',1,'delimiter','\n');
            header = strsplit(tempheader{1}{1},'\t');
            tempdata = textscan(fid,['%s',repmat('%s',1,length(header)),],'delimiter', '\t','CollectOutput',1);
        catch e
            disp(e.message)
            return;
        end
    fclose(fid);
    
    numbers = {'Cell' 'Sample' 'Repetition' 'Group' 'LI (mW/cm2)' 'MPP (mW/cm2)' 'MPPV (V)' 'MPPJ (mA/cm2)' 'JSC (mA/cm2)' 'VOC (V)' 'FF (%)' 'PCE (%)' 'RSH (Ohm/cm2)' 'RS (Ohm/cm2)' 'Integrationrate' 'Delay' 'LightSoaking' 'VoltageStabilization' 'ActiveArea'};
    text = {'Description' 'Filename' 'Date' 'Time' 'Type' 'ScanDirection' 'IlluminationDirection' 'Geometry' 'Filepath'};
    
    %# ... and save in individual array
    imp.dir     = folder;
    imp.name    = filename;
    imp.header  = header;
    imp.data  = tempdata{1};

    for n1 = 1:length(header)
        fname = strsplit(header{n1},' ');
        if ismember(header{n1},numbers)
            imp.(fname{1}) = str2double(tempdata{1}(:,n1));
        elseif ismember(header{n1},text)
            imp.(fname{1}) = tempdata{1}(:,n1);
        end
    end

%     assignin('base','imp',imp)
    imp.Group = imp.Group-min(imp.Group)+1;
    
    try
        fieldsExp = {'JSC','VOC','MPP','FF','PCE'};
        axExp = {'Current Density (mA/cm²)','Voltage (V)','Power (mW/cm²)','Fill Factor (%)', 'Efficiency (%)'};
%         limitsExp = {[0,0.2],[0,0.5],[0,0.1],[0,100],[0,0.1]};
        limitsExp = {[0,20],[0,1.2],[0,15],[0,100],[0,15]};
        
        screen_size = get(0, 'ScreenSize');
%         linewidth  = 2;
%         markersize = 12;
%         c = linspace(1,10,imp.Group);
        
        figExp = figure('NumberTitle','off','Name','Summary','Visible','on','Color','white','Resize','off','Position', [0 0 screen_size(3)*0.9 screen_size(4)*0.4],'PaperType','A4','PaperOrientation','landscape','PaperPosition',[0 0 29 20]);
        cOrder = get(gca,'colororder');
        cOrderStat = cOrder(1:length(fieldsExp),:);
        
        for n2=1:length(fieldsExp)
            subplot(1,length(fieldsExp),n2);
            gscatterLines = gscatter(imp.Group(imp.VOC>0.6&imp.FF<80&imp.Repetition>4),imp.(fieldsExp{n2})(imp.VOC>0.6&imp.FF<80&imp.Repetition>4),imp.Group(imp.VOC>0.6&imp.FF<80&imp.Repetition>4),cOrderStat,'o');
%             gscatter(imp.Group(strcmp(imp.ScanDirection,'forward')),imp.(fieldsExp{n2})(strcmp(imp.ScanDirection,'forward')),imp.Group(strcmp(imp.ScanDirection,'forward')),cOrderStat,'o');
%             hold all
%             gscatter(imp.Group(~strcmp(imp.ScanDirection,'forward')),imp.(fieldsExp{n2})(~strcmp(imp.ScanDirection,'forward')),imp.Group(~strcmp(imp.ScanDirection,'forward')),cOrderStat,'x');

            for n3 = 1:length(gscatterLines)
                gscatterLines(n3).LineWidth = 2;
            end
            set(gca,'XLim',[0.5 length(unique(imp.Description,'stable'))+0.5])
            set(gca,'XTick',1:length(unique(imp.Description,'stable')))
            set(gca,'YLim',limitsExp{n2})
            set(gca,'XTickLabel',unique(imp.Description,'stable'))
            set(gca,'XTickLabelRotation',45)
%             xlabel('Group')
            ylabel(axExp{n2})
            legend off   
        end
        saveas(figExp,[folder,'/',filename,'.fig'])
        saveas(figExp,[folder,'/',filename,'.jpg'])
        saveas(figExp,[folder,'/',filename,'.pdf'])
    catch e
        disp(e.message)
        return;
    end
end