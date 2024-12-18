# Use uma imagem base oficial do Python
FROM python:3.9-slim

# Defina o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copie os arquivos necessários para o contêiner
COPY . .

# Instale as dependências do sistema
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        git \
        curl \
        && rm -rf /var/lib/apt/lists/*

# Instale o Rust (necessário para algumas dependências Python)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    echo "export PATH=$HOME/.cargo/bin:\$PATH" >> /etc/profile

# Instale as dependências Python
RUN pip install --upgrade pip setuptools-rust && \
    pip install -r requirements.txt

# Exponha a porta que a aplicação irá utilizar
EXPOSE 8080

# Defina a variável de ambiente para o token HF
ENV HF_TOKEN=seu_token_hf_aqui

# Comando para iniciar a aplicação
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8080", "--timeout", "6000", "app:app"]
