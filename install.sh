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

function wait_for_contrail_task() {
    file_count=`ls .stage/contrail | wc -l`
    while [ $file_count -ne 0 ]; do
        echo "--------------Waiting for contrail task completion------------"
        sleep 10
        file_count=`ls .stage/contrail | wc -l`
    done
}

function get_contrail_installer() {
    sudo rm -rf contrail-installer
    if [ $? -ne 0 ]; then
        exit 1
    fi
    git clone https://github.com/nasim-techtrueup/contrail-installer.git
    if [ $? -ne 0 ]; then
        exit 1
    fi
    (cd contrail-installer && git checkout contrail_devstack)
    if [ $? -ne 0 ]; then
        exit 1
    fi
    cp localrc contrail-installer/localrc
    echo "REMOVE_FILE_ON_COMPLETION=../.stage/contrail" >> contrail-installer/localrc
    echo 1 > .stage/get_contrail
}

function get_devstack() {
    sudo rm -rf devstack
    if [ $? -ne 0 ]; then
        exit 1
    fi
    git clone https://github.com/nasim-techtrueup/devstack.git
    if [ $? -ne 0 ]; then
        exit 1
    fi
    (cd devstack && git checkout stable/${DEVSTACK_FLAVOUR})
    if [ $? -ne 0 ]; then
        exit 1
    fi
    cp contrail-installer/devstack/lib/neutron_plugins/opencontrail devstack/lib/neutron_plugins/
    cp contrail-installer/devstack/samples/localrc-all devstack/localrc
    echo "PHYSICAL_INTERFACE="${PHYSICAL_INTERFACE} >> devstack/localrc
    echo 1 > .stage/get_devstack
}

function restart_api_contrail() {
    (cd contrail-installer && ./contrail.sh restart_api)
    status=$?
    wait_for_contrail_task
    if [ $status -ne 0 ]; then
        exit 1
    fi
}

function build_contrail() {
    (cd contrail-installer && ./contrail.sh build)
    status=$?
    wait_for_contrail_task
    if [ $status -ne 0 ]; then
        exit 1
    fi
}

function install_contrail() {
    (cd contrail-installer && ./contrail.sh install)
    status=$?
    wait_for_contrail_task
    if [ $status -ne 0 ]; then
        exit 1
    fi
}

function restart_contrail() {
    echo "Restart function not supported"
    #(cd contrail-installer && ./contrail.sh restart)
    #status=$?
    #wait_for_contrail_task
    #if [ $status -ne 0 ]; then
    #    exit 1
    #fi
}

function start_contrail() {
    (cd contrail-installer && ./contrail.sh start)
    status=$?
    wait_for_contrail_task
    if [ $status -ne 0 ]; then
        exit 1
    else
        echo "-----------------------------------------------------------"
        echo "---------------contrail start completed--------------------"
        echo "-----------------------------------------------------------"
    fi
    (cd devstack && ./stack.sh)
    if [ $? -ne 0 ]; then
        exit 1
    else
        echo "-----------------------------------------------------------"
        echo "---------------Devstack stack completed--------------------"
        echo "-----------------------------------------------------------"
    fi
}

function configure_contrail() {
    (cd contrail-installer && ./contrail.sh configure)
    status=$?
    wait_for_contrail_task
    if [ $status -ne 0 ]; then
        exit 1
    fi
}

function init_contrail() {
    :
}

function check_contrail() {
    :
}

function clean_contrail() {
    (cd contrail-installer && ./contrail.sh clean)
    status=$?
    wait_for_contrail_task
    if [ $status -ne 0 ]; then
        exit 1
    fi
}

function stop_contrail() {
    (cd devstack && ./unstack.sh)
    if [ $? -eq 0 ];
    then
        echo "-----------------------------------------------------------"
        echo "---------------Devstack unstack completed------------------"
        echo "-----------------------------------------------------------"
    else
        exit 1
    fi
    echo 1 > .stage/contrail
    (cd contrail-installer && ./contrail.sh stop)
    status=$?
    wait_for_contrail_task
    if [ $status -eq 0 ];
    then
        echo "-----------------------------------------------------------"
        echo "---------------contrail stop completed---------------------"
        echo "-----------------------------------------------------------"
    else
        exit 1
    fi
}

function all_contrail_devstack() {
    echo 1 > .stage/contrail
    (cd contrail-installer && ./contrail.sh)
    status=$?
    wait_for_contrail_task
    if [ $status -eq 0 ];
    then
        echo "-----------------------------------------------------------"
        echo "---------------contrail start completed--------------------"
        echo "-----------------------------------------------------------"
    else
        exit 1
    fi
    (cd devstack && ./stack.sh)
    if [ $? -eq 0 ];
    then
        echo "-----------------------------------------------------------"
        echo "---------------Devstack stack completed--------------------"
        echo "-----------------------------------------------------------"
    else
        exit 1
    fi
}

#=================================
OPTION=$1
ARGS_COUNT=$#

HAVE_STAGE_DIR=`ls -la | grep .stage | wc -l`
if [ $HAVE_STAGE_DIR -eq 0 ];
then
    mkdir .stage
fi

have_contrail_installer=`ls -l .stage/get_contrail | wc -l`
if [ $have_contrail_installer -eq 0 ];
then
    get_contrail_installer
fi

have_devstack=`ls -l .stage/get_devstack | wc -l`
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
