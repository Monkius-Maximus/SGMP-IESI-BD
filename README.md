# SGMP-IESI-BD - Sistema de Gerenciamento e Manutenção Predial

Projeto que visa a criação de um Sistema de Gerenciamento e Manutenção Predial de forma que busca facilitar a convivência das pessoas que dividem o mesmo espaço e necessitam de uma alternativa às infinitas reuniões condominiais.

## 📋 Sobre o Projeto

Este repositório contém o design e implementação do banco de dados para um sistema completo de gerenciamento de condomínios residenciais. O sistema suporta:

- ✅ **Cadastro de Pessoas**: Moradores, funcionários e síndicos
- ✅ **Gerenciamento de Unidades**: Controle de apartamentos e ocupação
- ✅ **Reservas de Áreas Comuns**: Sistema de agendamento de espaços
- ✅ **Ordens de Serviço**: Controle de manutenção e reparos
- ✅ **Hierarquia de Funções**: Diferentes permissões por tipo de usuário

## 🗄️ Estrutura do Banco de Dados

### Arquivos Principais

| Arquivo | Descrição |
|---------|-----------|
| `database_schema.sql` | Schema completo do banco de dados (DDL) |
| `sample_data.sql` | Dados de exemplo para teste |
| `useful_queries.sql` | Consultas úteis e funções |
| `test_database.sql` | Script de teste e validação |
| `DATABASE_DOCUMENTATION.md` | Documentação técnica completa |

### Principais Entidades

- **👥 People**: Tabela base para todas as pessoas
- **🏠 Residents**: Moradores do condomínio
- **👷 Employees**: Funcionários de manutenção
- **⚖️ Syndics**: Síndicos (administradores)
- **🏢 Buildings**: Blocos/edifícios
- **🚪 Units**: Apartamentos/unidades
- **🎯 Common Areas**: Áreas comuns (salão, churrasqueira, etc.)
- **📅 Reservations**: Reservas de áreas comuns
- **🔧 Service Orders**: Ordens de serviço de manutenção

## 🚀 Como Usar

### Pré-requisitos

- PostgreSQL 12 ou superior
- Acesso administrativo ao banco de dados

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/Monkius-Maximus/SGMP-IESI-BD.git
cd SGMP-IESI-BD
```

2. **Conecte ao PostgreSQL**
```bash
psql -U seu_usuario -d nome_do_banco
```

3. **Execute os scripts na ordem**
```sql
-- 1. Criar estrutura do banco
\i database_schema.sql

-- 2. Inserir dados de exemplo
\i sample_data.sql

-- 3. Carregar consultas úteis
\i useful_queries.sql

-- 4. Testar instalação
\i test_database.sql
```

### Verificação da Instalação

Após executar os scripts, você deve ver:
- ✅ 11 tabelas criadas
- ✅ 3 views especializadas
- ✅ Dados de exemplo inseridos
- ✅ Funções utilitárias funcionando
- ✅ Todos os testes passando

## 📊 Funcionalidades Implementadas

### 1. Gerenciamento de Pessoas
- Cadastro unificado com herança de tabelas
- Validação de CPF e email
- Contratos de locação para inquilinos
- Mandatos para síndicos
- Cargos e salários para funcionários

### 2. Controle de Unidades
- Múltiplos blocos/edifícios
- Apartamentos com características específicas
- Relacionamento N:N entre moradores e unidades
- Controle de datas de mudança

### 3. Sistema de Reservas
- Áreas comuns configuráveis
- Verificação automática de disponibilidade
- Sistema de aprovação para áreas especiais
- Cálculo automático de custos

### 4. Ordens de Serviço
- Priorização automática (urgente, alta, média, baixa)
- Atribuição a funcionários
- Controle de custos estimados vs reais
- Vinculação a unidades ou áreas comuns

## 🔍 Consultas Úteis

### Moradores por Bloco
```sql
SELECT b.name as bloco, COUNT(*) as total_moradores
FROM buildings b
JOIN units u ON b.id = u.building_id
JOIN unit_residents ur ON u.id = ur.unit_id
WHERE ur.move_out_date IS NULL
GROUP BY b.name;
```

### Reservas do Mês
```sql
SELECT ca.name, COUNT(*) as total_reservas
FROM reservations r
JOIN common_areas ca ON r.common_area_id = ca.id
WHERE EXTRACT(MONTH FROM r.reservation_date) = EXTRACT(MONTH FROM CURRENT_DATE)
GROUP BY ca.name;
```

### Ordens de Serviço Pendentes
```sql
SELECT * FROM active_service_orders_view
WHERE status = 'open'
ORDER BY prioridade, data_abertura;
```

## 📈 Relatórios Disponíveis

- **Ocupação por Bloco**: Taxa de ocupação de cada edifício
- **Receita de Reservas**: Faturamento mensal das áreas comuns
- **Performance de Funcionários**: Produtividade da equipe
- **Custos de Manutenção**: Análise de gastos com reparos

## 🛡️ Segurança e Validações

- ✅ Integridade referencial em todas as relações
- ✅ Validação de formatos (CPF, email)
- ✅ Constraints de negócio (datas, horários)
- ✅ Índices para performance otimizada
- ✅ Triggers para atualizações automáticas

## 📚 Documentação

Para informações técnicas detalhadas, consulte:
- [`DATABASE_DOCUMENTATION.md`](DATABASE_DOCUMENTATION.md) - Documentação completa
- Comentários inline nos arquivos SQL
- Views e funções documentadas

## 🤝 Contribuição

Este projeto foi desenvolvido como parte do curso IESI-BD. Contribuições são bem-vindas!

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Diogo da Silva Rodrigues**
- GitHub: [@Monkius-Maximus](https://github.com/Monkius-Maximus)

---

*Desenvolvido para facilitar a gestão de condomínios e melhorar a qualidade de vida dos moradores! 🏠✨*
