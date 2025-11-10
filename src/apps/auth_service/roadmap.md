# Auth Service - Roadmap

## 🔐 Visão Geral

Serviço de autenticação e autorização responsável por gerenciar identidades de usuários, tokens JWT e OAuth2.

### Responsabilidades
- Autenticação de usuários (login/logout)
- Geração e validação de tokens JWT
- Integração OAuth2 (Google, Microsoft)
- Gerenciamento de sessões
- Role-Based Access Control (RBAC)
- Refresh tokens para renovação

---

## 🎯 Objetivos

1. Sistema de autenticação seguro e robusto
2. Suporte a múltiplos provedores de identidade
3. JWT stateless para escalabilidade
4. RBAC granular para controle de acesso
5. Conformidade com LGPD/GDPR

---

## 🏗️ Arquitetura

### Stack Tecnológico
- **Framework**: FastAPI (Python 3.11+)
- **Auth**: PyJWT, passlib para hashing
- **OAuth2**: authlib para integração
- **Validação**: Pydantic
- **Database**: DynamoDB (users, sessions) ou Aurora Serverless
- **Deployment**: AWS Lambda + API Gateway

### Estrutura

```
auth_service/
├── src/
│   ├── main.py                 # FastAPI app / Lambda handler
│   ├── api/
│   │   ├── auth_routes.py      # Endpoints de autenticação
│   │   └── user_routes.py      # Endpoints de usuários
│   ├── core/
│   │   ├── security.py         # JWT, hashing, crypto
│   │   ├── config.py           # Configurações
│   │   └── dependencies.py     # FastAPI dependencies
│   ├── models/
│   │   ├── user.py             # User model
│   │   └── token.py            # Token model
│   ├── services/
│   │   ├── auth_service.py     # Lógica de autenticação
│   │   ├── oauth_service.py    # OAuth2 providers
│   │   └── user_service.py     # CRUD de usuários
│   └── repositories/
│       └── user_repository.py  # Acesso ao banco
├── tests/
│   ├── test_auth_routes.py
│   ├── test_security.py
│   └── fixtures.py
├── requirements.txt
├── serverless.yml              # Serverless Framework config
└── README.md
```

---

## 📋 Tarefas de Implementação

### Fase 1: Setup e Core

#### 1.1 Setup do Projeto
- [ ] Criar estrutura de pastas
- [ ] Configurar `requirements.txt`:
  ```
  fastapi==0.104.1
  pydantic==2.5.0
  python-jose[cryptography]==3.3.0
  passlib[bcrypt]==1.7.4
  python-multipart==0.0.6
  boto3==1.29.0  # Para AWS
  authlib==1.2.1
  ```
- [ ] Setup de environments (.env para dev, secrets manager para prod)
- [ ] Configurar serverless.yml para deploy

**Critérios de Aceitação**:
- Projeto criado e dependências instaladas
- FastAPI roda localmente
- Environment variables configuradas

#### 1.2 Core Security Module
- [ ] Implementar `security.py`:
  - `hash_password(password: str) -> str`
  - `verify_password(plain: str, hashed: str) -> bool`
  - `create_access_token(data: dict, expires_delta: Optional[timedelta])`
  - `decode_access_token(token: str) -> dict`
  - `create_refresh_token(user_id: str) -> str`
- [ ] Configurar secrets (JWT_SECRET, ALGORITHM)
- [ ] Token expiration configurable

Exemplo:
```python
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.JWT_SECRET, algorithm=ALGORITHM)
    return encoded_jwt
```

**Critérios de Aceitação**:
- Senhas hashadas com bcrypt
- Tokens JWT gerados e validados
- Expiração funciona corretamente

---

### Fase 2: Database e Models

#### 2.1 User Model
- [ ] Definir schema Pydantic:
  ```python
  from pydantic import BaseModel, EmailStr
  from typing import Optional
  from datetime import datetime
  
  class UserBase(BaseModel):
      email: EmailStr
      full_name: str
      
  class UserCreate(UserBase):
      password: str
      
  class User(UserBase):
      id: str
      is_active: bool = True
      role: str = "user"  # user, admin, recruiter
      created_at: datetime
      
      class Config:
          from_attributes = True
  
  class Token(BaseModel):
      access_token: str
      refresh_token: str
      token_type: str = "bearer"
  ```

