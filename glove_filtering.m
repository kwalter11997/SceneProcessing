% cd('E:\TaskTest')
sceneDes = readtable('task_mainWords.csv'); 
sceneDes = readtable('task_list.xlsx'); 
% cd('E:\SceneProcessing\Meaning_Salience_Maps');
% sceneDes = readtable('SceneDescriptions.xls'); 

%load in the glove set
cd('E:\GloVe-master\GloVe')
glovefile = "glove.840B.300d";
if exist(glovefile + '.mat', 'file') ~= 2
    emb = readWordEmbedding(glovefile + '.txt');
    save(glovefile + '.mat', 'emb', '-v7.3');
else
    load(glovefile + '.mat')
end

cd('E:\TaskTest\FinalLibraryPyPics')
% cd('E:\SceneProcessing\FinalLibrary\images\all')
D = dir; 
D = D(~ismember({D.name}, {'.', '..'})); %first elements are '.' and '..' used for navigation - remove these
fileNames = {D.name}; %get all the file names
 
load('E:\TaskTest\subjData\taskTest_subj1') %load in any subject so we can grab the size array matrix (size of iamges as they appeared in the exp)
% load('E:\TargetPresentAbsent\subjData\targetPresentAbsent_subj1') %load in any subject so we can grab the size array matrix (size of iamges as they appeared in the exp)

fileSizes = [fileArray;num2cell(sizeArray)]; %make a matrix of filesizes how they appeared in the experiment (with filenames)

%screen info
scrnWidthPx = 1920; %screen width pixels
scrnWidthCm = 60; %screen width cm
viewDistCm = 63; %viewing distance of participants
%get visual angle info for error that should be applied via gaussian
scrnWidthDeg=2*atand((0.5*scrnWidthCm)/viewDistCm); %calculate screen width in degrees
pxperdeg = scrnWidthPx/scrnWidthDeg; %get number of pixels per degree
pxError = .375*pxperdeg; %multiply pixel per degree by average degree error (.375 taken from estimate of 0.25-0.50 from Eyelink Manual) to get the number of pixels in the estimated manufacturer error

%create some empty variables to save the maps in later
GloVeLibrary = {};

for f = 1:100
    f
    fileNameFull = fileNames{f};
    fileNameShort = erase(fileNameFull,'.jpg');
    myImage = imread(fileNameFull);
    sizeIdx = find(strcmp(fileSizes(1,:),fileNameShort)); %find which cell in our filesizes matrix contains the info about this image
     
    %% GloVe

    queryList = sceneDes.(fileNameShort);
    [semanticIm] = GloVe(fileNameShort, myImage, queryList, emb); %get the GloVe (semantic relevance) map
    GloVeFilt = imresize(semanticIm,[sizeArray(2,sizeIdx),sizeArray(1,sizeIdx)]);  %resize filter to fit our smaller experiment picture
    GloVeFilt = imgaussfilt(GloVeFilt,pxError); %add a gaussian of the eyetracker error
    GloVeFilt = (GloVeFilt - min(GloVeFilt(:))) / (max(GloVeFilt(:)) - min(GloVeFilt(:))); %normalize
   
    figure()
    subplot(1,2,1)
    imagesc(GloVeFilt(:,:,1))
    title(queryList(1))
    subplot(1,2,2)
    imagesc(GloVeFilt(:,:,2))
    title(queryList(2))
    
    GloVeLibrary(1,f) = {fileNameShort}; 
    GloVeLibrary(2,f) = {GloVeFilt}; 
    
end

SAVE = 'E:\TaskTest';
cd(SAVE)
savefile = 'GloVe_Heatmaps_mainWords';
save(savefile,'GloVeLibrary')