%% frequency of choosen objects

subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used

for subj = 1:30
    subj
    fileSubj = char(subjectNums(subj));  %file name for each subject 
    load(sprintf('E:\\SceneProcessing\\SubjData\\sceneProcessing_subj%s.mat',fileSubj)); %load the files one by one
    for trialNum = 1:100
        objects{trialNum} = trialObjects{1, trialNum}.object; %grab the object 
    end
    objectMat(subj,:) = objects
end

filename = 'objectsChoosen'
save(filename, 'objectMat')

objectCat = categorical(objectMat)
summary(objectCat(:))

figure()
histogram(objectCat(:))

%% frequency of all objects in the database

cd('E:\SceneProcessing\FinalLibrary\annotations_keywordsRemoved')
D = dir; 
D = D(~ismember({D.name}, {'.', '..'})); %first elements are '.' and '..' used for navigation - remove these
fileNames = {D.name}; %get all the file names
objectMat = {}; %create empty cell matrix

for f = 1:100
    filename = char(fileNames(f)); %filename
    v = loadXML(filename); %load the annotation file as the variable v
    objects = {v.annotation.object.name};
    objectMat = [objectMat,objects];
end

filename = 'allObjs_keywordsRemoved'
save(filename, 'objectMat')

objectCat = categorical(objectMat)
summary(objectCat(:))

figure()
histogram(objectCat(:))
