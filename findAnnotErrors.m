HOMEANNOTATIONS = 'C:\MATLAB\SceneProcessing\FinalLibrary\FinalAnnotations'; 

cd(HOMEANNOTATIONS);
D = dir; 
D = D(~ismember({D.name}, {'.', '..'})); %first elements are '.' and '..' used for navigation - remove these

fileNames = {D.name}; %get all the file names
fileNames(strcmp(fileNames,'.') | strcmp(fileNames,'..')) = [];%remove "." and ".." from file names

for read = 1:length(fileNames)
    str = fileread(char(fileNames(read)));
    if contains(str,'<folder>//')
       str = strrep(str,'<folder>//', '<folder>')
%        filename = erase(char(fileNames(read)),'.xml')
%        xmlwrite(filename,str)
    end
end