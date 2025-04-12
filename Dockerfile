FROM python:3.11-alpine

# Instala dependências
RUN apk update && apk add --no-cache \
    git cmake make g++ gcc musl-dev py3-pip

WORKDIR /build

# Clona o repositório do XGBoost
RUN git clone --recursive --branch v3.0.0 https://github.com/dmlc/xgboost.git

# Compila com OpenMP
RUN cd xgboost && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DUSE_OPENMP=1 && \
    make -j$(nproc)

# Instala e gera o .whl
WORKDIR /build/xgboost/python-package
RUN pip install --upgrade pip setuptools wheel && \
    pip install . --no-deps

# Copia o .whl para /output e renomeia
RUN mkdir -p /output
ENTRYPOINT sh -c '\
  echo "📦 Procurando .whl..."; \
  WHEEL_PATH=$(find /root/.cache/pip/wheels -name "xgboost*.whl" | head -n 1); \
  if [ -n "$WHEEL_PATH" ]; then \
    VERSION=$(basename "$WHEEL_PATH" | cut -d"-" -f2); \
    cp "$WHEEL_PATH" "/output/xgboost-${VERSION}-py3-none-any.whl"; \
    echo "✅ Copiado com sucesso: xgboost-${VERSION}-py3-none-any.whl"; \
  else \
    echo "❌ Nenhum arquivo .whl encontrado"; \
  fi'
