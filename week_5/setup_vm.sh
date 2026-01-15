#!/bin/bash
set -euo pipefail

BASHRC="$HOME/.bashrc"

# --- 1. Directories ---
mkdir -p "$HOME/spark" "$HOME/notebooks"

# --- 2. Python ---
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip python3-venv wget nano

# --- 3. Spark + Java ---
cd "$HOME/spark"

# Java
if [ ! -d "jdk-11.0.2" ]; then
    wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
    tar xzf openjdk-11.0.2_linux-x64_bin.tar.gz
    rm openjdk-11.0.2_linux-x64_bin.tar.gz
fi

# Spark
if [ ! -d "spark-3.3.2-bin-hadoop3" ]; then
    wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz
    tar xzf spark-3.3.2-bin-hadoop3.tgz
    rm spark-3.3.2-bin-hadoop3.tgz
fi

# --- 4. Export environment in current shell ---
export JAVA_HOME="$HOME/spark/jdk-11.0.2"
export SPARK_HOME="$HOME/spark/spark-3.3.2-bin-hadoop3"
export PATH="$JAVA_HOME/bin:$SPARK_HOME/bin:$PATH"

# --- 5. Prepend to .bashrc for future sessions ---
ENV_LINES=$(cat <<'EOF'
export JAVA_HOME="$HOME/spark/jdk-11.0.2"
export SPARK_HOME="$HOME/spark/spark-3.3.2-bin-hadoop3"
export PATH="$JAVA_HOME/bin:$SPARK_HOME/bin:$PATH"
EOF
)
if ! grep -q 'JAVA_HOME' "$BASHRC"; then
    TMP=$(mktemp)
    echo "$ENV_LINES" > "$TMP"
    cat "$BASHRC" >> "$TMP"
    mv "$TMP" "$BASHRC"
fi

# --- 6. Python virtual environment ---
cd "$HOME/notebooks"
python3 -m venv venv
source venv/bin/activate

pip install --upgrade pip
pip install jupyterlab ipykernel

# --- 7. Kernel creation ---
chmod +x ~/create_spark_kernel.sh
~/create_spark_kernel.sh

# --- 8. Start Jupyter Lab ---
nohup jupyter lab --no-browser --ip=127.0.0.1 --port=8888 > ~/notebooks/jupyter.log 2>&1 &