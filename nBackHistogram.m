%% N-back Histogram

addpath(genpath('E:\SceneProcessing'));
load('E:\SceneProcessing\subjData.mat')

nMatrix = zeros(length(subj),100); %set up a matrix for every n for every subj
    
for subj = 1:30
    subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used
    fileSubj = char(subjectNums(subj));  %file name for each subject 
    nMatrix(subj,:) = subjData.(['Sub' fileSubj]).nBack; %get the highest n for each subj
end

nMatrixVect=nMatrix(:) %list out as a single vector

bins = [0:max(nMatrixVect)]
histogram(nMatrixVect,bins)
xlabel('N-Back')
ylabel('Total # of Trials')
title('Histogram of N-Backs')

%% n-back by block 

%seperate into blocks by indexing trial sections
block1 = nMatrix(:,1:25);
block2 = nMatrix(:,26:50);
block3 = nMatrix(:,51:75);
block4 = nMatrix(:,76:100);

block1Vect = block1(:);
block2Vect = block2(:);
block3Vect = block3(:);
block4Vect = block4(:);

histogram([block1Vect,block2Vect,block3Vect,block4Vect],bins)

%% find performance curve over whole experiment vs by block