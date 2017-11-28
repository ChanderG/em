#!/bin/bash

command=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SHRDIR="$DIR/../share/em"

## Data Structures

# .experiments/HEAD - last experiment run number

# .experiments/STATUS - status of the current experiment, one of 
# NOTSTARTED  - not yet started
# CONFIGURING - after new/clone; under process of configuring
# RUNNING     - running right now (either setup/actual run)
# COMPLETING  - run done; waiting for completion/feedback

## Functions

# init a new experiment directory
function init(){
  mkdir .experiments
  echo "000" > .experiments/HEAD
  mkdir .experiments/exp
  echo "NOTSTARTED" > .experiments/STATUS

  echo "Init new repo in $PWD"
}

# start a new experiment run
function new(){
  # ensure curr/prev run is over
  status=$(cat .experiments/STATUS)
  if [ $status != "NOTSTARTED" ]; then
    echo "Current experiment run not completed. Cannot go to next run."
    return
  fi

  # obtain current run number
  num=$(cat .experiments/HEAD)
  num=$((num+1))

  # setup conf files
  mkdir .experiments/exp/$num
  jq .id=$num $SHRDIR/exp.conf > .experiments/exp/$num/exp.conf

  # update control files
  echo "$num" > .experiments/HEAD
  echo "CONFIGURING" > .experiments/STATUS

  echo "Created new run config $num"
}

# setup the new experiment run details
function setup(){
  # ensure curr run is started
  status=$(cat .experiments/STATUS)
  if [ $status != "CONFIGURING" ]; then
    echo "Current experiment run not in configure stage."
    return
  fi

  # obtain current run number
  num=$(cat .experiments/HEAD)

  $EDITOR .experiments/exp/$num/exp.conf

  # do verification here
  echo "Updated run $num setup"
}

function helpfun(){
  echo "em - experiment manager"

  echo ""
  echo "Commands: "
  echo "  init - create a new experiment repo"
  echo "  new - start a new experiment run"
  echo "  setup - setup the current experiment"
  echo "  run - run the current experiment"
  echo "  end - end the current experiment run"
  echo "  status - display the current run status"

  echo ""
  echo "  Advanced:"
  echo "    clone - clone experiment config from a previous run"
  echo "    show - list/view all runs"
}

if [ "$command" == "init" ]; then
  init
elif [ "$command" == "new" ]; then
  new
elif [ "$command" == "setup" ]; then
  setup
elif [ "$command" == "run" ]; then
  run
elif [ "$command" == "end" ]; then
  end
elif [ "$command" == "clone" ]; then
  clone
elif [ "$command" == "show" ]; then
  show
else
  helpfun
fi
