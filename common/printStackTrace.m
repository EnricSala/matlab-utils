function [  ] = printStackTrace( exception )
disp('# ----- MWException -----')
disp(['# Identifier: ' exception.identifier])
disp(['# Message: ' toSingleLine(exception.message)])
disp('# Stacktrace:');
stack = exception.stack;
for i = 1:length(stack)
    disp(['#    Error in: ' stack(i).name ', line: ' num2str(stack(i).line)]);
end
end

function [ single ] = toSingleLine( multi )
result = strrep(inputString, sprintf('\n'), ' ');
end
