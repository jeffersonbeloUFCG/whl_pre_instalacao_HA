# whl_do_xgboos_HA
Com a impossibilidade de instalar as dependencia necessarias para a execução do XGBOOST no ambiente do HA devido a limitações do homeassistant que roda muls r4 (versão essa exigida para executar o core no HA) e o xgboost precisa de R5. No HA não é possível atualizar o musl para versão mais atual o que impossibilita sua execução nesse ambiente. essa solução contorna essa limitação compilando todas as dependencias do XGBOOST em um ambiente externo e cria um .WHL (versão pré-compilada) que só é carregada e executada no HA.  

--------------------
PARA FUNCIONAMENTO, necessita apenas:

1) CRIE uma pasta no desktop: ex: xgboost
2) CRIE uma pasta output (onde será salvo o whl depois da criação da imagem)
3) cole os arquivos docker-compose.yml e Dockerfile dentro da pasta xgboost
4) abra o prompt e execute: docker compose up --build

Os arquivos .whl irão ser salvos na pasta output (versão mais atual - atualmente, 3.0.0)
Após o salvamento do arquivo (que já virá na nomeclatura correta - padrão PEP 427) - apenas suba o arquivo whl para o github [PUBLICO]

------------

A configuração do appdeamon será: 


    system_packages:
      - py3-numpy
      - python3
      - libgomp
      - py3-scikit-learn
      - py3-pandas
    python_packages:
      - tuya-connector-python
      - kafka-python
      - joblib==1.3.1
    init_commands:
      - >-
        pip install --no-cache-dir
        https://github.com/jeffersonbeloUFCG/whl_pre_instalacao_HA/raw/main/xgboost_3.0.0-py3-none-any.whl

----------

Um codigo que testa se tudo está rodando perfeitamente no appdaemon será: 

class TestandoInstalacao(hass.Hass):

    def initialize(self):
        # Teste do NumPy
        self.log(f"NumPy funcionando! Versao: {np.__version__}")
        arr = np.array([[1, 2], [3, 4]])
        self.log(f"Soma de array {arr} = {np.sum(arr)}")

        # Teste do XGBoost
        self.log(f"XGBoost funcionando! Versao: {xgb.__version__}")
        dtrain = xgb.DMatrix([[1, 2], [3, 4]], label=[0, 1])
        self.log(f"Linhas no DMatrix: {dtrain.num_row()}")

        # Teste do Pandas
        self.log(f"Pandas funcionando! Versao: {pd.__version__}")
        df = pd.DataFrame({"A": [1, 2, 3], "B": [4, 5, 6], "C": [5, 7, 9]})
        self.log(f"DataFrame criado: \n{df}")

        # Teste do scikit-learn
        self.log(f"scikit-learn funcionando! Versao: {sklearn_version}")
        
        # Exemplo simples de classificação com scikit-learn
        iris = load_iris()
        X = iris.data
        y = iris.target
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
        
        clf = RandomForestClassifier(n_estimators=100, random_state=42)
        clf.fit(X_train, y_train)
        y_pred = clf.predict(X_test)
        accuracy = accuracy_score(y_test, y_pred)
        self.log(f"Acuracia do modelo: {accuracy:.4f}")
  
apps.yaml

        testando_instalacao:
          module: testando_instalacao
          class: TestandoInstalacao