#### 2.2 User Repository
- [ ] Implementar `user_repository.py` para DynamoDB:
  - `create_user(user: UserCreate) -> User`
  - `get_user_by_id(user_id: str) -> Optional[User]`
  - `get_user_by_email(email: str) -> Optional[User]`
  - `update_user(user_id: str, data: dict) -> User`
  - `delete_user(user_id: str) -> bool`
- [ ] Tratar erros de duplicação (email já existe)

DynamoDB Table Schema:
```
Table: symbiowork-users
- PK: user_id (UUID)
- GSI: email-index (email como chave)
Attributes:
  - email
  - full_name
  - hashed_password
  - is_active
  - role
  - oauth_provider (opcional: "google", "microsoft", None)
  - created_at
  - updated_at
```

**Critérios de Aceitação**:
- CRUD de usuários funciona
- Emails únicos garantidos
- Índice secundário para busca por email

---

### Fase 3: Autenticação Local

#### 3.1 Auth Routes
- [ ] `POST /api/v1/auth/register`
  - Validar input (email, senha forte)
  - Hash password
  - Criar usuário no banco
  - Retornar User (sem senha)
- [ ] `POST /api/v1/auth/login`
  - Validar credenciais
  - Gerar access_token e refresh_token
  - Retornar tokens
- [ ] `POST /api/v1/auth/refresh`
  - Validar refresh_token
  - Gerar novo access_token
- [ ] `POST /api/v1/auth/logout`
  - Invalidar tokens (blacklist ou revoke no DB)

Exemplo de endpoint:
```python
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])

@router.post("/login", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    user_service: UserService = Depends()
):
    user = await user_service.authenticate_user(
        form_data.username,  # email
        form_data.password
    )
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password"
        )
    
    access_token = create_access_token(data={"sub": user.id, "role": user.role})
    refresh_token = create_refresh_token(user.id)
    
    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }
```

**Critérios de Aceitação**:
- Usuário consegue se registrar
- Login retorna tokens válidos
- Refresh token renova access_token
- Logout invalida tokens

---

### Fase 4: OAuth2 Integration

#### 4.1 OAuth2 Providers
- [ ] Configurar Google OAuth2:
  - Client ID e Secret em environment
  - Redirect URI configurado
  - Scopes: email, profile
- [ ] Configurar Microsoft OAuth2:
  - App registration no Azure AD
  - Client ID e Secret
  - Scopes: email, openid, profile
- [ ] Implementar fluxo OAuth2:
  1. Frontend redireciona para provider
  2. Provider callback para backend
  3. Backend troca code por access_token
  4. Busca dados do usuário no provider
  5. Cria ou atualiza usuário local
  6. Retorna token JWT para frontend

#### 4.2 OAuth Routes
- [ ] `GET /api/v1/auth/oauth/{provider}/authorize`
  - Redireciona para provider OAuth
- [ ] `GET /api/v1/auth/oauth/{provider}/callback`
  - Recebe code do provider
  - Troca por token
  - Autentica/cria usuário
  - Retorna JWT

Exemplo:
```python
from authlib.integrations.starlette_client import OAuth

oauth = OAuth()
oauth.register(
    name='google',
    client_id=settings.GOOGLE_CLIENT_ID,
    client_secret=settings.GOOGLE_CLIENT_SECRET,
    server_metadata_url='https://accounts.google.com/.well-known/openid-configuration',
    client_kwargs={'scope': 'openid email profile'}
)

@router.get("/oauth/google/callback")
async def google_callback(request: Request):
    token = await oauth.google.authorize_access_token(request)
    user_info = token.get('userinfo')
    
    # Buscar ou criar usuário
    user = await user_service.get_or_create_oauth_user(
        email=user_info['email'],
        full_name=user_info['name'],
        oauth_provider='google'
    )
    
    # Gerar JWT
    access_token = create_access_token(data={"sub": user.id})
    
    return {"access_token": access_token, "token_type": "bearer"}
```

**Critérios de Aceitação**:
- Login com Google funciona
- Login com Microsoft funciona
- Usuário OAuth é criado ou atualizado
- JWT é gerado após OAuth

---

### Fase 5: Autorização (RBAC)

#### 5.1 Role-Based Access Control
- [ ] Definir roles:
  - `user`: Acesso básico
  - `recruiter`: Acesso a recruitment_service
  - `admin`: Acesso total
