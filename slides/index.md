
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
--- 
### Installing software on Linux

Let's install `mariadb` on `ubuntu`:

Following [DigitalOcean tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-ubuntu-20-04)

```bash
sudo apt update -y
sudo apt install mariadb-server -y
sudo systemctl start mariadb.service
sudo mysql_secure_installation
```

---
### Explain ansible concepts

- [This URL](https://docs.ansible.com/ansible/latest/getting_started/basic_concepts.html#control-node)


---
### Control node vs managed nodes 


---
### Playbooks

- What is a task?
- What are handlers?
- What is a playbook?
- What is a role?


---
### Getting started with ansible

```bash
pip install ansible
```

---
### Ansible inventory

```yaml
leafs:
  hosts:
    leaf01:
      ansible_host: 192.0.2.100
    leaf02:
      ansible_host: 192.0.2.110

spines:
  hosts:
    spine01:
      ansible_host: 192.0.2.120
    spine02:
      ansible_host: 192.0.2.130

network:
  children:
    leafs:
    spines:
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
# Join us

`join@dragonsec.si`

<img src="./img/DragonSec_logo.png" alt="logo" title="Logo" width="300"/> 

