
###  Linux automation and hardening

<img src="./img/DragonSec_logo.png" alt="logo" title="Logo" width="300"/> 

Ljubljana FRI, April 2024

---
### Who are we?

<style>
.container{
    display: flex;
}
.col{
    flex: 1;
}
</style>

<div class="container">
    <div class="col">
        <div style="display: flex; align-items: center;"><img src="./img/github-light.png" alt="logo" title="Logo" width="50" style="margin-right: 10px;" /><b>DragonSec SI</b> </div>
        <div style="display: flex; align-items: center;"><img src="./img/twitter-light.png" alt="logo" title="Logo" width="50" style="margin-right: 10px;" /><b>@DragonSec_SI</b> </div>
        <div style="display: flex; align-items: center;"><img src="./img/mail-light.png" alt="logo" title="Logo" width="50" style="margin-right: 10px;" /><b>info@dragonsec.si</b> </div>
    </div> 
    <!-- .element: style="width: 100%;" -->
    <div class="col">
        <img src="./img/about-us.jpg" alt="logo" title="Logo" width="400"/> 
    </div>
</div>


---
### Os hardening

---
### File permissions

- `/usr/local/sbin`
- `/usr/local/bin`
- `/usr/sbin`
- `/usr/bin`
- `/sbin`
- `/bin`

---
### File permissions

```
find -L /bin -perm /go+w -type f
sudo chmod g+w /bin/cat
ls -lah /bin/cat
```

---
### FIle statistics

```bash
root@ubuntu-server-1:/var/log/audit# stat /etc/hosts
  File: /etc/hosts
  Size: 314             Blocks: 8          IO Block: 4096   regular file
Device: fd00h/64768d    Inode: 2228244     Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    4/     adm)
Access: 2024-04-09 17:45:41.220226168 +0000
Modify: 2024-04-09 17:45:41.108262181 +0000
Change: 2024-04-09 17:45:41.108262181 +0000
 Birth: 2024-01-07 04:33:17.446119191 +0000
```

---
### SUDO

- `/etc/sudoers/`
- `/etc/sudoers.d`

```bash
EDITOR=vim sudo visudo
```

---
### SYSTEMD

- Manages services and daemons
    - `systemctl start / stop/ disable / status/ enable`
- Also takes care of logging 
    - `journalctl -b`
    - `journalctl -u sshd`
    - `journalctl -u sshd -f`

---
### Password / group files

- `/etc/passwd`
- `/etc/group`
- `/etc/shadow`

```bash
lsattr /etc/passwd
chattr +i /etc/passwd
```

---
### Restrictions to system directories

```
sudo chmod -R 755 /boot
sudo chmod 755 /run
sudo chmod -R 755 /dev
sudo chmod 1777 /dev/shm
sudo chmod 1777 /tmp
```

Note:

`/boot`:
Contents: Contains boot loader files, such as kernels, initrd images, and configuration files necessary for the boot process.
Why restrict?: Unauthorized modifications could compromise the boot process or the kernel, leading to security breaches or system instability.
Recommended Permissions: Only root should have write access. Other users should have read access only to ensure they can read necessary configuration details without altering them.

`/run`:
Contents: Runtime data, like process IDs and lock files, since the last boot.
Why restrict?: Access to these could allow unauthorized users to interfere with running processes.
Recommended Permissions: Should be writable by root and readable by others, but specific subdirectories may have more restricted access.


`/dev`: 
Contents: Device files representing hardware components and other system devices.
Why restrict?: Improper access or modification of device files can lead to system instability, data corruption, or security vulnerabilities.
Recommended Permissions: The root user and specific groups (like dialout for serial ports, video for graphics devices) should have write access. Most users only need read access.

The sticky bit (1 in 1777) ensures only the owner can delete or modify their own files, despite the directory being writable.


---
### SUID bit 

```bash
find / -xdev \( -perm -4000 -o -perm -2000 \) -type f ! -path \
    '/proc/*' -print 2>/dev/null
```

```
[dsec@dsec ~]$ ls -l /home/dsec/secret 
-rwsr-xr-x. 1 root root 33333 Dec 42  2027 /home/dsec/secret
```
A file with SUID always executes as the user who owns the file, regardless of the user passing the command. If the file owner doesn't have execute permissions, then use an uppercase S here.

---
### SGID bit


```
[dsec@dsec ~]$ ls -l /home/dsec/secret2
drwxrws---. 1 dsec dsec 33333 Dec 42  2027 /home/dsec/secret2
```

