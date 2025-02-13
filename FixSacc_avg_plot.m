%% Averages by subject
for n = 0:10
    allFix = totalFix(totalFix(:,3) == n,:); %all events at this n
    allSacc = totalSacc(totalSacc(:,3) == n,:);

    allCorFix = allFix(allFix(:,5) == 1,:); %all correct events at this n
    allCorSacc = allSacc(allSacc(:,5) == 1,:);
    allIncorFix = allFix(allFix(:,5) == 0,:); %all incorrect events at this n
    allIncorSacc = allSacc(allSacc(:,5) == 0,:);

    %Number of Events
    avgFixN(n+1) = nanmean(allFix(:,1)); %averages of all events
    avgSaccN(n+1) = nanmean(allSacc(:,1));

    avgCorFixN(n+1) = nanmean(allCorFix(:,1)); %averages of correct events
    avgCorSaccN(n+1) = nanmean(allCorSacc(:,1)); 
    avgIncorFixN(n+1) = nanmean(allIncorFix(:,1)); %averages of incorrect events
    avgIncorSaccN(n+1) = nanmean(allIncorSacc(:,1));

    stdCorFixN(n+1) = nanstd(allCorFix(:,1)); %std of correct events
    stdCorSaccN(n+1) = nanstd(allCorSacc(:,1));
    stdIncorFixN(n+1) = nanstd(allIncorFix(:,1)); %std of incorrect events
    stdIncorSaccN(n+1) = nanstd(allIncorSacc(:,1));

    %Duration of Events
    avgFixD(n+1) = nanmean(allFix(:,2));
    avgSaccD(n+1) = nanmean(allSacc(:,2));

    avgCorFixD(n+1) = nanmean(allCorFix(:,2));
    avgCorSaccD(n+1) = nanmean(allCorSacc(:,2));
    avgIncorFixD(n+1) = nanmean(allIncorFix(:,2));
    avgIncorSaccD(n+1) = nanmean(allIncorSacc(:,2));

    stdCorFixD(n+1) = nanstd(allCorFix(:,2));
    stdCorSaccD(n+1) = nanstd(allCorSacc(:,2));
    stdIncorFixD(n+1) = nanstd(allIncorFix(:,2));
    stdIncorSaccD(n+1) = nanstd(allIncorSacc(:,2));

    %Stats

    %correct fixations N
    SEMCorFixN(n+1) = stdCorFixN(n+1)/sqrt(length(allCorFix(:,1)));          % Standard Error
    tsCorFixN(n+1) = max(tinv([0.025  0.975],length(allCorFix(:,1))-1));     % T-Score
    CICorFixN(n+1) = tsCorFixN(n+1)*SEMCorFixN(n+1);                          %Confidence Interval Value (add or subtract from mean to get CI)

    %incorrect fixations N
    SEMIncorFixN(n+1) = stdIncorFixN(n+1)/sqrt(length(allIncorFix(:,1)));        % Standard Error
    tsIncorFixN(n+1) = max(tinv([0.025  0.975],length(allIncorFix(:,1))-1));     % T-Score
    CIIncorFixN(n+1) = tsIncorFixN(n+1)*SEMIncorFixN(n+1);                       %Confidence Interval Value (add or subtract from mean to get CI)

    %correct fixations D
    SEMCorFixD(n+1) = stdCorFixD(n+1)/sqrt(length(allCorFix(:,1)));          % Standard Error
    tsCorFixD(n+1) = max(tinv([0.025  0.975],length(allCorFix(:,1))-1));     % T-Score
    CICorFixD(n+1) = tsCorFixD(n+1)*SEMCorFixD(n+1);                          %Confidence Interval Value (add or subtract from mean to get CI)

    %incorrect fixations D
    SEMIncorFixD(n+1) = stdIncorFixD(n+1)/sqrt(length(allIncorFix(:,1)));        % Standard Error
    tsIncorFixD(n+1) = max(tinv([0.025  0.975],length(allIncorFix(:,1))-1));     % T-Score
    CIIncorFixD(n+1) = tsIncorFixD(n+1)*SEMIncorFixD(n+1);                        %Confidence Interval Value (add or subtract from mean to get CI)

    %correct saccades N
    SEMCorSaccN(n+1) = stdCorSaccN(n+1)/sqrt(length(allCorSacc(:,1)));          % Standard Error
    tsCorSaccN(n+1) = max(tinv([0.025  0.975],length(allCorSacc(:,1))-1));      % T-Score
    CICorSaccN(n+1) = tsCorSaccN(n+1)*SEMCorSaccN(n+1);                          %Confidence Interval Value (add or subtract from mean to get CI)

    %incorrect saccades N
    SEMIncorSaccN(n+1) = stdIncorSaccN(n+1)/sqrt(length(allIncorSacc(:,1)));       % Standard Error
    tsIncorSaccN(n+1) = max(tinv([0.025  0.975],length(allIncorSacc(:,1))-1));     % T-Score
    CIIncorSaccN(n+1) = tsIncorSaccN(n+1)*SEMIncorSaccN(n+1);                       %Confidence Interval Value (add or subtract from mean to get CI)
      
    %correct saccades N
    SEMCorSaccD(n+1) = stdCorSaccD(n+1)/sqrt(length(allCorSacc(:,1)));          % Standard Error
    tsCorSaccD(n+1) = max(tinv([0.025  0.975],length(allCorSacc(:,1))-1));      % T-Score
    CICorSaccD(n+1) = tsCorSaccD(n+1)*SEMCorSaccD(n+1);                          %Confidence Interval Value (add or subtract from mean to get CI)

    %incorrect saccades N
    SEMIncorSaccD(n+1) = stdIncorSaccD(n+1)/sqrt(length(allIncorSacc(:,1)));       % Standard Error
    tsIncorSaccD(n+1) = max(tinv([0.025  0.975],length(allIncorSacc(:,1))-1));     % T-Score
    CIIncorSaccD(n+1) = tsIncorSaccD(n+1)*SEMIncorSaccD(n+1);                       %Confidence Interval Value (add or subtract from mean to get CI)
