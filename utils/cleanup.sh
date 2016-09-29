#!/bin/bash

senlin receiver-delete scale-out-receiver
senlin cluster-delete swarm-worker
sleep 1
senlin profile-delete swarm-worker-profile

heat stack-delete -y swarm-manager
