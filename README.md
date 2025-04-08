# whl_do_xgboos_HA
Com a impossibilidade de instalar certas dependencias no ambiente do HA e com isso instalar o xgboost para executar os modelos, essa solucao (PRE COMPILA todas as dependencias no docker desktop) e cria um arquivo compilado whl que permite contorna a limitacao muls r5 (que nao atualiza)

--------------------

1) CRIE uma pasta no desktop: ex: xgboost - diretorio
2) CRIE uma pasta output
3) cole os arquivos docker-compose.yml e Dockerfile dentro da pasta xgboost
4) abra o prompt e execute: docker compose up --build

O arquivo .whl vai ser salvo na pasta output e você atualiza no github. A partir disso instala no appdaemon a versao pre compilada
