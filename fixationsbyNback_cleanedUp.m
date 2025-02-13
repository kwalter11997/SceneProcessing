%% number/duration of fixations and saccades made by n-back

subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used

%create some empty variables for later
totalFixN = [];
totalFixDur = [];
totalSaccN = [];
totalSaccDur = [];
totalTrialLength = [];
oneEye = [];
oneEyeSubjs = [];
 
for subj = 1:30
    fileSubj = char(subjectNums(subj))  %file name for each subject 
    load(sprintf('E:\\SceneProcessing\\SubjData\\sceneProcessing_subj%s.mat',fileSubj)); %load the files one by one
        
    for trialNum = 1:100 
        
        myImage = imageArray{trialNum}; %image info (pixel data, used to draw image)
          
        [samplePosL,samplePosR,bothEyes,sampleTimes,trialTime,trialLength] = trialInfo(trialNum, eyelinkImportedData);
        
        missingIdxL = [find(isnan(samplePosL(:,1))),find(isnan(samplePosL(:,2)))]; %missing index
        missingIdxR = [find(isnan(samplePosR(:,1))),find(isnan(samplePosR(:,2)))]; %missing index
        
        missingTimesL = sampleTimes(missingIdxL); %missing times
        missingTimesR = sampleTimes(missingIdxR); %missing times
        
        if all(all(isnan(samplePosL))) %if there is no L eye data this trial
           L = 0; %only use right eye
           R = 1;
        elseif all(all(isnan(samplePosR))) %if there is no R eye data for this trial
          L = 1; %only use left eye
          R = 0;
        else
            [maxVar] = plotTrialPos(sampleTimes,samplePosL,samplePosR);
            %if xVar > 5000 | yVar > 5000 %if the difference in variance between the left and right eyes is over 10000 for x or y values
           if maxVar == 1 %1=left eye has worse variance, 2=right eye has worse variance
               L = 0; %only use right eye
               R = 1;
           else
               L = 1; %only use left eye
               R = 0;
           end
    %         else
    %              L = 1; %use both eyes
    %              R = 1;
    %         end
        end
        
       % oneEye(:,trialNum) = sum(L == 0 | R == 0); %keep track of which trials we're only using one eye for 
       whichEye(:,trialNum) = maxVar; %keep a record of which eye we're using
        
%         v(trialNum,:) = [xVar,yVar];
%     end
%         [avgErrDeg,maxErrDeg,xLocPx,yLocPx,xErrorPx,yErrorPx] = parseCalibrationEdf2Mat(eyelinkImportedData);
%         Lval = [abs(xErrorPx(1,:))',abs(yErrorPx(1,:))']; %left eye x and y validation 
%         Rval = [abs(xErrorPx(2,:))',abs(yErrorPx(2,:))']; %right eye x and y validation
% 
%         if sum(Lval(:) > 200) > 0 %if any of the error validations in the left eye are > 200
%             L = 0; 
%         else
%             L = 1;
%         end
%         if sum(Rval(:) > 200) > 0 %if any of the error validations in the right eye are > 200
%             R = 0;
%         else
%             R = 1;
%         end
%         
%         [calCheckL, calCheckR] = parseCalbyBlock(eyelinkImportedData)
        
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
        
%         figure()
%         imagesc(myImage)
%         hold on
%         plot(posX',posY','ob') %points are almost overlapping because this is left and right eye data together ie. double the number of fixations
         
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

           % cross reference with subjData, if we didn't have enough data there, remove the points here
           if isnan(subjData.(['Sub' fileSubj]).gbvs(trialNum))
               nFix = NaN;
               durFix = NaN;
           else
               nFix = sum(~isnan(cell2mat(fixMat(:,1)))); %total number of fixations (excluding nans) per trial 
               durFix = nansum(cell2mat(fixMat(:,3))) / 1000; %total duration of fixations (in seconds) per trial
           end
%            
            figure()
            imagesc(myImage)
            hold on
            plot(cell2mat(fixMat(:,1)),cell2mat(fixMat(:,2)), 'ob','LineWidth',1,'markerfacecolor','b') %points are almost overlapping because this is left and right eye data together ie. double the number of fixations

            set(gcf, 'Position',  [300, 200, 960, 540]) %make the window size in the same aspect ratio of the original experiment screen (1920x1080divided by 2) 
            set(gca,'XTick',[], 'YTick', []) %hide axes values (unecessary)       
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
        
