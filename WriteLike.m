%% Open text files to an array & preprocess them 
%This section loads all the texts from the array tt
%then process them - take of numbers, punctuation marks, standarsize to
%lower case and drop empty cells.
%then a corpus is being created from the words that were used in the first
%13000 words of each book. 
clearvars

%all writers - only full books - shows how close are the authors to each
%one (using 1 book from each)
tt={'Huxley_Brave_new_world_full.txt', 'Orwell_1984FULL.txt', 'Twain_Tom_Sawyer_full.txt', 'Austin_Pride.txt', 'Doyle_Holmes.txt', 'Dickents_two_cities.txt', 'Tolkien_Lordoftherings.txt', 'Salinger_Catcher.txt', 'Fitzgerald_Gatsby.txt' }; %array with all text names

disp('our authors:')
strtok(tt(1:(length(tt))),'_')
disp('and you!')
%if exist('Me_MyText.txt','file')
 %   tt(length(tt)+1)={'Me_MyText.txt'};
%end

for some=1:length(tt)
    howmuch=13000;
    howmuch2=howmuch;
    textvar=(textread(tt{some}, '%s'))'; %load the text
    disp(length(textvar));
    %pre-processing of the text
% standardize to lowercase
            textvar = lower(textvar);
% remove numbers
            textvar = regexprep(textvar, '[0-9]+','');
% remove  punctuations marks
            textvar=regexprep(textvar,'[^a-zA-Z0-9]','');
 % drop empty cells
            textvar=textvar(~cellfun('isempty',textvar));
            lengthi(some)=length(textvar);
%if howmuch>length(textvar)
 %       howmuch2=length(textvar);
  %  end
    textvar=textvar(1,1:howmuch2);
    if some==1
        corpus=textvar;  % add to corpus
        textmat=textvar;  % add to text memory
    else
        corpus=[corpus textvar];  % add to corpus
        corpus=unique(corpus); %delete duplicated words
        textmat(some,1:length(textvar))= textvar; % add to text memory
    end
end

%% TF-IDF and PCA 
%this section uses 13000 words from each book (or what was defined in
%the previous section) create a TF-IDF table using the corpus from the last section
%and then does PCA to reduce to two dimensions and present the differences
%between the authors (and you) on a table.
%the next section does an online feedback, so if you are in
%writing mode now - you can just skip to it!

%now for tf-idf 
TF=zeros(length(tt),length(corpus)); 
IDF=zeros(1,length(corpus));
for g=1:length(tt)
 textnow=textmat(g,1:end);
 textnow=textnow(~cellfun('isempty',textnow)); %clear empty cell for the ismember to work
 Rep_textnow = repmat(textnow,length(corpus),1);
 Rep_corpus = repmat(corpus',1,size(textnow,2));
 TF(g,:) = sum(strcmp(Rep_corpus,Rep_textnow),2)'/length(textnow);
 IDF=ismember(corpus,textnow)+IDF;
 appear=IDF;
end
for L=1:length(IDF)
    IDF(L)=log(length(tt)/IDF(L));
end
TF_IDF=zeros(length(tt),length(corpus));
for j=1:length(tt)
    TF_IDF(j,:)=zscore(TF(j,1:end).*(IDF));
end
%use the data to do PCA and plot the first two columns of "scores" 
 [~,scores,pcvars]=princomp(TF_IDF);
 labels2=strtok(tt(1:(length(tt))),'_');
 x=scores(:,1);
 y=scores(:,2);

scatter(x,y,'w','filled');
text(x(1:(length(x))),y(1:(length(y))),labels2,'color','b','fontsize',14);



%% do pca with my text- one time only
textvar2=(textread('Me_MyText.txt', '%s'))';        
% standardize to lowercase
        textvar2 = lower(textvar2);
% remove numbers
        textvar2 = regexprep(textvar2, '[0-9]+','');
% remove punctuations marks
        textvar2=regexprep(textvar2,'[^a-zA-Z0-9]','');
 % drop empty cells
        textvar2=textvar2(~cellfun('isempty',textvar2));

textvar3=unique(textvar2); %actually, its sort of a new corpus
TFIDFNEW=zeros(length(lengthi)+1, length(textvar3));
IDFNEW=zeros(1,length(textvar3));
TFNEW=zeros(length(lengthi),length(textvar3));
[yesno place]= ismember(textvar3,corpus);
for i=1:length(yesno)
    if yesno(i)==1
         IDFNEW(1,i)=log((length(lengthi)+1)/(appear(place(i))+1));
         TFNEW(1:length(lengthi),i)=TF(:,place(i));
    else
        IDFNEW(1,i)= log((length(lengthi)+1));
    end
end

%Adding the TF values of my text to the TFNEW matrix
textnow=textvar2;
 textnow=textnow(~cellfun('isempty',textnow)); %clear empty cell for the ismember to work
Rep_textnow = repmat(textnow,length(textvar3),1);
Rep_corpus = repmat(textvar3',1,size(textnow,2));
TFNEW(length(lengthi)+1,:) = sum(strcmp(Rep_corpus,Rep_textnow),2)'/length(textnow);

%creating ne TF_IDF matrix
    TF_IDFNEW=zeros(length(lengthi)+1,length(textvar3));
for j=1:(length(lengthi)+1)
    TF_IDFNEW(j,:)=zscore(TFNEW(j,1:end).*(IDFNEW));
end

%PCA and plotting
[~,scores,pcvars]=princomp(TF_IDFNEW);
 labels2=strtok(tt(1:(length(tt))),'_');
 x=scores(:,1);
 y=scores(:,2);

scatter(x,y,'w','filled');
text(x(1:(length(x)-1)),y(1:(length(y)-1)),labels2,'color','b');
text(x(length(x)),y(length(y)),'Me','color','r','fontsize',18,'FontWeight','bold');


%% update with changes in the document
% Now use timer to check every 30 seconds if there was a change in the
% document. in order to start, write "start(WriteLike)" in matlab main
% window. to stop, write "stop(WriteLike)".
% Here, the program uses the length of your text for the TF-IDF and the PCA
% and not a pre-defined number.
disp('please write start(WriteLike) in order to start')
WriteLike=timer('TimerFcn', @(h,~)onTimerCallback_new(corpus,tt,lengthi,appear,TF), 'Period', 20, 'ExecutionMode', 'fixedRate','busymode','drop','TasksToExecute',100);
