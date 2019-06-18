function tep_tep
%% Introduction
% Purpose:
% - Calculate TMS-evoked potentials (TEPs) from preprocessed epoched files 
%   1. Trial-wise baseline subtraction
%   2. Standard averaging
%
% Dependecies: 
% - SPM12
%
% Inputs: 
% - Epoched SPM12 EEG data file
%
% Outputs:
% - TEP data file with prefix 'mbspmeeg_' (m = mean, b = baseline)
%
%--------------------------------------------------------------------------
% (c) 05/2017, Eugenio Abela, Richardson Lab, IoPPN, KCL


%% Select data
data2tep   = spm_select(Inf,'mat','Select data to calculate ERP from ...');

%% Select baseline period
%--------------------------------------------------------------------------
% (Quite unnecessary code overhead, but we like windows).
prompt     = {'Enter baseline period:'};
dlg_title  = 'Baseline';
num_lines  = 1;
defaultans = {'-1000 -500'};
answer     = inputdlg(prompt,dlg_title,num_lines,defaultans);
baseline   = str2double(answer{:}); 

%% Loop over data
%--------------------------------------------------------------------------
% Initialise SPM12 defaults
spm('defaults','eeg');
spm_jobman('initcfg');

% Initialise waitbar
wb = waitbar(0,'Calculating TEP, please wait...');

% Loop
for ii = 1:size(data2tep,1)
    matlabbatch{1}.spm.meeg.preproc.bc.D = {data2tep(ii,:)};
    matlabbatch{1}.spm.meeg.preproc.bc.timewin = baseline;
    matlabbatch{1}.spm.meeg.preproc.bc.prefix = 'b';
    matlabbatch{2}.spm.meeg.averaging.average.D(1) = cfg_dep('Baseline correction: Baseline corrected M/EEG datafile', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','Dfname'));
    matlabbatch{2}.spm.meeg.averaging.average.userobust.standard = false;
    matlabbatch{2}.spm.meeg.averaging.average.plv = false;
    matlabbatch{2}.spm.meeg.averaging.average.prefix = 'm';
    spm_jobman('run',matlabbatch);
    waitbar(ii/size(data2tep,1));
end
close(wb);

%% End
%--------------------------------------------------------------------------
disp('Done!')
