# Content Generator Agent - Roadmap

## 🎬 Visão Geral

Agente de IA que gera conteúdo educacional de alta qualidade usando APIs de geração de vídeo/áudio (Veo3, NotebookLM, Grok, etc.).

### Responsabilidades
- Criar roteiros de aulas
- Gerar vídeos educacionais com edição profissional
- Produzir podcasts e áudios explicativos
- Criar apresentações e slides
- Gerar resumos e materiais de apoio

---

## 🎯 Funcionalidades

### 1. Geração de Roteiros
- Análise de plano de aula/ementa
- Estruturação pedagógica (introdução, desenvolvimento, conclusão)
- Definição de exemplos e exercícios
- Estimativa de tempo por seção

### 2. Geração de Vídeos (Veo3 / Sora / Runway)
- Vídeos explicativos animados
- Screencasts com narração
- Edição automática (cortes, transições, legendas)
- Música de fundo apropriada

### 3. Geração de Podcasts (NotebookLM / ElevenLabs)
- Conversas educacionais entre "hosts" de IA
- Narração de conteúdos
- Qualidade de áudio profissional
- Múltiplas vozes e estilos

### 4. Geração de Slides e Apresentações
- PowerPoint / Google Slides automatizado
- Design visual atraente
- Gráficos e diagramas
- Animações

### 5. Materiais de Apoio
- PDFs resumidos
- Exercícios e quizzes
- Flashcards
- Mind maps

---

## 📋 Tarefas de Implementação

### Fase 1: Integração com APIs de Geração

#### Veo3 (Google)
- [ ] Autenticação e setup
- [ ] Text-to-video generation
- [ ] Video editing e post-processing
- [ ] Download e storage

#### NotebookLM (Google)
- [ ] API integration (se disponível)
- [ ] Upload de conteúdo fonte
- [ ] Geração de podcast
- [ ] Conversão e download de áudio

#### Grok (xAI)
- [ ] API integration
- [ ] Geração de scripts e roteiros
- [ ] Análise e resumo de conteúdos

#### ElevenLabs (Text-to-Speech)
- [ ] Integração para narração
- [ ] Múltiplas vozes (professor, aluno, narrador)
- [ ] Clonagem de voz (opcional)

#### Runway ML / Synthesia
- [ ] Alternativas para geração de vídeo
- [ ] Avatar generation
- [ ] Video effects

### Fase 2: Pipeline de Geração

```
Input: Plano de Aula
  ↓
Análise e Estruturação (Grok/GPT-4)
  ↓
Geração de Roteiro
  ↓
┌─────────────┬──────────────┬────────────────┐
│   Vídeo     │    Podcast   │  Apresentação  │
│   (Veo3)    │ (NotebookLM) │  (Slides API)  │
└─────────────┴──────────────┴────────────────┘
  ↓
Post-Processing (legendas, edição, thumbnails)
  ↓
Revisão Humana
  ↓
Publicação (YouTube, Spotify, Google Drive)
```

### Fase 3: Geração de Roteiros Pedagógicos
- [ ] Prompt engineering para conteúdo educacional
- [ ] Estrutura ADDIE (Analyze, Design, Develop, Implement, Evaluate)
- [ ] Adaptação por nível (iniciante, intermediário, avançado)
- [ ] Inclusão de exemplos práticos

Exemplo de prompt:
```python
CONTENT_SCRIPT_PROMPT = """
Você é um designer instrucional expert em criar conteúdo educacional.

Disciplina: {disciplina}
Tópico: {topico}
Duração alvo: {duracao} minutos
Público: {nivel}

Crie um roteiro de vídeo educacional que inclua:

1. Hook (0-30s): Abertura impactante que prende atenção
2. Introdução (30s-2min): Contexto e objetivos da aula
3. Desenvolvimento (bulk): 
   - Explicação conceitual
   - Exemplos práticos
   - Demonstrações de código (se aplicável)
   - Analogias e metáforas
4. Exercícios (2-3min): Desafio para o aluno
5. Conclusão (1min): Recap e próximos passos

Formato: Markdown com timecodes
Estilo: Conversacional, didático, encorajador
"""
```

