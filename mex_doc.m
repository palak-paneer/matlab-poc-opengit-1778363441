% Bugcrowd PoC — MEX native-code escalation path (documentation only)
% A real attacker would ship a precompiled .mexa64 (Linux x86_64) Shared Object
% with mexFunction symbol calling system()/exec()/dlopen() before MATLAB
% sandboxing applies. Loading happens on first call; native code runs in the
% MATLAB process. This is a code-drop primitive that bypasses MATLAB's JIT
% sandbox and gives raw native execution surface for kernel-level attacks
% against the AWS 6.8.0-1024 kernel.
disp('See README.md for MEX escalation details');
