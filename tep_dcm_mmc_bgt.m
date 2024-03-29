function tep_dcm_mmc_bgt(fileList, outDir, start, offset)
% PURPOSE:
%  - This routine fits a model of a M1-M1-Thalamus circuit to TMS-evoked
%    potential data
%  - Can be used to fit a model to the whole temporal window, or to a 
%    series of non-overlapping windows
%
% INPUTS:
% - fileList   List of input files in SPM format. This should be time-  
%              series from virtual electrodes ('LFP-like') data.
% - outDir     Output directory
% - start      Start of fitting window in ms
% - offsets    Vector of window offsets in ms (e.g. if 50:10:100, fits
%              windows from start to 50ms, start to 60ms etc.)             
% 
% OUTPUTS:
% - DCM files 
%
% REFERENCES:
% - Motor microcircuit: PMID 26956910
% - Basal ganglia-Thalamus model: PMID 30130648


%% Check inputs
%--------------------------------------------------------------------------
if naring<1 
   error('Need inputs!'
elseif nargin<2
   files  = spm_select(Inf,'^ia.*\.mat$');
   outdir = spm_select(1,'dir','Select output directory...');
elseif nargin <3
   start   = -50;       
   offsets = 300; % if one number = 1 offset, so model whole window.
end

%% Specify DCM for each subject and time window
%--------------------------------------------------------------------------
for subji = 1:size(files,1)
   for offi = 1:length(offsets)
    
    % Define model options
    %----------------------------------------------------------------------
    DCM.options.analysis        = 'ERP';  
    DCM.options.model(1).source = 'MMC'; % Motor microcircuit
    DCM.options.model(2).source = 'MMC'; % Motor microcircuit
    DCM.options.model(3).source = 'BGT'; % Basal Ganglia Circuit model
    DCM.options.model(3).J      = 9;     % State that contributes to data (9 = Thalamus)
    DCM.options.spatial  = 'LFP';  % Spatial model is LFP (virtual electrode)
    DCM.options.trials   = 1;
    DCM.options.Tdcm     = [start offsets(offi)]; % Current window
    DCM.options.Rft      = 5;
    DCM.options.onset    = [3 64]; % Transcranial and non-transcranial input onset
    DCM.options.dur      = [5 16]; % Transcranial and non-transcranial input duration         
    DCM.options.h        = 1;      
    DCM.options.han      = 0;      
    DCM.options.D        = 1;
    DCM.options.lock     = 0;
    DCM.options.multiC   = 0;
    DCM.options.location = 0;
    DCM.options.Nmodes   = 2; 
    DCM.options.symmetry = 0;

    % Define filenames
    %----------------------------------------------------------------------
    DCM.xY.Dfile = files(subji,:);
    [~,nam,ext]  = spm_fileparts(files(subji,:));

    if offsets(offi)<100
        DCM.name = [outdir '/' 'DCM_' nam '_BGT',...
                        '_0' num2str(offsets(offi)) 'ms'];
    else
        DCM.name = [outdir '/' 'DCM_' nam '_BGT',...
                         '_' num2str(offsets(offi)) 'ms'];
    end

    % Define connectivity architecture 
    %----------------------------------------------------------------------
    DCM.xY.Ic            = [1 2]; % " Hidden" Thalamus / basal-ganglia
    DCM.Sname            = {'Left SM1', 'Right SM1','Thalamus'}; 
    DCM.Lpos             = []; 
    DCM.A{1}             = [0,1,1;1,0,1;0,0,0]; % forward between both M1 and from Thalamus to both M1
    DCM.A{2}             = [0,1,0;1,0,0;1,1,0]; % backward between both M1 and from both M1 to Thalamus
    DCM.A{3}             = [0,1,0;1,0,0;0,0,0]; % lateral (transcallosal) connections between M1
    DCM.B                = {};                  
    DCM.C                = [1 0;0 0;1 1];       % transcranial input is to left M1, non-transcranial to Thalamus 
    DCM.M                = [];
    DCM.xU.X             = [];

    % Report progress
    %----------------------------------------------------------------------
    disp(['Specified DCM for subject ' num2str(subji) ', time window '...
        num2str(offi)]);
    
    % Invert DCM (optional)
    %----------------------------------------------------------------------
    disp(['Inverting DCM for subject ' num2str(subji) ', time window '...
        num2str(offi)]);
    DCM = spm_dcm_erp(DCM);

    % Save DCM
    %----------------------------------------------------------------------
    save(DCM.name,'DCM');

    end
end

%% End
%--------------------------------------------------------------------------
disp('Done!')
