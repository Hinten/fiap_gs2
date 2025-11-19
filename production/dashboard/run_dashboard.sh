#!/bin/bash
# run_dashboard.sh - Script to run the unified Flutter dashboard

set -e

echo "=========================================="
echo "FIAP Dashboard - Unified Flutter App"
echo "=========================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado. Instale Flutter primeiro:"
    echo "   https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Get Flutter dependencies
echo "📦 Instalando dependências Flutter..."
flutter pub get

# Analyze code
echo "🔍 Analisando código..."
flutter analyze --no-fatal-infos

# List available devices
echo ""
echo "📱 Dispositivos disponíveis:"
flutter devices

# Check if Chrome is available for web
if flutter devices | grep -q "Chrome"; then
    DEVICE="chrome"
    echo ""
    echo "🌐 Usando Chrome para desenvolvimento web"
else
    # Use first available device
    DEVICE=$(flutter devices | grep "•" | head -1 | awk '{print $2}')
    echo ""
    echo "📱 Usando dispositivo: $DEVICE"
fi

# Start the app
echo ""
echo "🚀 Iniciando dashboard..."
echo "⚠️  Modo: SEM AUTENTICAÇÃO (Demo)"
echo "📝 Para alterar, remova --dart-define=SKIP_AUTH=true"
echo ""

flutter run \
  --dart-define=SKIP_AUTH=true \
  --dart-define=BACKEND_URL=http://localhost:8000 \
  --dart-define=USE_EMULATOR=true \
  -d "$DEVICE"
