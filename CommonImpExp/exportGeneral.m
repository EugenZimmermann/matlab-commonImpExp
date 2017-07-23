function status = exportGeneral(varargin)
% save structured data: folder (string), filename (string), data (struct)
% This function saves structured data to a single text file separating header
% information in input.header (starts with #) and measured data in input.data.
% Additionally, caption (input.caption) and units (input.units) can be saved.
% INPUT 2 parameters:
%   File: Full file name as one string without extension;
%   Input: Structured data containing header and data information.
%
% INPUT 3 parameters:
%   Folder: Name of folder as string (with and without date possible).
%   Filename: Name of filename as string without extension.
%   Input: Structured data containing header and data information.
%
% OUTPUT:
%   Status: Status of process
%
% EXAMPLES:
%   1. Direct file specification:
%     status = savemeasurement('C:\data\JV\Sample_XYZ',input)
%   2. Individual specification of folder and filename:
%     status = savemeasurement('C:\data\JV\', 'Sample_XYZ',input)
%
%
% Tested: Matlab 2015b, Win10
% Author: Eugen Zimmermann, Konstanz, (C) 2015 eugen.zimmermann@uni-konstanz.de

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
    
    %# add date and time to filename
    if isfield(input,'Date')
        date = input.Date;
    else
        date = '';
    end
    
    if isfield(input,'Time')
        time = ['_',strrep(input.Time,':','-'),'_'];
    else
        time = '';
    end
    
    %# open file for writing 
    if ~exist(fo,'dir')
        mkdir(fo);
    end
    
    file = fopen([fo,'\',date,time,fi,ext],'w');
    
    %# check header information and write to file with preceding #
    if isfield(input,'header')
        header = input.header;
        if isstruct(header)
            fn_header = fieldnames(header);
            for n1=1:length(fn_header)
                current_field = header.(fn_header{n1});
                if isnumeric(current_field)
                    fprintf(file,'#%s = %s\n',fn_header{n1},num2str(current_field));
                elseif ischar(current_field)
                    fprintf(file,'#%s = %s\n',fn_header{n1},current_field);
                end
            end
%         elseif iscell(header)
%             for n1=1:size(header,1)
%                 fprintf(file,'#%s = %s\n',header{n1}(1:2));
%             end
        end
    end
    
    if isfield(input,'caption')
        caption = input.caption;
        fprintf(file,[repmat('%s\t',1,length(caption)-1),'%s\n'],caption{:});
    end
    
    if isfield(input,'units')
        units = input.units;
        fprintf(file,[repmat('%s\t',1,length(units)-1),'%s\n'],units{:});
    end
    
    %# check data information
    if isfield(input,'data')
        %# rearrange measured data 
        data = input.data;
        if iscell(data)
            %# write measured data to file
            for n2=1:length(data)
                fprintf(file,[repmat('%f\t',1,length(data(n2,:))),'%f\n'],data(n2,:));
                fprintf(file,'\n');
            end
        elseif isstruct(data)
            fn_data = fieldnames(data);
            %# write names of measured data
            fprintf(file,[repmat('%s\t',1,length(fn_data)-1),'%s\n'],fn_data{:});

            %# create temporary array to save measurement data for export
            data_temp = zeros(length(data.(fn_data{1})),length(fn_data));
            for n2=1:length(fn_data)
                %# save measured data into temporary array
                data_temp(:,n2) = data.(fn_data{n2});
            end
            
            %# write measured data to file
            for n3=1:length(data.(fn_data{1}))
                fprintf(file,[repmat('%f\t',1,length(fn_data)-1),'%f\n'],data_temp(n3,:));
%                 fprintf(file,'\n');
            end
        end
    end
    
    %# close file
    fclose(file);
end