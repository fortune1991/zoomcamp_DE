#!/usr/bin/env bash
set -euo pipefail

# --- 1. Source .bashrc safely to pick up JAVA_HOME/SPARK_HOME ---
if [ -f "$HOME/.bashrc" ]; then
    set +u  # Temporarily allow unbound variables
    source "$HOME/.bashrc"
    set -u
fi

# --- 2. Validate JAVA_HOME ---
if [ -z "${JAVA_HOME:-}" ]; then
    if command -v java >/dev/null 2>&1; then
        JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
        export JAVA_HOME
    else
        echo "ERROR: JAVA_HOME not set and java not found in PATH"
        exit 1
    fi
fi

# --- 3. Validate SPARK_HOME ---
if [ -z "${SPARK_HOME:-}" ]; then
    DEFAULT_SPARK="$HOME/spark/spark-3.3.2-bin-hadoop3"
    if [ -d "$DEFAULT_SPARK" ]; then
        SPARK_HOME="$DEFAULT_SPARK"
        export SPARK_HOME
    else
        echo "ERROR: SPARK_HOME not set and default directory $DEFAULT_SPARK does not exist"
        exit 1
    fi
fi

# --- 4. Prepare PYTHONPATH for PySpark ---
PY4J_ZIP=$(find "$SPARK_HOME/python/lib" -name "py4j-*-src.zip" | head -n 1)
if [ -z "$PY4J_ZIP" ]; then
    echo "ERROR: Could not find py4j zip in $SPARK_HOME/python/lib"
    exit 1
fi
export PYTHONPATH="$SPARK_HOME/python:$PY4J_ZIP"

# --- 5. Kernel details ---
KERNEL_NAME="spark"
DISPLAY_NAME="Python 3 (Spark)"

# --- 6. Install Jupyter kernel ---
python -m ipykernel install --user \
    --name "$KERNEL_NAME" \
    --display-name "$DISPLAY_NAME"

# --- 7. Create kernel.json with environment variables ---
KERNEL_DIR=$(jupyter --data-dir)/kernels/$KERNEL_NAME
mkdir -p "$KERNEL_DIR"

cat > "$KERNEL_DIR/kernel.json" <<EOF
{
  "argv": [
    "$(which python)",
    "-m",
    "ipykernel_launcher",
    "-f",
    "{connection_file}"
  ],
  "display_name": "$DISPLAY_NAME",
  "language": "python",
  "env": {
    "JAVA_HOME": "$JAVA_HOME",
    "SPARK_HOME": "$SPARK_HOME",
    "PYTHONPATH": "$PYTHONPATH"
  }
}
EOF

echo "Spark kernel '$DISPLAY_NAME' installed successfully!"