#!/bin/bash

command=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SHRDIR="$DIR/../share/em"

## Data Structures

# .experiments/HEAD - last experiment run number

# .experiments/STATUS - status of the current experiment, one of 
# INACTIVE  - not yet started
# CONFIGURING - after new/clone; under process of configuring
# RUNNING     - running right now (either setup/actual run)
# COMPLETING  - run done; waiting for completion/feedback

## Functions

# init a new experiment directory
function init(){
  mkdir .experiments
  echo "000" > .experiments/HEAD
  mkdir .experiments/exp
  echo "INACTIVE" > .experiments/STATUS

  echo "Init new repo in $PWD"
}

# start a new experiment run
function new(){
  # ensure curr/prev run is over
  status=$(cat .experiments/STATUS)
  if [ $status != "INACTIVE" ]; then
    echo "Current experiment run not completed. Cannot go to next run."
    return
  fi

  # obtain current run number
  num=$(cat .experiments/HEAD)
  num=$((num+1))

  # setup conf files
  mkdir .experiments/exp/$num
  jq ".id=$num | .times.created=\"$(date)\"" $SHRDIR/exp.conf > .experiments/exp/$num/exp.conf

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

  jq .times.lastUpdated="\"$(date)\"" .experiments/exp/$num/exp.conf | sponge .experiments/exp/$num/exp.conf
  echo "Updated run $num setup"
}

# run the current configuration
function run(){
  # ensure curr run is ready
  status=$(cat .experiments/STATUS)
  if [ $status != "CONFIGURING" ]; then
    echo "Current experiment run not in configuration or already run."
    return
  fi

  # obtain current run number
  num=$(cat .experiments/HEAD)
  conffile=".experiments/exp/$num/exp.conf"

  # prepare run
  preRun=$(jq -r .pre_run $conffile)
  run=$(jq -r .run $conffile)
  postRun=$(jq -r .post_run $conffile)
  fetch=$(jq -r .fetch $conffile)

  if [ "$run" == "" ]; then
    echo "Cannot skip run script. Edit conf and try again."
    return
  fi
  if [ "$fetch" == "" ]; then
    echo "Cannot skip fetch script. Edit conf and try again."
    return
  fi
  # also need to check for existance and exec permissions on these files here

  # prepare environment variables
  while IFS=$'\t' read -r key value; do
    eval "export $key=$value"
  done < <(jq -r '.config | to_entries | .[] | [.key, .value] | @tsv' $conffile)

  ### it is run time

  echo "RUNNING" > .experiments/STATUS

  # copy runner scripts
  mkdir .experiments/exp/$num/runners
  mkdir outputs/

  # actual runner scripts run now
  if [ "$preRun" == "" ]; then
    echo "Skipping pre run."
  else
    ./$preRun |& tee outputs/preRun.log
    cp $preRun .experiments/exp/$num/runners/
  fi

  ./$run |& tee outputs/run.log
  cp $run .experiments/exp/$num/runners/

  if [ "$postRun" == "" ]; then
    echo "Skipping post run."
  else
    ./$postRun |& tee outputs/postRun.log
    cp $postRun .experiments/exp/$num/runners/
  fi

  ./$fetch |& tee outputs/fetch.log
  cp $fetch .experiments/exp/$num/runners/

  # finish up
  echo "COMPLETING" > .experiments/STATUS
  jq .times.run="\"$(date)\"" .experiments/exp/$num/exp.conf | sponge .experiments/exp/$num/exp.conf

  echo ""
  echo "Experiment run core complete"
  echo "Output available in outputs/"
}

# end the current run
function end(){
  # ensure curr run is done
  status=$(cat .experiments/STATUS)
  if [ $status != "COMPLETING" ]; then
    echo "Current experiment not ready to complete."
    return
  fi

  # obtain current run number
  num=$(cat .experiments/HEAD)
  conffile=".experiments/exp/$num/exp.conf"

  # chance to fill in the observation
  $EDITOR $conffile

  # move outputs folder
  mv outputs .experiments/exp/$num/

  # update status
  echo INACTIVE > .experiments/STATUS

  echo "Experiment run #$num ended"
}

# print status of the current run
function status(){
  echo "Last/current run number: "
  cat .experiments/HEAD
  echo "Status: "
  cat .experiments/STATUS
}

# clone config of a previous run
# for now, only the preceeding experiment run
function clone(){
  # ensure curr/prev run is over
  status=$(cat .experiments/STATUS)
  if [ $status != "INACTIVE" ]; then
    echo "Current experiment run not completed. Cannot go to next run."
    return
  fi

  # obtain current run number
  num=$(cat .experiments/HEAD)
  prev=$num
  num=$((num+1))

  # setup conf files
  mkdir .experiments/exp/$num
  # blank out as many fields as possible
  jq ".id=$num | .times.created=\"$(date)\" | .observations=\"\" | .times.lastUpdated=\"\" | .times.run=\"\"" .experiments/exp/$prev/exp.conf > .experiments/exp/$num/exp.conf

  # update control files
  echo "$num" > .experiments/HEAD
  echo "CONFIGURING" > .experiments/STATUS

  echo "Created new run config $num based on $prev run#"
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
elif [ "$command" == "status" ]; then
  status
elif [ "$command" == "clone" ]; then
  clone
elif [ "$command" == "show" ]; then
  show
else
  helpfun
fi
