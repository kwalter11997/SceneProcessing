function [targetGBVS,targetLSA,targetGloVe,gbvsAUCmat,lsaAUCmat,GloVeAUCmat] = listAUCs(trialNum,pics,myImage,scaledEyePos,gbvsFilt,lsaFilt,GloVeFilt,subj)
%% ROC analysis 
            
[gbvsAUC, lsaAUC, GloVeAUC] = ROC(myImage,scaledEyePos,gbvsFilt,lsaFilt,GloVeFilt); %grab AUC values           

gbvsAUCmat(pics) = gbvsAUC(subj);
lsaAUCmat(pics) = lsaAUC(subj);
GloVeAUCmat(pics) = GloVeAUC(subj);

targetGBVS(pics) = NaN; %has to return something, so we'll return NaNs (and remove them later)
targetLSA(pics) = NaN;
targetGloVe(pics) = NaN;

%save the target image seperate
if pics == trialNum
    targetGBVS(pics) = gbvsAUCmat(pics);
    targetLSA(pics) = lsaAUCmat(pics);
    targetGloVe(pics) = GloVeAUCmat(pics);

    gbvsAUCmat(pics) = NaN; %remove the target picture from the array
    lsaAUCmat(pics) = NaN;
    GloVeAUCmat(pics) = NaN;
end