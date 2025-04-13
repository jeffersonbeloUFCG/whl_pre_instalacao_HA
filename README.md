# whl_do_xgboos_HA
Com a impossibilidade de instalar as dependencia necessarias para a execução do XGBOOST no ambiente do HA devido a limitações do homeassistant que roda muls r4 (versão essa exigida para executar o core no HA) e o xgboost precisa de R5. No HA não é possível atualizar o musl para versão mais atual (R5 - o que danificaria a execução do CORE e do SO do HA), logo, tão limitação  impossibilita a execução do XGBOOST nesse ambiente. 

A solução proposta contorna essa limitação, pois compila todas as dependencias do XGBOOST em um ambiente externo que permite R5 e cria um .WHL (versão pré-compilada) carregada no homeassist que executa musl R4 normalmente.  

--------------------
PARA FUNCIONAMENTO, necessita apenas:

1) CRIE uma pasta no desktop: ex: xgboost
2) CRIE uma pasta output (onde será salvo o whl depois da criação da imagem)
3) cole os arquivos docker-compose.yml e Dockerfile dentro da pasta xgboost
4) abra o prompt e execute: docker compose up --build

Os arquivos .whl irão ser salvos na pasta output (versão 2.0.3 - a versão 3.0.0, atual, apresenta problemas no pacote CUDA que não é reconhecido no Alpine)
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
        https://github.com/jeffersonbeloUFCG/whl_pre_instalacao_HA/raw/main/xgboost-2.0.3-py3-none-any.whl

----------

Um codigo que testa se tudo está rodando perfeitamente no appdaemon será: 

    class TestandoInstalacao(hass.Hass):
    
        def initialize(self):
    
            # Teste da versão do Python
            python_versao = f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
            self.log(f"Versao do Python instalada: {python_versao}")
    
            # Teste do Joblib
            modelo = {"modelo": "teste"}
            joblib.dump(modelo, "/tmp/modelo.joblib")
            carregado = joblib.load("/tmp/modelo.joblib")
            self.log(f"Joblib funcionando! Modelo: {carregado}, Versao: {joblib.__version__}")
    
            # Teste do Kafka
            versao = kafka.__version__
            self.log(f"Kafka-python funcionando! Versao: {versao}")
    
            # Teste TuyaConnector
            try:
                # Não conecta, só testa se pode instanciar a classe
                dummy = tuya_connector.TuyaOpenAPI("https://openapi.tuyaus.com", "client_id", "client_secret")
                self.log("Tuya Connector funcionando! Classe TuyaOpenAPI importada com sucesso.")
            except Exception as e:
                self.log(f"Erro ao testar Tuya Connector: {e}")
    
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
