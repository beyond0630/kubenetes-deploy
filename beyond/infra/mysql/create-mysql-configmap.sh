#!/bin/bash

kubectl -n beyond delete cm mysql-conf
kubectl -n beyond create cm mysql-conf --from-file=mysqld.cnf
