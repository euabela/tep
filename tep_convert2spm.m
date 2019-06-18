function tep_convert
%% Introduction
% Purpose:
% - Convert multitrial data from Fieldtrip to SPM12
%
% Dependecies: 
% - SPM12
%
% Inputs: 
% - Epoched Fieldtrip data file (.mat, containing struct 'temp').
%
% Outputs:
% - Epoched SPM12 data file with prefix 'spmeeg_'
%
%--------------------------------------------------------------------------
% (c) 05/2017, Eugenio Abela, Richardson Lab, IoPPN, KCL


%% Select data and output directory
%--------------------------------------------------------------------------
data2convert = spm_select(Inf,'any','Select files to convert...');
outputdir    = spm_select(1,'dir','Select output directory...');

%% Loop over files
%--------------------------------------------------------------------------
spm('defaults','eeg');
spm_jobman('initcfg');

wb = waitbar(0,'Converting files...');
for ii = 1:size(data2convert,1)
    
    % Load variable
    load(deblank(data2convert(ii,:)));
    
    % Assign new pathname and convert
    [~ , nam, ext]  = spm_fileparts(data2convert(ii,:));
    filename        = [outputdir '/' 'spmeeg_' nam ext];
    D               = spm_eeg_ft2spm(temp,filename);
    
    % Update waitbar
    waitbar(ii/size(data2convert,1));
end
close(wb);

%% End
%--------------------------------------------------------------------------
disp('Done!')
