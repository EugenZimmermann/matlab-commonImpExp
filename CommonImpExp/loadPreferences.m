function [preferences, err] = loadPreferences(filename,log)
%getPreferences Reads preferences of "filename".ini
%   Read preferences of file "filename".ini and display error if file broken
%   ore incomplete

    %# flag - stays 1 if everything is OK, 0 if there was an error -> create new Settings file with default values
    err = 0;
    %# preferences - variable with successfully imported settings or empty cell array
    preferences = struct();
    
    try
        %# search for ""filename".ini"
        temp_filename = ['.\Preferences\',filename,'.ini'];
        files    = dir(temp_filename);
        %# if there is no "filename".ini inform user and generate new "filename".ini
        if ~size(files,1)
%             helpdlg(['Preferences-File for ', filename ,' not found. New file generated with default values. Please check preferences.']);
            err=1;
            return;
        end
        
        %# read "filename".ini
        %# delimiter is "=", only one setting per line
        fid = fopen(temp_filename,'r');
            preferences_temp = textscan(fid, repmat('%s',1,2), 'delimiter','=', 'CollectOutput',true);
            preferences_temp = strtrim(preferences_temp{1});
        fclose(fid);

        preferences = cell2struct(preferences_temp(:,2),preferences_temp(:,1),1);
        
    catch error
        log.update(error.message)
        err=2;
    end
    log.update(['loading preferences for ',filename,' done'])
end