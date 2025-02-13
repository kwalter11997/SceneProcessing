%% Permutation Stats

load('E:\SceneProcessing\AUCAnalysis\permutationAnalysis')
subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used

for maps = 1:3 %go through this analysis for each map type (GBVS = 1, LSA = 2, GloVe = 3)
    
    for subj  = 1:30
        fileSubj = char(subjectNums(subj)); %get the char characters for this subj
        targetMat(subj,:) = perm.(['Subj' fileSubj]).target{1,maps}; %make a matrix of all target data
   
        allAUCs(subj,:) = reshape(perm.(['Subj' fileSubj]).AUCarray{1,maps},1,[]); %grab all AUCs for this map
    end
    
    avgTargetIndiv = nanmean(targetMat); %calculate the mean target value (avg of all subjs) for every img
    avgTargetAll = mean(avgTargetIndiv) %calculate overall mean target value for this map
    
    %z = (obvs - mean) / std
    z = (avgTargetAll - nanmean(allAUCs(:))) / nanstd(allAUCs(:))
    normcdf(z)
    
    figure()
    h = histogram(allAUCs)
    xlim([0,1])
    ylim([0,7000])
    hold on
    plot(avgTargetAll, 0, 'r*', 'LineWidth', 2, 'MarkerSize', 15);
    ax=gca
    plot(ax.XLim(2)*.06,ax.YLim(2)*.95, 'r*', 'LineWidth', 1.5, 'MarkerSize', 10);
    text(ax.XLim(2)*.085,ax.YLim(2)*.95,sprintf('= %0.3f', avgTargetAll))
    text(ax.XLim(2)*.05,ax.YLim(2)*.9,sprintf('z = %0.3f', z))
    xlabel('AUC')
    ylabel('Frequency')
    if maps == 1
        title('GBVS')
    elseif maps == 2
        title('LSA')
    elseif maps == 3
        title('GloVe')
    end
end
    