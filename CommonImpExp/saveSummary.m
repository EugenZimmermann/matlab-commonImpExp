function status = saveSummary(summary,position,log)
    status = 1;
    
    sd = summary.Data;
    scn = summary.ColumnName;
    
    ind_folder = cellfun(@(s) ~isempty(regexpi(s,['^','Filepath','$'],'match')),scn);
    if ~isempty(ind_folder)
        ind_active = find(cellfun(@(s) ~isempty(s),sd(:,ind_folder)));
        if ~ind_active
            log.update('I do not save empty tables.');
            status = 0;
            return;
        end
        [fo,fi] = fileparts(sd{ind_active(1),ind_folder});
        if ~isempty(fi)
            fo = [fo,'\',fi];
        end
        if ~exist(fo,'dir')
            mkdir(fo);
        end
    else
        log.update('No filepath found.');
        status = 0;
        return;
    end

    ind_type = cellfun(@(s) ~isempty(regexpi(s,['^','Type','$'],'match')),scn);
    if ~isempty(ind_type)
        SummaryFile = [fo,'\',sd{ind_active(1),ind_type},'.summary'];
    else
        log.update('There is no Type specified in Table!');
        status = 0;
        return;
    end

    if position
        if exist(SummaryFile,'file')
            fidO = fopen(SummaryFile,'a');
        else
            fidO = fopen(SummaryFile,'w');
                fprintf(fidO, [repmat('%s\t',1,length(scn)-1),'%s\n'], scn{:});
        end
        tempData = cellfun(@(s) num2str(s,'%9.3f'),sd(position,:),'UniformOutput',false);
        fprintf(fidO, [repmat('%s\t',1,length(scn)-1),'%s\n'], tempData{:});
    else
        fidO = fopen(SummaryFile,'w');
            fprintf(fidO, [repmat('%s\t',1,length(scn)-1),'%s\n'], scn{:});
            
        for row=ind_active
            tempData = cellfun(@(s) num2str(s,'%9.3f'),sd(row,:),'UniformOutput',false);
            fprintf(fidO, [repmat('%s\t',1,length(scn)-1),'%s\n'], tempData{:});
        end
    end
    fclose(fidO);
end