%LSA images 
%Count all the objects in an image
%Refine objects to remove junk or unuseable objects
%Create a structure that contains all the refined objects (new library) 

HOMEIMAGES = 'C:\toolbox\SceneProcessing\images'; % you can set here your default folder
HOMEANNOTATIONS = 'C:\toolbox\SceneProcessing\annotations'; % you can set here your default folder

cd(HOMEANNOTATIONS);

D = dir; 
D = D(~ismember({D.name}, {'.', '..'})); %first elements are '.' and '..' used for navigation - remove these

folderNames = {D([D.isdir]).name};%get all the folder names
folderNames(strcmp(folderNames,'.') | strcmp(folderNames,'..')) = [];%remove "." and ".." from folder names

%% Fix file names so they can go into the structure 
for fNum = 1:length(folderNames)% loop over folders
    fileNames = dir(folderNames{fNum});%extract file names within folder
    fileNames = {fileNames(~[fileNames.isdir]).name}; %don't include folders, take only files
    [~,fileNames] = cellfun(@fileparts,fileNames,'un',0);%remove file type from name (you can't use ".jpg" in field names because it has a period
    for K = 1:length(fileNames)% loop over files 
        if contains(fileNames{K},'-') | contains(fileNames{K},'.') == 1 %if the file has '-' or '.' replace with _ because fieldnames cant have "-"
            oldNames = fileNames{K}
            if contains(fileNames{K},'-')
                newNames = strrep(fileNames{K},'-','_')
            else
                newNames = strrep(fileNames{K},'.','_')
            end
            
            cd(HOMEANNOTATIONS); %for each type
            oldAnnotFile = sprintf('D:\\MATLAB\\R2019a\\LabelMeToolbox-master\\annotations\\%s\\%s.xml',folderNames{fNum},oldNames); 
            newAnnotFile = sprintf('D:\\MATLAB\\R2019a\\LabelMeToolbox-master\\annotations\\%s\\%s.xml',folderNames{fNum},newNames); 
            movefile(oldAnnotFile, newAnnotFile);
            
            cd(HOMEIMAGES); %for each type
            oldImageFile = sprintf('D:\\MATLAB\\R2019a\\LabelMeToolbox-master\\images\\%s\\%s.jpg',folderNames{fNum},oldNames) 
            newImageFile = sprintf('D:\\MATLAB\\R2019a\\LabelMeToolbox-master\\images\\%s\\%s.jpg',folderNames{fNum},newNames)
            movefile(oldImageFile, newImageFile)
        end
    end
end

 %% Make the structure    
for fNum = 1:length(folderNames)% loop over folders
    fNum
    currD = D(fNum).name % Get the current subdirectory name
    files = dir(currD); %find all the files in the folder
    files = files(~ismember({files.name}, {'.', '..'})); %remove the "." and ".." that matlab puts at the top
    fileNames = dir(folderNames{fNum});%extract file names within folder
    fileNames = {fileNames(~[fileNames.isdir]).name}; %don't include folders, take only files
    [~,fileNames] = cellfun(@fileparts,fileNames,'un',0);%remove file type from name (you can't use ".jpg" in field names because it has a period        
    for fileNum = 1:length(fileNames)% loop over files
        fullfileName = fullfile(HOMEANNOTATIONS, currD, files(fileNum).name); % pick a file
        [annotation] = LMread(fullfileName); % grab annotation and image for this example
        nObjArray = {[]}; %clear obj array before each iteration 
         for n=1:length(annotation.object)    
             word = annotation.object(n).name; %get the name of each object
             if isempty(word) == 1
                 break
             else
             suggestion = checkSpelling(word); %check to see if its actually a word
             word = suggestion; %keep or delete it
             nObjArray(n) = {word} %fill in an array with the objects
             end
             %count how many objects
             nObjs = zeros(length(nObjArray),1);
             for n=1:length(nObjs)
                nObjs(n) = ~isempty(nObjArray{n});
             end
             nObjects = sum(nObjs)
         end
        %assign values to whatever fields you want, appended "Folder_" and "File" in front of fieldnames because they can't start with numbers :(
        myStruct.(['F_' folderNames{fNum}]).(['File_' fileNames{fileNum}]).objects = nObjArray
        myStruct.(['F_' folderNames{fNum}]).(['File_' fileNames{fileNum}]).nObjs = nObjects
    end
end


%             %Roundabout way of determining if any pics satisfy both
%             %conditions in a folder
%             logicArray1 = objArray>=7 %if any pics >=7
%             logicArray2 = objArray<=13 %if any pics <=13
%             withinRange = logicArray1+logicArray2 %add them, the ones that satisfy both will equal 2
%             withinRange = withinRange - 1 %subtract 1 so those that don't satisfy = 0 and those that do = 1
               
%             if any(withinRange) %if atleast one picture in the folder has between 7 and 13 objects 
%                useFolders(k,:) = {currD} %save that folder name      
%             end
%         end
%     end
% end
% 
% folder_list = zeros(length(useFolders),1);
% for n=1:length(useFolders)
%    folder_list(n) = ~isempty(useFolders{n});
% end
% folder_list;
% totalUseableFolders = sum(folder_list);

%% Get one picture from each folder (pic must have between 7-13 objects)

for n=1:length(useFolders)
    if folder_list(n) == 0 %unuseable folder
        continue
    end
    if folder_list(n) == 1 %useable folder
        currD = D(n).name; % Get the current subdirectory name
        files = dir(currD); %find all the files in the folder
        files = files(~ismember({files.name}, {'.', '..'})); %remove the "." and ".." that matlab puts at the top
        f = numel(files); %number of files
        objArray=zeros(1, f); % create an empty array to store number of objects
        for f = 1:numel(files) %go through the files one by one
            fileName = fullfile(HOMEANNOTATIONS, currD, files(f).name); % pick a file
            [annotation] = LMread(fileName); % grab annotation and image for this example
            if isfield(annotation, 'object') == 0 % if there's no objects, run this to avoid error
                nObjects = 0 %no objects
                objArray(f) = nObjects; %fill into array
                medianObj = median(objArray); %find the median of that array
                medianArray1(k) = medianObj; %put the median into the larger array
            else
                nObjects=length(annotation.object); %count objects
                objArray(f) = nObjects; %fill into array
            end
        end
        while 1    
            randFilePos = Ranint(f) %pick a random file position 
            objCheck = objArray(randFilePos) %get the number of objects for that file 
            if (objCheck>=7) && (objCheck<=13) == 1 %repeat loop until a file has between 7 ans 13 objects 
                break
            end
        end
        folder = files(randFilePos).folder;
        name = files(randFilePos).name;
        useAnnotFile = sprintf('%s\\%s', folder,name);
        useImageFile = sprintf('D:\\MATLAB\\R2019a\\LabelMeToolbox-master\\images\\%s\\%s',currD,name);
        useFiles(n,:) = {useAnnotFile,useImageFile};
        for k = 1:length(useFiles) %forgot to erase .xml, replace with .jpeg
            useImageFile = useFiles{k,2};
            useFiles{k,2} = strrep(useImageFile, '.xml','.jpeg');
        end
    end
end
 %% Check that the range is correct (count objs in pics we choose)
check_objArray = zeros(1,length(useFiles));
for k = 1:length(useFiles)
    fileName = useFiles{k,1};
    if isempty(fileName) == 1
        check_objArray(k) = 0; %0s in this array are files we skipped 
    else
    [annotation] = LMread(fileName);
    nObjects=length(annotation.object);
    check_objArray(k) = nObjects;  %0s in this array are files we skipped 
    end
end

check = zeros(length(check_objArray),1);
for n=1:length(check_objArray)
   check(n) = any(check_objArray(n));
end
check;
totalCheck = sum(check); %cool 

%% make an array of all the objects

for k=1:length(useFiles)
    fileName=useFiles{k,1};
    if isempty(fileName) == 1
       nObjArray(1,k) = {fileName}; %top row will be names
    else
    [annotation] = LMread(fileName);
    struct = annotation.object;
    nObjArray(1,k) = {fileName}; %top row will be names
    for n=1:length(annotation.object)
        nObjArray(n+1,k) = {struct(n).name}; %second row will start the object list 
%         word = cell2mat(nObjArray(n+1,k))
%         suggestion = checkSpelling(word)
%         word = suggestion 
    end
    end
end
nObjArray;

%% find frequency of each type of object across the pictures  

xx = nObjArray;
c = categorical(nObjArray(:,1));
categories(c)
countcats(c)


