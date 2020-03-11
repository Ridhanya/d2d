% Tcond = arLoadCondPEtab(expcondfilename)
%
% This function can be used to process experimental condition files in the format of PEtab.
%
%   expcondfilename    name of file.
%
% In this data format, there is one .tsv-file that contains the info about
% the experimental conditions. This should be called before arCompile.
% This data format shall allow easier transitions between modeling
% tools.
%
% See also arLoadDataPEtab
%
% References
%   - https://github.com/ICB-DCM/PEtab/blob/master/doc/documentation_data_format.md
%

function Tcond = arLoadCondPEtab(expcondfilename)

global ar;

if ~contains(expcondfilename,'.tsv')
    if ~contains(expcondfilename,'.')
        expcondfilename = [expcondfilename '.tsv'];
    else
        error('this file type is not supported!')
    end
end

%% Read in tsv file
T = tdfread(expcondfilename); % all data of the model
fns = fieldnames(T);
for i = 1:length(fns)
    if ischar(T.(fns{i}))
        T.(fns{i}) = regexprep(string(T.(fns{i})),' ','');
    end
end

if ~isfield(T,'conditionId')
    T.conditionId = T.conditionID;
end

for m = 1:length(ar.model)
    for i = 1:length(T.conditionId)
        for j = 1:length(ar.model(m).data)
            if strcmp(ar.model(m).data(j).name,T.conditionId(i))
                for k = 2:(length(fns))
                    % Check if parameter is replaced by condition
                    if sum(contains(ar.model(m).data(j).fp,fns{k}))>0    % changed p to fp to catch cases in which initial value was renamed from a0 to init_A_state
                        ar.model(m).data(j).fp{ismember(arSym(ar.model(m).data(j).fp), arSym(fns{k}))} = ...
                            num2str(T.(fns{k})(i));
                    % Check if initial state is set by condition
                    elseif any(strcmp(ar.model(m).xNames,fns{k}))
                        InitialsSet = strcmp(ar.model(m).xNames,fns{k});
                        if sum(InitialsSet) > 1
                            error('Problem in finding right initial state set in condition table!')
                        end
                        initialVariable = ar.model(m).px0{InitialsSet};
                        InitialDataVariableIndex = strcmp(initialVariable, ar.model(m).data(j).p);
                        ar.model(m).data(j).fp{InitialDataVariableIndex} = num2str(T.(fns{k})(i));
                    end
                end
            end
        end
    end
end

Tcond = struct2table(T);
end