- [ ] Implementar decorator/dependency para verificar role:
  ```python
  from fastapi import Depends, HTTPException, status
  from fastapi.security import OAuth2PasswordBearer
  
  oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")
  
  async def get_current_user(token: str = Depends(oauth2_scheme)) -> User:
      credentials_exception = HTTPException(
          status_code=status.HTTP_401_UNAUTHORIZED,
          detail="Could not validate credentials"
      )
      try:
          payload = decode_access_token(token)
          user_id: str = payload.get("sub")
          if user_id is None:
              raise credentials_exception
      except JWTError:
          raise credentials_exception
      
      user = await user_repository.get_user_by_id(user_id)
      if user is None:
          raise credentials_exception
      return user
  
  async def require_role(role: str):
      async def role_checker(user: User = Depends(get_current_user)):
          if user.role != role and user.role != "admin":
              raise HTTPException(
                  status_code=status.HTTP_403_FORBIDDEN,
                  detail="Insufficient permissions"
              )
          return user
      return role_checker
  
  # Uso:
  @router.get("/admin/users")
  async def list_users(user: User = Depends(require_role("admin"))):
      # Somente admins
      pass
  ```

**Critérios de Aceitação**:
- Endpoints protegidos por autenticação
- Roles verificadas antes de acesso
- 401 para não autenticado, 403 para sem permissão

---

### Fase 6: Segurança e Compliance

#### 6.1 Security Enhancements
- [ ] **Rate Limiting**: Limitar tentativas de login
  - Usar Redis ou DynamoDB para contador
  - Bloquear IP após N tentativas falhas
- [ ] **Password Policies**:
  - Mínimo 8 caracteres
  - Pelo menos 1 maiúscula, 1 minúscula, 1 número
  - Validar com regex ou biblioteca
- [ ] **MFA (Multi-Factor Authentication)** (opcional):
  - TOTP com pyotp
  - Backup codes
- [ ] **Session Management**:
  - Armazenar refresh tokens no DB
  - Permitir revogação (logout de todos os dispositivos)
- [ ] **Audit Logging**:
  - Logar todos logins/logouts
  - Logar mudanças de senha/role
  - Enviar para CloudWatch Logs

#### 6.2 LGPD/GDPR Compliance
- [ ] **Consentimento**:
  - Checkbox de termos de uso no registro
  - Privacy policy link
- [ ] **Direito ao Esquecimento**:
  - Endpoint `DELETE /api/v1/users/me`
  - Anonimizar dados ao invés de deletar (para auditoria)
- [ ] **Portabilidade**:
  - Endpoint `GET /api/v1/users/me/data-export`
  - Retornar JSON com todos os dados do usuário
- [ ] **Encryption**:
  - Dados sensíveis encriptados no DB
  - TLS 1.3 em trânsito

**Critérios de Aceitação**:
- Rate limiting bloqueia ataques de força bruta
- Políticas de senha fortes aplicadas
- Audit logs funcionando
- Endpoints LGPD implementados

---

### Fase 7: Testes e Documentação

#### 7.1 Testes
- [ ] **Unit Tests**:
  - Testar `hash_password`, `verify_password`
  - Testar `create_access_token`, `decode_access_token`
  - Testar user_service methods
- [ ] **Integration Tests**:
  - Testar fluxo completo de registro → login → access protegido
  - Testar OAuth2 flow (mockar provider)
  - Testar refresh token
- [ ] **Security Tests**:
  - Testar SQL injection (não aplicável, mas testar NoSQL injection)
  - Testar tokens expirados
  - Testar tokens inválidos

Exemplo de teste:
```python
import pytest
from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def test_register_user():
    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": "test@example.com",
            "full_name": "Test User",
            "password": "SecurePass123!"
        }
    )
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "test@example.com"
    assert "id" in data

def test_login_success():
    # Primeiro registrar
    client.post("/api/v1/auth/register", json={
        "email": "login@example.com",
        "full_name": "Login Test",
        "password": "Password123!"
    })
    
    # Então fazer login
    response = client.post(
        "/api/v1/auth/login",
        data={"username": "login@example.com", "password": "Password123!"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert "refresh_token" in data
```

Rodar testes:
```bash
pytest --cov=src --cov-report=html
```

