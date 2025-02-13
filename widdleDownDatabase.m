%% widdle down database  
%uses myStruct from all_Structures AKA the spellcheck structure 
load('all_Structures.mat')
HOMEANNOTATIONS = 'E:\SceneProcessing\LabelMe\annotations'
HOMEIMAGES =  'E:\SceneProcessing\LabelMe\images'
allFolders = fieldnames(myStruct) %get all folders

%% organize
for n = 1:length(fieldnames(myStruct))
    structFolder = cell2mat(allFolders(n)) %get foldername as it appears in the structure
    folder = erase(cell2mat(allFolders(n)),'F_') %get foldername as it appears in the files
    allFiles = fieldnames(myStruct.(structFolder)) %get all files 
    for f = 1:numel(allFiles) %go through the files one by one
        structFile = cell2mat(allFiles(f)); % filename as it appears in the structure
        file = erase(cell2mat(allFiles(f)),'File_') %filename as it appears in the files
        fullfileName = sprintf('%s\\%s\\%s.xml',HOMEANNOTATIONS, folder, file); % pick a file
        [annotation] = LMread(fullfileName); % grab annotation and image for this example  
        
        %Make the edited obj list nice and pretty 
        
        %Add object lists and polygons // percent of image labeled 
        fullObjsList = myStruct.(structFolder).(structFile).objects;
        newObjsList = fullObjsList;
        if ~isfield(annotation, 'object')
            newPolygons = {}; %if no objects exist in the annotation
        elseif ~isfield(annotation.object,'polygon')
            newPolygons = {}; %if no polygons exist in the annotation
        else
            allPolygons = {annotation.object.polygon};
            usedPolygons = allPolygons(1:length(fullObjsList));
            newPolygons = usedPolygons;
        end
        for objList = length(fullObjsList):-1:1
            if isempty(fullObjsList{objList})
               if objList > length(newObjsList)
                   continue
               else
                   newObjsList(objList) = [];
                   if isempty(newPolygons)
                       continue
                   else
                      newPolygons(objList) = [];
                   end
               end
            end
        end
        newObjsList = newObjsList';
        
        myStruct2.(structFolder).(structFile).objects.name = newObjsList;
        myStruct2.(structFolder).(structFile).objects.polygon = newPolygons';
        
        if isfield(annotation, 'object') & ~isempty(newPolygons)
            percentArea = labeled_areaMerged(annotation,myStruct2,structFolder,structFile) %calculate percent area of image is labeled    
        else %if there is no object field in the annotation, then no objects exist/nothing is labeled 
            percentArea = 0
        end
        
        myStruct2.(structFolder).(structFile).percentLabeled = percentArea; 
        
    end 
end
countStruct(myStruct2)

%% Remove images that are less than 75% labeled 
allFolders = fieldnames(myStruct2) %get all folders
for n = 1:length(fieldnames(myStruct2))
    structFolder = cell2mat(allFolders(n)); %get foldername as it appears in the structure
    allFiles = fieldnames(myStruct2.(structFolder)); %get all files 
    for f = 1:numel(allFiles) %go through the files one by one
        structFile = cell2mat(allFiles(f)); % filename as it appears in the structure
        if myStruct2.([structFolder]).([structFile]).percentLabeled >= .75 %if image is atleast 75% labled
           myStruct3.([structFolder]).([structFile]) = myStruct2.([structFolder]).([structFile]) %add it to the new structure
        end
    end
end

countStruct(myStruct3)

%% Take images with at least 15 unique objects 
allFolders = fieldnames(myStruct3); %get all folders
for n = 1:length(fieldnames(myStruct3))
    structFolder = cell2mat(allFolders(n)); %get foldername as it appears in the structure
    allFiles = fieldnames(myStruct3.(structFolder)); %get all files 
    for f = 1:numel(allFiles) %go through the files one by one
        structFile = cell2mat(allFiles(f)); % filename as it appears in the structure
        objList = myStruct3.([structFolder]).([structFile]).objects.name;
        if length(unique(objList)) >= 15 %count all unique objects 
            myStruct4.([structFolder]).([structFile]) = myStruct3.([structFolder]).([structFile]) %add to new structure
        end
    end
end

countStruct(myStruct4)       

