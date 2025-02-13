%% Startup
clear all
load('E:\SceneProcessing\FinalLibrary\finalStruct8.mat')
addpath(genpath('E:\SceneProcessing'));

commandwindow;
%% Set library
HOMEANNOTATIONS = 'E:\SceneProcessing\FinalLibrary\annotations'
HOMEIMAGES =  'E:\SceneProcessing\FinalLibrary\images\all'
SAVE = 'E:\SceneProcessing\SubjData';

cd(HOMEIMAGES);
D = dir; 
D = D(~ismember({D.name}, {'.', '..'})); %first elements are '.' and '..' used for navigation - remove these

% folderNames = {D([D.isdir]).name};%get all the folder names
% folderNames(strcmp(folderNames,'.') | strcmp(folderNames,'..')) = [];%remove "." and ".." from folder names

fileNames = {D.name}; %get all the file names
fileNames(strcmp(fileNames,'.') | strcmp(fileNames,'..')) = [];%remove "." and ".." from file names

%% Standard configuration
Screen('Preference','SkipSyncTests', 1);
PsychImaging('PrepareConfiguration');   % set up imaging pipeline
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma'); % gamma correction

%% Input for general information
prompt = {'Subject Number: ', '#of blocks', '# trials per block ', 'Duration (s)', 'Screen dimensions (cm): ','View Distance (cm): ','Eye tracking (0=No 1=Eyelink 2=Tobii)'};
dlg_title = 'SceneProcessing';
num_lines = 1;
def = {'XX', '4', '25', '10', '60 34','63', '1'};
answer = inputdlg(prompt,dlg_title,num_lines,def); % read in parameters from GUI
nblocks = str2num(char(answer(2,1))); %number of blocks
ntrials = str2num(char(answer(3,1))); %number of trials
duration = str2num(char(answer(4,1))); % Duration of study image presentation in secs
eyeTracking=str2num(char(answer(7,1))); % which eye tracker is being used 0) none; 1) Eyelink; 2) Tobii

% create file to save data - make sure not to overwrite existing file
sName=char(answer(1,1));
testSName=sName;
string = sprintf('sceneProcessing_subj%s.mat',sName);

cd(SAVE);
while exist([testSName,string],'file') ~= 0 % modify sName if subject already exists
    testSName=[sName,'_1'];
end
dataFile=sprintf('sceneProcessing_subj%s.mat', testSName); % matlab datafile to store experiment parameters and results

eyelinkImportedData=[]; % empty structure for saving, in case Tobii used
leftEye=[]; % dummy variables for Tobii, in case Eyelink used
rightEye=[];
eyeXTime=[];
testTimeRec=[];
    
leftEyeXposTrial=cell(1,ntrials); % set up data records for eye position during trials - use cells because # records may vary from trial to trial
leftEyeYposTrial=cell(1,ntrials);
rightEyeXposTrial=cell(1,ntrials);
rightEyeYposTrial=cell(1,ntrials);
%% Screen / Keyboard stuff
display.screens = Screen('Screens');
display.screenNumber = 0 ;
set(0,'units','pixels');
display.resOutput = Screen('Resolution',display.screenNumber);
display.refresh = display.resOutput.hz; 
display.scrnWidthPix=display.resOutput.width; % work out screen dimensions (pixels)
display.scrnHeightPix=display.resOutput.height;
display.viewDistance = str2num(char(answer(6,1))); %viewing distance
display.scrnWidthDeg=2*atand((0.5*display.scrnWidthPix)/display.viewDistance); % convert screen width to degrees visual angle
pixPerDeg=display.scrnWidthPix/display.scrnWidthDeg; % # pixels per degree
display.dimensionsCM = str2num(char(answer(5,1))); % screen size in cm
display.pixelSize = mean(display.dimensionsCM./pixPerDeg); %cm/pixel
display.ScreenBackground = GrayIndex(display.screenNumber); %make the background gray
scrnWidthPix = display.scrnWidthPix;
scrnHeightPix = display.scrnHeightPix;

[w, wRect] = Screen('OpenWindow', display.screenNumber, display.ScreenBackground); %w is name of window, wRect is size of window
frameRate=Screen('FrameRate', w); % screen timing parameters
nImageFrames=frameRate*duration;
    
