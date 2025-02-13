%% permutation analysis running with parfor
addpath('E:\SceneProcessing');
addpath(genpath('E:\SceneProcessing\Meaning_Salience_Maps'));
addpath('E:\SceneProcessing\subjData');
addpath('E:\SceneProcessing\PermutationAnalysis');
% load('E:\SceneProcessing\Meaning_Salience_Maps\GBVS_LSA_Heatmaps')
% load('E:\GloVe-master\GloVe\GloVe_Heatmaps')
load('E:\SceneProcessing\Meaning_Salience_Maps\GBVS_LSA_Heatmaps_CenterBias')

%create empty variables
targetGBVS = zeros(100,100,30);
% targetLSA = zeros(100,100,30);
% targetGloVe = zeros(100,100,30);
gbvsAUCmat = zeros(100,100,30); 
% lsaAUCmat = zeros(100,100,30);
% GloVeAUCmat = zeros(100,100,30);

%run through all subjects
subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used
fileNameLibrary = GBVSLibrary(1,:); %all 3 libraries are in the same order, so we'll just use gbvs

% parpool('local',10) %tell matlab to use 10 workers
% poolobj = gcp; %assign a name to our pool
% addAttachedFiles(poolobj, {'ROC.m'}) %attach the ROC function to our pool

cd('E:\SceneProcessing\FinalLibrary\images\all')
        
for subj=1:30
    fileSubj = char(subjectNums(subj))  %file name for each subject 
    subjdata = load(sprintf('E:\\SceneProcessing\\SubjData\\sceneProcessing_subj%s.mat',fileSubj)); %load the files one by one
    
    %take only the variables we need
    imageArray = subjdata.imageArray;
    sizeArray1 = subjdata.sizeArray(1,:);
    sizeArray2 = subjdata.sizeArray(2,:);
    fileArray = subjdata.fileArray;
    eyelinkMessInfo = subjdata.eyelinkImportedData.Events.Messages.info;
    eyelinkMessTime = subjdata.eyelinkImportedData.Events.Messages.time;
    eyelinkSampTime = subjdata.eyelinkImportedData.Samples.time;
    eyelinkSampGx1 = subjdata.eyelinkImportedData.Samples.gx(:,1);
    eyelinkSampGx2 = subjdata.eyelinkImportedData.Samples.gx(:,2);
    eyelinkSampGy1 = subjdata.eyelinkImportedData.Samples.gy(:,1);
    eyelinkSampGy2 = subjdata.eyelinkImportedData.Samples.gy(:,2);
    
    clear subjdata %make some space
    
    simSpace = [100,100]
    numSims = prod(simSpace)
        
%     tic
%     parfor trialNum=1:100 %all trials      
      for trialNum=1:100  
        CenterX = 960; %screen info
        CenterY = 540; 

        trialNum
        myImage = imageArray{trialNum}; %screengrab from experiment(need whole screen for accurate eyelink points)

        startMessage = sprintf('StartTrial%d', trialNum);
        endMessage = sprintf('EndTrial%d', trialNum);
       
        startTrialIndices=find(strcmp(eyelinkMessInfo, startMessage)); % find indices with "StartTrial" message
        endTrialIndices=find(strcmp(eyelinkMessInfo, endMessage)); % find indices with "EndTrial" message
        
        trialTime1 = eyelinkMessTime(startTrialIndices); %find the recorded times that this trial took place between
        trialTime2 = eyelinkMessTime(endTrialIndices);
        
         %grab closest indexes for start/end time (correct for if refresh wasnt set to 1000)
        [~,idx] = min(abs(eyelinkSampTime-trialTime1));
        startTrialIdx = find(eyelinkSampTime==eyelinkSampTime(idx));
        [~,idx] = min(abs(eyelinkSampTime-trialTime2));
        endTrialIdx = find(eyelinkSampTime==eyelinkSampTime(idx));

        allLpos = [eyelinkSampGx1,eyelinkSampGy1]; %get all L eye pos data
        allRpos = [eyelinkSampGx2,eyelinkSampGy2]; %get all R eye pos data

        samplePosL = allLpos(startTrialIdx:endTrialIdx,:); %all x and y L positions during this trial
        samplePosR = allRpos(startTrialIdx:endTrialIdx,:); %all x and y R positions during this trial

        bothEyes = [nanmean([samplePosL(:,1),samplePosR(:,1)],2),nanmean([samplePosL(:,2),samplePosR(:,2)],2)]; %accounts for nans, allows data where only one eye was tracked to be counted 

        rect = [(CenterX) - (sizeArray1(trialNum)./2) (CenterY) - (sizeArray2(trialNum)./2) sizeArray1(trialNum) sizeArray2(trialNum)]; %grab the rectangle that includes only the image (not the gray experiment background)
        rect = [rect(1), rect(2), rect(3)-1, rect(4)-1]; %subtract 1 pixel from width/height because matlab counts 0 as 1 (without this the dimensions would be 1 pixel too many)

        %save myImage as just the image how it appeared in the experiment 
        myImage = imcrop(myImage,rect); %crop the experimental window to be just the image
        picSize = size(myImage);
        screenSize = [0,0,1920,1080];
        scale = ([screenSize(4),screenSize(3)] - picSize(1:2)) / 2; %grab how many pixels on either side are gray background (y,x) for plotting later
        scaledEyePos = [bothEyes(:,1)-scale(2),bothEyes(:,2)-scale(1)]; %adjust eye positions so we can plot on just the image (no gray background)

