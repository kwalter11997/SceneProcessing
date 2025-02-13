%% Temporary library for testing
load('testObjStruct.mat')

HOMEIMAGES = 'C:\MATLAB\Scene_Processing\TemporaryLibrary\images'; % you can set here your default folder
HOMEANNOTATIONS = 'C:\MATLAB\Scene_Processing\TemporaryLibrary\annotations'; % you can set here your default folder

cd(HOMEIMAGES);
D = dir; 
D = D(~ismember({D.name}, {'.', '..'})); %first elements are '.' and '..' used for navigation - remove these

folderNames = {D([D.isdir]).name};%get all the folder names
folderNames(strcmp(folderNames,'.') | strcmp(folderNames,'..')) = [];%remove "." and ".." from folder names

%% Standard configuration
Screen('Preference','SkipSyncTests', 1);
PsychImaging('PrepareConfiguration');   % set up imaging pipeline
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma'); % gamma correction

%% Input for general information
prompt = {'Subject initials: ','Dominant eye (R/L)? ', '# trials ','Screen dimensions (cm): ','View Distance (cm): ','Eye tracking (y/n)? '};
dlg_title = 'FIRST EXPERIMENT';
num_lines = 1;
def = {'XX', 'R', '40', '56.59 33.02','X', 'y'};
answer = inputdlg(prompt,dlg_title,num_lines,def); % read in parameters from GUI
%nondominant_eye = 1-strcmpi(answer{2},'R');
%dummymode = strcmpi(answer{6},'n');      % set to 1 to initialize in dummymode (doesn't start with the Eyelink), 0 otherwise

%% Screen / Keyboard stuff
display.screens = Screen('Screens');
display.screenNumber = 2;
set(0,'units','pixels');
ScreenSize = get(0,'ScreenSize');
display.resOutput = Screen('Resolution',display.screenNumber);
display.numPixels = [display.resOutput.width  display.resOutput.height];%[1920 1080] pixel
display.refresh = display.resOutput.hz;%120;
display.dimensions = str2num(char(answer(4,1))); % screen size in cm
display.viewDistance = str2num(char(answer(5,1))); %viewing distance
display.pixelSize = mean(display.dimensions./display.numPixels); %cm/pixel
display.ScreenBackground = GrayIndex(display.screenNumber); %make the background gray
rect = []; %set size of window if you want

KbName('UnifyKeyNames'); %set key names
Esc=KbName('ESCAPE'); %set escape key

%% Experiment
cd(HOMEIMAGES)
ntrials=10; % number of trials

try
    [keyIsDown,seconds,keyCode] = KbCheck; % initialize KbCheck and variables to make sure they're properly initialized
    [w, wRect] = Screen('OpenWindow', display.screenNumber, display.ScreenBackground); %w is name of window, wRect is size of window
    duration=1; % Duration of study image presentation in secs.
    Screen('TextSize', w, 32);
    % write message to subject
    message=sprintf('Press %s to escape. Press any key to continue.',KbName(Esc));
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
    
    % loop through trials
    for trial=1:ntrials
        %pick a random folder
        randomFolder=randi(length(folderNames));
        randomFolder=folderNames(randomFolder);  
        
        % wait a bit between trials
        WaitSecs(0.500);
        
        %get foldername
        folder = char(randomFolder); 
        %get filenames from that folder
        files = dir(folder); %find all the files in the folder
        files = files(~ismember({files.name}, {'.', '..'})); %remove the "." and ".." that matlab puts at the top
        for nFile = 1:length(files) 
            fileNames(nFile) = {files(nFile).name}; %list the names
        end
        randomFile = randi(length(fileNames)); %pick a random file
        fileName = char(fileNames(randomFile)); %filename
        fileNameShort = erase(fileName, '.jpg'); %just the name (no .jpg) for later
        
        % read stimulus image into matlab matrix 'imdata':
        fullImgFile=strcat(HOMEIMAGES,'\',folder,'\',fileName); % get image file destination
        imdata=imread(char(fullImgFile));
        % make texture image out of image matrix 'imdata'
        tex=Screen('MakeTexture', w, imdata);
        % Draw texture image
        Screen('DrawTexture', w, tex);
        % Show stimulus on screen at next possible display refresh cycle, and record stimulus onset time in 'startrt':
        [VBLTimestamp, startrt]=Screen('Flip', w);
        
        % while loop to show stimulus until "duration" seconds elapsed.
        while (GetSecs - startrt)<=duration  
            if (keyCode(Esc)==1) %if at any point escape is pressed, close experiment 
                sca;
                return;
            end
            [keyIsDown,seconds,keyCode]=KbCheck;
        end
        
        % Clear screen to background color after fixed 'duration'
        Screen('Flip', w);
        
        %show 4 objects on the screen 
        
        %pick an object from the scene
        objChoice = objStruct.(['F_' folder]).(['File_' fileNameShort]).objects; %get all the objects in the image
        randomObj=randi(length(objChoice)); %randomly pick one
        objChoice = objChoice(randomObj); %that's the object we're using 
        if isempty(objChoice{1,1})
            
        %find other instances of that object
        for objSearch = 1:length(folderNames) %go through all the folders
            x = getfield(objStruct.(['F_' folderNames{objSearch}]),{1}); %get the file names for each folder (dynamic structures are annoying)
            objFile = fieldnames(x); 
            objFile = cell2mat(objFile);
            index = find(strcmp(objStruct.(['F_' folderNames{objSearch}]).([objFile]).objects, 'chair')==1) %search each object list for the name of the object we're looking for
        end

    end
    
    % Cleanup at end of experiment - Close window, show mouse cursor, close result file,normal priority:
    sca;
    ShowCursor;
    fclose('all');
    Priority(0);
    
    % End of experiment:
    end
catch
% Do same cleanup as at the end of a regular session...
sca;
ShowCursor;
fclose('all');
Priority(0);

% Output the error message that describes the error:
psychrethrow(psychlasterror);
end
