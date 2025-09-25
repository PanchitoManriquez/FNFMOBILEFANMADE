#!/bin/bash
set -e

# --- Actualizar sistema ---
echo "=== Actualizando sistema ==="
sudo apt update && sudo apt upgrade -y
sudo apt install -y git build-essential default-jdk unzip wget libgl1-mesa-dev libglu1-mesa-dev zipalign apksigner

# --- Instalar Haxe ---
echo "=== Instalando Haxe 4.2.2 ==="
wget https://github.com/HaxeFoundation/haxe/releases/download/4.2.2/haxe-4.2.2-linux64.tar.gz
tar -xf haxe-4.2.2-linux64.tar.gz
sudo mv haxe-4.2.2 /usr/lib/haxe
sudo ln -sf /usr/lib/haxe/haxe /usr/bin/haxe
sudo ln -sf /usr/lib/haxe/haxelib /usr/bin/haxelib

# --- Configurar haxelib ---
echo "=== Configurando haxelib ==="
mkdir -p ~/.haxelib
haxelib setup ~/.haxelib

# --- Instalar librerías Haxe necesarias ---
echo "=== Instalando librerías Haxe ==="
haxelib install lime
haxelib install openfl
haxelib install flixel
haxelib install flixel-addons
haxelib install flixel-ui
haxelib install hscript
haxelib install newgrounds
haxelib install extension-webm
haxelib run lime setup -y

# --- Clonar port FNF ---
echo "=== Clonando port FNF Android ==="
git clone https://github.com/luckydog7/Funkin-android.git
cd Funkin-android

# --- Compilar APK ---
echo "=== Compilando APK ==="
lime build android -release

# --- Crear keystore automático para firmar APK ---
echo "=== Creando keystore automático ==="
KEYSTORE=fnf-keystore.jks
ALIAS=fnfalias
PASSWORD=fnfpassword
keytool -genkey -v -keystore $KEYSTORE -alias $ALIAS -keyalg RSA -keysize 2048 -validity 10000 -storepass $PASSWORD -keypass $PASSWORD -dname "CN=FNF, OU=Dev, O=FNF, L=City, S=State, C=US"

# --- Firmar APK automáticamente ---
APK_PATH=export/android/bin/Funkin-android-release.apk
SIGNED_APK_PATH=export/android/bin/FNF-Android-Signed.apk
echo "=== Firmando APK ==="
apksigner sign --ks $KEYSTORE --ks-pass pass:$PASSWORD --key-pass pass:$PASSWORD --out $SIGNED_APK_PATH $APK_PATH

# --- Final ---
echo "=== ¡Todo listo! ==="
echo "APK firmado listo para instalar en Android:"
echo "$SIGNED_APK_PATH"
echo "Descárgalo usando Files/Download en Codespaces o scp desde Termux"