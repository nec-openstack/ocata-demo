
git clone https://github.com/yuanying/ocata-demo.git
git clone https://git.openstack.org/openstack/diskimage-builder.git
git clone https://git.openstack.org/openstack/dib-utils.git
export PATH="${PWD}/dib-utils/bin:$PATH"
export ELEMENTS_PATH=diskimage-builder/elements
export ELEMENTS_PATH=${ELEMENTS_PATH}:ocata-demo/elements

diskimage-builder/bin/disk-image-create vm \
      ubuntu selinux-permissive \
      docker \
      -o ubuntu-trusty-docker.qcow2