KbName('UnifyKeyNames'); %set key names
Esc=KbName('Q'); %set escape key

%Set up eyetracking
if eyeTracking==1 % Eye tracking with Eyelink
    if (Eyelink('Initialize') ~= 0), return; % check eye tracker is live
    end
    el=EyelinkInitDefaults(w);
    if ~EyelinkInit(0)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    Eyelink('command',['calibration_area_proportion =' '0.5' '0.5']);
    Eyelink('command',['validation_area_proportion =' '0.5' '0.5']);
    Eyelink('command', 'calibration_type = HV9'); %set 9 calibration points 
    Eyelink('openfile', 'ETData.edf');
    EyelinkDoTrackerSetup(el); 
    Eyelink('StartRecording'); % start eye tracking at trial start
    HideCursor; % remove distraction of cursor - later restore it with:  ShowCursor('Arrow');
elseif eyeTracking==2 % % Eye tracking with Tobii EyeX or 4C
    addpath(genpath('C:\toolbox\TobiiMatlabToolbox3.0')); % add path to Tobii toolbox files
    tobii = tobii_connect('C:\toolbox\TobiiMatlabToolbox3.0\matlab_server\'); % establish connection ot Tobii
    [msg, DATA, tobii]= tobii_command(tobii,'init'); % initialize Tobii
    [msg, DATA]= tobii_command(tobii,'start','EyeXData\'); % start logging data
    testTimeRec=nan(ntrials,2); % empty matrix of start and stop times for Tobii
    HideCursor; % remove distraction of cursor - later restote it with:  ShowCursor('Arrow');
end

%% Experiment
cd(HOMEIMAGES)

try
    Seed=round(sum(100*clock)); % use current time to generate new seed number for random number generation so that all trial parameters can be reproduced if necessary
    rng(Seed); % seed the random number generator
    [keyIsDown,seconds,keyCode] = KbCheck; % initialize KbCheck and variables to make sure they're properly initialized
    CenterX=wRect(1)+(display.scrnWidthPix/2); % center X of display
    CenterY=wRect(2)+(display.scrnHeightPix/2); %center Y of display

    %set the target centers for where the objects will appear 
    cTarg1 = [(CenterX - (display.scrnWidthPix/4)), (CenterY - (display.scrnHeightPix/4))]; %bottom left
    cTarg2 = [(CenterX + (display.scrnWidthPix/4)), (CenterY - (display.scrnHeightPix/4))]; %bottom right
    cTarg3 = [(CenterX - (display.scrnWidthPix/4)), (CenterY + (display.scrnHeightPix/4))]; %top left
    cTarg4 = [(CenterX + (display.scrnWidthPix/4)), (CenterY + (display.scrnHeightPix/4))]; %top right
    cTargets = [cTarg1;cTarg2;cTarg3;cTarg4];

    % write message to subject
    Screen('TextSize', w, 32); %set text size for message
    message=sprintf('Hello! Thank you for participanting in this study. Your goal is to view the images as they appear on the screen. \n You will have 10 seconds to study each image. You will then be asked to choose which object \n out of four similar objects was present in the scene you studied. After 2 correct responses in a row, \n you will be asked to recall the image 1 before the last image viewed. If you ever answer incorrectly, \n you will have to remember one less. Try and remember each scene as best you can. \n Press %s to escape. Press any key to continue.',KbName(Esc));
    DrawFormattedText(w, message, 'center', 'center', WhiteIndex(w));
    % Update the display to show the instruction text:
    Screen('Flip', w);
    % Wait for keypress:
    KbWait;
    
    if keyCode(Esc) == 1 %if pressed escape then quit
        sca;
    else
        % Clear screen to background color (our 'gray' as set at the beginning):
        Screen('Flip', w);
        % Wait a second before starting trial
        WaitSecs(1.000);

        %randomize files
        randomFile=randperm(length(fileNames));
        randomFile=fileNames(randomFile);  
        
        %set up counters 
        subjResponses = zeros(1,ntrials*nblocks); %make the variable subjResponses (subject responses), to be filled at the end 
        nArray  = zeros(1,ntrials*nblocks); %set up array to keep track of how the n changed throughout the experiment
        %nArray(1) = n;
            
        %loop through blocks
        for block = 1:nblocks

            if block > 1 && eyeTracking == 1
                %recalibrate before each block (don't count on first block because we already calibrated before the instructions) 
                Eyelink('StopRecording');
                Eyelink('Message', sprintf('Recalibrate%d',block)); % insert message at start of recalibration
                EyelinkDoTrackerSetup(el); %hands control off to the eyetracker for calibration
                Eyelink('StartRecording'); %start recording again
            end
             
            n = 0; %start with 0 back
            consec = []; %make the variable consec (consecutive trials), to be filled at the end
            conCount = 0; %start a variable conCount to count the number of consecutive trials since last switch
            
            % loop through trials (per block)
            for blockTrial=1:ntrials
                
                trial = ((block-1)*ntrials)+blockTrial; %formula to get overall trial number 
                nArray(trial) = n; %keep track of the n 
                
                HideCursor; %hide while images are being shown

                % wait a bit between trials
                WaitSecs(0.500);

                %get file info
                fileName = char(randomFile(trial))
                fileShort = erase(fileName, '.jpg'); %just the name (no .jpg) for later
                fileArray(trial) = {fileShort}; %list all the files as they appear throughout the experiment 
                fullAnnFile = strcat(HOMEANNOTATIONS, '\', fileShort, '.xml'); %get annotation file destination
                fullImgFile = strcat(HOMEIMAGES, '\', fileName); % get image file destination

                %get folder info
                [annotation] = LMread(fullAnnFile); % grab annotation so we can get the folder name
                folder = annotation.folder;
                folderArray(trial) = {folder}; %put the folder in an array so we can grab it later
                folderNames = fieldnames(finalStruct8); %list all the folders

                % read stimulus image into matlab matrix 'imdata':
                imdata=imread(char(fullImgFile));
                %resize all images to be the same size
                width = length(imdata(1,:,:)); %dimensions of image
                height = length(imdata(:,1,:));
                maxDim = max([width;height]); %largest dimension
                scaleratio = 1280 / maxDim; %scale based off largest dimension
                imdata = imresize(imdata, scaleratio);
                sizeArray(1,trial) = length(imdata(1,:,:)); %save resized width dimension
                sizeArray(2,trial) = length(imdata(:,1,:)); %save resized height dimension 
                % make texture image out of image matrix 'imdata'
                tex=Screen('MakeTexture', w, imdata);
                % Draw texture image
                Screen('DrawTexture', w, tex);
                % Show stimulus on screen at next possible display refresh cycle, and record stimulus onset time in 'startIm':
                [VBLTimestamp, startIm]=Screen('Flip', w);
                imageArray{trial}=Screen('GetImage', w); % grab an RGB image of the screen for visualization

                %start recording eye position
                OSGazeX=[]; % clear records of eye positions
                OSGazeY=[];
                ODGazeX=[];
                ODGazeY=[];
                for frameNo=1:nImageFrames % for as long as the image is on screen
                    if eyeTracking==1 % Eyelink
                        if frameNo==1
                            Eyelink('Message', sprintf('StartTrial%d',trial)); % inset message at start of trial
                        end
                        if Eyelink('NewFloatSampleAvailable')>0 % get the sample in the form of an event structure
                            evt = Eyelink('NewestFloatSample'); % capture latest position
                            OSGazeX=[OSGazeX evt.gx(1)]; % store current OS and OD gaze
                            OSGazeY=[OSGazeY evt.gy(1)];
                            ODGazeX=[ODGazeX evt.gx(2)];
                            ODGazeY=[ODGazeY evt.gy(2)];
                        end
                    elseif eyeTracking==2 % Tobii
                        [LEpos, REpos, etTime] = tobii_getGPN(tobii,scrnWidthPix,scrnHeightPix); % get Tobii's estimate of current point of gaze
                        if frameNo==1 
                            testTimeRec(trial,1)=etTime; % note time at start of this trial
                        end
                        OSGazeX=[OSGazeX LEpos(1)*display.scrnWidthPix]; % store current OS and OD gaze
                        OSGazeY=[OSGazeY LEpos(2)*display.scrnHeightPix];
                        ODGazeX=[ODGazeX REpos(1)*display.scrnWidthPix];
                        ODGazeY=[ODGazeY REpos(2)*display.scrnHeightPix];
                    end
                end

                % while loop to show stimulus until "duration" seconds elapsed.
                while (GetSecs - startIm)<=duration  
                    if (keyCode(Esc)==1) %if at any point escape is pressed, close experiment 
                        sca;
                        %return;
                    end
                    [keyIsDown,seconds,keyCode]=KbCheck;
                end

                 % Clear screen to background color after fixed 'duration'
                Screen('Flip', w);

                %record end of trial for eyetracking
                if eyeTracking==1 % Eyelink
                    Eyelink('Message', sprintf('EndTrial%d',trial)); % inset message at end of trial
                elseif eyeTracking==2 % Tobii
                    testTimeRec(trial,2)=etTime; % note time at end of this trial
                end

                % store eye position data
                leftEyeXposTrial{trial}=OSGazeX; % store record of gaze position at frame rate during trial
                leftEyeYposTrial{trial}=OSGazeY;
                rightEyeXposTrial{trial}=ODGazeX;
                rightEyeYposTrial{trial}=ODGazeY;

                % wait a bit between trials
                WaitSecs(0.500);

                ShowCursor('Arrow'); %show during obj choice task

                %% pick an object from the scene n back
                nbackFolder = char(folderArray(trial-n)); %find the folder n back
                nbackFile = char(fileArray(trial-n)); %find the file n back

                allObjs = finalStruct8.(['F_' nbackFolder]).(['File_' nbackFile]).objects; %get all the objects in the image
                randomObj=randperm(length(allObjs)); %randomize the order
                for z = 1:length(allObjs)
                    correctObj = {[]}; %clear in case we have to run again
                    correctObjDim = {[]};
                    objChoice = allObjs(randomObj(z)); %go through the random order until one of the objects has at least 3 matches in the image library
                    correctObj = finalStruct8.(['F_' nbackFolder]).(['File_' nbackFile]).objInfo(randomObj(z)); %get the info for this object
                    correctObjDim = {[finalStruct8.(['F_' nbackFolder]).(['File_' nbackFile]).objDim(1,randomObj(z)), finalStruct8.(['F_' nbackFolder]).(['File_' nbackFile]).objDim(2,randomObj(z))]}; %get correct obj dimensions
                    correctObjFile = nbackFile;
                    origCorrObjDims = {[finalStruct8.(['F_' nbackFolder]).(['File_' nbackFile]).originalDims(1,randomObj(z)), finalStruct8.(['F_' nbackFolder]).(['File_' nbackFile]).originalDims(2,randomObj(z))]}; %get original obj dimensions for correct obj (not our stretched obj - this is how it appears in the image)

                    %if the object has been choosen before, pick new
                    if trial ~= 1 %don't do this on the first trial because we don't have the trialObjects array yet 
                       usedBefore = []; %clear array
                       for q = 1:length(trialObjects)
                           cor = trialObjects{1,q}.correct; %which obj was correct that trial 
                           usedObj = trialObjects{1,q}.masks{1,cor}; %run through all previously correct objs 
                           usedBefore(1,q) = isequal(correctObj{1,1},usedObj); %make an array of logical answers for "if has been used before"
                       end
                       if sum(usedBefore) > 0 %if there's a 1 within that array, skip to a new object
                          continue %restart the object loop
                       end
                    end

                    %if the object is a NaN, pick a new object
                    if isnan(cell2mat(correctObj))
                        continue
                    end
                    
                    %if both of the obj dimensions are less than 100 pixels, pick a new object    
                    if origCorrObjDims{1,1}(1,1) < 100 && origCorrObjDims{1,1}(1,2) < 100 
                        continue %restart the object loop
                    else    

                        %% find other instances of that object
                        matchingObjs = {[]}; %clear matching obejcts array before each new image
                        matchingObjsDim = {[]};
                        origMatchingObjDims = {[]};
                        matchingObjsFile = {[]};

                        overallFileNum = 0; %start a count

                        for folderSearch = 1:length(folderNames) %go through all the folders
                             files = fieldnames(finalStruct8.(char(folderNames(folderSearch)))); %find all the files in the folder

                             for nFile = 1:length(files) 
                                overallFileNum = overallFileNum + 1; %keep track of how many files we've counted so we can make a full array
                                skipFiles = strcmp(char(erase(files(nFile),'File_')),fileArray(trial-n:trial)); %test for each file, create a logical array of files we want to skip

                                if sum(skipFiles) > 0 %if any file in the logic array comes up as true 
                                    matchingObjs(overallFileNum) = {[]};
                                    matchingObjsDim(overallFileNum) = {[]};
                                    origMatchingObjDims(overallFileNum) = {[]};
                                    matchingObjsFile(overallFileNum) = {[]};
                                    continue  %don't look in the file we're already using // or any file within the specified nBack  
                                else
                                     index = find(strcmp(finalStruct8.([folderNames{folderSearch}]).(files{nFile}).objects, objChoice)==1); %search each object list for the name of the object we're looking for
                                     if ~isempty(index) %if the same object is found somewhere 
                                         if length(index) > 1 %if that file has more than one of this object
                                            randIndex = randi(length(index)); %pick a random one of that object
                                            index = index(randIndex); %that's the object
                                         end
                                         matchingObjs(overallFileNum) = finalStruct8.([folderNames{folderSearch}]).(files{nFile}).objInfo(index); %pull the object mask of matching objects
                                         matchingObjsDim(overallFileNum) = {[finalStruct8.([folderNames{folderSearch}]).(files{nFile}).objDim(1,index), finalStruct8.([folderNames{folderSearch}]).(files{nFile}).objDim(2,index)]}; %pull the dimensions for each object
                                         origMatchingObjDims(overallFileNum) = {[finalStruct8.([folderNames{folderSearch}]).(files{nFile}).originalDims(1,index), finalStruct8.([folderNames{folderSearch}]).(files{nFile}).originalDims(2,index)]}; %get original obj dimensions for correct obj (not our stretched obj - this is how it appears in the image)
                                         matchingObjsFile(overallFileNum) = {erase(files{nFile},'File_')};

                                         if origMatchingObjDims{1,overallFileNum}(1,1) < 100 || origMatchingObjDims{1,overallFileNum}(1,2) < 100  
                                             matchingObjs(overallFileNum) = {[]}; %remove a matching obj from the string if it's too small
                                             matchingObjsDim(overallFileNum) = {[]};
                                             origMatchingObjDims(overallFileNum) = {[]};
                                             matchingObjsFile(overallFileNum) = {[]};
                                         end
                                         if isnan(matchingObjsDim{overallFileNum})
                                            matchingObjs(overallFileNum) = {[]}; %remove objs with NaN dimensions
                                            matchingObjsDim(overallFileNum) = {[]};
                                            origMatchingObjDims(overallFileNum) = {[]};
                                            matchingObjsFile(overallFileNum) = {[]};
                                         end
                                     end
                                 end
                             end

                            matchingObjs = matchingObjs(~cellfun('isempty',matchingObjs)); %delete empty cells
                            matchingObjsDim = matchingObjsDim(~cellfun('isempty',matchingObjsDim));
                            origMatchingObjDims = origMatchingObjDims(~cellfun('isempty',origMatchingObjDims));
                            matchingObjsFile = matchingObjsFile(~cellfun('isempty',matchingObjsFile));
                            %imshow(cell2mat(matchingObjs(1,2)))
                        end
                    end

                    if length(matchingObjs) >= 3 %if the object we've picked has at least 3 matches, end that loop, continue on
                        break 
                    end
                end

                %shuffle order of objs
                randomObjOrder = randperm(length(matchingObjs));
                matchingObjs = matchingObjs(randomObjOrder);
                matchingObjsDim = matchingObjsDim(randomObjOrder);
                origMatchingObjDims =  origMatchingObjDims(randomObjOrder);
                matchingObjsFile =  matchingObjsFile(randomObjOrder);

                %take only 3 objs
                matchingObjs = matchingObjs(1:3); 
                matchingObjsDim = matchingObjsDim(1:3);
                origMatchingObjDims = origMatchingObjDims(1:3);
                matchingObjsFile = matchingObjsFile(1:3);

                %add the correct obj into the array
                matchingObjs = [matchingObjs, correctObj];
                matchingObjsDim = [matchingObjsDim, correctObjDim];
                origMatchingObjDims = [origMatchingObjDims, origCorrObjDims];
                matchingObjsFile = [matchingObjsFile, correctObjFile];
                randomObjOrder = randperm(length(matchingObjs)); %shuffle again now with the correct obj and 3 matching objs
                matchingObjs = matchingObjs(randomObjOrder);
                matchingObjsDim = matchingObjsDim(randomObjOrder);
                origMatchingObjDims =  origMatchingObjDims(randomObjOrder);
                matchingObjsFile = matchingObjsFile(randomObjOrder);

                %% set where the objects / response rectangles for the mouse will appear
                nObjs=length(matchingObjs);
                respRects=zeros(nObjs, 4);
                xStimCenter=zeros(1,nObjs);
                yStimCenter=zeros(1,nObjs);
                for objNum=1:nObjs 
                    dim = cell2mat(matchingObjsDim(objNum)); %dimensions of our object
                    respRects(objNum,:)= [cTargets(objNum,1) - dim(2)/2 , cTargets(objNum,2) - dim(1)/2 , cTargets(objNum,1) + dim(2)/2 , cTargets(objNum,2) + dim(1)/2 ]; %set the boundries of where we'll draw the obj
                    xStimCenter(objNum)=cTargets(objNum,1);
                    yStimCenter(objNum)=cTargets(objNum,2);
                end

                %set which obj position is the correct one
                for match = 1:length(matchingObjs)
                    matchIndex(match) = isequal(correctObj, matchingObjs(1,match))
                end
                correctResp = find(matchIndex, 1); %the obj pos that is true is correct

                %record which objects were choosen throughout the experiment 
                trialStruct.object = cell2mat(objChoice);
                trialStruct.masks = matchingObjs;
                trialStruct.dims =  matchingObjsDim;
                trialStruct.origDims =  origMatchingObjDims;
                trialStruct.files = matchingObjsFile;
                trialStruct.correct = correctResp;
                trialObjects{trial} = trialStruct;

                [mx,my,buttons] = GetMouse(w); % wait for mouse button release before processing response
                while any(buttons) % if already down, wait for release (observer must move cursor to obj)
                    [mx,my,buttons] = GetMouse(w);
                end

                for objNum=1:nObjs 
                    % make texture image out of image matrix 
                    objtex=Screen('MakeTexture', w, cell2mat(matchingObjs(objNum)));
                    % Draw texture image
                    Screen('DrawTexture', w, objtex, [], respRects((objNum),:)');
                end

                % Show stimulus on screen at next possible display refresh cycle, and record response onset time in 'startResp':
                [VBLTimestamp, startResp]=Screen('Flip', w);

                onsetTime = GetSecs; % note time at start of trial

                while ~any(buttons) % run this loop until observer presses any button
                    WaitSecs(0.016); % wait one video frame
                    [mx,my,buttons] = GetMouse(w);
                end

                responseLatency(trial)= GetSecs-onsetTime; % note time at end of trial minus time at start of trial
                mouseDistFromEachBox=sqrt((mx-xStimCenter).^2+(my-yStimCenter).^2); %find mouse position
                [~,respNum]=min(mouseDistFromEachBox);

                conCount = conCount + 1; %add a count to the consecutive trial number 

                if respNum == correctResp %if correct
                    resp = 1; %record correct
                else
                    resp = 0; %record incorrect 
                end

                subjResponses(trial) = resp; %record responses 
                if resp == 0 %if last response was wrong
                   consec = 0; %clear the consecutive vector 
                else %if last response was right
                    if conCount < 2
                        consec = 0; %makes sure we only start recounting the vector after 2 new trials  
                    else
                        consec = sum(subjResponses(trial-1:trial)); %if correct, count the consecutive vector
                    end
                end

                if respNum == correctResp %if correct
                   if consec == 2 %and if we've had 2 consecutive correct responses in a row
                      message = sprintf('Correct! Now look for objects from the image %d back. \n press space to continue', n+1); %update directions
                      DrawFormattedText(w, message, 'center', 'center', [0 1 0]); %last part is color (green)
                      Screen('Flip', w);
                      KbWait;

                      n = n+1; %up the nBack
                      conCount = 0; %restart the count for consecutive correct answers
                   else
                       message = 'Correct!';
                       DrawFormattedText(w, message, 'center', 'center', [0 1 0]); %last part is color (green)
                       Screen('Flip', w);
                       WaitSecs(.75); 
                   end

                else %if incorrect 
                    if n == 0 %if we're only at 0 back, just say incorrect
                        message = 'Incorrect';
                        DrawFormattedText(w, message, 'center', 'center', [1 0 0]); %last part is color (red)
                        Screen('Flip', w);
                        WaitSecs(.75);
                    else %if we're more than 0 back, change directions to say n-1 back 
                        message = sprintf('Incorrect. Now look for objects from the image %d back. \n press space to continue',n-1);
                        DrawFormattedText(w, message, 'center', 'center', [1 0 0]); %last part is color (red)
                        Screen('Flip', w);
                        KbWait;

                        n = n-1; %drop back an n
                    end
                end
            end 
            %end of block
            blockmessage = 'You have reached the end of this block. \n You may take a short break, when you are ready to continue, \n press spacebar';
            DrawFormattedText(w, blockmessage, 'center', 'center', WhiteIndex(w));
            Screen('Flip', w);
            KbWait;
        end
    end
    
    %% save data and clean up
    cd(SAVE);
    sca;
    ShowCursor;
    Screen('CloseAll');
    Priority(0);
    if eyeTracking==1 % Stop Eyetracker at end of experiment
        Eyelink('StopRecording');
        Eyelink('CloseFile');
        Eyelink('ReceiveFile','ETData.edf',pwd,1);
        eyelinkImportedData = Edf2Mat('ETData.edf'); % https://github.com/uzh/edf-converter
    elseif eyeTracking==2
        [~, ~, tobii]= tobii_command(tobii,'stop');% Stop Eyetracking
        leftEye=load('EyeXData\Left.txt'); % load left eye data from EyeX file
        rightEye=load('EyeXData\Right.txt'); % load right eye data from EyeX file
        eyeXTime=load('EyeXData\Time.txt'); % load time data from EyeX file
        tobii_close(tobii);
    end

    save(dataFile, 'CenterX','CenterY','cTargets','display','eyelinkImportedData','eyeTracking','eyeXTime','fileArray','folderArray','imageArray','leftEye','leftEyeXposTrial','leftEyeYposTrial','nArray','ODGazeX','ODGazeY','OSGazeX','OSGazeY','prompt','responseLatency','rightEye','rightEyeXposTrial','rightEyeYposTrial','sizeArray','subjResponses','testTimeRec','trialObjects','wRect');  
    
catch % error during experiment, save data so far and clean up
    cd(SAVE);
    sca;
    ShowCursor;
    Priority(0);
    if eyeTracking==1 % Stop Eyetracker at end of trial
        Eyelink('StopRecording');
        Eyelink('CloseFile');
        Eyelink('ReceiveFile','ETData.edf',pwd,1);
        eyelinkImportedData = Edf2Mat('ETData.edf'); % https://github.com/uzh/edf-converter
    elseif eyeTracking==2
        [~, ~, tobii]= tobii_command(tobii,'stop');% Stop Eyetracking
        leftEye=load('EyeXData\Left.txt'); % load left eye data from EyeX file
        rightEye=load('EyeXData\Right.txt'); % load right eye data from EyeX file
        eyeXTime=load('EyeXData\Time.txt'); % load time data from EyeX file
        tobii_close(tobii);
    end
    Screen('CloseAll');
    
    save(dataFile, 'CenterX','CenterY','cTargets','display','eyelinkImportedData','eyeTracking','eyeXTime','fileArray','folderArray','imageArray','leftEye','leftEyeXposTrial','leftEyeYposTrial','nArray','ODGazeX','ODGazeY','OSGazeX','OSGazeY','prompt','responseLatency','rightEye','rightEyeXposTrial','rightEyeYposTrial','sizeArray','subjResponses','testTimeRec','trialObjects','wRect');
    
    % Output the error message that describes the error:
    psychrethrow(psychlasterror);
end
 