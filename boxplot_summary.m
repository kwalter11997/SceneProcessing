%% gbvs & lsa quick summary 

subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used

for subj = 1:30
    avgGBVS(subj) = nanmean(AUC.(['Sub' char(subjectNums(subj))]).gbvs_CB)
    sdGBVS(subj) = nanstd(AUC.(['Sub' char(subjectNums(subj))]).gbvs_CB)
    
    avgLSA(subj) = nanmean(AUC.(['Sub' char(subjectNums(subj))]).lsa)
    sdLSA(subj) = nanstd(AUC.(['Sub' char(subjectNums(subj))]).lsa)    
    
    avgGloVe(subj) = nanmean(AUC.(['Sub' char(subjectNums(subj))]).glove)
    sdGloVe(subj) = nanstd(AUC.(['Sub' char(subjectNums(subj))]).glove)
end
    
% figure()
% subplot(1,2,1)
% m=[avgGBVS',avgLSA', avgGloVe']
% boxplot(m,'Labels',{'GBVS','LSA','GloVe'})
% title({'Mean of AUCs','Across Subjects'})
% ylabel('Mean')
% subplot(1,2,2)
% s=[sdGBVS',sdLSA', sdGloVe']
% boxplot(s,'Labels',{'GBVS','LSA', 'GloVe'})
% title({'Standard Deviation of','AUCs Across Subjects'})
% ylabel('Standard Deviation')

figure()
subplot(1,2,1)
m=[avgGBVS', avgGloVe']
boxplot(m,'Labels',{'GBVS','GloVe'})
title({'Mean AUROC'})
ylabel('Mean')
subplot(1,2,2)
s=[sdGBVS', sdGloVe']
boxplot(s,'Labels',{'GBVS', 'GloVe'})
title({'Standard Deviation AUROC'})
ylabel('Standard Deviation')

% [p,tbl,stats] = anova1([avgGBVS';avgLSA';avgGloVe'],[repmat(1,30,1);repmat(2,30,1);repmat(3,30,1)])
% [c,m,h,nms] =  multcompare(stats,'alpha',.05,'ctype','bonferroni')

[h,p,ci,stats] = ttest(avgGBVS',avgGloVe') %paired ttest
[h,p,ci,stats] = ttest(sdGBVS',sdGloVe') %paired ttest

d = computeCohen_d(avgGBVS',avgGloVe', 'paired')

mean(avgGBVS)
mean(sdGBVS)
mean(avgLSA)
mean(sdLSA)
mean(avgGloVe)
mean(sdGloVe)
