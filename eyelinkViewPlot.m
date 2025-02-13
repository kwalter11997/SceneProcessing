%% Eyelink - plot eye position data

 %eyelinkImportedData = Edf2Mat('ETData.edf'); % https://github.com/uzh/edf-converter

for trialNum=1:length(fileArray)
    
    %plot positions
    
    figure(); % open a new figure
    imshow(imageArray{trialNum});
    axis on;
    hold on; % add fixations on top of text image
    
    startMessage = sprintf('StartTrial%d', trialNum);
    endMessage = sprintf('EndTrial%d', trialNum);
    startTrialIndices=find(strcmp(eyelinkImportedData.Events.Messages.info, startMessage)); % find indices with "StartTrial" message
    endTrialIndices=find(strcmp(eyelinkImportedData.Events.Messages.info, endMessage)); % find indices with "EndTrial" message

    trialTime = eyelinkImportedData.Events.Messages.time(startTrialIndices:endTrialIndices); %find the recorded times that this trial took place between
    startPosIndex = find(eyelinkImportedData.Samples.time==trialTime(1)); %find index of start position
    endPosIndex = find(eyelinkImportedData.Samples.time==trialTime(2)); %find index of end position

    LxPos=eyelinkImportedData.Samples.gx(startPosIndex:endPosIndex,1); % find x positions of left eye
    LyPos=eyelinkImportedData.Samples.gy(startPosIndex:endPosIndex,1); % find y positions of left eye
    plot(LxPos, LyPos, 'xb'); % plot left eye data as blue points
    RxPos=eyelinkImportedData.Samples.gx(startPosIndex:endPosIndex,1); % find x positions of right eye
    RyPos=eyelinkImportedData.Samples.gy(startPosIndex:endPosIndex,1); % find y positions of right eye
    plot(RxPos, RyPos, 'xr'); % plot right eye data as red points
    hold off; % end adding data

    %plot histograms
    
    x=0:0.01:1; y=x; % generate (x,y) bins, with 100 steps
    
    leftEye = [LxPos,LyPos];
    rightEye = [RxPos,RyPos];
    
    %normalize on a scale from 0 to 1 based on window size
    normalizedLeftX = (leftEye(:,1)-0)./(wRect(3)-0); 
    normalizedLeftY = (leftEye(:,2)-0)./(wRect(4)-0);
    normalizedRightX = (rightEye(:,1)-0)./(wRect(3)-0);
    normalizedRightY = (rightEye(:,2)-0)./(wRect(4)-0);
    normalizedLeftEye = [normalizedLeftX,normalizedLeftY];
    normalizedRightEye = [normalizedRightX,normalizedRightY];
 
    HL = hist3(normalizedLeftEye,{x,y}); % create a 2D histogram of left eye positions
    HR = hist3(normalizedRightEye,{x,y}); % create a 2D histogram of right eye positions
    
    gaussFilt=fspecial('gaussian',[9 1],2); % create gaussian filter with standard deviation of 2 pixels
    HL=conv2(gaussFilt,gaussFilt',HL,'same'); % smooth left eye histogram
    HR=conv2(gaussFilt,gaussFilt',HR,'same'); % smooth right eye histogram
    figure(); % open a new figure
    imagesc(x,y,imageArray{trialNum}); % show this trial's image
    hold on; % allow data adding to figure
    contour(x,y,HL','g','linewidth',2); % contour map of Left eye position ingreen
    contour(x,y,HR','r','linewidth',2); % contour map of Right eye position inred
    hold off; % end adding data

    %plot heatmaps 
    
    HB = hist3((normalizedLeftEye+normalizedRightEye)./2,{x,y}); % create a 2D histogram of mean eye positions
%     HB = hist3((leftEye+rightEye)./2,{x,y}); % create a 2D histogram of mean eye positions
    HB=conv2(gaussFilt,gaussFilt',HB,'same'); % smooth both eyes histogram
    figure(); % open a new figure
    imagesc(overlayHeatmap( imageArray{trialNum} , HB' ));
end
