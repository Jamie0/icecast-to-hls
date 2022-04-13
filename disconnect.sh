#!/bin/bash

[ -f pid_$MOUNT ] && kill -- -$(cat pid_$MOUNT)
