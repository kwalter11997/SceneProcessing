%% put subj eyetracking data into the structure subjdata

subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used

for subj = 1:30
    subj
    fileSubj = char(subjectNums(subj));  %file name for each subject 
    load(sprintf('E:\\SceneProcessing\\SubjData\\sceneProcessing_subj%s.mat',fileSubj)); %load the files one by one
   
    subjData.(['Sub' fileSubj]).eyelinkImportedData.Events.Messages.info = eyelinkImportedData.Events.Messages.info;
    subjData.(['Sub' fileSubj]).eyelinkImportedData.Events.Messages.time = eyelinkImportedData.Events.Messages.time;
    subjData.(['Sub' fileSubj]).eyelinkImportedData.Samples.gx = eyelinkImportedData.Samples.gx;
    subjData.(['Sub' fileSubj]).eyelinkImportedData.Samples.gy = eyelinkImportedData.Samples.gy;
    subjData.(['Sub' fileSubj]).eyelinkImportedData.Samples.time = eyelinkImportedData.Samples.time;
end

SAVE = 'E:\SceneProcessing';
cd(SAVE);
matfile = 'subjData';
save(matfile, 'subjData');


% also add image data and foldernames 
for subj = 1:30
    subj
    fileSubj = char(subjectNums(subj));  %file name for each subject 
    load(sprintf('E:\\SceneProcessing\\SubjData\\sceneProcessing_subj%s.mat',fileSubj)); %load the files one by one
    for trialNum = 1:100
        myImage = imageArray{trialNum}; %image info (pixel data, used to draw image)
        fileName = fileArray{trialNum}; %image name
        folderName = folderArray{trialNum}; %folder name

        subjData.(['Sub' fileSubj]).images{trialNum} = myImage;
        subjData.(['Sub' fileSubj]).folders{trialNum} = folderName;
    end
end. 

% make a small vs large version
for subj = 1:30
    fileSubj = char(subjectNums(subj)); 
    
    subjData.(['Sub' fileSubj]) = rmfield(subjData.(['Sub' fileSubj]),'eyelinkImportedData');
    subjData.(['Sub' fileSubj]) = rmfield(subjData.(['Sub' fileSubj]),'images');
    subjData.(['Sub' fileSubj]) = rmfield(subjData.(['Sub' fileSubj]),'folders');
end