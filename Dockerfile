# Dockerfile for building Ansible image for Alpine 3, with as few additional software as possible.
#
# @see https://github.com/gliderlabs/docker-alpine/blob/master/docs/usage.md
#
# Version  1.0
#


# pull base image
FROM alpine:3.4

MAINTAINER Jim Smyth <jim@trailswehike.com>

ENV ANSIBLE_LIBRARY /var/lib/ansible/custom_modules

RUN echo "===> Installing sudo to emulate normal OS behavior..."  && \
    apk --update add sudo                                         && \
    \
    \
    echo "===> Adding Python runtime..."  && \
    apk --update add python py-pip openssl ca-certificates     && \
    apk --update add --virtual build-dependencies \
                python-dev libffi-dev openssl-dev build-base \
                linux-headers                                  && \
    pip install --upgrade pip cffi                             && \
    \
    \
    echo "===> Installing Ansible..."  && \
    pip install ansible                && \
    \
    \
    echo "===> Installing Custom Reqs..."             && \
    pip install dnspython                             && \
    pip install netaddr                               && \
    pip install -U shade==1.11.1 \
        python-cinderclient==1.8.0 \
        python-designateclient==2.3.0 \
        python-glanceclient==2.5.0 \
        python-heatclient==1.4.0 \
        python-ironicclient==1.7.0 \
        python-keystoneclient==3.5.0 \
        python-magnumclient==2.3.0 \
        python-neutronclient==5.1.0 \
        python-novaclient==6.0.0 \
        python-openstackclient==3.2.0 \
        keystoneauth1==2.12.1 \
        os-client-config==1.21.0 && \
    \
    \
    echo "===> Installing handy tools (not absolutely required)..."  && \
    apk --update add sshpass openssh-client rsync  && \
    \
    \
    echo "===> Removing package list..."  && \
    apk del build-dependencies            && \
    rm -rf /var/cache/apk/*               && \
    \
    \
    echo "===> Adding hosts for convenience..."  && \
    mkdir -p /etc/ansible                        && \
    echo 'localhost' > /etc/ansible/hosts

# Infoblox Python Library
ADD https://raw.githubusercontent.com/Infoblox-Development/Infoblox-API-Python/b0c356fa661b6c445ed49691ba75efdfd5932e9a/infoblox.py /usr/lib/python2.7
ADD https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/openstack.py /etc/ansible/inventory/

# Make the openstack.py executable
RUN chmod +x /etc/ansible/inventory/openstack.py

# default command: display Ansible version
CMD [ "ansible-playbook", "--version" ]