#### 7.2 Documentação
- [ ] README com:
  - Como rodar localmente
  - Como rodar testes
  - Como deployar
  - Environment variables necessárias
- [ ] API Documentation (auto-gerado pelo FastAPI)
  - Acessível em `/docs` (Swagger UI)
  - Acessível em `/redoc` (ReDoc)
- [ ] Arquitetura e decisões de design

**Critérios de Aceitação**:
- Cobertura de testes 80%+
- Todos os testes passando
- Documentação completa e clara

---

## 🔌 Endpoints (Resumo)

### Auth
- `POST /api/v1/auth/register` - Criar conta
- `POST /api/v1/auth/login` - Login (retorna JWT)
- `POST /api/v1/auth/refresh` - Renovar access_token
- `POST /api/v1/auth/logout` - Logout

### OAuth2
- `GET /api/v1/auth/oauth/{provider}/authorize` - Iniciar OAuth
- `GET /api/v1/auth/oauth/{provider}/callback` - Callback OAuth

### Users
- `GET /api/v1/users/me` - Dados do usuário atual
- `PUT /api/v1/users/me` - Atualizar perfil
- `DELETE /api/v1/users/me` - Deletar conta (LGPD)
- `GET /api/v1/users/me/data-export` - Exportar dados (LGPD)

### Admin (somente role=admin)
- `GET /api/v1/admin/users` - Listar todos os usuários
- `PUT /api/v1/admin/users/{id}/role` - Mudar role de usuário

---

## 📊 Database Schema (DynamoDB)

### Table: symbiowork-users
```
Partition Key: user_id (String, UUID)
GSI: email-index (email as partition key)

Attributes:
- user_id: String (UUID)
- email: String (unique)
- full_name: String
- hashed_password: String (null for OAuth users)
- is_active: Boolean
- role: String (user, recruiter, admin)
- oauth_provider: String (google, microsoft, null)
- created_at: Number (timestamp)
- updated_at: Number (timestamp)
```

### Table: symbiowork-refresh-tokens
```
Partition Key: token_id (String, UUID)
GSI: user_id-index

Attributes:
- token_id: String
- user_id: String
- token_hash: String
- expires_at: Number (timestamp)
- revoked: Boolean
- created_at: Number
```

---

## ✅ Critérios de Aceitação Final

- [ ] Registro e login funcionando
- [ ] OAuth2 com Google e Microsoft
- [ ] JWT gerado e validado
- [ ] Refresh tokens funcionando
- [ ] RBAC implementado
- [ ] Rate limiting ativo
- [ ] Audit logging configurado
- [ ] Compliance LGPD (esquecimento, portabilidade)
- [ ] Testes com cobertura 80%+
- [ ] Documentação completa
- [ ] Deploy serverless funcionando

---

## 🚀 Deploy (Serverless Framework)

```yaml
# serverless.yml
service: symbiowork-auth

provider:
  name: aws
  runtime: python3.11
  region: us-east-1
  environment:
    DYNAMODB_TABLE_USERS: ${self:service}-users-${opt:stage, 'dev'}
    JWT_SECRET: ${env:JWT_SECRET}
    GOOGLE_CLIENT_ID: ${env:GOOGLE_CLIENT_ID}
    GOOGLE_CLIENT_SECRET: ${env:GOOGLE_CLIENT_SECRET}

functions:
  api:
    handler: src.main.handler
    events:
      - http:
          path: /{proxy+}
          method: ANY
          cors: true

resources:
  Resources:
    UsersTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: ${self:service}-users-${opt:stage, 'dev'}
        AttributeDefinitions:
          - AttributeName: user_id
            AttributeType: S
          - AttributeName: email
            AttributeType: S
        KeySchema:
          - AttributeName: user_id
            KeyType: HASH
        GlobalSecondaryIndexes:
          - IndexName: email-index
            KeySchema:
              - AttributeName: email
                KeyType: HASH
            Projection:
              ProjectionType: ALL
        BillingMode: PAY_PER_REQUEST
```

Deploy:
```bash
serverless deploy --stage prod
```

---

## 📚 Referências

- [FastAPI Security](https://fastapi.tiangolo.com/tutorial/security/)
- [PyJWT Documentation](https://pyjwt.readthedocs.io/)
- [OAuth2 RFC](https://oauth.net/2/)
- [OWASP Auth Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
