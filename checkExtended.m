clc
clear all

nodes=analyzeExtended(1);

terminal=0;
for k=1:length(nodes)
    if isempty(nodes(k).children)
        terminal=terminal+1;
    end
end
terminal