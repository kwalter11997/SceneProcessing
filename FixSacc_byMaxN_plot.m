%% seperate into max N subjs
figure()
hold on
for figs = 1:2
    for subj = 1:30
        subjFix = totalFix(totalFix(:,4) == subj,:);
        subjSacc = totalSacc(totalSacc(:,4) == subj,:);

        if figs == 1 %number of fixations/saccades
            avgFix(subj) = nanmean(subjFix(:,1)); %average number of fixations this subject made
            stdFix(subj) = nanstd(subjFix(:,1)); %std of number of fixations this subj made
            avgSacc(subj) = nanmean(subjSacc(:,1)); %average number of saccades this subject made
            stdSacc(subj) = nanstd(subjSacc(:,1)); %std of number of saccades this subj made
            subplot(1,2,1)
        else %duration of fixations / saccades
            avgFix(subj) = nanmean(subjFix(:,2)); %average duration of fixations this subject made
            stdFix(subj) = nanstd(subjFix(:,2)); %std duration of fixations this subj made
            avgSacc(subj) = nanmean(subjSacc(:,2)); %average dur of sacc this subject made
            stdSacc(subj) = nanstd(subjSacc(:,2)); %std dur of sacc this subj made
            subplot(1,2,2)
        end

        maxN(subj) = max(subjFix(:,3)); %max N this subj reached

        SEMFix(subj) = stdFix(subj)/sqrt(length(subjFix(:,1)));                % Standard Error
        tsFix(subj) = max(tinv([0.025  0.975],length(subjFix(:,1))-1));        % T-Score
        CIFix(subj) = avgFix(subj) + tsFix(subj)*SEMFix(subj);                 % Confidence interval

        errorbar(maxN(subj),avgFix(subj),tsFix(subj)*SEMFix(subj), 'ob','MarkerFaceColor','b'); %error bars are confidence intervals 
        hold on

        SEMSacc(subj) = stdSacc(subj)/sqrt(length(subjSacc(:,1)));             % Standard Error
        tsSacc(subj) = max(tinv([0.025  0.975],length(subjSacc(:,1))-1));      % T-Score
        CISacc(subj) = avgSacc(subj) + tsSacc(subj)*SEMSacc(subj);             % Confidence interval

        errorbar(maxN(subj),avgSacc(subj),tsSacc(subj)*SEMSacc(subj), 'or','MarkerFaceColor','r'); %error bars are confidence intervals 
    end
    
    if figs == 1
        maxFixN = [maxN',avgFix']
        maxSaccN = [maxN',avgSacc']
    else
        maxFixDur = [maxN',avgFix']
        maxSaccDur = [maxN',avgSacc']
    end    
    
    b1=polyfit(maxN,avgFix,1);  % use polyfit for coefficients
    line1 = refline(b1)         % will work when give the coefficients explicitly
    line1.Color = 'blue'

    b2=polyfit(maxN,avgSacc,1);  % use polyfit for coefficients
    line2 = refline(b2)         % will work when give the coefficients explicitly
    line2.Color = 'red'

    legend('Fixations', 'Saccades')
    xlim([1,11])
    xlabel('Max N-Back')

    if figs == 1
        title({'Average Number of Fixations and' 'Saccades Made by Each Subject'})
        ylabel('Average Number of Events')
    else
        title({'Average Duration of Fixations and' 'Saccades Made by Each Subject'})
        ylabel('Average Duration of Events (s)')
    end
    
    x_1 = maxN
    y_1 = avgFix

    x_2 = maxN
    y_2 = avgSacc

    p2_1 = polyfit(get(line1,'xdata'),get(line1,'ydata'),1); %get the intercepts for the line equation
    x1 = ones(size(x_1,2),1); %need a column of ones for regress to work
    X_1 = [x1 x_1'];    % Includes column of ones
    %[b1,bint1,r1,rint1,stats1] = regress(y_1',X_1) %stats = [r2 F prob s2]
    [rho1,p1] = corr(x_1',y_1','Rows','pairwise')

    p2_2 = polyfit(get(line2,'xdata'),get(line2,'ydata'),1); %get the intercepts for the line equation
    x2 = ones(size(x_2,2),1); %need a column of ones for regress to work
    X_2 = [x2 x_2'];    % Includes column of ones
    %[b2,bint2,r2,rint2,stats2] = regress(y_2',X_2) %stats = [r2 F prob s2]
    [rho2,p2] = corr(x_2',y_2','Rows','pairwise')

    
    if figs == 1
        text(7, 17, [sprintf('r(%d)=',sum(~isnan(totalFix(:,1)))) num2str(round(rho1,3)) ' ', 'p=' round(num2str(p1,3))],'Color','b');
        %text(8, 18, ['y=' num2str(round(p2_1(1),3)) '*x+' num2str(round(p2_1(2),3))],'Color','b'); 

        text(7, 16, [sprintf('r(%d)=',sum(~isnan(totalSacc(:,1)))) num2str(round(rho2,3)) ' ', 'p=' round(num2str(p2,3))],'Color','r');
        %text(8, 16, ['y=', num2str(round(p2_2(1),3)) '*x+' num2str(round(p2_2(2),3))],'Color','r');
    else
        text(7.1, .8, [sprintf('r(%d)=',sum(~isnan(totalFix(:,1)))) num2str(round(rho1,3)) ' ', 'p=' round(num2str(p1,3))],'Color','b');
        %text(8, 0.8, ['y=' num2str(round(p2_1(1),3)) '*x+' num2str(round(p2_1(2),3))],'Color','b'); 

        text(7.1, 0.4, [sprintf('r(%d)=',sum(~isnan(totalSacc(:,1)))) num2str(round(rho2,3)) ' ', 'p=' round(num2str(p2,3))],'Color','r');
        %text(8, 0.2, ['y=', num2str(round(p2_2(1),3)) '*x+' num2str(round(p2_2(2),3))],'Color','r');
    end
end

subjAvgFix = [maxFixN,maxFixDur(:,2)]
subjAvgSacc = [maxSaccN,maxSaccDur(:,2)]

matfile = 'subjAvgFix';
save(matfile,'subjAvgFix')
matfile = 'subjAvgSacc';
save(matfile,'subjAvgSacc')

%% run some stats

%post hoc annotation:
%Columns 1-2 are the indices of the two samples being compared.  
%Columns 3-5 are a lower bound, estimate, and upper bound for their difference. 
%Column 6 is the p-value for each individual comparison. 
figure()
%anova by max n groups
[P,T,STATS,TERMS] = anovan(subjAvgFix(:,2),subjAvgFix(:,1)) %are # of fixations different across groups?        (no) 
posthoc = multcompare(STATS)                                                                                    %all post hocs nonsig
[P,T,STATS,TERMS] = anovan(subjAvgFix(:,3),subjAvgFix(:,1)) %are duration of fixations different across groups? (no)
posthoc = multcompare(STATS)                                                                                    %all post hocs nonsig
[P,T,STATS,TERMS] = anovan(subjAvgSacc(:,2),subjAvgFix(:,1)) %are # of saccades different across groups?        (no) 
posthoc = multcompare(STATS)                                                                                    %all post hocs nonsig
[P,T,STATS,TERMS] = anovan(subjAvgSacc(:,3),subjAvgFix(:,1)) %are duration of saccades different across groups? (no)
posthoc = multcompare(STATS)  