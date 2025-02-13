%% eyetracking fixations, gbvs and lsa heatmaps, roc analysis

addpath(genpath('E:\SceneProcessing\Meaning_Salience_Maps'));
addpath('E:\SceneProcessing\subjData');
addpath('E:\SceneProcessing\AUCAnalysis');
load('E:\SceneProcessing\Meaning_Salience_Maps\GBVS_LSA_Heatmaps_CenterBias')
load('E:\GloVe-master\GloVe\GloVe_Heatmaps')

subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used

for subj = 1:30
    fileSubj = char(subjectNums(subj))  %file name for each subject 
    load(sprintf('E:\\SceneProcessing\\SubjData\\sceneProcessing_subj%s.mat',fileSubj)); %load the files one by one

    for trialNum=1:length(fileArray)
        cd('E:\SceneProcessing\FinalLibrary\images\all')
        trialNum
        myImage = imageArray{trialNum}; %screengrab from experiment(need whole screen for accurate eyelink points)
        fileName = fileArray{trialNum}; %image name

        %plot positions

    %     figure(); % open a new figure
    %     imshow(myImage);
    %     axis on;
    %     hold on; % add fixations on top of text image

        startMessage = sprintf('StartTrial%d', trialNum);
        endMessage = sprintf('EndTrial%d', trialNum);
        startTrialIndices=find(strcmp(eyelinkImportedData.Events.Messages.info, startMessage)); % find indices with "StartTrial" message
        endTrialIndices=find(strcmp(eyelinkImportedData.Events.Messages.info, endMessage)); % find indices with "EndTrial" message

        trialTime = eyelinkImportedData.Events.Messages.time(startTrialIndices:endTrialIndices); %find the recorded times that this trial took place between

        %grab closest indexes for start/end time (correct for if refresh wasnt set to 1000)
        [val,idx] = min(abs(eyelinkImportedData.Samples.time-trialTime(1)));
        startPosIndex = find(eyelinkImportedData.Samples.time==eyelinkImportedData.Samples.time(idx));
        [val,idx] = min(abs(eyelinkImportedData.Samples.time-trialTime(2)));
        endPosIndex = find(eyelinkImportedData.Samples.time==eyelinkImportedData.Samples.time(idx));

        LxPos=eyelinkImportedData.Samples.gx(startPosIndex:endPosIndex,1); % find x positions of left eye
        LyPos=eyelinkImportedData.Samples.gy(startPosIndex:endPosIndex,1); % find y positions of left eye
    %     plot(LxPos, LyPos, 'xb'); % plot left eye data as blue points
        RxPos=eyelinkImportedData.Samples.gx(startPosIndex:endPosIndex,2); % find x positions of right eye
        RyPos=eyelinkImportedData.Samples.gy(startPosIndex:endPosIndex,2); % find y positions of right eye
    %     plot(RxPos, RyPos, 'xr'); % plot right eye data as red points
    %     hold off; % end adding data

%          x=0:.001:1; y=0:.001:1; %1000 steps

        leftEye = [LxPos,LyPos];
        rightEye = [RxPos,RyPos];
        bothEyes = [nanmean([leftEye(:,1),rightEye(:,1)],2),nanmean([leftEye(:,2),rightEye(:,2)],2)]; %accounts for nans, allows data where only one eye was tracked to be counted 
        %plot(bothEyes(:,1), bothEyes(:,2), 'xg')
        
        rect = [(CenterX) - (sizeArray(1,trialNum)./2) (CenterY) - (sizeArray(2,trialNum)./2) sizeArray(1,trialNum) sizeArray(2,trialNum)]; %grab the rectangle that includes only the image (not the gray experiment background)
        rect = [rect(1), rect(2), rect(3)-1, rect(4)-1]; %subtract 1 pixel from width/height because matlab counts 0 as 1 (without this the dimensions would be 1 pixel too many)
        
        %save myImage as just the image how it appeared in the experiment 
        myImage = imcrop(myImage,rect); %crop the experimental window to be just the image
        picSize = size(myImage);
        screenSize = wRect;        
        scale = ([screenSize(4),screenSize(3)] - picSize(1:2)) / 2; %grab how many pixels on either side are gray background (y,x) for plotting later
        scaledEyePos = [bothEyes(:,1)-scale(2),bothEyes(:,2)-scale(1)]; %adjust eye positions so we can plot on just the image (no gray background)
        
%         figure();
%         subplot(1,3,1);
%         imagesc([rect(1),rect(1)+rect(3)], [rect(2),rect(2)+rect(4)], overlayHeatmap(myImage, eyeTrackingFilt));
%         hold on;
%         plot(bothEyes(:,1), bothEyes(:,2), 'xb');
%         hold off;
%         title('Eyetracking');

        %% GBVS
           
        gbvsMapIdx = find(strcmp(GBVSLibrary(1,:),fileName)); %find this file in our heatmap library
        gbvsFilt = GBVSLibrary(2,gbvsMapIdx); %grab this heatmap
        gbvsFilt = gbvsFilt{1,1};
        
