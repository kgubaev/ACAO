@echo off
docker run --rm -it ^
  -e ROBOT_PLUGINS_DIRECTORY=/tools/robot-plugins ^
  -v "%cd%:/work" ^
  -w /work/src/ontology ^
  obolibrary/odkfull:v1.6 ^
%*