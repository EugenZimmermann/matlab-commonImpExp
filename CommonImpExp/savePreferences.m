function savePreferences(filename,preferences,log)
%setPreferences Write preferences to "filename".ini
%   Write preferences to file "filename".ini and display error if something
%   is wrong with parameters
% @param preferences

    try
        fo = '.\Preferences\';
        if ~exist(fo,'dir')
            mkdir(fo);
        end
        temp_filename = [fo,filename,'.ini'];
        fid = fopen(temp_filename,'w');
%             fprintf(fid, 'Settingsize=%s\n',num2str(sizepreferences));
            for n1 = fieldnames(preferences)'
                fprintf(fid, '%s = %s\n',n1{1},num2str(eval(['preferences.',n1{1}])));
            end
        fclose(fid);
    
    catch error
        log.update(error.message)
        log.update(['saveing preferences for ',filename,' failed'])
    end
%     disp(['saveing preferences for ',filename,' done'])
end
