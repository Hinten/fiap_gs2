import 'package:approval_interface/approval_interface.dart';

/// Mock data generator for demonstration purposes
class MockData {
  /// Generate a list of mock approval items
  static List<ApprovalItem> generateMockApprovalItems() {
    final now = DateTime.now();

    return [
      ApprovalItem(
        id: '1',
        type: ApprovalType.codeReview,
        title: 'Pull Request #123: Implementar autenticação JWT',
        description: 'Adiciona suporte para autenticação JWT com refresh tokens',
        priority: ApprovalPriority.high,
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2)),
        assignedTo: 'Prof. João Silva',
        content: {
          'pr_number': 123,
          'author': 'aluno@example.com',
          'files_changed': 15,
          'additions': 450,
          'deletions': 120,
        },
        metadata: {
          'repository': 'fiap_project',
          'branch': 'feature/jwt-auth',
        },
      ),
      ApprovalItem(
        id: '2',
        type: ApprovalType.grading,
        title: 'Avaliação - Trabalho Final - Grupo 5',
        description: 'Sistema de recomendação com Machine Learning',
        priority: ApprovalPriority.critical,
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 5)),
        assignedTo: 'Prof. Maria Santos',
        content: {
          'grade': 8.5,
          'criteria': {
            'implementation': 9.0,
            'documentation': 8.0,
            'testing': 8.5,
          },
          'feedback':
              'Excelente implementação do algoritmo de recomendação. Documentação poderia ser mais detalhada.',
        },
      ),
      ApprovalItem(
        id: '3',
        type: ApprovalType.award,
        title: 'Ranking Mensal - Novembro 2024',
        description: 'Classificação de alunos baseada em entregas e qualidade',
        priority: ApprovalPriority.normal,
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(days: 1)),
        content: {
          'rankings': [
            {'position': 1, 'student': 'Ana Costa', 'score': 95},
            {'position': 2, 'student': 'Bruno Lima', 'score': 92},
            {'position': 3, 'student': 'Carlos Dias', 'score': 88},
          ],
        },
      ),
      ApprovalItem(
        id: '4',
        type: ApprovalType.content,
        title: 'Vídeo Explicativo: Design Patterns em Python',
        description: 'Vídeo de 15min explicando padrões Observer e Factory',
        priority: ApprovalPriority.normal,
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 8)),
        assignedTo: 'Prof. Pedro Oliveira',
        content: {
          'duration': '15:32',
          'format': 'MP4',
          'size_mb': 125,
          'thumbnail': 'https://example.com/thumb.jpg',
        },
        metadata: {
          'topic': 'Design Patterns',
          'language': 'Portuguese',
        },
      ),
      ApprovalItem(
        id: '5',
        type: ApprovalType.issue,
        title: 'Revisão de Conteúdo: Erro no slide 15',
        description: 'Código de exemplo contém erro de sintaxe',
        priority: ApprovalPriority.high,
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 1)),
        content: {
          'issue_type': 'syntax_error',
          'location': 'slide 15',
          'suggested_fix': 'Trocar "print x" por "print(x)"',
        },
      ),
      ApprovalItem(
        id: '6',
        type: ApprovalType.codeReview,
        title: 'Pull Request #124: Adicionar testes unitários',
        description: 'Adiciona testes para o módulo de autenticação',
        priority: ApprovalPriority.normal,
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 12)),
        assignedTo: 'Prof. João Silva',
        content: {
          'pr_number': 124,
          'author': 'estudante@example.com',
          'files_changed': 8,
          'test_coverage': '85%',
        },
      ),
      ApprovalItem(
        id: '7',
        type: ApprovalType.grading,
        title: 'Avaliação - Sprint 2 - Grupo 3',
        description: 'Implementação de API RESTful',
        priority: ApprovalPriority.normal,
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(days: 2)),
        assignedTo: 'Prof. Maria Santos',
        content: {
          'grade': 9.0,
          'criteria': {
            'api_design': 9.5,
            'documentation': 8.5,
            'error_handling': 9.0,
          },
        },
      ),
      ApprovalItem(
        id: '8',
        type: ApprovalType.content,
        title: 'Podcast: Carreira em DevOps',
        description: 'Episódio 15: Entrevista com profissional sênior',
        priority: ApprovalPriority.low,
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(days: 3)),
        content: {
          'duration': '45:20',
          'format': 'MP3',
          'guest': 'Ricardo Ferreira',
        },
      ),
      ApprovalItem(
        id: '9',
        type: ApprovalType.grading,
        title: 'Avaliação - Exercício 10 - Grupo 1',
        description: 'Implementação de algoritmo de ordenação',
        priority: ApprovalPriority.critical,
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(hours: 3)),
        assignedTo: 'Prof. Pedro Oliveira',
        content: {
          'grade': 7.5,
          'criteria': {
            'correctness': 8.0,
            'efficiency': 7.0,
            'code_quality': 7.5,
          },
          'feedback': 'Algoritmo funciona mas pode ser otimizado.',
        },
      ),
      ApprovalItem(
        id: '10',
        type: ApprovalType.codeReview,
        title: 'Pull Request #125: Refatorar módulo de database',
        description: 'Melhora organização e performance das queries',
        priority: ApprovalPriority.low,
        status: ApprovalStatus.pending,
        createdAt: now.subtract(const Duration(days: 1, hours: 6)),
        assignedTo: 'Prof. João Silva',
        content: {
          'pr_number': 125,
          'author': 'dev@example.com',
          'files_changed': 12,
          'performance_gain': '30%',
        },
      ),
    ];
  }

  /// Generate mock approval history items
  static List<ApprovalItem> generateMockHistoryItems() {
    final now = DateTime.now();

    return [
      ApprovalItem(
        id: 'h1',
        type: ApprovalType.codeReview,
        title: 'Pull Request #120: Implementar cache Redis',
        description: 'Adiciona camada de cache com Redis',
        priority: ApprovalPriority.high,
        status: ApprovalStatus.approved,
        createdAt: now.subtract(const Duration(days: 5)),
        reviewedAt: now.subtract(const Duration(days: 4)),
        approvedAt: now.subtract(const Duration(days: 4)),
        assignedTo: 'Prof. João Silva',
      ),
      ApprovalItem(
        id: 'h2',
        type: ApprovalType.grading,
        title: 'Avaliação - Trabalho Final - Grupo 2',
        description: 'Sistema de e-commerce com React',
        priority: ApprovalPriority.normal,
        status: ApprovalStatus.approved,
        createdAt: now.subtract(const Duration(days: 7)),
        reviewedAt: now.subtract(const Duration(days: 6)),
        approvedAt: now.subtract(const Duration(days: 6)),
        assignedTo: 'Prof. Maria Santos',
        content: {
          'grade': 9.5,
        },
      ),
      ApprovalItem(
        id: 'h3',
        type: ApprovalType.content,
        title: 'Vídeo: Introdução ao Kubernetes',
        description: 'Tutorial básico de containers',
        priority: ApprovalPriority.normal,
        status: ApprovalStatus.rejected,
        createdAt: now.subtract(const Duration(days: 10)),
        reviewedAt: now.subtract(const Duration(days: 9)),
        assignedTo: 'Prof. Pedro Oliveira',
        content: {
          'rejection_reason': 'Qualidade de áudio precisa melhorar',
        },
      ),
    ];
  }
}
