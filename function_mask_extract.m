function [isoObj, nObjArray, nObjects, dimensions, objArray] = function_mask_extract(folder,fileShort,HOMEANNOTATIONS,HOMEIMAGES)

%% pull an object's mask from an image 
cd(HOMEANNOTATIONS);
fullAnnFile = strcat(HOMEANNOTATIONS,'\',folder,'\',fileShort,'.xml'); % pick a sample image
[annotation, myImage] = LMread(fullAnnFile, HOMEIMAGES); % grab annotation and image for this example
nObjects = length(annotation.object);

for objNum=1:length(annotation.object)
    myMask = []; %clear mask variable each iteration 
    if isempty(annotation.object(objNum).polygon) == 1
        continue
    else
    xLoc=str2num(char(annotation.object(objNum).polygon.pt.x)); % extract vertices of labeled object
    yLoc=str2num(char(annotation.object(objNum).polygon.pt.y));
   %drawpolygon('Position',[xLoc'; yLoc']'); % draw object outline on figure alternative:     plot([xLoc; xLoc(1)],[yLoc; yLoc(1)], 'LineWidth', LineWidth, 'color', [0 0 0]); 
    myMask(:,:,1) = roipoly(myImage,xLoc,yLoc); % find logical polygon for this object
    myMask(:,:,2) = roipoly(myImage,xLoc,yLoc); %run again to remove next RGB color
    myMask(:,:,3) = roipoly(myImage,xLoc,yLoc); %run again to remove next RGB color
    %imshow(myMask); %see where the mask is if you want

    isoObj = myImage; %set the image name to be isolated object
    isoObj(~myMask) = 125; %clear everything outside of the mask and make background gray
    %imshow(isoObj); %show the isolated object if you want
    isoObj = imcrop(isoObj, [min(xLoc),min(yLoc),max(xLoc)-min(xLoc),max(yLoc)-min(yLoc)]); %[xmin ymin width height] crop the picture so it's just the object 

    width = max(xLoc) - min(xLoc); %dimensions of object
    height = max(yLoc) - min(yLoc);
    maxDim = max([width;height]); %largest dimension
    scaleratio = 300 / maxDim; %scale based off largest dimension

    isoObj = imresize(isoObj, scaleratio); %make the images approx the same size
%     figure(); %if you want to see the objects for testing
%     imshow(isoObj);

    [rows, columns, numberOfColorBands] = size(isoObj); % dimensions of cropped image
    objName = {annotation.object(objNum).name}; % name of this object
    nObjArray(objNum) = objName; %fill in an array with the objects
    dimensions(1,objNum) = rows; %save row dimension
    dimensions(2,objNum) = columns; %save column dimension
    objArray(objNum) = {isoObj}; %save obj info
    end
end