#!/bin/bash
#
# update-firefox.sh
# Descarga e instala la última versión de Firefox (binario oficial de Mozilla)
# en /opt/firefox, sin tocar el sistema de paquetes (apt).
#
# Uso:
#   chmod +x update-firefox.sh
#   ./update-firefox.sh

set -e  # cortar el script si algo falla

TMP_DIR="/tmp/firefox-update"
ARCHIVE="$TMP_DIR/firefox-latest.tar.xz"
URL="https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=es-AR"

echo "==> Preparando carpeta temporal..."
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

echo "==> Descargando Firefox..."
curl -L -o "$ARCHIVE" "$URL"

echo "==> Verificando tipo de archivo descargado..."
FILE_TYPE=$(file -b "$ARCHIVE")
echo "    Tipo detectado: $FILE_TYPE"

if echo "$FILE_TYPE" | grep -qi "HTML\|ASCII text"; then
    echo "ERROR: la descarga no trajo un archivo comprimido válido."
    echo "Puede que la URL haya cambiado o haya un problema de red."
    exit 1
fi

echo "==> Cerrando Firefox si está abierto..."
pkill -x firefox 2>/dev/null || true

echo "==> Extrayendo archivo..."
cd "$TMP_DIR"
tar xf "$ARCHIVE"

if [ ! -d "$TMP_DIR/firefox" ]; then
    echo "ERROR: no se encontró la carpeta 'firefox' extraída."
    exit 1
fi

echo "==> Instalando en /opt/firefox..."
sudo rm -rf /opt/firefox
sudo mv "$TMP_DIR/firefox" /opt/firefox

echo "==> Creando enlace simbólico en /usr/local/bin/firefox..."
sudo ln -sf /opt/firefox/firefox /usr/local/bin/firefox

echo "==> Limpiando archivos temporales..."
rm -rf "$TMP_DIR"

echo ""
echo "Firefox actualizado correctamente."
/opt/firefox/firefox --version
