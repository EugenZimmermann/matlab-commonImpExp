function status = exportLog(varargin)
% save log data: folder (string), filename (string), data (struct)
% This function saves structured log data (input.data) to a single text file.
% INPUT 2 parameters:
%   File: Full file name as one string without extension;
%   Input: Structured log data containing date and data information.
%
% INPUT 3 parameters:
%   Folder: Name of folder as string (with and without date possible).
%   Filename: Name of filename as string with or without (.txt will be appended) extension.
%   Input: Structured data containing date and data information.
%
% OUTPUT:
%   Status: Status of process
%
% EXAMPLES:
%   1. Direct file specification:
%     status = savemeasurement('C:\data\JV\Sample_XYZ.ext',input)
%   2. Individual specification of folder and filename:
%     status = savemeasurement('C:\data\JV\', 'Sample_XYZ.ext',input)
%
% Tested: Matlab 2015b, Win10
% Author: Eugen Zimmermann, Konstanz, (C) 2015 eugen.zimmermann@uni-konstanz.de
% Last Modified on 2015-11-03

    status = 1;

    %# check for number of arguments
    switch nargin
        case 2
            filepath = varargin{1};
            input = varargin{2};

        case 3
            folder = varargin{1};
            filename = varargin{2};
            input = varargin{3};
            filepath = [folder,con_a_b(strcmp(folder(end),'\'),'','\'),filename];

        otherwise
            errordlg('Wrong number of arguments!')
            status = 0;
            return;
    end
    [fo,fi,ext] = fileparts(filepath);
    if isempty(ext)
        ext = '.txt';
    end
    
    %# add date to filename
    if isfield(input,'Date')
        date = [input.Date,'_'];
    else
        date = '';
    end
    
    %# check if folder exists, otherwise create it
    if ~exist(fo,'dir')
        mkdir(fo);
    end
    
    %#  check if file exists
    filename_final = [fo,'\',date,fi,ext];
    if ~exist(filename_final,'file')
        %# create new file if file does not exist
        file = fopen(filename_final,'w');
    else
        %# append to existing file
        file = fopen(filename_final,'a');
    end
    
    try
        %# check data information
        if isfield(input,'data')
            data = input.data;

            %# write measured data to file
            if iscell(data)
                cellfun(@(s) fprintf(file,'%s\n',s),flipud(data));
            else
                fprintf(file,'%s\n',data);
            end
        end
    catch error
        disp(error.message)
        
        %# close file
        fclose(file);
    end
    
    %# close file
    fclose(file);
end