%         gbvsFilt = gbvsFilt./sum(gbvsFilt(:)); %integrate to 1
        
%         zgbvs = zscore(gbvsFilt);
%         zgbvs = rescale(zgbvs, 0, 1);
%                 
%         gbvsFilt = (gbvsFilt-mean(gbvsFilt(:))) / std(gbvsFilt(:)); %normalize mean and std
%         gbvsFilt = 0.5+0.25*gbvsFilt; %make mean 0.5 and std 0.25
%        
%         gbvsFilt = (gbvsFilt - min(gbvsFilt(:))) / (max(gbvsFilt(:)) - min(gbvsFilt(:)))
        
%         if mean(gbvsFilt(:)) > 0.5
%            gbvsFilt = max(gbvsFilt(:)) - gbvsFilt; %flip distribution
%            y = log10(0.5)/log10(mean(gbvsFilt(:))); 
%            gbvsFilt = gbvsFilt.^y;
%            gbvsFilt = max(gbvsFilt(:)) - gbvsFilt; %flip back
%         else
%             y = log10(0.5)/log10(mean(gbvsFilt(:))); 
%             gbvsFilt = gbvsFilt.^y;
%         end

%         gbvsFilt = (gbvsFilt-mean(gbvsFilt(:))) / std(gbvsFilt(:)); %normalize mean and std
%         gbvsFilt = 0.5+0.25*gbvsFilt; %make mean 0.5 and std 0.25
        
        %% LSA
        
        lsaMapIdx = find(strcmp(LSALibrary(1,:),fileName)); %find this file in our heatmap library
        lsaFilt = LSALibrary(2,lsaMapIdx); %grab this heatmap
        lsaFilt = lsaFilt{1,1};
         
        %% GloVe
           
        GloVeMapIdx = find(strcmp(GloVeLibrary(1,:),fileName)); %find this file in our heatmap library
        GloVeFilt = GloVeLibrary(2,GloVeMapIdx); %grab this heatmap
        GloVeFilt = GloVeFilt{1,1};
        
        %% ROC analysis 
        %True Positive Rate:
        %Sensitivity = True Positives / (True Positives + False Negatives)
        %True Positive Rate = Sensitivity
        
        %False Positive Rate:
        %Specificity = True Negatives / (True Negatives + False Positives)
        %False Positive Rate = 1-Specificity
        
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
            
%             rocVal(senslevel) = nansum(sensIm(:))/nObs; % proportion data points include (TRUE POSITIVE RATE) 
%             xaxis(senslevel) = (sum(specLevel(:))-sum(sensIm(:)))/(sizeArray(1,trialNum)*sizeArray(2,trialNum) - nObs); %(FALSE POSITIVE RATE)
        end    
    
        truePosRate = flip(truePosRate);
        falsePosRate = flip(falsePosRate);
 
        gbvsAUC(trialNum) = trapz(falsePosRate, truePosRate);
%         gbvsAUC(trialNum) = trapz(xaxis, rocVal);
% 
%         figure();
%         subplot(1,3,1)
%         plot(falsePosRate, truePosRate);
%         title('GBVS')
%         text(max(falsePosRate)*.70, max(truePosRate)*.10, ['AUC = ' num2str(gbvsAUC(trialNum))]) %put the AUC value in the bottom right corner of the plot
%         xlabel('False Postive Rate')
%         ylabel('True Positive Rate')
        
%         figure();
% %         set(gcf, 'Position',  [600, 500, 1200, 450]); %set the size and position of the figure window
%         subplot(1,2,1)
%         plot(xaxis, rocVal);
%         title('GBVS')
%         text(max(xaxis)*.70, max(rocVal)*.10, ['AUC = ' num2str(gbvsAUC(trialNum))]) %put the AUC value in the bottom right corner of the plot
%         xlabel('False Postive Rate')
%         ylabel('True Positive Rate')
        
        %lsa
        myProbSurface = lsaFilt; % probability surface
        myProbSurface = myProbSurface-min(myProbSurface(:)); % min 0
        myProbSurface = myProbSurface/max(myProbSurface(:)); % max 1

        for senslevel=1:length(specRate)
            specLevel=myProbSurface; % set surface
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
            
