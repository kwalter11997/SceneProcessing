%% Save data and plot eye position data
load('sceneProcessing_subjKW_tobii.mat')

for trialNum=1:length(fileArray) % create a new figure for each trial
    figure(); % open a new figure
    imshow(imageArray{trialNum});
    axis on;
    hold on; % add fixations on top of text image
    xPos=leftEyeXposTrial{trialNum}; % convert left eye x position data to pixel position
    yPos=leftEyeYposTrial{trialNum}; % convert left eye y position data to pixel position
    plot(xPos, yPos, 'xb'); % plot left eye data as blue points
    xPos=rightEyeXposTrial{trialNum}; % convert right eye x position data to pixel position
    yPos=rightEyeYposTrial{trialNum}; % convert right eye y position data to pixel position
    plot(xPos, yPos, 'xr'); % plot right eye data as red points
    hold off; % end adding data
end


x=0:0.01:1; y=x; % generate (x,y) bins, with 100 steps
for trialNum=1:length(fileArray) % create a new figure for each trial
    leftEye = [leftEyeXposTrial{trialNum}',leftEyeYposTrial{trialNum}'];
    rightEye = [rightEyeXposTrial{trialNum}',rightEyeYposTrial{trialNum}'];
    
    normalizedLeftX = (leftEye(:,1)-min(leftEye(:,1)))/(max(leftEye(:,1))-min(leftEye(:,1)));
    normalizedLeftY = (leftEye(:,2)-min(leftEye(:,2)))/(max(leftEye(:,2))-min(leftEye(:,2)));
    normalizedRightX = (rightEye(:,1)-min(rightEye(:,1)))/(max(rightEye(:,1))-min(rightEye(:,1)));
    normalizedRightY = (rightEye(:,2)-min(rightEye(:,2)))/(max(rightEye(:,2))-min(rightEye(:,2)));
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
    contour(x,y,HR','r','linewidth',2); % contour map of Right eye position ingreen
    hold off; % end adding data
end

for trialNum=1:length(fileArray); % create a new figure for each trial
    HB = hist3((leftEye{trialNum}+leftEye{trialNum})./2,{x,y}); % create a 2D histogram of mean eye positions
    HB=conv2(gaussFilt,gaussFilt',HB,'same'); % smooth both eyes histogram
    figure(); % open a new figure
    imagesc(overlayHeatmap( imageArray{trialNum} , HB' ));
end

length(imageArray{trialNum}(1,:,:))
length(imageArray{trialNum}(:,1,:))