%        % figure()
%         imagesc(myImage)
%         hold on
%         plot(SposXL',SposYL','--xb') %points are almost overlapping because this is left and right eye data together ie. double the number of fixations
%         plot(EposXL',EposXL,'--xb')
%         plot(SposXR',SposYR','--xr') %points are almost overlapping because this is left and right eye data together ie. double the number of fixations
%         plot(EposXR',EposXR,'--xr')
       
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
              
            % cross reference with subjData, if we didn't have enough data there, remove the points here
            if isnan(subjData.(['Sub' fileSubj]).gbvs(trialNum))
                nSacc = NaN;
                durSacc = NaN;
            else
                 nSacc = sum(~isnan(cell2mat(saccMat(:,1)))); %total number of saccades (excluding nans) per trial 
                 durSacc = nansum(cell2mat(saccMat(:,5))) / 1000; %total duration of saccades (in seconds) per trial
            end
        end
%         
%         figure()
%         imagesc(myImage)
        hold on
        plot(cell2mat(saccMat(:,1)),cell2mat(saccMat(:,2)),'--r','LineWidth',.75) %plot lines connecting saccades and fixations
        
       logicMat(trialNum,:) = durFix+durSacc > trialLength(trialNum); %see if the sum of fixations and saccades are more than the length of the trial

       FixN(trialNum,:) = [nFix,nArray(trialNum),subj]; %make a matrix for trials, add the n back along with it
       FixDur(trialNum,:) = [durFix,nArray(trialNum),subj];

       SaccN(trialNum,:) = [nSacc,nArray(trialNum),subj]; 
       SaccDur(trialNum,:) = [durSacc,nArray(trialNum),subj];
       
    end
    trialLengths = [trialLength',repmat(subj,100,1)]; %trial length and subject number
    totalTrialLength = [totalTrialLength;trialLengths]; %append
    
    totalFixN = [totalFixN;FixN]
    totalFixDur = [totalFixDur;FixDur]
    totalSaccN = [totalSaccN;SaccN]
    totalSaccDur = [totalSaccDur;SaccDur]
    
%     oneEyeSubjs(subj,:) = oneEye; %keep track of which subjects/trials we're only using one eye for 
    whichEyeSubjs(subj,:) = whichEye; %keep track of which subjects/trials we're only using one eye for
end

%% save 

totalFix = [totalFixN(:,1),totalFixDur];
totalSacc = [totalSaccN(:,1),totalSaccDur];
%fix an error that caused duplicate fix times where should be nans
totalFix(isnan(totalFix(:,1)),2) = NaN;

SAVE = 'E:\SceneProcessing';
cd(SAVE);
matfile = 'FixbyN';
save(matfile, 'totalFix');
matfile = 'SaccbyN';
save(matfile,'totalSacc')

%% check
logicMat = totalFix(:,2)+totalSacc(:,2) > totalTrialLength(:,1)/1000
logicCheck = sum(logicMat) %see how many trials are over the trial time (out of 200 trials)
logicIndx = find(logicMat) %see which trials are over trial time (under 100 indicates subj1, over 100 indicates subj27; last 2 digits indicates trial #)

%% plot
%total duration by n
figure()
scatter(totalFix(:,3),totalFix(:,2),'b')
hold on
scatter(totalSacc(:,3),totalSacc(:,2),'r')
ls = lsline;
ls(1).Color = 'r';
ls(2).Color = 'b';
xlabel('N-back')
ylabel('Time')
title('Duration of Fixations and Saccades across N-Back')
legend('Fixations', 'Saccades')
ylim([0,10])

x_2 = totalFix(:,3)
y_2 = totalFix(:,2)

x_1 = totalSacc(:,3)
y_1 = totalSacc(:,2)

p2_1 = polyfit(get(ls(1),'xdata'),get(ls(1),'ydata'),1); %get the intercepts for the line equation
x1 = ones(size(x_1,1),1); %need a column of ones for regress to work
X_1 = [x1 x_1];    % Includes column of ones
[b1,bint1,r1,rint1,stats1] = regress(y_1,X_1) %stats = [r2 F prob s2]

p2_2 = polyfit(get(ls(2),'xdata'),get(ls(2),'ydata'),1); %get the intercepts for the line equation
x2 = ones(size(x_2,1),1); %need a column of ones for regress to work
X_2 = [x2 x_2];    % Includes column of ones
[b2,bint2,r2,rint2,stats2] = regress(y_2,X_2) %stats = [r2 F prob s2]

text(8.2, 4.4, [sprintf('r(%d)=', sum(~isnan(totalFix(:,1)))) num2str(round(sqrt(stats1(1)),3)) ' ', 'p=' num2str(round(stats1(3),3))],'Color','r');
text(8.2, 3.9, ['y=' num2str(round(p2_1(1),3)) '*x+' num2str(round(p2_1(2),3))],'Color','r');

text(8.2, 5.4, [sprintf('r(%d)=', sum(~isnan(totalSacc(:,1)))) num2str(round(sqrt(stats2(1)),3)) ' ', 'p=' num2str(round(stats2(3),3))],'Color','b');
text(8.2, 4.9, ['y=' num2str(round(p2_2(1),3)) '*x+' num2str(round(p2_2(2),3))],'Color','b');

%total amount by n
figure()
scatter(totalFix(:,3),totalFix(:,1),'x','b')
hold on
scatter(totalSacc(:,3),totalSacc(:,1),'o','r')
ls = lsline;
ls(1).Color = 'red';
ls(2).Color = 'blue';

xlabel('N-back')
ylabel('# of Events')
title('Amount of Fixations and Saccades across N-Back')
legend('Fixations', 'Saccades')

x_1 = totalFix(:,3)
y_1 = totalFix(:,1)

x_2 = totalSacc(:,3)
y_2 = totalSacc(:,1)

p2_1 = polyfit(get(ls(1),'xdata'),get(ls(1),'ydata'),1); %get the intercepts for the line equation
x1 = ones(size(x_1,1),1); %need a column of ones for regress to work
X_1 = [x1 x_1];    % Includes column of ones
[b1,bint1,r1,rint1,stats1] = regress(y_1,X_1) %stats = [r2 F prob s2]
p2_2 = polyfit(get(ls(2),'xdata'),get(ls(2),'ydata'),1); %get the intercepts for the line equation
x2 = ones(size(x_2,1),1); %need a column of ones for regress to work
X_2 = [x2 x_2];    % Includes column of ones
[b2,bint2,r2,rint2,stats2] = regress(y_2,X_2) %stats = [r2 F prob s2]

text(7.5, 13, [sprintf('r(%d)=',sum(~isnan(totalFix(:,1)))) num2str(round(sqrt(stats1(1)),3)) ' ', 'p=' num2str(stats1(3))],'Color','r');
text(7.5, 10, ['y=' num2str(round(p2_1(1),3)) '*x+' num2str(round(p2_1(2),3))],'Color','r'); 

text(7.5, 5, [sprintf('r(%d)=',sum(~isnan(totalSacc(:,1)))) num2str(round(sqrt(stats2(1)),3)) ' ', 'p=' num2str(stats2(3))],'Color','b');
text(7.5, 3, ['y=', num2str(round(p2_2(1),3)) '*x+' num2str(round(p2_2(2),3))],'Color','b');

%grab some basic descriptives 
nanmin(totalFix(:,2))
nanmax(totalFix(:,2))
quantile(totalFix(:,2),[.25 .5 .75])
nanmean(totalFix(:,2))

nanmin(totalSacc(:,2))
nanmax(totalSacc(:,2))
quantile(totalSacc(:,2),[.25 .5 .75])
nanmean(totalSacc(:,2))

%% split by subject's ability, correct vs incorrect responses 
totalResponses = [];

for subj = 1:30
    fileSubj = char(subjectNums(subj));  %file name for each subject 
    totalResponses = [totalResponses;subjData.(['Sub' fileSubj]).response'];  
end

totalFix(:,5) = totalResponses;
totalSacc(:,5) = totalResponses;

corRows = []
incorRows = []

for n = 0:10
    nRows = [];
    rows = totalFix(:,3) == n; %logic mat for rows at each n
    for m = 1:length(rows)
        if rows(m) == 1 %if this is an n we're looking for
           %nRows = [nRows;totalFix(m-n,[1:2]),n,totalFix(m,5)]; %grab the data from the photo being recalled (duration/amount from the photo n back [m-n], correct response from the trial being done [m])
            nRows = [nRows;totalFix(m,[1:2]),n,totalFix(m,4),totalFix(m,5)];
%            nRows = [nRows;totalFix(m-n,[1:2]),totalFix(m-n,3),totalFix(m,5)];
        end
    end

    cor = nRows(:,5) == 1; %correct responses
    
    corRows = [corRows;nRows(cor,:)]; %correct rows at this n
    incorRows = [incorRows;nRows(~cor,:)]; %incorrect rows at this n

end

%take averages by n for each subj
avgCor = []
avgIncor = []
for subj = 1:30
    subjCorRows = corRows(corRows(:,4) == subj,:); %grab all rows for this subj
    subjIncorRows = incorRows(incorRows(:,4) == subj,:);
    for n = 1:max(subjCorRows(:,3))
        avgCorRows = subjCorRows(subjCorRows(:,3) == n,:);
        avgCor = [avgCor;mean(avgCorRows(:,1)),mean(avgCorRows(:,2)),n,subj];
    end
    for n = 1:max(subjIncorRows(:,3))
        avgIncorRows = subjIncorRows(subjIncorRows(:,3) == n,:);
        avgIncor = [avgIncor;mean(avgIncorRows(:,1)),mean(avgIncorRows(:,2)),n,subj];
    end
end

stdFix = nanstd(totalFix(:,1))

figure()
hold on
scatter(avgCor(:,3),avgCor(:,1),'ob')
scatter(avgIncor(:,3),avgIncor(:,1),'or')
xlabel('N-back')
ylabel('# of Events')
title('Average Amount of Fixations across N-Back')

SEMFix = stdFix/sqrt(length(subjFix(:,1)));                % Standard Error
tsFix = max(tinv([0.025  0.975],length(subjFix(:,1))-1));        % T-Score
CIFix = avgFix + tsFix*SEMFix;                 % Confidence interval

errorbar(maxN(subj),avgFix(subj),tsFix(subj)*SEMFix(subj), 'ob','MarkerFaceColor','b'); %error bars are confidence intervals 

%plot all trials
figure()
hold on

subplot(1,2,1)
scatter(corRows(:,3),corRows(:,1),'o','b')
hold on
scatter(incorRows(:,3),incorRows(:,1),'x','r')
xlabel('N-back')
ylabel('# of Events')
title('Amount of Fixations across N-Back')

ls = lsline
ls(1).Color = 'red';
ls(2).Color = 'blue';

legend('Correct', 'Incorrect')

subplot(1,2,2)
scatter(corRows(:,3),corRows(:,2),'o','b')
hold on
scatter(incorRows(:,3),incorRows(:,2),'x','r')
xlabel('N-back')
ylabel('Duration of Events')
title('Duration of Fixations across N-Back')

ls = lsline
ls(1).Color = 'red';
ls(2).Color = 'blue';

legend('Correct', 'Incorrect')

%saccades
corRows = []
incorRows = []

for n = 0:10
    nRows = [];
    rows = totalSacc(:,3) == n; %logic mat for rows at each n
    for m = 1:length(rows)
        if rows(m) == 1 %if this is an n we're looking for
           %nRows = [nRows;totalSacc(m-n,[1:2]),n,totalSacc(m,5)]; %grab the data from the photo being recalled (duration/amount from the photo n back [m-n], correct response from the trial being done [m])
         nRows = [nRows;totalSacc(m,[1:2]),n,totalSacc(m,4),totalSacc(m,5)];
%         nRows = [nRows;totalSacc(m,[1:2]),totalSacc(m,3),totalSacc(m,5)];
        end
    end
%     nRows = totalSacc(rows,:); %grab just the rows for this n

    cor = nRows(:,5) == 1; %correct responses
    
    corRows = [corRows;nRows(cor,:)]; %correct rows at this n
    incorRows = [incorRows;nRows(~cor,:)]; %incorrect rows at this n

end

figure()

subplot(1,2,1)
scatter(corRows(:,3),corRows(:,1),'o','b')
hold on
scatter(incorRows(:,3),incorRows(:,1),'x','r')
xlabel('N-back')
ylabel('# of Events')
title('Amount of Saccades across N-Back')

ls = lsline
ls(1).Color = 'red';
ls(2).Color = 'blue';

legend('Correct', 'Incorrect')

subplot(1,2,2)
scatter(corRows(:,3),corRows(:,2),'o','b')
hold on
scatter(incorRows(:,3),incorRows(:,2),'x','r')
xlabel('N-back')
ylabel('Duration of Events')
title('Duration of Saccades across N-Back')

ls = lsline
ls(1).Color = 'red';
ls(2).Color = 'blue';

legend('Correct', 'Incorrect')
