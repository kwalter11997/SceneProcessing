subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be used
 
for subj = 1:30
     fileSubj = char(subjectNums(subj));

     maxN(subj) = max(subjData.(sprintf('Sub%s', fileSubj)).nBack); %max N this subj reached   
end

figure()
set(gcf, 'Position', [100 100 300 400])

s(1) = subplot(4,1,1:3)
histogram(maxN)
ylabel('Number of Subjects')
t = title('Distribution of Maximum N-Back Reached Across Subjects')
titlePos = get( t , 'position');
titlePos(2) = 10.5;
set( t , 'position' , titlePos);

s(2) = subplot(4,1,4)
boxplot(maxN, 'Orientation','Horizontal')
set(gca,'YTick',[])
set(gca,'XTick',[])
xlabel('Maximum N-Back','FontSize',10)

linkaxes(s,'x')