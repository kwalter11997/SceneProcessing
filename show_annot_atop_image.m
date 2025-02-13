%% Library Check (show annotation on top of image)

FINALIMAGES = 'E:\SceneProcessing\FinalLibrary\images\all';
FINALANNOTATIONS = 'E:\SceneProcessing\FinalLibrary\annotations_keywordsRemoved';
cd(FINALANNOTATIONS)

D = dir; 
D = D(~ismember({D.name}, {'.', '..'})); %first elements are '.' and '..' used for navigation - remove these
fileNames = {D.name}; %get all the file names

for n = 1:length(fileNames)
    file = char(fileNames(n));
    annotation = LMread(file); 
    figure();
    imshow(erase([FINALIMAGES,'\',file,'.jpg'],'.xml'))
    LMplot(annotation);
    [h,class] = LMplot(annotation)
    title(file);
end

figure()
LMobjectmask(annotation,'E:\SceneProcessing\LabelMe\images','minar');
LMplot(annotation);
