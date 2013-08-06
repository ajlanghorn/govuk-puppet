# Developing on GDS Virtual Machines

Welcome to GDS. The following instructions show you how to get your
development environment running.

## 0. Context

Our development environment is an Ubuntu virtual machine with a view
to achieving [dev-prod parity][1]. By default, the steps below will
set you up with a [VirtualBox][2] VM, managed and configured by
[Vagrant][3]. If you feel strongly about using another piece of
software (such as VMWare) for your development VM, you may find
instructions for doing so [on the wiki][4].

Either way, you will need virtualisation enabled in your BIOS, otherwise it
won't work. This tends to be enabled by default on Macs, but is worth
checking for other manufacturers.

[1]: http://www.12factor.net/dev-prod-parity
[2]: https://www.virtualbox.org/
[3]: http://vagrantup.com/
[4]: https://github.com/alphagov/wiki/wiki

## 1. Prerequisites and assumptions

  * You have [VirtualBox](https://www.virtualbox.org/) installed
  * You have an account on [GitHub.com](https://github.com)
  * You have an account on
    [GDS's GitHub Enterprise](https://github.gds) and you can see the
    [Puppet repository](https://github.gds/gds/puppet) (which you can,
    because you're reading this)
  * You have [Vagrant 1.2](http://downloads.vagrantup.com/) or greater
    installed - these instructions may work with older versions, but
    they're not officially supported
  * You have some other repositories from GDS checked out to work on -
    these should be located alongside the `puppet` repository we're in
    now (e.g `~/govuk/puppet:~/govuk/frontend`)

### A note on Boxen

If you have a GDS issued laptop and you want to automate most of this,
consider building your laptop using
[GDS Boxen](https://github.com/alphagov/gds-boxen). Specifically
you'll want these things:

    include vagrant
    include virtualbox
    vagrant::plugin { 'vagrant-dns': }
    include projects::puppet

## 2. Booting your VM

Assuming your Puppet code is checked out into:

    ~/govuk/puppet

the following commands will bootstrap your VM:

    cd ~/govuk/puppet/development
    ./bootstrap.sh

and follow the instructions. Your machine will be automatically
provisioned so you shouldn't have to do anything once it's finished.

Once your VM is running you should be able to SSH into it:

    vagrant ssh

and that's it. Now you can get to work!

## Extras

* Your VM comes pre-configured with an IP address. This is visible in
  the [Vagrantfile](./Vagrantfile) (but currently defaults to `10.1.1.254`)
* If you want to add extra RAM, you can do so in a
  `Vagrantfile.localconfig` file in this directory, which is
  automatically read by Vagrant (don't forget to re-run `vagrant
  up`!):

        $ cat ./Vagrantfile.localconfig
        config.vm.provider :virtualbox do |vm|
          vm.customize [ "modifyvm", :id, "--memory", "1024", "--cpus", "2" ]
        end

* If you want to be able to SSH into your VM directly, add the
  following to your `~/.ssh/config`:

        Host dev
          User vagrant
          ForwardAgent yes
          IdentityFile ~/.vagrant.d/insecure_private_key
          HostName 10.1.1.254
          StrictHostKeyChecking no
          UserKnownHostsFile=/dev/null

* To re-run Puppet, just SSH into your VM and run `govuk_puppet`.