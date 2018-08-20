function imp = importSummary(folder,filename,varargin)
% import summary data of new setup (*.summary)
% This function imports summary data into struct imp.

% INPUT:
%   folder: string pointing to a folder
%   filename: string containing the name of the file
%
% OUTPUT:
%   imp: resulting struct with fields: dir, name, and all fields saved in *.summary

% Tested: Matlab 2014a, 2014b, 2015a, 2015b, Win8.1, Win10
% Author: Eugen Zimmermann, Konstanz, (C) 2016 eugen.zimmermann@uni-konstanz.de
% Last Modified on 2018-08-20

    input = inputParser;
        addRequired(input,'folder');
        addRequired(input,'filename');
        addParameter(input,'plotActive',1,@(x) isscalar(x) && ~isnan(x) && (x==0 || x==1));
        addParameter(input,'lineWidth',2,@(x) isscalar(x) && ~isnan(x) && x>0 && x<5);
        addParameter(input,'markerSize',8,@(x) isscalar(x) && ~isnan(x) && x>0 && x<30);
        addParameter(input,'limitsJSC',[0,20],@(x) isnumric(x) && ~isnan(x) && min(size(x))==1 && max(size(x))==2);
        addParameter(input,'limitsVOC',[0,1.1],@(x) isnumric(x) && ~isnan(x) && min(size(x))==1 && max(size(x))==2);
        addParameter(input,'limitsMPP',[0,15],@(x) isnumric(x) && ~isnan(x) && min(size(x))==1 && max(size(x))==2);
        addParameter(input,'limitsFF',[0,100],@(x) isnumric(x) && ~isnan(x) && min(size(x))==1 && max(size(x))==2);
        addParameter(input,'limitsPCE',[0,15],@(x) isnumric(x) && ~isnan(x) && min(size(x))==1 && max(size(x))==2);
        addParameter(input,'colorOrder','hot',@(x) ischar(x) || isstring(x));
        addParameter(input,'filter','imp.VOC>0.6&imp.FF<80&imp.Repetition==1',@(x) ischar(x) || isstring(x));
        addParameter(input,'splitBackwardAndForward',1,@(x) isscalar(x) && ~isnan(x) && (x==0 || x==1));
        addParameter(input,'font','Arial',@(x) ischar(x) || isstring(x));
    parse(input,folder,filename,varargin{:});

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

    %plot if activated
    if input.Results.plotActive
        [sortGroup,sortGroupInd] = sort(imp.Group);
        sortGroup = findgroups(sortGroup);

        tempfnames = fieldnames(imp);
        for n2 = 1:length(tempfnames)
            if ~ismember(tempfnames{n2},{'dir','name','header'})
                imp.(tempfnames{n2}) = imp.(tempfnames{n2})(sortGroupInd);
            end
        end

        try
            fieldsExp = {'JSC','VOC','MPP','FF','PCE'};
            axExp = {'Current Density (mA/cm²)','Voltage (V)','Power (mW/cm²)','Fill Factor (%)', 'Efficiency (%)'};
            limitsExp = {input.Results.limitsJSC,input.Results.limitsVOC,input.Results.limitsMPP,input.Results.limitsFF,input.Results.limitsPCE};

            lineWidth  = input.Results.lineWidth;
            markerSize = input.Results.markerSize;

            figExp = figure('NumberTitle','off','Name','Summary','Visible','on','Color','white','Resize','off','Position', [0 0 1800 600],'PaperOrientation','landscape','PaperType','A4','PaperPosition',[0 0 29 20]);
            cOrder = eval(input.Results.colorOrder);
            if strcmpi(input.Results.colorOrder,'hot')
                cOrder = cOrder(5:end-10,:);
            end
            cOrderStat = cOrder(1:max(floor((length(cOrder))/length(unique(sortGroup))),1):end-1,:);
            
            try
                eval(['filter=',input.Results.filter,';'])
            catch e
                disp(e.message)
                filter = ones(length(sortGroup),1);
            end
            positions = [100,200,250,375];
            
            if input.Results.splitBackwardAndForward
                filterForward = strcmp(imp.ScanDirection,'forward');
                filterBackward = ~strcmp(imp.ScanDirection,'forward');
            end
            
            for n2=1:length(fieldsExp)
                subplot(1,length(fieldsExp),n2,'TickLabelInterpreter','none','Units','pixels','FontName','Arial','FontSize',12,'Position',[positions]+(n2-1)*[350 0 0 0]);
                if ~input.Results.splitBackwardAndForward
                    gscatterLines = gscatter(sortGroup(filter),imp.(fieldsExp{n2})(filter),sortGroup(filter),cOrderStat,'o');
                    for n3 = 1:length(gscatterLines)
                        gscatterLines(n3).LineWidth = lineWidth;
                        gscatterLines(n3).MarkerSize = markerSize;
                    end
                else
                    gscatterLinesForward = gscatter(sortGroup(filter&filterForward),imp.(fieldsExp{n2})(filter&filterForward),sortGroup(filter&filterForward),cOrderStat,'o');
                    hold all
                    gscatterLinesBackward = gscatter(sortGroup(filter&filterBackward),imp.(fieldsExp{n2})(filter&filterBackward),sortGroup(filter&filterBackward),cOrderStat,'x');
                    
                    for n3 = 1:length(gscatterLinesForward)
                        gscatterLinesForward(n3).LineWidth = lineWidth;
                        gscatterLinesForward(n3).MarkerSize = markerSize;
                    end
                    
                    for n3 = 1:length(gscatterLinesBackward)
                        gscatterLinesBackward(n3).LineWidth = lineWidth;
                        gscatterLinesBackward(n3).MarkerSize = markerSize;
                    end
                end

                set(gca,'XLim',[0.5 length(unique(imp.Description,'stable'))+0.5])
                set(gca,'XTick',1:length(unique(imp.Description,'stable')))
                set(gca,'YLim',limitsExp{n2})
                set(gca,'XTickLabel',unique(imp.Description,'stable'))
                set(gca,'XTickLabelRotation',45)
                set(gca,'FontName',input.Results.font,'FontSize',14)
                ylabel(axExp{n2})
                legend off   
            end
            saveas(figExp,[folder,'/',filename,'.fig'])
            saveas(figExp,[folder,'/',filename,'.jpg'])
%             saveas(figExp,[folder,'/',filename,'.pdf'])
        catch e
            disp(e.message)
            return;
        end
    end
end