end

%% Fixation Plot
figure()
sgtitle('Fixations')
set(gcf, 'Position',  [800, 500, 900, 400]) %set figure size

%Number of events
subplot(1,2,1)
hold on

% errorbar([0:10],avgCorFixN,CICorFixN, '-ob','MarkerFaceColor','b'); %error bars are confidence intervals      
% errorbar([0:10],avgIncorFixN,CIIncorFixN, '-or','MarkerFaceColor','r'); %error bars are confidence intervals 
errorbar([0:10],avgCorFixN,SEMCorFixN, '-ob','MarkerFaceColor','b'); %error bars are SEM 
errorbar([0:10],avgIncorFixN,SEMIncorFixN, '-or','MarkerFaceColor','r'); %error bars are SEM

plot([0:10],avgCorFixN, 'b', 'LineWidth', 1)
plot([0:10],avgIncorFixN, 'r', 'LineWidth', 1)

legend('Correct', 'Incorrect')
title('Number of Events')
xlabel('N-Back')
ylabel('Average Number of Events')
ylim([15,40])

%Duration of Events
subplot(1,2,2)
hold on

% errorbar([0:10],avgCorFixD,CICorFixD, '-ob','MarkerFaceColor','b'); %error bars are confidence intervals      
% errorbar([0:10],avgIncorFixD,CICorFixD, '-or','MarkerFaceColor','r'); %error bars are confidence intervals 
errorbar([0:10],avgCorFixD,SEMCorFixD, '-ob','MarkerFaceColor','b'); %error bars are SEM
errorbar([0:10],avgIncorFixD,SEMCorFixD, '-or','MarkerFaceColor','r'); %error bars are SEM

plot([0:10],avgCorFixD, 'b', 'LineWidth', 1)
plot([0:10],avgIncorFixD, 'r', 'LineWidth', 1)

legend('Correct', 'Incorrect')
title('Duration of Events')
xlabel('N-Back')
ylabel('Average Cumulative Duration of Events')
ylim([0,10])
%% Saccade Plot
figure()
sgtitle('Saccades')
set(gcf, 'Position',  [800, 500, 900, 400]) %set figure size

%Number of events
subplot(1,2,1)
hold on

% errorbar([0:10],avgCorSaccN,CICorSaccN, '-ob','MarkerFaceColor','b'); %error bars are confidence intervals      
% errorbar([0:10],avgIncorSaccN,CIIncorSaccN, '-or','MarkerFaceColor','r'); %error bars are confidence intervals 
errorbar([0:10],avgCorSaccN,SEMCorSaccN, '-ob','MarkerFaceColor','b'); %error bars are SEM
errorbar([0:10],avgIncorSaccN,SEMIncorSaccN, '-or','MarkerFaceColor','r'); %error bars are SEM
plot([0:10],avgCorSaccN, 'b', 'LineWidth', 1)
plot([0:10],avgIncorSaccN, 'r', 'LineWidth', 1)

legend('Correct', 'Incorrect')
title('Number of Events')
xlabel('N-Back')
ylabel('Average Number of Events')
ylim([15,40])

%Duration of Events
subplot(1,2,2)
hold on 
 
% errorbar([0:10],avgCorSaccD,CICorSaccD, '-ob','MarkerFaceColor','b'); %error bars are confidence intervals      
% errorbar([0:10],avgIncorSaccD,CIIncorSaccD, '-or','MarkerFaceColor','r'); %error bars are confidence intervals 
errorbar([0:10],avgCorSaccD,SEMCorSaccD, '-ob','MarkerFaceColor','b'); %error bars are SEM  
errorbar([0:10],avgIncorSaccD,SEMIncorSaccD, '-or','MarkerFaceColor','r'); %error bars are SEM 


plot([0:10],avgCorSaccD, 'b', 'LineWidth', 1)
plot([0:10],avgIncorSaccD, 'r', 'LineWidth', 1)

legend('Correct', 'Incorrect')
title('Duration of Events')
xlabel('N-Back')
ylabel('Average Cumulative Duration of Events')
ylim([0,10])

