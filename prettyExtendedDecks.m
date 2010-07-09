function prettyExtendedDecks()

%Preprocessing decklists in a text-oriented language saves a lot of time
load names;
load matrix;

matrix=matrix(:,2:end);

siz=size(matrix);

for k=1:siz(1)
    fid=fopen(['./web/deck',num2str(k),'.dat'],'wt');
    f=find(matrix(k,:));
    for kk=1:length(f);
        fprintf(fid,['%g ',names{f(kk)},'\n'], matrix(k,f(kk)));
    end
    fclose(fid);
end
    