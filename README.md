# Experiment manager

Record and control your experiments.

## Flow
An experiment is one repo/ groups of experiments with a common codebase/intention.

Experiment runs are iterations of the experiment by changing code and other parameters even the actual expriment scripts.

The stages of an experiment run are:

1. Start -> create a conf file which describes the experiment and hooks up the runners as required.
2. Configure -> edit and set variables and scripts are required
3. Run -> Automated running of defined scripts
4. Observe -> Read/Browse/Analyze the outputs of the experiment
5. End -> End a run by describing the observations and notes. Archive the results/outputs and prepare for the next run.

Experiment runs are controlled using the config files with more or less predefined fields. Some of the config variables are exposed as environment variables for use in thr runner scripts. 

Experiment configuration also has fields for hypothesis and observations, where the purpose of the experiment and the results are to be documented.

### Runners
The 4 variables:

1. `pre-run`: pre run setup script (optional)
2. `run`: main run script (required)
3. `post-run`: post run analysis script (optional)
4. `fetch`: required outputs/logs that need be saved (required). The fetch script needs to bring in all required outputs to be saved to a folder called `outputs/` in the experiment folder.

## Logging

The chief purpose of this tools it to log as much of the experiments as possible. 

Firstly, the config for each run is stored - this includes everything from the code version to the hypothesis and observtation fields filled in by the user.

Secondly, everything `fetch` stores is copied into run specific folders to have full record of the outputs and logs for every run.

Thirdly, all runner scripts are also copied into run specific folders for complete control. Note that this a simple implementation for now. Sharing unchanged scripts, using hashes or backing the scripts onto a version control system instead of naive full copying are possible future approaches to do this.

Eventually the idea is to have other frontends to this underlying store of runs to have querying and displaying capabilities.

## Dependencies
jq
