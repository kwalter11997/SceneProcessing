%% long format for R
subjectNums = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14';'15';'16';'17';'18';'19';'20';'21';'22';'23';'24';'25';'26';'27';'28';'29';'30'}; %list of subj numbers to be usedfor subj=1:30

sub=[];
nback=[];
gbvs=[];
lsa=[];
glove=[];

for subj=1:30  
    sub = [sub;repmat(subj,100,1)];
    nback = [nback;AUC.(['Sub' char(subjectNums(subj))]).nBack'];
    gbvs = [gbvs;AUC.(['Sub' char(subjectNums(subj))]).gbvs_CB'];
    lsa = [lsa;AUC.(['Sub' char(subjectNums(subj))]).lsa'];
    glove = [glove;AUC.(['Sub' char(subjectNums(subj))]).glove'];
end

t1=table(sub,nback,gbvs,lsa,glove)

%alternate
salsem=[]
val=[]

for subj=1:30  
    sub = [sub;repmat(subj,300,1)];
    nback = [nback;repmat(AUC.(['Sub' char(subjectNums(subj))]).nBack',3,1)];
    salsem = [salsem;repmat("gbvs",100,1);repmat("lsa",100,1);repmat("glove",100,1)];
    val = [val;AUC.(['Sub' char(subjectNums(subj))]).gbvs_CB';AUC.(['Sub' char(subjectNums(subj))]).lsa';AUC.(['Sub' char(subjectNums(subj))]).glove'];
end

t2=table(sub,nback,salsem,val)