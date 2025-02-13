function [L,R] = bestEye(samplePosL,samplePosR,sampleTimes)

if all(all(isnan(samplePosL))) %if there is no L eye data this trial
   L = 0; %only use right eye
   R = 1;
elseif all(all(isnan(samplePosR))) %if there is no R eye data for this trial
  L = 1; %only use left eye
  R = 0;
else
   [maxVar] = plotTrialPos(sampleTimes,samplePosL,samplePosR);
   if maxVar == 1 %1=left eye has worse variance, 2=right eye has worse variance
       L = 0; %only use right eye
       R = 1;
   else
       L = 1; %only use left eye
       R = 0;
   end
end