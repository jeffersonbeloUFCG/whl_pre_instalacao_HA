# Dockerfile - Geração unificada de .whl compatíveis com musl (PEP 427)
FROM python:3.10-alpine

# Instala dependências de compilação
RUN apk add --no-cache \
    python3-dev \
    py3-pip \
    build-base \
    cmake \
    git \
    gfortran \
    openblas-dev \
    lapack-dev \
    musl-dev \
    cython \
    libxml2-dev \
    libxslt-dev \
    libffi-dev \
    openssl-dev \
    && mkdir -p /output /build

# Atualiza ferramentas de build
RUN pip install --upgrade pip setuptools wheel

# Compila os pacotes puros: numpy, scikit-learn, pandas
RUN pip wheel --no-deps \
    --wheel-dir=/root/.cache/pip/wheels \
    numpy==1.23.5 \
    scikit-learn==1.2.2 \
    pandas==2.1.4

# Compila o XGBoost (necessita build manual)
WORKDIR /build
RUN git clone --recursive --branch v1.7.6 https://github.com/dmlc/xgboost.git
WORKDIR /build/xgboost
RUN mkdir -p build && cd build && \
    cmake .. -DUSE_OPENMP=ON -DUSE_CUDA=OFF && \
    make -j$(nproc)
WORKDIR /build/xgboost/python-package
RUN python setup.py bdist_wheel

# Copia todos os .whl para /output com nomes PEP 427
ENTRYPOINT sh -c '\
  echo "📦 Verificando pacotes gerados..."; \
  mkdir -p /output; \
  for pkg in numpy scikit-learn pandas xgboost; do \
    FILE=$(find /root/.cache/pip/wheels /build/xgboost/python-package/dist -type f -name "${pkg//-/_}-*.whl" -o -name "${pkg}-*.whl" | head -n 1); \
    if [ -n "$FILE" ]; then \
      VER=$(echo "$FILE" | sed -E "s/.*${pkg//-/_}-([0-9.]+).*/\\1/"); \
      EXT=$(echo "$FILE" | grep -q 'linux_x86_64' && echo "linux_x86_64" || echo "py3-none-any"); \
      NEW_NAME="${pkg}-${VER}-${EXT}.whl"; \
      cp "$FILE" "/output/$NEW_NAME"; \
      echo "✅ Copiado com sucesso: $NEW_NAME"; \
    else \
      echo "❌ Falha ao gerar ou localizar o .whl de $pkg"; \
    fi; \
  done'