### Fase 4: Pós-Processamento
- [ ] Legendas automáticas (Whisper API)
- [ ] Tradução (múltiplos idiomas)
- [ ] Thumbnails atrativas (DALL-E, Midjourney)
- [ ] Chapters e timestamps
- [ ] SEO optimization (títulos, descrições, tags)

### Fase 5: Interface de Aprovação
- [ ] Dashboard para professores
- [ ] Preview de vídeos/áudios gerados
- [ ] Edição de roteiros
- [ ] Re-geração de seções específicas
- [ ] Aprovação e publicação

### Fase 6: Publicação Automatizada
- [ ] Upload para YouTube
- [ ] Upload para Spotify/Apple Podcasts
- [ ] Integração com LMS da FIAP
- [ ] Notificação de alunos

### Fase 7: Testes e Deploy
- [ ] Geração de conteúdo de teste
- [ ] Validação de qualidade (professores)
- [ ] Testes de performance (tempo de geração)
- [ ] Deploy serverless

---

## 🔌 Endpoints

- `POST /api/v1/content/generate/script` - Gerar roteiro
- `POST /api/v1/content/generate/video` - Gerar vídeo
- `POST /api/v1/content/generate/podcast` - Gerar podcast
- `POST /api/v1/content/generate/slides` - Gerar slides
- `GET /api/v1/content/jobs/{job_id}` - Status de geração
- `GET /api/v1/content/preview/{content_id}` - Preview
- `PUT /api/v1/content/{content_id}/edit` - Editar
- `POST /api/v1/content/{content_id}/approve` - Aprovar e publicar

---

## 📊 Database Schema

### Table: content_generation_jobs
```
PK: job_id
Attributes:
  - type (video, podcast, slides, pdf)
  - input_data (JSON: plano de aula)
  - script_generated (Markdown)
  - output_urls (List: vídeos, áudios, etc)
  - status (queued, generating, reviewing, approved, published)
  - professor_id
  - created_at
  - completed_at
```

### Table: generated_content
```
PK: content_id
Attributes:
  - job_id
  - type
  - title
  - description
  - file_url (S3)
  - thumbnail_url
  - duration_seconds
  - publish_urls (YouTube, Spotify, etc)
  - views_count
  - created_at
```

---

## 🤖 Agente CrewAI

```python
content_creator_agent = Agent(
    role='Educational Content Creator',
    goal='Create engaging and high-quality educational materials',
    backstory="""Expert in instructional design and multimedia production.
    You create content that is pedagogically sound and visually appealing.""",
    tools=[
        Veo3Tool(),
        NotebookLMTool(),
        GrokTool(),
        SlideGeneratorTool(),
    ],
)
```

---

## 🎨 Exemplos de Output

### Vídeo (Veo3)
- Duração: 10-15 minutos
- Qualidade: 1080p, 30fps
- Legendas: PT-BR, EN (auto)
- Thumbnail personalizada
- Edição profissional com cortes e transições

### Podcast (NotebookLM)
- Formato: MP3, 128kbps
- Duração: 15-30 minutos
- Múltiplas vozes
- Música intro/outro
- Show notes automáticas

### Slides
- Formato: PPTX ou Google Slides
- Design: Tema FIAP
- 15-25 slides
- Animações e transições
- Gráficos e imagens

---

## ✅ Critérios de Aceitação

- [ ] Integração com pelo menos 2 APIs de geração
- [ ] Geração de roteiro automática
- [ ] Vídeos gerados com qualidade profissional
- [ ] Podcasts com áudio claro e natural
- [ ] Interface de preview e edição
- [ ] Publicação automatizada
- [ ] Tempo de geração < 30min por conteúdo
- [ ] Aprovação de professores antes de publicar
- [ ] Deploy serverless

---

## 📚 Referências

- [Google Veo](https://deepmind.google/technologies/veo/)
- [NotebookLM](https://notebooklm.google/)
- [Grok API](https://x.ai/)
- [ElevenLabs](https://elevenlabs.io/)
- [Runway ML](https://runwayml.com/)
- [Instructional Design (ADDIE)](https://www.instructionaldesign.org/models/addie/)
