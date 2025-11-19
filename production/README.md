# Production - MVP Unificado

Aplicação de produção integrando todos os pacotes implementados do FIAP AI-Enhanced Learning Platform.

## 📁 Estrutura

```
production/
├── backend/          # Backend unificado Python
│   ├── main.py      # API FastAPI integrada
│   ├── README.md    # Documentação backend
│   └── run_backend.sh
│
└── dashboard/       # Dashboard unificado Flutter
    ├── lib/         # Código Flutter
    ├── README.md    # Documentação dashboard
    └── run_dashboard.sh
```

## 🚀 Quick Start

### Backend

```bash
cd backend
./run_backend.sh
```

Ou veja [backend/README.md](backend/README.md) para instruções detalhadas.

### Dashboard

```bash
cd dashboard
./run_dashboard.sh
```

Ou veja [dashboard/README.md](dashboard/README.md) para instruções detalhadas.

## ⚙️ Modo Sem Autenticação

Ambas aplicações suportam execução sem autenticação Firebase:

**Backend:**
```bash
export FIRESTORE_EMULATOR_HOST=localhost:8080
export FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
python main.py
```

**Dashboard:**
```bash
flutter run --dart-define=SKIP_AUTH=true -d chrome
```

## 📦 Serviços Integrados

### Backend (3 microservices)
- ✅ Research Management API (`/api/v1/research/*`)
- ✅ Content Reviewer Agent (`/api/v1/content-review/*`)
- ✅ Auth Service (compartilhado)

### Dashboard (4 interfaces)
- ✅ Sistema de Temas
- ✅ Autenticação Firebase
- ✅ Dashboards de Pesquisa
- ✅ Interface de Aprovação

## 📝 Documentação

- [Backend README](backend/README.md) - Setup, configuração, API docs
- [Dashboard README](dashboard/README.md) - Setup, execução, features
- [README Principal](../README.md) - Visão geral do projeto

## 🔧 Desenvolvimento

### Pré-requisitos

- Python 3.11+
- Flutter 3.0+
- Firebase project (ou usar emulador)

### Setup Completo

```bash
# Backend
cd backend
python -m venv .venv
source .venv/bin/activate
./run_backend.sh

# Dashboard (nova sessão terminal)
cd dashboard
flutter pub get
./run_dashboard.sh
```

## 🐛 Troubleshooting

### Backend não inicia
- Verifique se os packages estão instalados: `pip list | grep -E "(auth-service|research-management|content-reviewer)"`
- Configure `.env` com credenciais Firebase ou use emulador

### Dashboard não compila
- Execute `flutter clean && flutter pub get`
- Verifique versão do Flutter: `flutter --version`
- Use `flutter doctor` para diagnosticar problemas

### Conflitos de dependências
- Backend: Use ambientes virtuais separados
- Dashboard: Veja `pubspec.yaml` para overrides de dependências

## 📊 Status do MVP

**Implementado**: 43.75% (7/16 packages)
- Backend Python: 30% (3/10)
- Frontend Flutter: 66.7% (4/6)

Ver [README principal](../README.md) para detalhes completos.

## 📄 Licença

POC desenvolvida para FIAP Global Solution 2025.2
