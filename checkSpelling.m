function suggestion = checkSpelling(word,h)
%CHECKSPELLING  uses MSWord to correct spelling
%   CHECKSPELLING(WORD) checks the spelling of WORD
%Start the Word ActiveX Server and check the spelling of WORD

% h = actxserver('word.application');
% h.Document.Add;
correct = h.CheckSpelling(word);
if correct
    for i = 0:9
        nums = num2str(i);
        string_has_numeric = contains(word,nums); %if word has any number in it
        if string_has_numeric == 1 
            suggestion = []; %remove it
            break %stop the loop if number is found
        else
        suggestion = word; %keep the word if it's a word
        end
    end
else
    %If not a word, remove it
    suggestion = [];
end
%Quit Word to release the server
% try
%     h.Quit
% catch
%     disp('cannot quit word')
% end
