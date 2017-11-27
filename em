#!/bin/bash

command=$1

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
