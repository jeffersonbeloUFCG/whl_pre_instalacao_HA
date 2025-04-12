# Usar a imagem base Python 3.11 Alpine
FROM python:3.11-alpine

# Instalar dependências para compilação
RUN apk update && apk add --no-cache \
    git cmake make g++ gcc musl-dev py3-pip \
    openblas-dev lapack-dev gfortran

WORKDIR /build

# Clona o repositório do XGBoost na versão 1.7.6 (v.3.0.0 - deu problema na instalação CUDA)
RUN git clone --recursive --branch v1.7.6 https://github.com/dmlc/xgboost.git

# Compila o XGBoost com OpenMP e sem CUDA
RUN cd xgboost && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DUSE_OPENMP=ON -DUSE_CUDA=OFF && \
    make -j$(nproc)

# Instala e gera o .whl do XGBoost
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
