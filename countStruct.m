function [nTotal] = countStruct(struct)

allFolders = fieldnames(struct)
for n = 1:numel(fieldnames(struct))
    folder = cell2mat(allFolders(n)); %go through the folders
    nFiles = numel(fieldnames(struct.(folder))); %find all the files in the folder
    nFileArray(1,n) = nFiles
end
nTotal = sum(nFileArray)