# Packer Boxes

The project contains some experiments in creating boxes for different platforms.



Some of the boxes here are used as base for the environments created in https://github.com/danielehc/consul_labs



## Folder content

* #### debian9-stretch

  Contains definitions for  creating a Debian 9 image for Virtualbox.

  Requires Packer to work (https://www.packer.io/).

  A ready to use version of this image can be found at https://app.vagrantup.com/danielec/boxes/stretch64

* #### docker

  Contains definitions to create a Vagrant box using the Virtualbox image created in the **debian9-stretch** lab that contains the scripts necessary to create a new Docker image from scratch and to build new ones using that as a base.