- If set on a file, it allows the file to be executed as the group that owns the file (similar to SUID)
- If set on a directory, any files created in the directory will have their group ownership set to that of the directory owner


---
### Coredumps

```
- name: Create additional limits config file
  community.general.pam_limits:
    dest: /etc/security/limits.d/10.hardcore.conf
    domain: "*"
    limit_type: hard
    limit_item: core
    value: "0"
  when: not ansible_check_mode
```
Prevent core dumps for all users. These are usually not needed and may contain sensitive information.

---
### Firewall / databases / services

- `iptables`
- `mariadb`
- `postgresql`
- `nginx`
- `apache`
- `docker` - Ales Brelih will cover this

`linpeas.sh` !!!!

---
### Auditd

```bash
sudo apt install auditd
sudo systemctl enable --now auditd
/var/log/audit/audit.log
```

**SIEM** ready

---
### Auditd

```bash
auditctl -w /etc/passwd -p warx -k user-info-access
auditctl -a always,exit -F arch=b64 -S setuid -k setuid-call
```

Note:

Configuration: The system administrator configures auditd by setting up rules that define which actions and events should be audited. 
These rules can be specified for system calls, file accesses, modifications, and more.

Event Monitoring: Once configured, auditd monitors the system for any actions or events that match the audit rules.
It can capture a wide range of information, including the type of event, the time it occurred,
the user responsible for the event, the success or failure of the event, and more.

Logging: When an event matches an audit rule, auditd logs detailed information about the event to the audit log files, 
typically located in /var/log/audit/. These log entries provide a trace of the monitored activities for later review.

Analysis: Audit logs can be analyzed manually by system administrators or using automated tools to detect anomalies, 
unauthorized actions, or non-compliance with policies. This analysis can help in forensic investigations, compliance audits, 
and improving system security.


---
### Kernel parameters

- `sysctl`
- `/etc/sysctl.conf`
- `/etc/sysctl.d/`

```bash
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p
sysctl -w net.ipv6.conf.all.disable_ipv6=1 # quick change 
```

---
### Kernel modules

- `kernel.kexec_load_disabled` - prevent loading new kernel images
- `kernel.modules_disabled` - prevent loading new kernel modules


---
### Kernel Address Space Layout Randomization (KASLR) 

- `kernel.kptr_restrict` - restrict access to kernel pointers (2 max)
- `kernel.randomize_va_space` - randomize memory layout (2 max)


Note:

`kernel.kptr_restrict`: This controls the visibility of kernel symbols to users, with 2 being the most restrictive setting, 
hiding kernel addresses even from root, complicating attacks that rely on knowledge of kernel internals.

`kernel.randomize_va_space`: Set to 2 for the maximum level of address space layout randomization, 
making it harder for attackers to predict memory addresses and exploit memory corruption vulnerabilities.

---
### Address Space Layout Randomization (ASLR) 

- `vm.mmap_rnd_bits` - randomize mmap base address
- `vm.mmap_rnd_compat_bits` - randomize mmap base address for 32-bit processes

---
### Protecting files 

- `fs.protected_hardlinks` - restrict hardlink creation to the file owner
- `fs.protected_symlinks` - restrict symlink creation to the file owner
- `fs.protected_fifos` - restrict FIFO only to the file owner
- `fs.protected_regular` - restrict regular files only to the file owner

Note:
`fs.protected_hardlinks` and `fs.protected_symlinks`: 
When set to 1, these options prevent users from creating hard links to files they do not own or to which they have no write access, 
and from following symlinks that could lead to similar privilege escalation through race conditions, respectively. 
This mitigates a class of time-of-check-time-of-use (TOCTOU) vulnerabilities, often exploited through /tmp file races.

`fs.protected_fifos` and `fs.protected_regular`: 
 These control the creation of FIFO special devices and regular files, 
 reducing the risk of certain types of privilege escalation attacks by 
 restricting how these files can be created in world-writable directories.

---
### ICMP

- `net.ipv4.icmp_echo_ignore_broadcasts`  
- `net.ipv4.icmp_echo_ignore_all` 
- `net.ipv4.icmp_ignore_bogus_error_responses`  
- `net.ipv4.icmp_ratelimit` 
- `net.ipv4.icmp_ratemask` 


Note:

`net.ipv4.icmp_echo_ignore_broadcasts`: Ignores ICMP echo requests to broadcast addresses, 
mitigating the risk of amplification attacks that could be used in denial of service (DoS) attacks.

