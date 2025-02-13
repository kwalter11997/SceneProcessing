%% add correct vs incorrect response label into subjData

subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used
 
for subj = 1:30
    fileSubj = char(subjectNums(subj))  %file name for each subject 
    load(sprintf('E:\\SceneProcessing\\SubjData\\sceneProcessing_subj%s.mat',fileSubj)); %load the files one by one
        
    subjData.(['Sub' fileSubj]).response = subjResponses
end

SAVE = 'E:\SceneProcessing';
cd(SAVE);
matfile = 'subjData';
save(matfile, 'subjData');