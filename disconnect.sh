#!/bin/bash

[ -f pid_$MOUNT ] && kill -9 -- -$(cat pid_$MOUNT)
