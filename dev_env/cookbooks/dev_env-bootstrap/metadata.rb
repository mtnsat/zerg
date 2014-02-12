maintainer       "MTN Sattelite Communications"
maintainer_email "andres.rojas@mtnsat.com"
description      "(Hacky) bootstrap for setting up a proper dev_env for Zergrush"
version          "0.1"

depends "apt"
depends "build-essential"
depends "kvm"
depends "libvirt"

execute "generate ssh skys for ubuntu." do
    user username
    creates "/home/ubuntu/.ssh/id_rsa.pub"
    command "ssh-keygen -t rsa -q -f /home/ubuntu/.ssh/id_rsa -P \"ubuntu\""
end