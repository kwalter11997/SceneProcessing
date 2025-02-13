sceneDes = readtable('SceneDescriptions.xls'); 

cd('E:\SceneProcessing\FinalLibrary\images\all')
D = dir; 
D = D(~ismember({D.name}, {'.', '..'})); %first elements are '.' and '..' used for navigation - remove these
fileNames = {D.name}; %get all the file names
 
load('E:\SceneProcessing\SubjData\sceneprocessing_subj01') %load in any subject so we can grab the size array matrix (size of iamges as they appeared in the exp)

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
GBVSLibrary = {};
LSALibrary = {};

for f = 1:100
    f
    fileNameFull = fileNames{f};
    fileNameShort = erase(fileNameFull,'.jpg');
    myImage = imread(fileNameFull);
    sizeIdx = find(strcmp(fileSizes(1,:),fileNameShort)); %find which cell in our filesizes matrix contains the info about this image
    
    %% gbvs
           
    out_gbvs = gbvs(myImage); 
    gbvsFilt = imresize(out_gbvs.master_map_resized, [sizeArray(2,sizeIdx),sizeArray(1,sizeIdx)]); %resize so it's how it appeared in the experiment    
    gbvsFilt = imgaussfilt(gbvsFilt,pxError); %add a gaussian of the eyetracker error       
    gbvsFilt = (gbvsFilt - min(gbvsFilt(:))) / (max(gbvsFilt(:)) - min(gbvsFilt(:))); %normalize

    %show all 3 maps individually
    figure()
    subplot(2,2,1)
    imagesc(out_gbvs.top_level_feat_maps{1, 1})
    title('Color')
    colorbar
    subplot(2,2,2)
    imagesc(out_gbvs.top_level_feat_maps{1, 2})
    title('Intensity')
    colorbar
    subplot(2,2,3)
    imagesc(out_gbvs.top_level_feat_maps{1, 3})
    title('Orientation')
    colorbar
    subplot(2,2,4)
    imagesc(out_gbvs.master_map)
    title('Average Salience Map')
    colorbar
         
    figure()
    imagesc(gbvsFilt)
     
    %% LSA

    queryList = sceneDes.(fileNameShort);
    [semanticIm] = LSA(fileNameShort, myImage, queryList); %get the LSA (semantic relevance) map
    lsaFilt = imresize(semanticIm,[sizeArray(2,sizeIdx),sizeArray(1,sizeIdx)]);  %resize filter to fit our smaller experiment picture
    lsaFilt = imgaussfilt(lsaFilt,pxError); %add a gaussian of the eyetracker error
    lsaFilt = (lsaFilt - min(lsaFilt(:))) / (max(lsaFilt(:)) - min(lsaFilt(:))); %normalize
   
%     figure()
%     imagesc(lsaFilt)
    
    GBVSLibrary(1,f) = {fileNameShort}; 
    GBVSLibrary(2,f) = {gbvsFilt}; 
    LSALibrary(1,f) = {fileNameShort};
    LSALibrary(2,f) = {lsaFilt};
    
end

SAVE = 'E:\SceneProcessing\Meaning_Salience_Maps';
cd(SAVE)
savefile = 'GBVS_LSA_Heatmaps_CenterBias';
save(savefile,'GBVSLibrary','LSALibrary')
