# Docker

## Manager

    $ ssh 192.168.204.21 "curl -fsSL https://get.docker.com/ | sh"
    $ ssh 192.168.204.21 "sudo usermod -aG docker yuanying"
    $ ssh 192.168.204.21 "docker swarm init --advertise-addr 192.168.204.21"

## Worker

    $ ssh 192.168.204.31 "curl -fsSL https://get.docker.com/ | sh"
    $ ssh 192.168.204.31 "sudo usermod -aG docker yuanying"
    $ ssh 192.168.204.31 "docker swarm join \
        --token SWMTKN-1-1c0x57y6iptkoc931997bwvaohkxoh7sf0jp9jdwurbi3l18qy-ef1jpiwrwsqgdd01vn5024c6l \
        192.168.204.21:2377"
