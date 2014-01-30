Zerg
=========

Zerg is a tool for launching an arbitrary number of virtual machines and running a task on all of them at once. 

  - Intended for use on a linux host
  - Mac users can test through another VM-based dev environment
  - Written in ruby
  - JSON config files
  - *Will support several hypervisors* (VirtualBox, KVM, LXC)

Version
----

1.0

Tech
-----------

Zerg uses a number of open source projects to work properly:

* [Packer] - tool for building identical machine images from single source file
* [Vagrant] - tool for building complete development environments
* [Chef Solo] - Open source utility for using Opscode Chef cookbooks without access to a server
* [Ruby] - Ruby programming language

Develop (OSX)
--------------
Install [Vagrant]. Then:

```sh
git clone git@github.com:MTNSatelliteComm/zerg.git zerg
cd zerg/dev_env
vagrant up --provision
vagrant ssh
cd /zerg
```

Use
--------------

TBD

  - *zerg hive init*
  - *zerg hive verify*
  - *zerg hive list*
  - *zerg status*
  - *zerg rush [task]*
  - *zerg stop [task]*


Environment variables
--------------

  - HIVE_CWD - location of hive folder. If not defined - $(pwd)/hive
  

[Vagrant]:http://wwww.vagrantup.com
[Packer]:http://www.packer.io
[Chef Solo]:http://docs.opscode.com/chef_solo.html
[Ruby]:https://www.ruby-lang.org