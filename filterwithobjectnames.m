%% get the list of labeled object names and counts 
Kerristruct = load ('objMaskStruct.mat');
thestruct = Kerristruct.objMaskStruct;

objcount = struct; %this structure is used to store object names and counts 
fn = fieldnames(thestruct);

for i=1:numel(fn) %loop through all the folders
    
    currfolder = thestruct.(fn{i});
    currfn = fieldnames(currfolder);
    
    for j=1:numel(currfn) %loop through all the images
        img = currfolder.(currfn{j});
        
        if isfield(img,'objects')
            for k=1:size(img.objects,2)
                objname = img.objects{k};
                objname(isletter(objname)==0)=[]; 
                %delete any nonalphabetic part of the object name, so that
                %it can be used as a fieldname
            
                if ~ isempty(objname)
                
                    if isfield(objcount,objname)
                        %if the object name is already in the structure,
                        %add 1 to its value
                        objcount.(objname) = objcount.(objname)+1;
                    else
                        %if it is a new one, add it as a new field
                        objcount.(objname) = 1;
                       
                    end
                end 
            
            end
        end
        %disp( strcat(currfn{j},' is done'))
        
    end
    
    disp( strcat(fn{i},' is done'))
        
    
end




%% find the high frequency objects (but not too common??)

objname = fieldnames(objcount);

freq_obj="";

for i = 1:length(objname)
    if objcount.(objname{i})>200 && objcount.(objname{i})<350 
        %find the objects that occur 200-350 times in the structure
        %the range needs to be discussed
       
        freq_obj=freq_obj+" "+objname{i};
    end       
end
       
freqlst = split(freq_obj," "); 


%% find images containing certain amount of frequent objects


newstruct=struct; % a new structure to store qualified images



for i=1:numel(fn) %loop through all the folders
    
    currfolder = thestruct.(fn{i});
    currfn = fieldnames(currfolder);
    
    for j=1:numel(currfn) %loop through all the images in the current folder
        img = currfolder.(currfn{j}); 
        score = 0; %the score variable is used to count how many commonly labeled objects are in the current image
        
        if ~isfield(img,'objects') %if no labeled objects, delete the image from the structure
            currfolder = rmfield(currfolder,currfn{j});
        else
            for k=1:size(img.objects,2) %loop through all objects, to see if contains the frequent ones
                objname = img.objects{k};
                objname(isletter(objname)==0)=[];
            
                if ~ isempty(objname)
            
                    r = strfind(freqlst,objname); %check if the object matches elements in the freqlist
                
                    if ~isempty(find(~cellfun(@isempty,r), 1))
                        score = score +1;
                     
                    end
                end 
            
            end
            if score<6 %the image must contain <6 commonly labeled objects, it will be removed from the structure
             %the number needs to be discussed
             
                currfolder = rmfield(currfolder,currfn{j});
                
            end
            
            
        end
        
    end
    
    if ~isempty(fieldnames(currfolder)) 
        %after the filtering, if the folder is not empty, then add it to the new structure
        newstruct.(fn{i})=currfolder;
        
        
    end
    
      
    
end
 
% count how many images are in the new structure
% countPicsInStruct(newstruct)

%count
newFolders = fieldnames(newstruct);
for n = 1:numel(fieldnames(newstruct))
    folder = cell2mat(newFolders(n)); %go through the folders
    nNewFiles = numel(fieldnames(newstruct.(folder))); %find all the files in the folder
    nNewFileArray(1,n) = nNewFiles;
end
nFinalTotal = sum(nNewFileArray)

commonObjStruct = newstruct
matfile = 'commonObjStruct.mat';
save(matfile, 'commonObjStruct');