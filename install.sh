# proto is https or ssh
#! /bin/bash

# Contrail NFV
# ------------
if [[ $EUID -eq 0 ]]; then
    echo "You are running this script as root."
    echo "Cut it out."
    exit 1
fi
# Save trace setting
TOP_DIR=`pwd`
CONTRAIL_USER=$(whoami)
source localrc

GIT_BASE=${GIT_BASE:-git://github.com}

unset LANG
unset LANGUAGE
LC_ALL=C
export LC_ALL
DEVSTACK_FLAVOUR=${DEVSTACK_FLAVOUR:-newton}

function get_contrail_installer() {
    git clone https://github.com/nasim-techtrueup/contrail-installer.git
    (cd contrail-installer && git checkout contrail_devstack)
    cp localrc contrail-installer/localrc
}

function get_devstack() {
    git clone https://github.com/nasim-techtrueup/devstack.git
    (cd devstack && git checkout stable/${DEVSTACK_FLAVOUR})
    cp contrail-installer/devstack/lib/neutron_plugins/opencontrail devstack/lib/neutron_plugins/
    cp contrail-installer/devstack/samples/localrc-all devstack/localrc
    echo "PHYSICAL_INTERFACE="${PHYSICAL_INTERFACE} >> devstack/localrc
}

function restart_api_contrail() {
    (cd contrail-installer && ./contrail.sh restart_api)
}

function build_contrail() {
    (cd contrail-installer && ./contrail.sh build)
}

function install_contrail() {
    (cd contrail-installer && ./contrail.sh install)
}

function restart_contrail() {
    (cd contrail-installer && ./contrail.sh restart)
}

function start_contrail() {
    (cd contrail-installer && ./contrail.sh start)
    (cd devstack && ./stack.sh)
}

function configure_contrail() {
    (cd contrail-installer && ./contrail.sh configure)
}

function init_contrail() {
    :
}

function check_contrail() {
    :
}

function clean_contrail() {
    (cd contrail-installer && ./contrail.sh clean)
}

function stop_contrail() {
    (cd contrail-installer && ./contrail.sh stop)
    (cd devstack && ./unstack.sh)
}

function all_contrail_devstack() {
    (cd contrail-installer && ./contrail.sh)
    (cd devstack && ./stack.sh)
}

#=================================
OPTION=$1
ARGS_COUNT=$#

have_contrail_installer=`find . -name contrail-installer | grep ./contrail-installer | wc -l`
if [ $have_contrail_installer -eq 0 ];
then
    get_contrail_installer
fi

have_devstack=`find . -name contrail-installer | grep ./devstack | wc -l`
if [ $have_devstack -eq 0 ];
then
    get_devstack
fi

if [ $ARGS_COUNT -eq 0 ];
then 
    all_contrail_devstack
elif [ $ARGS_COUNT -eq 1 ] && [ "$OPTION" == "install" ] || [ "$OPTION" == "start" ] || [ "$OPTION" == "configure" ] || [ "$OPTION" == "clean" ] || [ "$OPTION" == "stop" ] || [ "$OPTION" == "build" ] || [ "$OPTION" == "restart" ] || [ "$OPTION" == "restart_api" ];
then
    ${OPTION}_contrail
else
    echo_msg "Usage ::install.sh [option]"
    echo_msg "install.sh(Without any option executes 1.build,2.install,3.configure,4.start phases)"
    echo_msg "ex:install.sh install"
    echo_msg "[options]:"
    echo_msg "build"
    echo_msg "install"
    echo_msg "start"
    echo_msg "stop"
    echo_msg "configure"
    echo_msg "clean"
    echo_msg "restart"
    echo_msg "restart_api"

fi