%         tic
            for pics = 1:100
                picName = fileArray{pics}; %go through all images
                pics

                idx = find(strcmp(picName,fileNameLibrary)); %find the index of this pic in our heatmap library 

                gbvsFilt = GBVSLibrary(2,idx); %grab this heatmap
                gbvsFilt = gbvsFilt{1,1};
%                 lsaFilt = LSALibrary(2,idx); %grab this heatmap
%                 lsaFilt = lsaFilt{1,1};
%                 GloVeFilt = GloVeLibrary(2,idx); %grab this heatmap
%                 GloVeFilt = GloVeFilt{1,1};

                gbvsFilt = imresize(gbvsFilt, [size(myImage,1),size(myImage,2)]); %resize so it's the size of our target image
%                 lsaFilt = imresize(lsaFilt, [size(myImage,1),size(myImage,2)]); %resize so it's the size of our target image          
%                 GloVeFilt = imresize(GloVeFilt, [size(myImage,1),size(myImage,2)]); %resize so it's the size of our target image

                %% ROC analysis       
%                 [gbvsAUC, lsaAUC, GloVeAUC] = ROC(myImage,scaledEyePos,gbvsFilt,lsaFilt,GloVeFilt); %grab AUC values           
  
%JUST FOR RE-DOING GBVS - otherwise can use function above
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                myFixIm = zeros(size(myImage)); % empty fixation image

                x=0:1:size(myImage,2)-1; %make x and y the size of the image
                y=0:1:size(myImage,1)-1;

                myFixIm = hist3(scaledEyePos,{x,y})'; %histogram of every pixel that was fixated       

                nObs = nansum(myFixIm(:)); %number of fixations total

                specRate=0:0.01:1; % levels of 1-specificity
                rocVal=zeros(1, length(specRate)); % estimated sensitivity

                %gbvs
                myProbSurface = gbvsFilt; % probability surface = heatmap
                myProbSurface = myProbSurface-min(myProbSurface(:)); % min 0
                myProbSurface = myProbSurface/max(myProbSurface(:)); % max 1

                %roc plot traditionally has sensIm (rocVal) on y axis and 1-spec on x axis, so we have to do the 1-specLevel part because our x axis is just spec
                for senslevel=1:length(specRate)
                    specLevel = myProbSurface; % set surface (our map)
        %             specLevel = specLevel > (1 - specRate(senslevel)); % set at current level - which spots on the map are above our current set level
                    specLevel = specLevel >= specRate(senslevel);
                    insideMap = specLevel.*myFixIm; % cacluate how many points in this level of specificity (how many points between the eyetracking fixations and heatmap are overlapping)
                    outsideMap = (1-specLevel).*myFixIm; %calculate how many points are outside this level of specificity

                    truePos = sum(insideMap(:)); %Heatmap where there was a point
                    trueNeg = sum((1-specLevel).*(myFixIm==0),'all'); %No heatmap where there was no point
                    falsePos = sum(specLevel.*(myFixIm==0),'all'); %Heatmap where there was no point
                    falseNeg = sum(outsideMap(:)); %No heatmap when in fact there was a point

                    truePosRate(senslevel) = truePos / (truePos+falseNeg);
                    falsePosRate(senslevel) = 1 - (trueNeg / (trueNeg+falsePos));
                end    

                truePosRate = flip(truePosRate);
                falsePosRate = flip(falsePosRate);

                gbvsAUC = trapz(falsePosRate, truePosRate);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                gbvsAUCmat(trialNum,pics,subj) = gbvsAUC;
%                 lsaAUCmat(trialNum,pics,subj) = lsaAUC;
%                 GloVeAUCmat(trialNum,pics,subj) = GloVeAUC;

                targetGBVS(trialNum,pics,subj) = NaN; %has to return something, so we'll return NaNs (and remove them later)
%                 targetLSA(trialNum,pics,subj) = NaN;
%                 targetGloVe(trialNum,pics,subj) = NaN;

                %save the target image seperate
                if pics == trialNum
                    targetGBVS(trialNum,pics,subj) = gbvsAUCmat(trialNum,pics,subj);
%                     targetLSA(trialNum,pics,subj) = lsaAUCmat(trialNum,pics,subj);
%                     targetGloVe(trialNum,pics,subj) = GloVeAUCmat(trialNum,pics,subj);

                    gbvsAUCmat(trialNum,pics,subj) = NaN; %remove the target picture from the array
%                     lsaAUCmat(trialNum,pics,subj) = NaN;
%                     GloVeAUCmat(trialNum,pics,subj) = NaN;
                end    
            end
        end
end
%         [gbvsAUCmat,lsaAUCmat,GloVeAUCmat,targetGBVS,targetLSA,targetGloVe] = perm(subj,GBVSLibrary,LSALibrary,GloVeLibrary)      

delete(gcp('nocreate')); %close the parloop

SAVE = 'E:\SceneProcessing\AUCAnalysis'
cd(SAVE)
% saveFile = 'parforPermutationAnalysis';
% save(saveFile,'targetGBVS','targetLSA','targetGloVe','gbvsAUCmat','lsaAUCmat','GloVeAUCmat')
saveFile = 'parforPerm_GBVS_CB'
save(saveFile,'targetGBVS','gbvsAUCmat')
