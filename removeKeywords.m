%% Remove unecessary descriptors from .xml files

cd('E:\SceneProcessing\FinalLibrary\annotations_keywordsRemoved')
D = dir; 
D = D(~ismember({D.name}, {'.', '..'})); %first elements are '.' and '..' used for navigation - remove these
fileNames = {D.name}; %get all the file names

keywords = ["frontal", "occluded", "crop", "side", "front", "rear", "back", "region", "cut", "left", "right", "Frontal", "Occluded", "Crop", "Side", "Front", "Rear", "Back", "Region", "Cut", "Left", "Right"]; %list of words we want to remove 

for f = 1:length(fileNames)
    filename = char(fileNames(f)); %filename
    v = loadXML(filename); %load the annotation file as the variable v

    for i = 1:length(v.annotation.object)
           newstr = erase(v.annotation.object(i).name, keywords); %remove keywords
           newstr = strtrim(newstr); %removes trailing whitespace if any (not necessary for LSA but looks cleaner)
           v.annotation.object(i).name = newstr %replace the annotation word 
           %the new v.annotation file will still have deleted objects, when
           %calling [annotation] later we remove these objects 
    end
    writeXML(filename,v); %save the new file
end

%fix overcorrections
for f = 1:length(fileNames)
    filename = char(fileNames(f)); %filename
    v = loadXML(filename); %load the annotation file as the variable v
    for i = 1:length(v.annotation.object)
        if strcmpi(v.annotation.object(i).name,'bus s')
           v.annotation.object(i).name = 'bus stop'
%            filename
%            f
           break
        end
    end
%            newstr = regexprep(v.annotation.object(i).name, keywords, '', 'ignorecase') %remove keywords
%            newstr = strtrim(newstr) %removes trailing whitespace if any (not necessary for LSA but looks cleaner)
%            v.annotation.object(i).name = newstr %replace the annotation word 
    writeXML(filename,v); %save the new file
end
%% check that we didn't accidentally remove part of a real word
h = actxserver('word.application');
h.Document.Add;
for f = 1:length(fileNames)
    filename = char(fileNames(f));
    v = loadXML(filename);
    startObjs = length(v.annotation.object); %number of objects before spellcheck
    nObjArray = {[]}; %clear obj array before each iteration 
    for n=1:length(v.annotation.object)    
        word = v.annotation.object(n).name; %get the name of each object
        if isempty(word) == 1
            break
        else
        suggestion = checkSpelling(word,h); %check to see if its actually a word
        word = suggestion; %keep or delete it
        nObjArray(n) = {word}; %fill in an array with the objects
        end
     end
     %count how many objects
     nObjs = zeros(length(nObjArray),1); %reset
     for n=1:length(nObjs)
        nObjs(n) = ~isempty(nObjArray{n});
     end
     finalObjs = sum(nObjs);
     if startObjs ~= finalObjs %if we have a new incorrect spelling
         filename %readout the filename to check 
         break
     end
end

%% edit words that appear as NaNs in LSA
for trialNum=94:length(fileArray)
    trialNum
    myImage = imageArray{trialNum}; %image info (pixel data, used to draw image)
    fileName = fileArray{trialNum}; %image name

    %switch back to full sized image bc were using the structure in LSA
    %which relys on specific coordinates 
    myImage = imread([fileName,'.jpg']); %full sized image

    queryList = sceneDes.(fileName);

    [semanticIm] = LSA(fileName, myImage, queryList); %get the LSA (semantic relevance) map
end
        
keywords = ['DVD']; %list of words we want to remove 

for f = 1:length(fileNames)
    filename = char(fileNames(f)); %filename
    v = loadXML(filename); %load the annotation file as the variable v

    for i = 1:length(v.annotation.object)
           if strcmp(v.annotation.object(i).name,keywords)
               filename
               %newstr = regexprep(v.annotation.object(i).name, keywords, 'spoon holder', 'ignorecase'); %remove keywords
               newstr = ['cd']
               newstr = strtrim(newstr); %removes trailing whitespace if any (not necessary for LSA but looks cleaner)
               v.annotation.object(i).name = newstr; %replace the annotation word 
           %the new v.annotation file will still have deleted objects, when
           %calling [annotation] later we remove these objects 
           end
    end
    writeXML(filename,v); %save the new file
end