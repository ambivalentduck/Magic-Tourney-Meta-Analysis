function node=analyzeExtended(varargin)

if ~isempty(varargin)
    tol=varargin{1};
else
    tol=5; %Decks within an archetype are within tol cards of one another
end

%Preprocessing decklists in a text-oriented language saves a lot of time
load names;
load matrix;

global scores original
scores=matrix(:,1); %#ok<NODEF>
matrix=matrix(:,2:end);
original=matrix;

siz=size(matrix);
ave=mean(matrix,1);

cmatrix=matrix;
for k=1:siz(2)
    cmatrix(:,k)=cmatrix(:,k)-ave(k);
end

node(1).parent=0;
node(1).umbrella=1:siz(1);
nodes=1;

[node,nodes]=branch(node,nodes,1,matrix,tol);

figure(1)
treeplot([node.parent])

for k=1:length(node)
    fid=fopen(['./web/node',num2str(k),'.dat'],'wt');
    fprintf(fid,'Parent: %g\n',node(k).parent);
    if ~isempty(node(k).children)
        fprintf(fid,'Children: %g %g\n',node(k).children(1),node(k).children(2));
    else
        fprintf(fid,'Children: \n');
    end
    fprintf(fid,'Score: %g+/-%g\n',node(k).score(1),node(k).score(2));
    fprintf(fid,'Decision:\n');
    fnd=find(node(k).decision);
    [srt,I]=sort(node(k).decision(fnd));
    for kk=1:length(fnd)
        fprintf(fid,['%g ',names{fnd(I(kk))},'\n'],srt(kk));
    end
    fprintf(fid,'Composite:\n');
    fnd=find(node(k).composite);
    [srt,I]=sort(node(k).composite(fnd));
    for kk=1:length(fnd)
        fprintf(fid,['%g ',names{fnd(I(kk))},'\n'],srt(kk));
    end
    fprintf(fid,'Decks:\n');
    for kk=1:length(node(k).umbrella)
        fprintf(fid,'%g\n',node(k).umbrella(kk));
    end
    fclose(fid);
end

end

function [node, nodes]=branch(node, nodes, target, matrix, tol)
global scores original
[coeff,score,latent]=princomp(matrix);
node(target).coeff=coeff(:,1);
node(target).vals=score(:,1);
node(target).score=[mean(scores(node(target).umbrella)),std(scores(node(target).umbrella))];
node(target).composite=mean(original(node(target).umbrella,:));
node(target).composite=node(target).composite.*(node(target).composite>1);
node(target).decision=coeff(:,1).*(abs(coeff(:,1))>max(abs(coeff(:,1)))*.3);

[trash,m]=min(score(:,1));
[trash,M]=max(score(:,1));

%norm((matrix(m,:)-matrix(M,:)).*coeff(:,1)')>tol %Differ along the principle component
%sum(abs(matrix(m,:)-matrix(M,:)))>tol %Total cards difference


if sum(abs((matrix(m,:)>0)-(matrix(M,:)>0)))>tol %Differ by more than tol card *names*
    f=find(score(:,1)>0);
    g=find(score(:,1)<=0);
    if length(node(target).umbrella)-(length(f)+length(g))
        disp 'Oh crap'
    end
    nodes=nodes+2;
    next1=nodes;
    node(target).children=[next1-1 next1];
    node(nodes-1).parent=target;
    node(nodes).parent=target;
    node(nodes-1).umbrella=node(target).umbrella(f);
    node(nodes).umbrella=node(target).umbrella(g);
    cmatrix=matrix(f,:);
    for k=1:size(cmatrix,1);
        cmatrix(k,:)=cmatrix(k,:)-dot(cmatrix(k,:),coeff(:,1))*coeff(:,1)';
    end
    [node,nodes]=branch(node,nodes,nodes-1,cmatrix,tol);
    cmatrix=matrix(g,:);
    for k=1:size(cmatrix,1);
        cmatrix(k,:)=cmatrix(k,:)-dot(cmatrix(k,:),coeff(:,1))*coeff(:,1)';
    end
    [node,nodes]=branch(node,nodes,next1,cmatrix,tol);
end

end