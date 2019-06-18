function tep_convert2images(data2convert, timeWin)
%% Convert EEG data to SPM12 images
% PURPOSE:
% - This function converts EEG data in SPM12 format to scalp x time
%   images. 
%
% INPUTS
% - data2convert     ERP file list (data in SPM format)
% - timeWin          Time window of interest, i.e. [startTime endTime]
%                    Defaults to -50 to 300
% OUTPUTS
% - EEG scalp x time images
%
% DEPENDENCIES:
%  - SPM 12
%
% USAGE:
% >> tep_convert2images
% >> tep_convert2images('myeegfile.mat')
%
%--------------------------------------------------------------------------
% (c) Eugenio Abela, RichardsonLab, www.epilepsy-london.org

%% Check inputs
%--------------------------------------------------------------------------
if nargin<1                       % set regexp here:
    data2convert = spm_select(Inf,'^abfspmeeg.*\.mat$','Select data to convert...');
elseif nargin<2
    timeWin = [-50 300];
end

% Fire up SPM
%--------------------------------------------------------------------------
spm('defaults','eeg');
spm_jobman('initcfg');

% Loop over files
%--------------------------------------------------------------------------
h = waitbar(0,'Please wait...');
for filei = 1:size(data2convert,1)

    % Define output file prefix
    prefix = ['t' num2str(timeWin(1) '-' num2str(timeWin(2)];
    
    % Define matlabbatch parameters
    matlabbatch{1}.spm.meeg.images.convert2images.D = cellstr(data2convert(filei,:));
    matlabbatch{1}.spm.meeg.images.convert2images.mode = 'scalp x time';
    matlabbatch{1}.spm.meeg.images.convert2images.conditions = {'TEP'};
    matlabbatch{1}.spm.meeg.images.convert2images.channels{1}.all = 'all';
    matlabbatch{1}.spm.meeg.images.convert2images.timewin = timeWin;
    matlabbatch{1}.spm.meeg.images.convert2images.freqwin = [-Inf Inf];
    matlabbatch{1}.spm.meeg.images.convert2images.prefix = prefix;

    % Run job
    spm_jobman('run',matlabbatch);
    
    % Update waitbar
    waitbar(filei/size(data2convert,1));
end

% Close waitbar
close(h);

%% End
%--------------------------------------------------------------------------
disp('Done!')
