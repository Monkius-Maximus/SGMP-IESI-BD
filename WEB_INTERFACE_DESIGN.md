# SGMP - Design da Interface Web

## Visão Geral do Sistema

Este documento descreve o design da interface web para o Sistema de Gerenciamento e Manutenção Predial (SGMP), que será desenvolvida utilizando HTML, CSS, JavaScript e React (conceitual).

## Arquitetura da Interface

### 1. Layout Principal

```
┌─────────────────────────────────────────────────┐
│                 HEADER                          │
│  🏠 SGMP - Sistema de Gestão Predial           │
│  [Menu] [Usuário] [Configurações]              │
├─────────────────────────────────────────────────┤
│ SIDEBAR    │           MAIN CONTENT             │
│            │                                    │
│ 👥 Pessoas │  ┌─────────────────────────────┐   │
│ 🏢 Unidades│  │                             │   │
│ 🎯 Áreas   │  │     DASHBOARD/CONTENT       │   │
│ 📅 Reservas│  │                             │   │
│ 🔧 Ordens  │  │                             │   │
│ 📊 Relatórios│ │                             │   │
│            │  └─────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

### 2. Módulos Principais

#### 2.1 Dashboard (Página Inicial)
- **Cards de resumo**: Total de moradores, unidades ocupadas, reservas pendentes, ordens abertas
- **Gráficos**: Ocupação por bloco, reservas por mês
- **Alertas**: Ordens urgentes, reservas para aprovação
- **Atividades recentes**: Últimas ações do sistema

#### 2.2 Módulo Pessoas
**Subseções:**
- **Moradores** (`residents`)
  - Lista com filtros (ativo/inativo, proprietário/inquilino)
  - Formulário de cadastro/edição
  - Associação com unidades
  
- **Funcionários** (`employees`)
  - Lista por função (porteiro, zelador, jardineiro)
  - Cadastro com cargo e salário
  - Histórico de ordens executadas
  
- **Síndicos** (`syndics`)
  - Síndico atual
  - Histórico de mandatos
  - Funcionalidades de aprovação

#### 2.3 Módulo Unidades
- **Lista de Edifícios** (`buildings`)
  - Visualização por bloco
  - Taxa de ocupação
  
- **Unidades** (`units`)
  - Grid visual dos apartamentos
  - Status (ocupado/vago/manutenção)
  - Detalhes (metragem, quartos, vagas)

#### 2.4 Módulo Áreas Comuns
- **Catálogo de Áreas** (`common_areas`)
  - Cards com fotos e descrições
  - Capacidade e valor por hora
  - Horários de funcionamento
  
- **Sistema de Reservas** (`reservations`)
  - Calendário visual
  - Processo de aprovação
  - Histórico de uso

#### 2.5 Módulo Ordens de Serviço
- **Lista de OS** (`service_orders`)
  - Filtros por status e prioridade
  - Kanban board (Abertas → Em Progresso → Concluídas)
  - Atribuição para funcionários

#### 2.6 Módulo Relatórios
- **Ocupação**: Gráficos de ocupação por bloco
- **Financeiro**: Receitas de reservas, custos de manutenção
- **Performance**: Produtividade dos funcionários
- **Histórico**: Atividades do sistema

### 3. Componentes de Interface

#### 3.1 Cards de Informação
```html
<div class="info-card">
  <div class="card-header">
    <h3>🏠 Unidades</h3>
  </div>
  <div class="card-body">
    <div class="metric">
      <span class="number">89</span>
      <span class="label">Ocupadas</span>
    </div>
    <div class="progress">
      <div class="progress-bar" style="width: 89%"></div>
    </div>
  </div>
</div>
```

#### 3.2 Formulários Dinâmicos
- Validação em tempo real (CPF, email)
- Auto-complete para campos relacionados
- Upload de documentos/fotos
- Máscaras de entrada (telefone, CPF)

#### 3.3 Tabelas Interativas
- Ordenação por colunas
- Filtros avançados
- Paginação
- Exportação (CSV, PDF)

#### 3.4 Calendário de Reservas
- Visualização mensal/semanal
- Drag & drop para reagendamento
- Cores por status (pendente/aprovada/rejeitada)
- Tooltips com detalhes

### 4. Fluxos de Usuário

#### 4.1 Cadastro de Morador
```
1. Página Pessoas → Moradores → Novo
2. Formulário: Dados pessoais → Dados de contato → Unidade
3. Validação → Confirmação → Redirect para lista
```

#### 4.2 Reserva de Área Comum
```
1. Áreas Comuns → Selecionar área → Calendário
2. Escolher data/horário → Preencher detalhes
3. Submeter para aprovação → Notificação síndico
4. Aprovação → Confirmação → Pagamento (se aplicável)
```

#### 4.3 Abertura de OS
```
1. Nova OS → Tipo (Unidade/Área Comum)
2. Localização → Descrição do problema
3. Prioridade → Anexos → Submeter
4. Atribuição automática → Notificação funcionário
```

### 5. Tecnologias Utilizadas

#### 5.1 Frontend
- **HTML5**: Estrutura semântica
- **CSS3**: Flexbox/Grid, animações, responsividade
- **JavaScript ES6+**: Interatividade e validações
- **React** (conceitual): Componentes reutilizáveis

#### 5.2 Bibliotecas/Frameworks
- **Chart.js**: Gráficos e dashboards
- **FullCalendar**: Calendário de reservas
- **Bootstrap/Tailwind**: Framework CSS
- **Font Awesome**: Ícones

#### 5.3 Integração Backend
- **API REST**: Comunicação com PostgreSQL
- **Fetch API**: Requisições assíncronas
- **WebSockets**: Notificações real-time

### 6. Responsividade

#### 6.1 Breakpoints
- **Mobile**: < 768px (sidebar colapsada)
- **Tablet**: 768px - 1024px (layout adaptado)
- **Desktop**: > 1024px (layout completo)

#### 6.2 Adaptações Mobile
- Menu hambúrguer
- Cards empilhados
- Formulários simplificados
- Touch-friendly buttons

### 7. Acessibilidade

- **ARIA labels**: Screen readers
- **Contraste**: WCAG 2.1 AA
- **Navegação por teclado**: Tab index
- **Texto alternativo**: Imagens e ícones

### 8. Performance

- **Lazy loading**: Carregamento sob demanda
- **Minificação**: CSS/JS otimizados
- **Caching**: Estratégias de cache
- **Compressão**: Gzip/Brotli

## Implementação

A implementação será feita em etapas:

1. **Estrutura HTML**: Layout e navegação básica
2. **Estilos CSS**: Design system e responsividade
3. **JavaScript**: Funcionalidades interativas
4. **Integração**: Conexão com backend (mock inicial)
5. **Testes**: Validação de funcionalidades
6. **Documentação**: Guias de usuário

---

**Objetivo**: Criar uma interface intuitiva e moderna que facilite a gestão condominial, reduzindo a necessidade de reuniões presenciais e melhorando a comunicação entre moradores, síndicos e funcionários.