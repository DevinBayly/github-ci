#!/bin/bash
cd /opt/modelE2_planet_1.0/decks
# this will probably show an error about a folder missing, but then it creates it
make rundeck RUNSRC=E1oM20 RUN=E1oM20_Test
# this downloads a bunch of files
../exec/get_input_data -w E1oM20_Test $HOME/ModelE_Support/prod_input_files
make clean; make -j setup RUN=E1oM20_Test
echo "NOW STARTING THE FIRST 1HR RUN"
../exec/runE E1oM20_Test -cold-restart -np 2