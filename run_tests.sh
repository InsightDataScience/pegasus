#!/bin/bash

export PEG_ROOT=$(dirname "${BASH_SOURCE}")
bats --tap ${PEG_ROOT}/test/test_utils.bats
