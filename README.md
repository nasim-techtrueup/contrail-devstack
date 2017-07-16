contrail-devstack
==================

contrail-devstack is a set of scripts and utilities to quickly 
build, install, configure and deploy OpenContrail + Devstack

# Versions

The contrail-devstack master branch generally points to trunk versions 
of OpenContrail components and newton branch of devstack

# localrc

contrail-devstack installer uses ``localrc`` to contain all local configuration
and customizations.  Best to start with a sample localrc.

    cd contrail-devstack
    cp samples/localrc-all localrc

# OpenContrail script

install.sh is the main script that supports following options:

    build     ... to build OpenContrail
    Install   ... to Install OpenContrail
    configure ... to Configure & Provision 
    start     ... to Start OpenContrail + Devstack Modules
    stop      ... to Stop OpenContrail + Devstack Modules
    restart   ... to Restart OpenContrail Modules without resetting data

# Launching OpenContrail + devstack

Run the following NOT AS ROOT:

    cd contrail-devstack
    cp samples/localrc-all localrc (edit localrc as needed)
    ./install.sh build
    ./install.sh install
    ./install.sh configure
    ./install.sh start

# Verify installation
    1) screen -x contrail and run through various tabs to see various contrail modules are running
    2) Run utilities/contrail-status to see if all services are running
    3) screen -x stack and run through various tabs to see various devstack modules are running

# Rebuild installation with new changes
make required changes to contrail or devstack and trigger rebuild using
    ./install.sh rebuild

# Running Contrail sanity
Note that default sample localrc enables simple gateway. A script is available that will
create a virtual network, launch two VMs, ping each VM from host and then SSH into it.
Follow the steps below:

    cd ~/contrail-devstack/contrail-installer/utilities
    export CONTRAIL_DIR=~/contrail-devstack/contrail-installer
    export DEVSTACK_DIR=~/contrail-devstack/devstack
    ./contrail-sanity

# Opencontrail UI
OpenContrail UI runs on http port 8080. It will automatically redirect to https port 8143.
username is "admin", and the password is mentioned in the localrc (default: "contrail123")
