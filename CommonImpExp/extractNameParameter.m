function [out] = extractNameParameter(filename,varargin)
%EXTRACTNAMEPARAMETER Summary of this function goes here
%   Detailed explanation goes here
    possible_fields = {'temperature','exitationL','intensity','frequency','time','fluence','exitationE','area','length','Bias','Diode'};
    input = inputParser;
    addRequired(input,'filename',@(x) ischar(x));
    addParameter(input,'Delimiter','_',@(x) ischar(x));
    addParameter(input,'expected_fields',possible_fields,@(x) iscell(x));
    parse(input,filename,varargin{:});

    name_split = strrep(input.Results.filename,',','.');%regexp(input.Results.filename,input.Results.Delimiter,'split');
    expected_fields = input.Results.expected_fields;
    
    out = struct();
    
    f = 'excitationL';
    if ismember(f,expected_fields)
        name = regexp(name_split, '(?<value>\d+\.?\d*)(?<unit>((nmexc|nm|um|µm)))','names');
        if ~isempty(fieldnames(name)) && ~isempty(name)
            out.(f) = str2double(name(1).value);
            out.([f,'_unit']) = name(1).unit;
        end
    end
    
    f = 'temperature';
    if ismember(f,expected_fields)
        name = regexp(name_split, '(?<value>\d+\.?\d*)(?<unit>((K|°C|°F)))','names');
        if ~isempty(fieldnames(name)) && ~isempty(name)
            out.(f) = str2double(name(1).value);
            out.([f,'_unit']) = name(1).unit;
        end
    end
    
    f = 'frequency';
    if ismember(f,expected_fields)
        name = regexp(name_split, '(?<value>\d+\.?\d*)(?<unit>((m|k|M)?Hz))','names');
        if ~isempty(fieldnames(name)) && ~isempty(name)
            out.(f) = str2double(name(1).value);
            out.([f,'_unit']) = name(1).unit;
        end
    end
    
    f = 'intensity';
    if ismember(f,expected_fields)
        name = regexp(name_split, '(?<value>\d+\.?\d*)(?<unit>((u|µ|m|k|M)?W))','names');
        if ~isempty(fieldnames(name)) && ~isempty(name)
            out.(f) = str2double(name(1).value);
            out.([f,'_unit']) = name(1).unit;
        end
    end
    
    f = 'time';
    if ismember(f,expected_fields)
        name = regexp(name_split, '(?<value>\d+\.?\d*)(?<unit>((m|µ|u|f|p)?s|m|min|h|d|y))','names');
        if ~isempty(fieldnames(name)) && ~isempty(name)
            out.(f) = str2double(name(1).value);
            out.([f,'_unit']) = name(1).unit;
        end
    end
    
    f = 'Bias';
    if ismember(f,expected_fields)
        name = regexp(name_split, 'Bias_(?<value>-?\d+\.?\d*)(?<unit>(V))','names');
        if ~isempty(fieldnames(name)) && ~isempty(name)
            out.(f) = str2double(name(1).value);
            out.([f,'_unit']) = name(1).unit;
        end
    end
    
    f = 'Diode';
    if ismember(f,expected_fields)
        name = regexp(name_split, 'Diode_(?<value>\d+\.?\d*)(?<unit>(V))','names');
        if ~isempty(fieldnames(name)) && ~isempty(name)
            out.(f) = str2double(name(1).value);
            out.([f,'_unit']) = name(1).unit;
        end
    end
end