%% If an image is smaller than 1000x1000 remove it
allFolders = fieldnames(myStruct4); %get all folders
for n = 1:length(fieldnames(myStruct4))
    structFolder = cell2mat(allFolders(n)); %get foldername as it appears in the structure
    folder = erase(cell2mat(allFolders(n)),'F_'); %get foldername as it appears in the files
    allFiles = fieldnames(myStruct4.(structFolder)); %get all files 
    for f = 1:numel(allFiles) %go through the files one by one
        structFile = cell2mat(allFiles(f)); % filename as it appears in the structurefor n = length(D4):-1:1
        file = [erase(cell2mat(allFiles(f)),'File_'),'.jpg']; %filename as it appears in the files
        if contains(file,'-') | contains(file,'.') %restructure the names so they match how they appear in the structure
            file = strrep(file,'-','_');
            file = strrep(file,'.','_');
            file = strrep(file,'_jpg','.jpg');
        end
        cd([HOMEIMAGES,'\',folder]);
        info = imfinfo(file); %get image info
        width = info.Width; %get width
        height = info.Height; %get height
        if width >= 1000 && height >= 1000 %if both width and height are over 1000, add to the new struct
           myStruct5.([structFolder]).([structFile]) = myStruct4.([structFolder]).([structFile]) %add to new structure
        end
    end
end

countStruct(myStruct5) 

%% remove portait images
allFolders = fieldnames(myStruct5); %get all folders
for n = 1:length(fieldnames(myStruct5))
    structFolder = cell2mat(allFolders(n)); %get foldername as it appears in the structure
    folder = erase(cell2mat(allFolders(n)),'F_'); %get foldername as it appears in the files
    allFiles = fieldnames(myStruct5.(structFolder)); %get all files 
    for f = 1:numel(allFiles) %go through the files one by one
        structFile = cell2mat(allFiles(f)); % filename as it appears in the structurefor n = length(D4):-1:1
        file = [erase(cell2mat(allFiles(f)),'File_'),'.jpg']; %filename as it appears in the files
        if contains(file,'-') | contains(file,'.') %restructure names
            file = strrep(file,'-','_');
            file = strrep(file,'.','_');
            file = strrep(file,'_jpg','.jpg');
        end
        fullfile = [HOMEIMAGES,'\',folder,'\',file];
        cd([HOMEIMAGES,'\',folder]);
        info = imfinfo(fullfile); %get info
        width = info.Width; %get width
        height = info.Height; %get height
        if width >= height %if width is greater or equal to height (aka not a portait image), add to struct
           myStruct6.([structFolder]).([structFile]) = myStruct5.([structFolder]).([structFile]) %add to new structure
        end
    end
end

countStruct(myStruct6)   

% %% check common objs
% objcount = struct; %this structure is used to store object names and counts 
% fn = fieldnames(myStruct6);
% for i=1:numel(fn) %loop through all the folders
%     currfolder = myStruct6.(fn{i});
%     currfn = fieldnames(currfolder);
%     for j=1:numel(currfn) %loop through all the images
%         img = currfolder.(currfn{j}); 
%         if isfield(img,'objects')
%             for k=1:length(img.objects.name)
%                 objname = img.objects.name{k};
%                 objname(isletter(objname)==0)=[]; 
%                 %delete any nonalphabetic part of the object name, so that
%                 %it can be used as a fieldname     
%                 if ~ isempty(objname)
%                    if isfield(objcount,objname)%if the object name is already in the structure,add 1 to its value
%                       objcount.(objname) = objcount.(objname)+1;
%                    else %if it is a new one, add it as a new field
%                       objcount.(objname) = 1;
%                     end
%                 end 
%             end
%         end
%     end  
% end
% 
% objname = fieldnames(objcount);
% 
% freq_obj="";
% 
% for i = 1:length(objname)
%     if objcount.(objname{i})>50 && objcount.(objname{i})<350 
%         %find the objects that occur 200-350 times in the structure
%         %the range needs to be discussed
%        
%         freq_obj=freq_obj+" "+objname{i};
%     end       
% end
%        
% freqlst = split(freq_obj," "); 

%% if 25% of the unique objects are just parts of larger objects

xParts = {'headlight', 'taillight', 'windsheild', 'wind sheild' 'carwheel', 'car wheel' 'wheel', 'cardoor', 'car door', 'door', 'doorhandle', 'door handle', 'tail light', 'head light', 'wheel rim', 'window', 'window occluded', 'door occluded', 'head', 'arm', 'leg', 'torso', 'foot', 'hand'} 

allFolders = fieldnames(myStruct6); %get all folders
for n = 1:length(fieldnames(myStruct6))
    structFolder = cell2mat(allFolders(n)); %get foldername as it appears in the structure
    allFiles = fieldnames(myStruct6.(structFolder)); %get all files 
    for f = 1:numel(allFiles) %go through the files one by one
        structFile = cell2mat(allFiles(f)); % filename as it appears in the structurefor n = length(D4):-1:1
        
        objList = unique(myStruct6.(structFolder).(structFile).objects.name);
        totalMatches = zeros(length(objList),1); %create an empty array of potential matches 
        for match = 1:length(xParts)
            matchList = strcmp(xParts(match),objList);
            totalMatches = matchList + totalMatches;
        end
        
        percent = sum(totalMatches) / length(totalMatches)

        if percent < .25
            myStruct7.([structFolder]).([structFile]) = myStruct6.([structFolder]).([structFile]) %add to new structure
        end
    end
end

countStruct(myStruct7)  

%% if 50% of the area of the photo is made up of one large object (use original annotations for this bc we removed words like "carFrontal" from spellcheck

allFolders = fieldnames(myStruct7); %get all folders
for n = 1:length(fieldnames(myStruct7))
    structFolder = cell2mat(allFolders(n)); %get foldername as it appears in the structure
    allFiles = fieldnames(myStruct7.(structFolder)); %get all files 
    for f = 1:numel(allFiles) %go through the files one by one
        structFile = cell2mat(allFiles(f)); % filename as it appears in the structurefor n = length(D4):-1:1
        folder = erase(structFolder,'F_');
        file = erase(structFile,'File_');
        fullAnnofilename = sprintf('E:\\SceneProcessing\\LabelMe\\annotations\\%s\\%s.xml', folder, file);
        [annotation] = LMread(fullAnnofilename);
        allPolys = length(annotation.object);
        
        for pLength = 1:allPolys
            if ~isempty(annotation.object(pLength).polygon)%check for polygons first
                xList = cellfun(@str2double, {annotation.object(pLength).polygon.pt.x})';
                yList = cellfun(@str2double, {annotation.object(pLength).polygon.pt.y})';
                poly = polyshape(xList,yList); %make the polygon
                objArea = area(poly); %grab the area of the polygon

                fullImgfilename = sprintf('E:\\SceneProcessing\\LabelMe\\images\\%s\\%s.jpg', folder, file);
                cd(HOMEIMAGES);
                img = imread(fullImgfilename);
                [height, width, dim] = size(img);
                totalArea = height * width;
                objPercent = objArea / totalArea
                if objPercent > .50
                    break
                else
                    myStruct8.([structFolder]).([structFile]) = myStruct7.([structFolder]).([structFile]) %add to new structure
                end
            end
        end
    end
end

countStruct(myStruct8)  

%% Remove objs from the count that we wouldn't search (aka the lists from above, parts / broad categories), remove photos that now have less than 15 unique objs 

xParts = {'headlight', 'taillight', 'windsheild', 'wind sheild' 'carwheel', 'car wheel' 'wheel', 'cardoor', 'car door', 'doorhandle', 'door handle', 'tail light', 'head light', 'wheel rim', 'head', 'arm', 'leg', 'torso', 'foot', 'hand','road', 'building', 'grass', 'snow', 'sidewalk'} 

allFolders = fieldnames(myStruct8); %get all folders
for n = 1:length(fieldnames(myStruct8))
    structFolder = cell2mat(allFolders(n)); %get foldername as it appears in the structure
    allFiles = fieldnames(myStruct8.(structFolder)); %get all files 
    for f = 1:numel(allFiles) %go through the files one by one
        structFile = cell2mat(allFiles(f)); % filename as it appears in the structurefor n = length(D4):-1:1
        
        objList = unique(myStruct8.(structFolder).(structFile).objects.name);
        totalMatches = zeros(length(objList),1); %create an empty array of potential matches 
        for match = 1:length(xParts)
            matchList = strcmp(xParts(match),objList);
            totalMatches = matchList + totalMatches
        end
        if length(totalMatches) - sum(totalMatches) >= 15
            myStruct9.([structFolder]).([structFile]) = myStruct8.([structFolder]).([structFile]) %add to new structure
        end
    end
end
            
countStruct(myStruct9)  
  
%% check grayscale
allFolders = fieldnames(myStruct5); %get all folders
for n = 1:length(fieldnames(myStruct5))
    structFolder = cell2mat(allFolders(n)); %get foldername as it appears in the structure
    folder = erase(cell2mat(allFolders(n)),'F_'); %get foldername as it appears in the files
    allFiles = fieldnames(myStruct5.(structFolder)); %get all files 
    for f = 1:numel(allFiles) %go through the files one by one
        file = [erase(cell2mat(allFiles(f)),'File_'),'.jpg'] %filename as it appears in the files
        annotFile = [erase(file, '.jpg'),'.xml'];
        fullAnnFile = ['E:\SceneProcessing\LabelMe\annotations','\',folder,'\',annotFile]; % pick a sample image
        [annotation, myImage] = LMread(fullAnnFile, ['E:\SceneProcessing\LabelMe\images','\',folder]); % grab annotation and image for this example
        %remove black and white images
        colortest = length(size(myImage));
        if colortest ~= 3 %if not color image, print x=1 (just double checking because pretty sure there are none at this point)
           x=n
           y=f
        end
    end
end