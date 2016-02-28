function onTimerCallback(corpus,tt,lengthi,appear,TF)
textvar2=(textread('Me_MyText.txt', '%s'))';
disp('Last refresh was at:')
c = num2cell(clock);
disp(datestr(datenum(c{:})));

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
text(x(1:(length(x)-1)),y(1:(length(y)-1)),labels2,'color','b','fontsize',14);
text(x(length(x)),y(length(y)),'Me','color','r','fontsize',18,'FontWeight','bold');


end