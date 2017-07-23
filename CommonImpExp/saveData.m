function [status, fullPath] = saveData(varargin)
% save structured measurement: folder (string), filename (string), measurement (struct)
% This function saves structured measurement to a single text file separating header
% information in input.header (starts with #) and measured measurement in input.measurement.
% INPUT 2 parameters:
%   File: Full file name as one string without extension;
%   Input: Structured measurement containing header and measurement information.
%
% INPUT 3 parameters:
%   Folder: Name of folder as string (with and without date possible).
%   Filename: Name of filename as string without extension.
%   Input: Structured measurement containing header and measurement information.
%
% OUTPUT:
%   Status: Status of process
%
% EXAMPLES:
%   1. Direct file specification:
%     status = savemeasurement('C:\measurement\JV\Sample_XYZ',input)
%   2. Individual specification of folder and filename:
%     status = savemeasurement('C:\measurement\JV\', 'Sample_XYZ',input)
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
            filepath = [folder,filename];

        otherwise
            errordlg('Wrong number of arguments!')
            status = 0;
            return;
    end

    %# check if units are globaly declared, otherwise declare default values
    global gui
    if ~isfield(gui,'units')
        units.V = 'V';
        units.voltage = units.V;
        units.bias = units.V;
        units.mppV = units.V;
        units.VOC = units.V;

        units.I = 'mA';
        units.current = units.I;
        units.mppI = units.I;
        units.ISC = units.I;

        units.J = 'mA/cm2';
        units.currentdensity = units.J;
        units.mppJ = units.J;
        units.JSC = units.J;
        
        units.mpp = 'mW/cm2';
        units.LI = 'mW/cm2';
        
        units.lambda = 'nm';
        units.wavelength = units.lambda;
        units.PhotonFlux = 'photons/cm-2';
        units.EQE = '%';
        units.EQExphase = '%';
        units.EQEyphase = '%';

        units.FF = '%';
        units.Rs = 'Ohm/cm2';
        units.Rsh = 'Ohm/cm2';
        
        units.Time = 's';
        units.T = 's';
        
        units.FilterPosition = 'steps';
    else
        units = gui.units;
    end
    
    unitsFNames = fieldnames(units);
    LI = '';

    %# check if measurement type is implemented yet
    switch input.header.Type
        case 'lightIV'
            ext = '.IV2';
            OutputOrder = {'V','I','J','Time'};
        case 'lightTRSIV'
            ext = '.IVT';
            OutputOrder = {'V','I','J','Time'};
        case 'darkIV'
            ext = '.IV0';
            OutputOrder = {'V','I','J','Time'};
        case 'EQE_K'
            ext = '.eqe';
            OutputOrder = {'wavelength','I','EQE'};
        case 'EQE_L'
            ext = '.eqe';
            OutputOrder = {'wavelength','V','EQE','EQExphase','EQEyphase'};
        case 'EQE_B'
            ext = '.eqe';
            OutputOrder = {'bias','wavelength','V','EQE','EQExphase','EQEyphase'};
        case 'EQECalibration'
            ext = '.cqe';
            switch input.header.Device
                case 'LockIn'
                    OutputOrder = {'wavelength','V','PhotonFlux'};
                case 'Keithley'
                    OutputOrder = {'wavelength','I','PhotonFlux'};
            end
        case 'LICalibration'
            ext = '.cli';
            OutputOrder = {'FilterPosition','LI','I'};
        case 'LICalibrationSpline'
            ext = '.cli';
            OutputOrder = {'FilterPosition','LI'};
        case 'LIDIV'
            ext = '.IV4';
            OutputOrder = {'V','I','J','Time'};
            if isfield(input.header,'LI')
                LI = ['_',num2str(input.header.LI,'%03d')];
            end
        case 'advIV'
            ext = '.IV5';
            OutputOrder = {'V','I','J'};
        case {'lightTRP','darkTRP'}
            ext = '.TRP';
            OutputOrder = {'Time','J','I','V'};
        case {'lightTRS','darkTRS'}
            ext = '.TRS';
            OutputOrder = {'Time','J','I','V'};
        case {'lightIVC','darkIVC'}
            ext = '.IVC';
            OutputOrder = {'Time','J','I','V'};
        case 'Cycle'
            OutputOrder = {'V','J','I'};%,'Time'
            ext = '.cycle';
        case 'MPP'
            ext = '.mpp';
            OutputOrder = {'Time','mpp','V','J','I'};
        case 'MPPT'
            ext = '.mppt';
            OutputOrder = {'Time','mpp','V','J','I','Temperature'};
        case 'JSC'
            ext = '.jsc';
            OutputOrder = {'Time','J','I','V'};
        case 'JSCT'
            ext = '.jsct';
            OutputOrder = {'Time','J','I','V','Temperature'};
        case 'VOC'
            ext = '.voc';
            OutputOrder = {'Time','mpp','V','J','I'};
        case 'VOCT'
            ext = '.voct';
            OutputOrder = {'Time','mpp','V','J','I','Temperature'};
        otherwise
            disp(['implement ',input.header.Type,' into saveData!'])
            status = 0;
            return;
    end
    
    %# add date and time to filename
    if isfield(input.header,'Date')
        date = ['_',input.header.Date];
    else
        date = '';
    end
    
    if isfield(input.header,'Time')
        time = ['_',strrep(input.header.Time,':','-')];
    else
        time = '';
    end
    
    %# open file for writing
    [fo,fi] = fileparts(filepath);
    fo2 = [fo,con_a_b(~isempty(date),['\',input.header.Date,'\'],'\')];  
    if ~exist(fo2,'dir')
        mkdir(fo2);
    end
    
    filepath = [fo2,fi];
    fullPath = [filepath,LI,date,time,ext];
    file = fopen([filepath,LI,date,time,ext],'w');
    try
        %# check header information and write to file with preceding #
        if isfield(input,'header')
            header = fieldnames(input.header);
            for n1=1:length(header)
                %# ckeck if header values are supposed to have units
                if ismember(lower(header{n1}),lower(unitsFNames))
                    fprintf(file,'#%s\t%s\t%s\n',header{n1},num2str(input.header.(header{n1})),units.(header{n1}));
                else
                    fprintf(file,'#%s\t%s\n',header{n1},num2str(input.header.(header{n1})));
                end
            end
            fprintf(file,'\t\n');
        end

        %# check measurement information
        if isfield(input,'measurement')
            %# rearrange measured data
            try
                measurement = fieldnames(orderfields(input.measurement,OutputOrder));
            catch E
                disp(E.message)
                measurement = fieldnames(input.measurement);
            end
            %# write names of measured data
            fprintf(file,[repmat('%s\t',1,length(measurement)-1),'%s\n'],measurement{:});
            
            %# create temporary array to save measurement data for export
            measurement_temp = zeros(length(input.measurement.(measurement{1})),length(measurement));
            for n2=1:length(measurement)
                %# save measured data into temporary array
                measurement_temp(:,n2) = input.measurement.(measurement{n2});
                try
                    %# write units of measured data to file
                    if n2==length(measurement)
                        fprintf(file,'%s\n',units.(measurement{n2}));
                    else
                        fprintf(file,'%s\t',units.(measurement{n2}));
                    end
                catch E
                    disp(E.message)
                    fprintf(file,'\n');
                end
            end

            %# write measured data to file
            for n3=1:length(input.measurement.(measurement{1}))
                fprintf(file,[repmat('%g\t',1,length(measurement)),'%g\n'],measurement_temp(n3,:));
                fprintf(file,'\n');
            end
        end
        %# close file
        fclose(file);
    catch error
        error.message
        fclose(file);
    end
end