%             rocVal(senslevel)=nansum(sensIm(:))/nObs; % proportion data points included
%             xaxis(senslevel)=(sum(specLevel(:))-sum(sensIm(:)))/(sizeArray(1,trialNum)*sizeArray(2,trialNum)- nObs);  
        end       
       
        truePosRate = flip(truePosRate);
        falsePosRate = flip(falsePosRate);
        
        lsaAUC(trialNum) = trapz(falsePosRate, truePosRate);
%         lsaAUC(trialNum) = trapz(xaxis, rocVal);

%         subplot(1,3,2)
%         plot(falsePosRate, truePosRate);
%         title('LSA')
%         text(max(falsePosRate)*.70, max(truePosRate)*.10, ['AUC = ' num2str(lsaAUC(trialNum))]) %put the AUC value in the bottom right corner of the plot
%         xlabel('False Postive Rate')
%         ylabel('True Positive Rate')
% 
%         subplot(1,2,2)
%         plot(xaxis, rocVal);
%         title('LSA')
%         text(max(xaxis)*.70, max(rocVal)*.10, ['AUC = ' num2str(lsaAUC(trialNum))]) %put the AUC value in the bottom right corner of the plot
%         xlabel('False Postive Rate')
%         ylabel('True Positive Rate')


        %GloVe
        myProbSurface = GloVeFilt; % probability surface = heatmap
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
            
%             rocVal(senslevel) = nansum(sensIm(:))/nObs; % proportion data points include (TRUE POSITIVE RATE) 
%             xaxis(senslevel) = (sum(specLevel(:))-sum(sensIm(:)))/(sizeArray(1,trialNum)*sizeArray(2,trialNum) - nObs); %(FALSE POSITIVE RATE)
        end    
    
        truePosRate = flip(truePosRate);
        falsePosRate = flip(falsePosRate);
 
        GloVeAUC(trialNum) = trapz(falsePosRate, truePosRate);

% %        figure();
%         subplot(1,3,3)
%         plot(falsePosRate, truePosRate);
%         title('GloVe')
%         text(max(falsePosRate)*.70, max(truePosRate)*.10, ['AUC = ' num2str(GloVeAUC(trialNum))]) %put the AUC value in the bottom right corner of the plot
%         xlabel('False Postive Rate')
%         ylabel('True Positive Rate')
    end
    
%     %% Look at imagesc versions of heatmap
% 
    myImage = imresize(myImage,[sizeArray(2,trialNum) sizeArray(1,trialNum)]); %resize to the size it appeared in the experiment 
    scaledEyePos = [bothEyes(:,1)-scale(2),bothEyes(:,2)-scale(1)]
    
    figure()
    %set(gcf, 'Position', [ 500 500 1800 600])
    subplot(2,2,1)
    imagesc(myImage)
    set(gca,'XTick',[], 'YTick', [])
    title('Orignial Image')
    p1 = subplot(2,2,2)
    imagesc(myImage)
    hold on
    imagesc(gbvsFilt, 'AlphaData', .7)
%     plot(scaledEyePos(:,1), scaledEyePos(:,2), 'xb');
    title('GBVS')
    originalSize1 = get(gca, 'Position') %save the size of this so we can implement it to the colorbar images
    set(gca,'XTick',[], 'YTick', [])
    colorbar
    p2 = subplot(2,2,3)
    imagesc(myImage)
    hold on
    imagesc(lsaFilt, 'AlphaData', .7)
%     plot(scaledEyePos(:,1), scaledEyePos(:,2), 'xb');
    title('LSA')
    originalSize2 = get(gca, 'Position')
    set(gca,'XTick',[], 'YTick', [])
    colorbar
    p3 = subplot(2,2,4)
    imagesc(myImage)
    hold on
    imagesc(GloVeFilt, 'AlphaData', .7)
%     plot(scaledEyePos(:,1), scaledEyePos(:,2), 'xb');
    title('GloVe')
    originalSize3 = get(gca, 'Position')
    set(gca,'XTick',[], 'YTick', [])
    colorbar
    
    set(p1, 'Position', originalSize1)
    set(p2, 'Position', originalSize2)
    set(p3, 'Position', originalSize3)
    
    %% Save AUC for each map, along with the scene shown and current n-back 
    
    %save as an individual AUC structure 
%     AUC.(['Sub' fileSubj]).gbvs = gbvsAUC;
%     AUC.(['Sub' fileSubj]).lsa = lsaAUC;
%     AUC.(['Sub' fileSubj]).glove = GloVeAUC;
%     AUC.(['Sub' fileSubj]).file = fileArray;
%     AUC.(['Sub' fileSubj]).nBack = nArray;
    AUC.(['Sub' fileSubj]).gbvs_CB = gbvsAUC;
    
    SAVE = 'E:\SceneProcessing\AUCAnalysis';
    cd(SAVE);
    matfile = 'AUC';
    save(matfile, 'AUC');
     
end

