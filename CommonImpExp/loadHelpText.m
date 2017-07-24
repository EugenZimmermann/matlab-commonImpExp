function text = loadHelpText()
    files    = dir('.\*.txt');
    idx = find(cellfun(@(x) strcmpi(x,'Readme.txt'),{files.name}));
    if ~idx
        text = 'Readme.txt not found.';
        return;
    end
    files = files(idx);
    
    fid = fopen(['./',files.name],'r');
        text = textscan(fid, '%s', inf, 'delimiter' ,'\n');
        text = char(text{1});
    fclose(fid);
    
    disp('loading HELP done')
end