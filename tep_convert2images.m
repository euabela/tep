function tep_convert2images(data2convert)
%% Convert EEG data to SPM12 images
% PURPOSE:
% This function converts EEG data in SPM12 format to scalp x time
% images. 
%--------------------------------------------------------------------------
% (c) Eugenio Abela, RichardsonLab, www.epilepsy-london.org

if nargin<1                       % set regexp here:
    data2convert = spm_select(Inf,'^abfspmeeg.*\.mat$','Select data to convert...');
end
spm('defaults','eeg');
spm_jobman('initcfg');

h = waitbar(0,'Please wait...');
for filei = 1:size(data2convert,1)

    % Define matlabbatch parameters
    matlabbatch{1}.spm.meeg.images.convert2images.D = cellstr(data2convert(filei,:));
    matlabbatch{1}.spm.meeg.images.convert2images.mode = 'scalp x time';
    matlabbatch{1}.spm.meeg.images.convert2images.conditions = {'TEP'};
    matlabbatch{1}.spm.meeg.images.convert2images.channels{1}.all = 'all';
    matlabbatch{1}.spm.meeg.images.convert2images.timewin = [15 300];
    matlabbatch{1}.spm.meeg.images.convert2images.freqwin = [-Inf Inf];
    matlabbatch{1}.spm.meeg.images.convert2images.prefix = 't+15-300_';

    % Run
    spm_jobman('run',matlabbatch);
    waitbar(filei/size(data2convert,1));
end
close(h);
%% END