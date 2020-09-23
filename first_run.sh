#!/bin/bash

# make sure the .githooks folder and its content is executable
sudo chmod -R +x .githooks

# set custom git hooks folder to .githooks
git config core.hooksPath .githooks
