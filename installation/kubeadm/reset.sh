#!/bin/sh

rm -rf certs/pki config/admin.conf

vagrant destroy -f

vagrant up controller-1 controller-2 controller-3
