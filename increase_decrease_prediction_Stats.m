load('E:\SceneProcessing\AUCAnalysis\minMax_GBVS_LSA_GloVe_AUC')

lowMin_gbvs = find(gbvsMinMax(:,1) > gbvsMinMax(:,2)) %subjs where the min n-back scored a lower AUC (model increased prediction with load) 
lowMin_lsa = find(lsaMinMax(:,1) > lsaMinMax(:,2)) %subjs where the min n-back scored a lower AUC (model increased prediction with load)
lowMin_glove = find(gloveMinMax(:,1) > gloveMinMax(:,2)) %subjs where the min n-back scored a lower AUC (model increased prediction with load)

highMin_gbvs = find(gbvsMinMax(:,1) < gbvsMinMax(:,2)) %subjs where the min n-back scored a higher AUC (model decreased prediction with load) 
highMin_lsa = find(lsaMinMax(:,1) < lsaMinMax(:,2)) %subjs where the min n-back scored a higher AUC (model decreased prediction with load)
highMin_glove = find(gloveMinMax(:,1) < gloveMinMax(:,2)) %subjs where the min n-back scored a higher AUC (model decreased prediction with load)

% figure()
% subplot(1,2,1)
% coordLineStyle = 'k.';
% boxplot(gbvsMinMax(lowMin_gbvs,:), 'Symbol', coordLineStyle, 'Labels',{'Min N','Max N'}); hold on;
% parallelcoords(gbvsMinMax(lowMin_gbvs,:), 'Color', 0.7*[1 1 1], 'LineStyle', '-',...
%   'Marker', '.', 'MarkerSize', 10);
% title('GBVS Decrease w/ Load')
% subplot(1,2,2)
% boxplot(gbvsMinMax(highMin_gbvs,:), 'Symbol', coordLineStyle, 'Labels',{'Min N','Max N'}); hold on;
% parallelcoords(gbvsMinMax(highMin_gbvs,:), 'Color', 0.7*[1 1 1], 'LineStyle', '-',...
%   'Marker', '.', 'MarkerSize', 10);
% title('GBVS Increase w/ Load')

subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used

x=1;
for subj = lowMin_gbvs'
    fileSubj = char(subjectNums(subj));
    gbvsIncreasewLoad_highestNs(x) = max(AUC.(['Sub' num2str(fileSubj)]).nBack); %get the highest n for each subj
    x=x+1;
end
x=1;
for subj = lowMin_lsa'
    fileSubj = char(subjectNums(subj));
    lsaIncreasewLoad_highestNs(x) = max(AUC.(['Sub' num2str(fileSubj)]).nBack); %get the highest n for each subj
    x=x+1;
end
x=1;
for subj = lowMin_glove'
    fileSubj = char(subjectNums(subj));
    gloveIncreasewLoad_highestNs(x) = max(AUC.(['Sub' num2str(fileSubj)]).nBack); %get the highest n for each subj
    x=x+1;
end

mean(gbvsIncreasewLoad_highestNs)
mean(lsaIncreasewLoad_highestNs)
mean(gloveIncreasewLoad_highestNs)

[h,p,ci,stats] = ttest2(gbvsIncreasewLoad_highestNs,lsaIncreasewLoad_highestNs)
[h,p,ci,stats] = ttest2(gbvsIncreasewLoad_highestNs,gloveIncreasewLoad_highestNs)