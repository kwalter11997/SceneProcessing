%% find % of eyetracking data that fell outside the specified image region

subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used

for subj = 14:30
    fileSubj = char(subjectNums(subj))  %file name for each subject 
    load(sprintf('E:\\SceneProcessing\\SubjData\\sceneProcessing_subj%s.mat',fileSubj)); %load the files one by one
        
    for trialNum = 1:100 
        trialNum
        
        myImage = imageArray{trialNum}; %image info (pixel data, used to draw image)
          
        [samplePosL, samplePosR, sampleTimes, trialTime, trialLength, pupilSize] = trialInfo(trialNum, eyelinkImportedData); %grab info from the trial
        
        [L,R] = bestEye(samplePosL,samplePosR,sampleTimes); %determine which eye to use
        
        missingIdxL = [find(isnan(samplePosL(:,1))),find(isnan(samplePosL(:,2)))]; %missing index
        missingIdxR = [find(isnan(samplePosR(:,1))),find(isnan(samplePosR(:,2)))]; %missing index
        
        missingTimesL = sampleTimes(missingIdxL); %missing times
        missingTimesR = sampleTimes(missingIdxR); %missing times
        
        %% Fixations

        startFixIndex  = min(find(eyelinkImportedData.Events.Efix.start >= trialTime(1))); %lowest index thats past (or equal to) trial start time
        endFixIndex =  max(find(eyelinkImportedData.Events.Efix.end <= trialTime(2))); %highest index before (or equal to) trial end time
        
        trialIndex = startFixIndex:endFixIndex; %all the cells for this trial
        
        sFixTimes = eyelinkImportedData.Events.Efix.start(trialIndex); %start times of every fixation during the trial
        
        eyeFix = eyelinkImportedData.Events.Efix.eye(trialIndex); %every fixation during the trial (which eye)
        
        eyedurFix = eyelinkImportedData.Events.Efix.duration(trialIndex); %durations of all fixations during the trial  

        posX = eyelinkImportedData.Events.Efix.posX(trialIndex); %all x positions
        posY = eyelinkImportedData.Events.Efix.posY(trialIndex); %all y positions
        
        fMatFix = [eyeFix',num2cell(posX)',num2cell(posY)',num2cell(sFixTimes)',num2cell(eyedurFix)']; %make a matrix of positions and each eye they correspond with
        fMatFix(:,6) = {[]}; %add a row of empties to be filled in later
         
        if L == 0 %if left eye validation is bad
           fMatFix = fMatFix(strcmp(fMatFix(:,1),'RIGHT'),:); %take only right eye data
        end
        if R == 0 %if right eye validation is bad
           fMatFix = fMatFix(strcmp(fMatFix(:,1),'LEFT'),:); %take only left eye data
        end
              
        for m = 1:length(fMatFix(:,1)) 
            missingL = cell2mat(fMatFix(m,4))-1 == missingTimesL; %if the time before the start of this fixation was a missing point
            missingR = cell2mat(fMatFix(m,4))-1 == missingTimesR; 
            if sum(missingL(:)) > 0 | sum(missingR(:)) > 0 %if either of these logical matrices have ones in them, then the start time for this fixation occured after missing data
                fMatFix(m,:) = [{NaN},{NaN},{NaN},{NaN},{NaN},{NaN}]; %remove this point, but leave it as NaNs
            end
        end
                            
        c=1; %set a start value for c (counter)
        for i = 1:length(fMatFix(:,1))
            if length(fMatFix(:,1)) == 1 %if there was only one fixation
               fMatFix(i,6) = {c};
            end
            if i+1 > length(fMatFix(:,1)) %if we've reached the last value (odd number)
               break
            else
                diffTime = abs(cell2mat(fMatFix(i,4)) - cell2mat(fMatFix(:,4))); %difference in times against all other fixations
                idx = diffTime < 100; %find all indexes where fixations occured 100/1000 s apart
                fMatFix(idx,6) = {c}; %assign them a value so they stay matched up
                c=c+1;
            end
        end
        
        %assign values to any unmatched events 
        for i = 1:length(fMatFix(:,1))
            if isempty(fMatFix{i,6})
               fMatFix(i,6) = {c}; %find any blank spots and give them their own value
               c=c+1;
            end
        end
    
        if isempty(fMatFix) %if there were no fixations this trial (missed trial), set results as NaNs 
            nFix = NaN; %total number of saccades per trial 
            saccFix = NaN; %total duration of saccades per trial
        else      
            fixMat = []; %create empty variable 
            for q = 1:max(cell2mat(fMatFix(:,6))) %go though all unique values for matches
                nums = cell2mat(fMatFix(:,6)); %convert cells to a list of all values
                rows = nums == q; %find index of current values
                if sum(rows) == 0 %if we skipped over a unique value for some reason, skip to next
                    continue
                end
                avgRows = fMatFix(rows,:); %grab the two rows we wanna combine
                if length(avgRows(:,1)) >= 2 %find how many rows with this unique value (one or two), if 2 or more then average
                    fMatFixComb = [{mean(cell2mat(avgRows(:,2)))},{mean(cell2mat(avgRows(:,3)))},{mean(cell2mat(avgRows(:,5)))}]; %take average x and y positions and durations
                    fixMat = [fixMat;fMatFixComb]; %append to end of matrix
                else
                    fMatFixComb = [avgRows(:,2),avgRows(:,3),avgRows(:,5)]; %if one unique row, just grab positions and duration
                    fixMat = [fixMat;fMatFixComb]; %append to end of matrix
                end
            end

            rect = [(CenterX) - (sizeArray(1,trialNum)./2) (CenterY) - (sizeArray(2,trialNum)./2) sizeArray(1,trialNum) sizeArray(2,trialNum)]; %grab the rectangle that includes only the image (not the gray experiment background)
            rect = [rect(1), rect(2), rect(3)-1, rect(4)-1]; %subtract 1 pixel from width/height because matlab counts 0 as 1 (without this the dimensions would be 1 pixel too many)

            allFix(trialNum) = length(fixMat); %all fixations on screen  
            if isempty(fixMat) %if all nans this trial fill in with nans
                fixMat =  [{NaN},{NaN},{NaN}]; 
            else
                for x = 1:length(fixMat(:,1))
                    if cell2mat(fixMat(x,1)) < rect(1) | cell2mat(fixMat(x,1)) > rect(1)+rect(3) | cell2mat(fixMat(x,2)) < rect(2) | cell2mat(fixMat(x,2)) > rect(2)+rect(4) %if a fixation falls outside the range of the image
                        fixMat(x,:) = [{NaN},{NaN},{NaN}]; %remove the fixation (make it a NaN)
                    end
                    if cell2mat(fixMat(x,3)) / 1000 > 10 %if a fixation lasts more than 10 seconds (eyetracker error missing point), remove it
                       fixMat(x,:) = [{NaN},{NaN},{NaN}];
                    end
                end
            end
            fixInsideImg(trialNum) = sum(~isnan(cell2mat(fixMat(:,1)))); %fixations only inside the image
        end

        %% Saccades
        %grab closest indexes after start/ before end time 
        startSaccIndex  = min(find(eyelinkImportedData.Events.Esacc.start >= trialTime(1))); %lowest index thats past (or equal to) trial start time
        endSaccIndex =  max(find(eyelinkImportedData.Events.Esacc.end <= trialTime(2))); %highest index before (or equal to) trial end time
        
        trialIndex = startSaccIndex:endSaccIndex;
        
        sSaccTimes = eyelinkImportedData.Events.Esacc.start(trialIndex); %start times of every saccade during the trial
        eSaccTimes = eyelinkImportedData.Events.Esacc.end(trialIndex); %end times of every saccade during the trial
        
        eyeSacc = eyelinkImportedData.Events.Esacc.eye(trialIndex); %every saccade during the trial (which eye)
        
        eyedurSacc = eyelinkImportedData.Events.Esacc.duration(trialIndex); %durations of all saccades during the trial  
        
        posX = eyelinkImportedData.Events.Esacc.posX(trialIndex); %all x start positions
        posY = eyelinkImportedData.Events.Esacc.posY(trialIndex); %all y start positions
        posXend = eyelinkImportedData.Events.Esacc.posXend(trialIndex); %all x start positions
        posYend = eyelinkImportedData.Events.Esacc.posYend(trialIndex); %all y start positions
        
        saccBlinkTimeDiff = eyelinkImportedData.Events.Esacc.end-eyelinkImportedData.Events.Eblink.end'; % time between end of a saccade and end of a blink (all possible pairs)
        saccBlinkTimeDiff(saccBlinkTimeDiff<=0)=nan; %take only positive values (endblink events before endsacc)
        isBlink = (min(saccBlinkTimeDiff) < eyelinkImportedData.Events.Esacc.duration);
        isBlink = isBlink(trialIndex);
        
        fMatSacc = [eyeSacc',num2cell(posX)',num2cell(posY)',num2cell(posXend)',num2cell(posYend)',num2cell(sSaccTimes)',num2cell(eSaccTimes)',num2cell(eyedurSacc)']; %make a matrix of positions and each eye they correspond with
        fMatSacc(:,9) = {[]}; %add an empty column 
        
        fMatSacc = fMatSacc(~isBlink,:); %remove saccades that are actually blinks
         
        if L == 0 %if left eye validation is bad
           fMatSacc = fMatSacc(strcmp(fMatSacc(:,1),'RIGHT'),:); %take only right eye data
        end
        if R == 0 %if right eye validation is bad
           fMatSacc = fMatSacc(strcmp(fMatSacc(:,1),'LEFT'),:); %take only left eye data
        end
               
        for m = 1:length(fMatSacc(:,1)) 
            missingLS = cell2mat(fMatSacc(m,6))-1 == missingTimesL; %if the time before the start of this saccade was a missing point
            missingRS = cell2mat(fMatSacc(m,6))-1 == missingTimesR; 
            missingLE = cell2mat(fMatSacc(m,7))-1 == missingTimesL; %if the time before the end of this saccade was a missing point (blink)
            missingRE = cell2mat(fMatSacc(m,7))-1 == missingTimesR;
            if sum(missingLS(:)) > 0 | sum(missingRS(:)) > 0 | sum(missingLE(:)) > 0 | sum(missingRE(:)) > 0 %if any of these logical matrices have ones in them, then the start time or end time for this fixation occured after missing data
                fMatSacc(m,:) = [{NaN},{NaN},{NaN},{NaN},{NaN},{NaN},{NaN},{NaN},{NaN}]; %remove this point, but leave it as NaNs
            end
        end
        
        c=1; %set a start value for c (counter)
        for i = 1:length(fMatSacc(:,1))
            if length(fMatSacc(:,1)) == 1 %if there was only one saccade 
               fMatSacc(i,9) = {c};
            end
            if i+1 > length(fMatSacc(:,1)) %if we've reached the last value (odd number)
               break
            else
                diffTime = abs(cell2mat(fMatSacc(i,6)) - cell2mat(fMatSacc(:,6))); %difference in times against all other saccades
                idx = diffTime < 100; %find all indexes where fixations occured 100/1000 s apart
                fMatSacc(idx,9) = {c}; %assign them a value so they stay matched up
                c=c+1;
            end
        end
                      
        for i = 1:length(fMatSacc(:,1))
            if isempty(fMatSacc{i,9})
               fMatSacc(i,9) = {c}; %find any blank spots and give them their own value
               c=c+1;
            end
        end

        if isempty(fMatSacc) %if there were no saccades this trial (missed trial), set results as NaNs 
            nSacc = NaN; %total number of saccades (excluding nans) per trial 
            durSacc = NaN; %total duration of saccades (in seconds) per trial
        else
            saccMat = []; %create empty variable 
            for q = 1:max(cell2mat(fMatSacc(:,9))) %go though all unique values for matches
                nums = cell2mat(fMatSacc(:,9)); %convert cells to a list of all values
                rows = nums == q; %find index of current values
                if sum(rows) == 0 %if we skipped over a unique value for some reason, skip to next
                    continue
                end
                avgRows = fMatSacc(rows,:); %grab the two rows we wanna combine
                if length(avgRows(:,1)) >= 2 %find how many rows with this unique value (one or two), if more than 2 then average
                    fMatSaccComb = [{mean(cell2mat(avgRows(:,2)))},{mean(cell2mat(avgRows(:,3)))},{mean(cell2mat(avgRows(:,4)))},{mean(cell2mat(avgRows(:,5)))},{mean(cell2mat(avgRows(:,8)))}]; %take average positions and durations
                    saccMat = [saccMat;fMatSaccComb]; %append to end of matrix
                else
                    fMatSaccComb(:) = [avgRows(:,2),avgRows(:,3),avgRows(:,4),avgRows(:,5),avgRows(:,8)]; %if one unique row, just grab positions and duration
                    saccMat = [saccMat;fMatSaccComb]; %append to end of matrix
                end
            end

            rect = [(CenterX) - (sizeArray(1,trialNum)./2) (CenterY) - (sizeArray(2,trialNum)./2) sizeArray(1,trialNum) sizeArray(2,trialNum)]; %grab the rectangle that includes only the image (not the gray experiment background)
            rect = [rect(1), rect(2), rect(3)-1, rect(4)-1]; %subtract 1 pixel from width/height because matlab counts 0 as 1 (without this the dimensions would be 1 pixel too many)

            allSacc(trialNum) = length(saccMat);
            if isempty(saccMat) %if all nans this trial fill in with nans
             saccMat = [{NaN},{NaN},{NaN},{NaN},{NaN}];
            else
                for x = 1:length(saccMat(:,1))
                    if cell2mat(saccMat(x,1)) < rect(1) | cell2mat(saccMat(x,1)) > rect(1)+rect(3) | cell2mat(saccMat(x,2)) < rect(2) | cell2mat(saccMat(x,2)) > rect(2)+rect(4) | ... 
                            cell2mat(saccMat(x,3)) < rect(1) | cell2mat(saccMat(x,3)) > rect(1)+rect(3) | cell2mat(saccMat(x,4)) < rect(2) | cell2mat(saccMat(x,4)) > rect(2)+rect(4); %if a fixation falls outside the range of the image
                       saccMat(x,:) = [{NaN},{NaN},{NaN},{NaN},{NaN}]; %remove the fixation (make it a NaN)
                    end
                    if cell2mat(saccMat(x,5)) / 1000 > 2 %if a single saccade lasts more than 2 seconds (eyetracker error missing point), remove it
                       saccMat(x,:) = [{NaN},{NaN},{NaN},{NaN},{NaN}];
                    end
                end
            end
            saccInsideImg(trialNum) = sum(~isnan(cell2mat(saccMat(:,1))));
        end     
    end
    allFixTotal(subj,:) = allFix; %make a matric of all subjects
    allSaccTotal(subj,:) = allSacc;
    totalFixInsideImg(subj,:) = fixInsideImg;
    totalSaccInsideImg(subj,:) = saccInsideImg;
end
sum(totalFixInsideImg(:))  / sum(allFixTotal(:)) %percentage of points included
sum(totalSaccInsideImg(:)) / sum(allSaccTotal(:)) %percentage of points included

(sum(totalFixInsideImg(:)) + sum(totalSaccInsideImg(:))) / (sum(allFixTotal(:)) + sum(allSaccTotal(:))) %percentage of points included

filename = 'percentageImgOutside'
save(filename,'allFixTotal','allSaccTotal','totalFixInsideImg','totalSaccInsideImg')