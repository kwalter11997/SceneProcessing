%% AUC Stats
subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used

for subj = 1:30
    fileSubj = char(subjectNums(subj));
    allNs(subj) = max(AUC.(['Sub' num2str(fileSubj)]).nBack); %get the highest n for each subj
    maxN = max(allNs); %find highest n out of all subjs so we can make a matrix
end

blocks = [repmat(1,25,1);repmat(2,25,1);repmat(3,25,1);repmat(4,25,1)]';
totalgbvsAvg = zeros(length(subj), maxN+1); %set up a matrix for the total average later (plus 1 because we include 0)
totallsaAvg = zeros(length(subj), maxN+1); %set up a matrix for the total average later
totalgbvs = [];
totallsa = [];
totalglove = [];

for subj = 1:30
    fileSubj = char(subjectNums(subj));
    Ns = max(AUC.(['Sub' num2str(fileSubj)]).nBack)
    gbvsCats = []; %clear variables
    gbvsAvg = [];
    lsaCats = [];
    lsaAvg = [];
    gloveCats = [];
    gloveAvg = [];
    gbvsMat = []
    lsaMat = [];
    gloveMat = [];
    gbvsSD = [];
    lsaSD = [];
    gloveSD = [];
    for n = 0:Ns
        idx = find(AUC.(['Sub' num2str(fileSubj)]).nBack==n) %find the index of each n back
        block = blocks(idx);
        
        gbvsCats = AUC.(['Sub' num2str(fileSubj)]).gbvs_CB(idx); %get gbvs values at this nback
        lsaCats = AUC.(['Sub' num2str(fileSubj)]).lsa(idx); %get lsa values for this nback
        gloveCats = AUC.(['Sub' num2str(fileSubj)]).glove(idx); %get glove values for this nback
        
        gbvsAvg(n+1) = nanmean(gbvsCats); %get average for the nback
        lsaAvg(n+1) = nanmean(lsaCats); %get average for this nback
        gloveAvg(n+1) = nanmean(gloveCats); %get average for this nback
         
        gbvsMat = [gbvsCats',repmat(n,length(gbvsCats),1),repmat(subj,length(gbvsCats),1),idx',block']; %make a matrix of auc, nback, and subject        
        totalgbvs = [totalgbvs;gbvsMat]; %continue adding onto this matrix
        lsaMat = [lsaCats',repmat(n,length(lsaCats),1),repmat(subj,length(lsaCats),1),idx',block']; %make a matrix of auc, nback, and subject        
        totallsa = [totallsa;lsaMat]; %continue adding onto this matrix
        gloveMat = [gloveCats',repmat(n,length(gloveCats),1),repmat(subj,length(gloveCats),1),idx',block']; %make a matrix of auc, nback, and subject        
        totalglove = [totalglove;gloveMat]; %continue adding onto this matrix
    end
    
%     figure()
%     plot([0:Ns], gbvsAvg,[0:Ns],lsaAvg, 'LineWidth', 2)
%     legend('gbvs','LSA')
%     title('Viewing Method across N-Back')
%     xlabel('N-Back')
%     ylabel('AUC')
    
    for missingIndex = (length(gbvsAvg)+1):maxN+1 %length +1 as to not include maxN, maxN +1 to include 0
        gbvsAvg(missingIndex)=NaN; %fill in the end of each with NaNs so matrix is even
        lsaAvg(missingIndex)=NaN;
        gloveAvg(missingIndex)=NaN;
    end
    
    totalgbvsAvg(subj,:) = gbvsAvg;
    totallsaAvg(subj,:) = lsaAvg;
    totalgloveAvg(subj,:) = gloveAvg;

    gbvsSD = nanstd(totalgbvsAvg); %get std 
    lsaSD = nanstd(totallsaAvg); %get std 
    gloveSD = nanstd(totalgloveAvg); %get std
end

totalAvggbvs = nanmean(totalgbvsAvg);
totalAvglsa = nanmean(totallsaAvg);  
totalAvgglove = nanmean(totalgloveAvg);

gbvsSEM = gbvsSD / sqrt(30); %get SEM 
lsaSEM = lsaSD / sqrt(30); %get SEM 
gloveSEM = gloveSD / sqrt(30); %get SEM

file = 'total_GBVSCB_LSA_GloVe_AUC'
save(file, 'totalgbvs', 'totallsa', 'totalglove')

%% boxplots
%maxmin
gbvsminN = totalgbvsAvg(:,1);
for subj = 1:30 
    maxsubj = allNs(subj); %index highest n for each subj
    gbvsmaxN(subj,:) = totalgbvsAvg(subj,maxsubj+1);
end
lsaminN = totallsaAvg(:,1);
for subj = 1:30 
    maxsubj = allNs(subj); %index highest n for each subj
    lsamaxN(subj,:) = totallsaAvg(subj,maxsubj+1);
end
gloveminN = totalgloveAvg(:,1);
for subj = 1:30 
    maxsubj = allNs(subj); %index highest n for each subj
    glovemaxN(subj,:) = totalgloveAvg(subj,maxsubj+1);
end
gbvsMinMax = [gbvsminN,gbvsmaxN]; %create 2 columns for AUC at min / max N for each subj
lsaMinMax = [lsaminN,lsamaxN];
gloveMinMax = [gloveminN,glovemaxN];

[h_gbvs,p_gbvs,ci_gbvs,stats_gbvs] = ttest(gbvsMinMax(:,1),gbvsMinMax(:,2))
[h_lsa,p_lsa,ci_lsa,stats_lsa] = ttest(lsaMinMax(:,1),lsaMinMax(:,2))
[h_glove,p_glove,ci_glove,stats_glove] = ttest(gloveMinMax(:,1),gloveMinMax(:,2)) 

figure();
sp1 = subplot(1,3,1)
coordLineStyle = 'k.';
boxplot(gbvsMinMax, 'Symbol', coordLineStyle, 'Labels',{'Min N','Max N'}); hold on;
parallelcoords(gbvsMinMax, 'Color', 0.7*[1 1 1], 'LineStyle', '-',...
  'Marker', '.', 'MarkerSize', 10);
title('GBVS')
%text(0.6,.3,sprintf('t(%d)=%0.3f; p=%0.3f',stats_gbvs.df,stats_gbvs.tstat,p_gbvs))
plot([1,2],[nanmean(gbvsMinMax(:,1)),nanmean(gbvsMinMax(:,2))],'Color','black','LineWidth',1)
ylabel('ROC')

sp2 = subplot(1,3,2)
coordLineStyle = 'k.';
boxplot(lsaMinMax, 'Symbol', coordLineStyle, 'Labels',{'Min N','Max N'}); hold on;
parallelcoords(lsaMinMax, 'Color', 0.7*[1 1 1], 'LineStyle', '-',...
  'Marker', '.', 'MarkerSize', 10);
title('LSA')
%text(0.6,.3,sprintf('t(%d)=%0.3f; p=%0.3f',stats_lsa.df,stats_lsa.tstat,p_lsa))
plot([1,2],[nanmean(lsaMinMax(:,1)),nanmean(lsaMinMax(:,2))],'Color','black','LineWidth',1)
ylabel('ROC')

sp3 = subplot(1,3,3)
coordLineStyle = 'k.';
boxplot(gloveMinMax, 'Symbol', coordLineStyle, 'Labels',{'Min N','Max N'}); hold on;
parallelcoords(gloveMinMax, 'Color', 0.7*[1 1 1], 'LineStyle', '-',...
  'Marker', '.', 'MarkerSize', 10);
title('GloVe')
%text(0.6,.3,sprintf('t(%d)=%0.3f; p=%0.3f',stats_glove.df,stats_glove.tstat,p_glove))
plot([1,2],[nanmean(gloveMinMax(:,1)),nanmean(gloveMinMax(:,2))],'Color','black','LineWidth',1)
ylabel('ROC')

linkaxes([sp1,sp2,sp3],'y');


%all Ns 
numlist = repmat(0:10,30,1)
[p,tbl,stats] = anova1(totalgbvsAvg(:),numlist(:))
[c,m,h,nms] =  multcompare(stats,'alpha',.05,'ctype','bonferroni')

[p,tbl,stats] = anova1(totallsaAvg(:),numlist(:))
[c,m,h,nms] =  multcompare(stats,'alpha',.05,'ctype','bonferroni')

[p,tbl,stats] = anova1(totalgloveAvg(:),numlist(:))
[c,m,h,nms] =  multcompare(stats,'alpha',.05,'ctype','bonferroni')

figure();
coordLineStyle = 'k.';
boxplot(totalgbvsAvg, 'Symbol', coordLineStyle, 'Labels',{'0','1','2','3','4','5','6','7','8','9','10'}); hold on;
parallelcoords(totalgbvsAvg, 'Color', 0.7*[1 1 1], 'LineStyle', '-',...
  'Marker', '.', 'MarkerSize', 10);
title({'Average GBVS AUC', 'at Each N-Back'})
ylabel('AUC')
xlabel('N-Back')
ylim([.6,.9])

plot([1:11], nanmean(totalgbvsAvg), 'k', 'LineWidth', 1)
% sigstar({[9,6]})

figure();
coordLineStyle = 'k.';
boxplot(totallsaAvg, 'Symbol', coordLineStyle, 'Labels',{'0','1','2','3','4','5','6','7','8','9','10'}); hold on;
parallelcoords(totallsaAvg, 'Color', 0.7*[1 1 1], 'LineStyle', '-',...
  'Marker', '.', 'MarkerSize', 10);
title({'Average LSA AUC', 'at Each N-Back'})
ylabel('AUC')
xlabel('N-Back')

plot([1:11], nanmean(totallsaAvg), 'k', 'LineWidth', 1)
% sigstar({[6,3],[4,6]},[.009,.04])

figure();
coordLineStyle = 'k.';
boxplot(totalgloveAvg, 'Symbol', coordLineStyle, 'Labels',{'0','1','2','3','4','5','6','7','8','9','10'}); hold on;
parallelcoords(totalgloveAvg, 'Color', 0.7*[1 1 1], 'LineStyle', '-',...
  'Marker', '.', 'MarkerSize', 10);
title({'Average GloVe AUC', 'at Each N-Back'})
ylabel('AUC')
xlabel('N-Back')

plot([1:11], nanmean(totalgloveAvg), 'k', 'LineWidth', 1)
% sigstar({[6,10],[7,8],[4,8]})

%% Stats
%gbvs
for n1 = 1:11
    for n2 = 1:11
        [h,p,ci,stats] = ttest(totalgbvsAvg(:,n1),totalgbvsAvg(:,n2)) 
        if p > .05
            str = sprintf('t(%d)=%0.3f; p=(%0.3f)',stats.df,stats.tstat,p)
        elseif p < .05 && p > .01
            str = sprintf('t(%d)=%0.3f; p<0.05)*',stats.df,stats.tstat)
        elseif p < .01 && p > .001
           str = sprintf('t(%d)=%0.3f; p<0.01)**',stats.df,stats.tstat)
        elseif p < .001
            str = sprintf('t(%d)=%0.3f; p<0.001)***',stats.df,stats.tstat)
        elseif isnan(p)
            str = {'-'}
        end
        gbvsStats(n1,n2) = {str}
    end
end

%lsa
for n1 = 1:11
    for n2 = 1:11
        [h,p,ci,stats] = ttest(totallsaAvg(:,n1),totallsaAvg(:,n2)) 
        if p > .05
            str = sprintf('t(%d)=%0.3f; p=(%0.3f)',stats.df,stats.tstat,p)
        elseif p < .05 && p > .01
            str = sprintf('t(%d)=%0.3f; p<0.05)*',stats.df,stats.tstat)
        elseif p < .01 && p > .001
           str = sprintf('t(%d)=%0.3f; p<0.01)**',stats.df,stats.tstat)
        elseif p < .001
            str = sprintf('t(%d)=%0.3f; p<0.001)***',stats.df,stats.tstat)
        elseif isnan(p)
            str = {'-'}
        end
        lsaStats(n1,n2) = {str}
    end
end

%glove
for n1 = 1:11
    for n2 = 1:11
        [h,p,ci,stats] = ttest(totalgloveAvg(:,n1),totalgloveAvg(:,n2)) 
        if p > .05
            str = sprintf('t(%d)=%0.3f; p=(%0.3f)',stats.df,stats.tstat,p)
        elseif p < .05 && p > .01
            str = sprintf('t(%d)=%0.3f; p<0.05)*',stats.df,stats.tstat)
        elseif p < .01 && p > .001
           str = sprintf('t(%d)=%0.3f; p<0.01)**',stats.df,stats.tstat)
        elseif p < .001
            str = sprintf('t(%d)=%0.3f; p<0.001)***',stats.df,stats.tstat)
        elseif isnan(p)
            str = {'-'}
        end
        gloveStats(n1,n2) = {str}
    end
end