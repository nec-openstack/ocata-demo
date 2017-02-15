# How to install

    git clone https://github.com/nec-openstack/ocata-demo.git
    git clone https://git.openstack.org/openstack/diskimage-builder.git
    git clone https://git.openstack.org/openstack/tripleo-image-elements.git
    git clone https://git.openstack.org/openstack/heat-templates.git
    git clone https://git.openstack.org/openstack/dib-utils.git
    export PATH="${PWD}/dib-utils/bin:$PATH"
    export ELEMENTS_PATH=diskimage-builder/elements
    export ELEMENTS_PATH=${ELEMENTS_PATH}:tripleo-image-elements/elements
    export ELEMENTS_PATH=${ELEMENTS_PATH}:heat-templates/hot/software-config/elements
    export ELEMENTS_PATH=${ELEMENTS_PATH}:ocata-demo/elements

    diskimage-builder/bin/disk-image-create vm \
          ubuntu selinux-permissive \
          os-collect-config \
          os-refresh-config \
          os-apply-config \
          heat-config \
          heat-config-cfn-init \
          heat-config-script \
          docker-install \
          pip-and-virtualenv \
          -o ubuntu-trusty-docker.qcow2

    glance image-create --name ubuntu-docker \
                        --os-distro ubuntu \
                        --visibility public \
                        --disk-format=qcow2 \
                        --container-format=bare \
                        --file=ubuntu-trusty-docker.qcow2
