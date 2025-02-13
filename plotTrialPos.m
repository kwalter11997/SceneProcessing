function [maxVar] = plotTrialPos(sampleTimes,samplePosL,samplePosR)
% 
% figure()
% subplot(2,1,1)
% plot(sampleTimes,samplePosL(:,1)) %xdata L
% hold on
% plot(sampleTimes,samplePosR(:,1)) %xdata R
% 
% subplot(2,1,2)
% plot(sampleTimes,samplePosL(:,2)) %ydata L
% hold on 
% plot(sampleTimes,samplePosR(:,2)) %ydata R
% 
% find moving average of data, compare to original. use whichever is closer to original
% LXdiff = nansum(abs(samplePosL(:,1) - smooth(samplePosL(:,1)))); %L X
% LYdiff = nansum(abs(samplePosL(:,2) - smooth(samplePosL(:,2)))); %L Y
% 
% RXdiff = nansum(abs(samplePosR(:,1) - smooth(samplePosR(:,1))));  %R X
% RYdiff = nansum(abs(samplePosR(:,2) - smooth(samplePosR(:,2)))); %R Y

% Ldiff = LXdiff+LYdiff; %overall discrepency in L
% Rdiff = RXdiff+RYdiff; %overall discrepency in R

Ldiff = nansum(nansum(abs(samplePosL) - smoothdata(samplePosL))); %L
Rdiff = nansum(nansum(abs(samplePosR) - smoothdata(samplePosR)));  %R X

maxVar = find([Ldiff,Rdiff] == max([Ldiff,Rdiff])); %find which eye has the greatest discrepency after finding the moving average (L = 1 / R = 2)
    
if length(maxVar) > 1 %if the difference is the same in both eyes, just take left
    maxVar = 1;
end

% xLvar = var(samplePosL(:,1),'omitnan');
% xRvar = var(samplePosR(:,1),'omitnan');
% 
% yLvar = var(samplePosL(:,2),'omitnan');
% yRvar = var(samplePosR(:,2),'omitnan');
%  
% xVar = abs(xLvar - xRvar);
% yVar = abs(yLvar - yRvar);
% 
% XorYvar = find([xVar,yVar] == max([xVar,yVar])); %see which has higher variance, x or y (1=x 2=y)
% 
% if XorYvar == 1
%     maxVar = find(xvars == max(xvars)); %find index of max variance (1 = left 2 = right)
% else
%     maxVar = find(yvars == max(yvars)); 
% end


% xVarL = abs(var(samplePosL(:,1),'omitnan'));
% yVarL = abs(var(samplePosL(:,2),'omitnan'));
% xVarR = abs(var(samplePosR(:,1),'omitnan'));
% yVarR = abs(var(samplePosR(:,2),'omitnan'));
% 
% xvars = [xVarL,xVarR];
% yvars = [yVarL,yVarR];
% 
% XorYvar = find([xvars,yvars] == max([xvars,yvars])); %see which has higher variance, x or y (1=x 2=y)

% if XorYvar == 1 | XorYvar == 2
%     maxVar = find(xvars == max(xvars)); %find index of max variance (1 = left 2 = right)
% else
%     maxVar = find(yvars == max(yvars)); 
% end
