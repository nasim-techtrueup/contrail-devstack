contrail-devstack
==================

contrail-devstack is a set of scripts and utilities to quickly 
build, install, configure and deploy OpenContrail + Devstack

# Versions

The contrail-devstack master branch generally points to trunk versions 
of OpenContrail components and newton branch of devstack

# localrc

contrail-devstack installer uses ``localrc`` to contain all local configuration
and customizations.  Best to start with a available localrc, edit as required

# Launching OpenContrail + devstack

Run the following NOT AS ROOT:

    cd contrail-devstack
    ./install.sh

# Verify installation
    1) screen -x contrail and run through various tabs to see various contrail modules are running
    2) Run utilities/contrail-status to see if all services are running
    3) screen -x stack and run through various tabs to see various devstack modules are running

# Rebuild installation with new changes
make required changes to contrail or devstack and trigger rebuild using
    ./install.sh rebuild

