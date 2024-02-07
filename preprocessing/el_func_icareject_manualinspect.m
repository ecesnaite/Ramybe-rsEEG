function EEG = el_func_icareject_manualinspect(EEG, n_comp)

% assignin('base', 'EEG', EEG);
[EEG] = pop_selectcomps(EEG,n_comp);

% wait for decision
comp_handles = findobj('-regexp', 'tag', '^selcomp.*');
while true %
    try
        waitforbuttonpress
    catch
        if ~any(isgraphics(comp_handles))
            break
        end
    end
end

% This line is important for updating the list of rejected and re-accepted
% ICs!
EEG.reject.gcompreject = evalin('base', 'ALLEEG(end).reject.gcompreject');

