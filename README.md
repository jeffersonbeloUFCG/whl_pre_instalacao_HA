# whl_do_xgboos_HA
Com a impossibilidade de instalar certas dependencias no ambiente do HA e com isso instalar o xgboost para executar os modelos, essa solucao (PRE COMPILA todas as dependencias no docker desktop) e cria um arquivo compilado whl que permite contorna a limitacao muls r5 (que nao atualiza)

--------------------
Atualmente, 4 whl são gerados pelo DockerFile e dockercompose: 

numpy-1.23.5-linux_x86_64.whl 
pandas-2.1.4-py3-none-any.whl
scikit-learn-1.2.2-linux_x86_64.whl
xgboost-1.7.6-linux_x86_64.whl

Todos esses dependiam de g++ para ser compilado com dependencia R5 o que impossibilitava. Dessa forma, contorna-se a limitacao

--------------------
PARA FUNCIONAMENTO:

1) CRIE uma pasta no desktop: ex: xgboost - diretorio
2) CRIE uma pasta output
3) cole os arquivos docker-compose.yml e Dockerfile dentro da pasta xgboost
4) abra o prompt e execute: docker compose up --build

Os arquivos .whl irão ser salvos na pasta output e depois precisam ser upados no github. A partir disso, com o link do git, instala no appdaemon a versao pre compilada

------------


system_packages:
  - py3-numpy #pode ser instalado assim
  - python3
  - libgomp
  - py3-scikit-learn #descobri que pode ser instalado assim
  - py3-pandas # pandas nao é nessario
python_packages:
  - tuya-connector-python
  - kafka-python
  - joblib==1.3.1
init_commands:
  - >-
    pip install --no-cache-dir
    https://github.com/jeffersonbeloUFCG/whl_pre_instalacao_HA/raw/main/xgboost-1.7.6-py3-none-any.whl

Logo, so precisa do xgboost
