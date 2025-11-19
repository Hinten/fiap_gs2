#!/bin/bash
# run_dashboard.sh - Script to run the unified Flutter dashboard
# Supports debug, release, web, and mobile modes

set -e

echo "=========================================="
echo "FIAP Dashboard - Unified Flutter App"
echo "=========================================="

# Parse command line arguments
MODE="debug"
PLATFORM="auto"
SKIP_AUTH="true"
BACKEND_URL="http://localhost:8000"

while [[ $# -gt 0 ]]; do
  case $1 in
    --release)
      MODE="release"
      shift
      ;;
    --web)
      PLATFORM="chrome"
      shift
      ;;
    --mobile)
      PLATFORM="mobile"
      shift
      ;;
    --with-auth)
      SKIP_AUTH="false"
      shift
      ;;
    --backend-url)
      BACKEND_URL="$2"
      shift 2
      ;;
    --help)
      echo "Uso: ./run_dashboard.sh [OPÇÕES]"
      echo ""
      echo "Opções:"
      echo "  --release         Build em modo release"
      echo "  --web             Executar na web (Chrome)"
      echo "  --mobile          Executar em dispositivo móvel"
      echo "  --with-auth       Habilitar autenticação Firebase (padrão: desabilitado)"
      echo "  --backend-url URL URL do backend (padrão: http://localhost:8000)"
      echo "  --help            Exibir esta mensagem"
      echo ""
      echo "Exemplos:"
      echo "  ./run_dashboard.sh                           # Web, debug, sem auth"
      echo "  ./run_dashboard.sh --with-auth               # Web, debug, com auth"
      echo "  ./run_dashboard.sh --release --web           # Build web release"
      echo "  ./run_dashboard.sh --mobile                  # Dispositivo móvel"
      exit 0
      ;;
    *)
      echo "Opção desconhecida: $1"
      echo "Use --help para informações de uso"
      exit 1
      ;;
  esac
done

echo ""
echo "Configuração:"
echo "  Modo: $MODE"
echo "  Plataforma: $PLATFORM"
echo "  Autenticação: $([ "$SKIP_AUTH" = "true" ] && echo "DESABILITADA (Demo)" || echo "HABILITADA")"
echo "  Backend URL: $BACKEND_URL"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado. Instale Flutter primeiro:"
    echo "   https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✓ Flutter encontrado: $(flutter --version | head -1)"

# Get Flutter dependencies
echo ""
echo "📦 Instalando dependências Flutter..."
flutter pub get

if [ "$MODE" = "release" ]; then
    echo ""
    echo "🔨 Building para produção..."
    
    if [ "$PLATFORM" = "chrome" ] || [ "$PLATFORM" = "auto" ]; then
        echo "   Building aplicação web..."
        flutter build web --release \
          --dart-define=SKIP_AUTH=$SKIP_AUTH \
          --dart-define=BACKEND_URL=$BACKEND_URL \
          --dart-define=USE_EMULATOR=true
        
        echo ""
        echo "✅ Build web completo!"
        echo ""
        echo "📁 Arquivos em: build/web/"
        echo ""
        echo "Para servir a aplicação:"
        echo "  cd build/web"
        echo "  python3 -m http.server 8080"
        echo ""
        echo "Então abra http://localhost:8080 no navegador"
    else
        echo "Builds release para mobile requerem configuração adicional"
        echo "Use 'flutter build apk' ou 'flutter build ios' manualmente"
        exit 1
    fi
else
    # Analyze code
    echo ""
    echo "🔍 Analisando código..."
    flutter analyze --no-fatal-infos

    # List available devices
    echo ""
    echo "📱 Dispositivos disponíveis:"
    flutter devices

    # Determine device
    if [ "$PLATFORM" = "chrome" ]; then
        DEVICE="chrome"
        echo ""
        echo "🌐 Usando Chrome para desenvolvimento web"
    elif [ "$PLATFORM" = "mobile" ]; then
        DEVICE=$(flutter devices | grep "•" | grep -v "Chrome" | head -1 | awk '{print $2}')
        echo ""
        echo "📱 Usando dispositivo: $DEVICE"
    else
        # Auto-detect: prefer Chrome if available
        if flutter devices | grep -q "Chrome"; then
            DEVICE="chrome"
            echo ""
            echo "🌐 Usando Chrome para desenvolvimento web"
        else
            DEVICE=$(flutter devices | grep "•" | head -1 | awk '{print $2}')
            echo ""
            echo "📱 Usando dispositivo: $DEVICE"
        fi
    fi

    # Start the app
    echo ""
    echo "🚀 Iniciando dashboard..."
    if [ "$SKIP_AUTH" = "true" ]; then
        echo "⚠️  Modo: SEM AUTENTICAÇÃO (Demo)"
        echo "📝 Para habilitar auth, use: --with-auth"
    else
        echo "🔐 Modo: COM AUTENTICAÇÃO (Firebase)"
    fi
    echo ""

    flutter run \
      --dart-define=SKIP_AUTH=$SKIP_AUTH \
      --dart-define=BACKEND_URL=$BACKEND_URL \
      --dart-define=USE_EMULATOR=true \
      -d "$DEVICE"
fi
