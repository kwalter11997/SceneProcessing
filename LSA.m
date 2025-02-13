function [semanticIm] = LSA(fileName, myImage, queryList)

FINALIMAGES = 'E:\2D_Image_CVI\Images_jpg';
FINALANNOTATIONS = 'E:\2D_Image_CVI\annotations';
cd(FINALANNOTATIONS);
[annotation]=LMread([fileName,'.xml'],FINALANNOTATIONS);

imSize=size(myImage);
nObjects=length(annotation.object);

%nObjects = struct.(['F_' folderName]).(['File_' fileName]).nObjs; 
myMask=false([imSize(1)  imSize(2) nObjects]); % set up memory for areas of all objects
objSize=zeros(1, nObjects); % list of object sizes

% objName={};
% figure();
% imshow(myImage);
% LineWidth=2;
% hold on
for objNum=1:nObjects
    xLoc=str2num(char(annotation.object(objNum).polygon.pt.x)); % extract vertices of labeled object
    yLoc=str2num(char(annotation.object(objNum).polygon.pt.y));
%     xLoc=str2num(char(struct.(['F_' folderName]).(['File_' fileName]).polygons{objNum,1}.pt.x)); % extract vertices of labeled object
%     yLoc=str2num(char(struct.(['F_' folderName]).(['File_' fileName]).polygons{objNum,1}.pt.y));
%     drawpolygon('Position',[xLoc'; yLoc']'); % draw object outline on figure alternative:     plot([xLoc; xLoc(1)],[yLoc; yLoc(1)], 'LineWidth', LineWidth, 'color', [0 0 0]); 
    myMask(:,:,objNum) = roipoly(myImage,xLoc,yLoc); % find logical polygon for this object
    objSize(objNum)=sum(sum(myMask(:,:,objNum))); % size of this object
    %objName(objNum)=struct.(['F_' folderName]).(['File_' fileName]).objects(objNum);
    objName(objNum) = {annotation.object(objNum).name};
end
hold off

%% Conduct Semantic Salinence analysis for this image's objects
% http://lsa.colorado.edu/
url = 'http://lsa.colorado.edu/cgi-bin/LSA-one2many-x.html';
options = weboptions('RequestMethod', 'post', 'ArrayFormat','json');
% options = weboptions('RequestMethod', 'post', 'ArrayFormat','csv');
quetyList=strjoin(objName,'\r\n\r\n');

nQueries=length(queryList);
objectSemanticSim=zeros(nQueries,nObjects);

for queryNum=1:nQueries
    %lsaData = webwrite(url,'LSAspace','General_Reading_up_to_1st_year_college','txt1',queryList{queryNum},'txt2',quetyList, options); %default document to document comparison
    lsaData = webwrite(url,'LSAspace','General_Reading_up_to_1st_year_college','CmpType','term2term','txt1',queryList{queryNum},'txt2',quetyList,options); %term to term comparison
    
    [startIndex, endIndex]= regexp(lsaData,'<TR> <TD ALIGN=CENTER>');% each line in table
    endtableIndex=regexp(lsaData,'</TABLE>'); % end of table
    for objNum=1:nObjects % read in each line from table
        if objNum<nObjects
            nextLine=lsaData(startIndex(objNum+1):startIndex(objNum+2)); % extract each line starting from 2nd line
        else
            nextLine=lsaData(startIndex(objNum+1):endtableIndex); % last object use end of table
        end
        [lineStartIndex, lineEndIndex]=regexp(nextLine,'<TD ALIGN=CENTER>'); % find both table markers in this line
        objectSemanticSim(queryNum,objNum)=str2double(nextLine(lineEndIndex(2)+2:end-2)); % sematnic salience is last few characters in this line
    end
end

if sum(isnan(objectSemanticSim(:))) >= 1 %if there are any nans in this analysis
   lsaData %readout the LSA table to check
end

% figure()
for queryNum=1:nQueries
    %indivSemanticIm=nanmean(objectSemanticSim(queryNum,:))*ones(imSize(1),imSize(2)); % mean value similarity image for object similarities
    indivSemanticIm=zeros(imSize(1),imSize(2)); %create an empty matrix to fill
    
    [~,sizeOrder] = sort(objSize, 'descend'); % start with largest object
    for objNum=1:nObjects % work through objects in size order to minimize occlusions
        currentObject=sizeOrder(objNum); % next largest object
        indivSemanticIm(myMask(:,:,currentObject)==1)=objectSemanticSim(queryNum,currentObject); % assign pixels to this similarity
    end

    semanticImList(queryNum) = {indivSemanticIm};
    
%     subplot(2,3,queryNum); % plot each image in sub plot
%     imagesc(indivSemanticIm); % show each image
%     colorbar; % show the scale
%     queryList{queryNum} = replace(queryList{queryNum},'_','\_');
%     title(queryList{queryNum}); % show the similarity item
end

combList = cat(3,semanticImList{:}); %cat makes the cells (which are 2d matricies) into a cube structure, effectively stacking them, then divide across the 3rd dimension (averaging the "stacks")
% semanticIm = nanmean(combList,3); %average maps
semanticIm = combList; %keep maps seperate
%change nans to 0s to avoid errors down the line (nan is essentially 0)
semanticIm(isnan(semanticIm)) = 0;

% subplot(2,3,6)
% imagesc(semanticIm)
% colorbar; % show the scale
% title('Average Semantic Relevance'); % show the similarity item

cd(FINALIMAGES)