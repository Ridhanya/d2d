%% standard

arInit;
addpath('../PanRTK_commonScripts')
arLoadModel('RTKmodel_Met_qFACS')
arLoadData('RTKdata_332M_AB_CTG',1,'csv');
arLoadData('RTKdata_BxPc3_AB_CTG',1,'csv');

arCompileAll
arLink;

arSetParsPattern('basal_', -1, 1, 1, -5, 6);
arSetParsPattern('scale_', -1, 1, 1, -5, 8);
arSetParsPattern('sd_', -1, 1, 1, -3, 6);

arSetPars({'init_EGFR_EGF','init_ErbB3_HRG','init_IGF1R_IGF1','init_Met_HGF'},zeros(1,4),ones(1,4)*2,zeros(1,4),ones(1,4)*-5,ones(1,4)*3);
arSetParsPattern('sd_FACS_',-0.8,2,1,-5,3);
arSetPars({'EGF_kD','HRG_kD','IGF1_kD','HGF_kD'},[log10(1) log10(0.05) log10(0.3) log10(0.3)],ones(1,4)*2,ones(1,4),ones(1,4)*-5,ones(1,4)*3);

% Load Parameters of best fit
arLoadPars('Final_Model')
arSave('Final_model')

% Load data of CTG viability screen and calculated receptor surface levels
load('CTG_output_struct.mat')
% 
% %Calculate model features and set Matrices needed for BDT training
global bdt
global bdt_figures
crawl_viability(log10(Matrices.qFACS./10000),1)
set_RNA_Matrices(0)
set_RNA_Matrices(1)
 
save('BDT_matrices_new.mat','bdt','bdt_figures')

% %Calculate model features for TCGA, to use after BDT calibration based on
% %in-vitro data
% load('TCGA_matrices.mat')
% create_Matrices_TCGA
% mutations_into_TCGA
% save('Own_BDT_plus_TCGA_matrices.mat','bdt','bdt_figures','TCGA_Matrices')