`net.ipv4.icmp_ignore_bogus_error_responses`: Prevents the logging of bogus ICMP error responses, 
which could be used by attackers to fill disk space with log entries or to cause other types of mischief.

`net.ipv4.icmp_ratelimit` and `net.ipv4.icmp_ratemask`: These control the rate limit and type of ICMP messages 
the system will process. Limiting ICMP traffic helps mitigate the risk of ICMP flood attacks.


---
### IP Forwarding & Reverse path filtering

- `net.ipv4.ip_forward` 
- `net.ipv4.conf.all.accept_redirects` 
- `net.ipv4.conf.all.send_redirects`
- `net.ipv4.conf.all.rp_filter`

Note:

`IP Forwarding`
`net.ipv4.ip_forward` and `net.ipv6.conf.all.forwarding`: These control the forwarding of packets at the IP level. 
Disabling IP forwarding (0) ensures that a system does not act as a router, which is a recommended security measure for most end-user devices and 
servers that do not intentionally route packets.

`Reverse Path Filtering`
`net.ipv4.conf.all.rp_filter` and `net.ipv4.conf.default.rp_filter`: Enable reverse path filtering 
to prevent IP spoofing attacks by verifying that 
the source address of received packets is reachable through the interface they came from. 
This is a mechanism against certain types of network attacks, including source address spoofing.


---
### ARP

- `net.ipv4.conf.all.arp_ignore`
- `net.ipv4.conf.all.arp_announce`

Note:
`net.ipv4.conf.all.arp_ignore` and `net.ipv4.conf.all.arp_announce`: These settings adjust the response behavior to ARP requests and 
the announcement strategy, mitigating ARP spoofing/poisoning attacks.

---
### SSH hardening

---
### SSHD configuration options

```
PermitEmptyPasswords no
PermitRootLogin no
PasswordAuthentication no
AllowUsers user1 user2
AllowGroups group1 group2
ClientAliveInterval 300 # Set timeout
X11Forwarding no
```

Note:

Timeout prompt after 5min of inactivity, if no response, the connection will be closed.

---
### Fail2ban

```bash
sudo apt install fail2ban
sudo systemctl enable --now fail2ban
```

Configure in `/etc/fail2ban/jail.local`

---
--- 
### Installing software on Linux

Let's install `mariadb` on `ubuntu`:

Following [Digital Ocean tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-ubuntu-20-04)

```bash
sudo apt update -y
sudo apt install mariadb-server -y
sudo systemctl start mariadb.service
sudo mysql_secure_installation
```

---
###  Ansible 

<img src="./img/ansible_inv_start.svg" alt="inv_start" title="inv_start" width="500"/>

---
### Playbooks

- What is a task?
- What are handlers?
- What is a playbook?
- What is a role?

---
### Getting started with ansible

```bash
python3 -m venv .venv
. .venv/bin/activate
pip install ansible
```

---
### Ansible inventory

```yaml
dmz:
  hosts:
    web_server:
      ansible_host: 192.168.121.67
      ansible_port: 22
      ansible_user: vagrant
      ansible_private_key_file: 'pk_path'
    ....
internal:
  hosts:
    auth_server:
      ansible_host: 192.168.121.105
      ansible_port: 22
      ansible_user: vagrant
      ansible_private_key_file: 'pk_path'
    ....

```

Note: Here we can se an example of ansible inventory file.

---
### Ansible inventory

```bash
λ ansible all -m ping -i inventory.ini
ubuntu-server-4 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
ubuntu-server-5 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
...
```

Note: Testing the connection to all hosts in the inventory file.

---
### Writing ansible playbook

```yaml
- name: My first play
  hosts: all 
  tasks:
   - name: Ping my hosts
     ansible.builtin.ping:

   - name: Print message
     ansible.builtin.debug:
      msg: Hello world

```
---
### Running our first ansible playbook

```bash
λ ansible-playbook -i inventory.ini playbooks/first_play.yml
```

Or just limit to one host:
```bash
λ ansible-playbook -i inventory.ini  --limit="ubuntu-server-2" playbooks/first_play.yml
```

---
### LIVE DEMO

- Ansible inventory, running our first playbook, installing database
- Checking out ansible os hardening role

```
git clone https://github.com/dev-sec/ansible-collection-hardening.git
```

---
# Join us

`join@dragonsec.si`

<img src="./img/DragonSec_logo.png" alt="logo" title="Logo" width="300"/> 

