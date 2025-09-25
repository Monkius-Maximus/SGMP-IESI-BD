# SGMP - Sistema de Gerenciamento e Manutenção Predial

## Documentação do Banco de Dados

### 1. Visão Geral

Este banco de dados foi projetado para gerenciar um sistema de condomínio residencial, suportando todas as operações necessárias para o controle de moradores, funcionários, unidades, áreas comuns e ordens de serviço.

### 2. Arquitetura do Banco de Dados

O sistema utiliza uma arquitetura relacional com PostgreSQL, seguindo os princípios de normalização e integridade referencial.

#### 2.1 Principais Características:
- **Herança de tabelas**: Utiliza uma tabela base `people` com especializações para `residents`, `employees` e `syndics`
- **Integridade referencial**: Todas as relações são protegidas por chaves estrangeiras
- **Índices otimizados**: Índices estratégicos para melhor performance
- **Triggers automáticos**: Atualização automática de timestamps
- **Views especializadas**: Consultas pré-definidas para operações comuns
- **Funções utilitárias**: Funções para validação e formatação

### 3. Estrutura das Tabelas

#### 3.1 Gerenciamento de Pessoas

##### `people` (Tabela Base)
```sql
- id (SERIAL PRIMARY KEY)
- full_name (VARCHAR(255) NOT NULL)
- cpf (VARCHAR(11) UNIQUE NOT NULL)
- email (VARCHAR(255) UNIQUE)
- phone (VARCHAR(20))
- mobile_phone (VARCHAR(20))
- birth_date (DATE)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

**Validações:**
- CPF deve ter exatamente 11 dígitos
- Email deve seguir formato válido

##### `residents` (Herda de people)
```sql
- id (INTEGER PRIMARY KEY → people.id)
- emergency_contact_name (VARCHAR(255))
- emergency_contact_phone (VARCHAR(20))
- is_owner (BOOLEAN DEFAULT FALSE)
- rental_contract_start (DATE)
- rental_contract_end (DATE)
- status (VARCHAR(20) CHECK: 'active', 'inactive', 'moved_out')
```

##### `employees` (Herda de people)
```sql
- id (INTEGER PRIMARY KEY → people.id)
- position (VARCHAR(100) NOT NULL)
- hire_date (DATE NOT NULL)
- salary (DECIMAL(10,2))
- work_schedule (VARCHAR(100))
- status (VARCHAR(20) CHECK: 'active', 'inactive', 'terminated')
```

##### `syndics` (Herda de people)
```sql
- id (INTEGER PRIMARY KEY → people.id)
- mandate_start (DATE NOT NULL)
- mandate_end (DATE NOT NULL)
- is_current (BOOLEAN DEFAULT FALSE)
```

#### 3.2 Gerenciamento de Unidades

##### `buildings`
```sql
- id (SERIAL PRIMARY KEY)
- name (VARCHAR(100) NOT NULL)
- description (TEXT)
- total_floors (INTEGER NOT NULL)
- units_per_floor (INTEGER NOT NULL)
- created_at (TIMESTAMP)
```

##### `units`
```sql
- id (SERIAL PRIMARY KEY)
- building_id (INTEGER → buildings.id)
- unit_number (VARCHAR(20) NOT NULL)
- floor (INTEGER NOT NULL)
- area_sqm (DECIMAL(8,2))
- bedrooms (INTEGER DEFAULT 0)
- bathrooms (INTEGER DEFAULT 0)
- parking_spaces (INTEGER DEFAULT 0)
- status (VARCHAR(20) CHECK: 'occupied', 'vacant', 'maintenance')
- created_at (TIMESTAMP)
```

**Restrições:**
- Combinação única de `building_id` + `unit_number`

##### `unit_residents` (Relacionamento N:N)
```sql
- id (SERIAL PRIMARY KEY)
- unit_id (INTEGER → units.id)
- resident_id (INTEGER → residents.id)
- is_responsible (BOOLEAN DEFAULT FALSE)
- move_in_date (DATE NOT NULL)
- move_out_date (DATE)
- created_at (TIMESTAMP)
```

#### 3.3 Áreas Comuns e Reservas

##### `common_areas`
```sql
- id (SERIAL PRIMARY KEY)
- name (VARCHAR(255) NOT NULL)
- description (TEXT)
- capacity (INTEGER)
- hourly_rate (DECIMAL(8,2) DEFAULT 0.00)
- requires_approval (BOOLEAN DEFAULT FALSE)
- is_active (BOOLEAN DEFAULT TRUE)
- operating_hours_start (TIME)
- operating_hours_end (TIME)
- created_at (TIMESTAMP)
```

##### `reservations`
```sql
- id (SERIAL PRIMARY KEY)
- common_area_id (INTEGER → common_areas.id)
- resident_id (INTEGER → residents.id)
- reservation_date (DATE NOT NULL)
- start_time (TIME NOT NULL)
- end_time (TIME NOT NULL)
- total_cost (DECIMAL(8,2) DEFAULT 0.00)
- status (VARCHAR(20) CHECK: 'pending', 'approved', 'rejected', 'cancelled', 'completed')
- approved_by (INTEGER → syndics.id)
- approval_date (TIMESTAMP)
- notes (TEXT)
- created_at (TIMESTAMP)
```

**Validações:**
- `end_time` deve ser maior que `start_time`
- `reservation_date` deve ser no futuro ou hoje

#### 3.4 Ordens de Serviço

##### `service_orders`
```sql
- id (SERIAL PRIMARY KEY)
- title (VARCHAR(255) NOT NULL)
- description (TEXT NOT NULL)
- unit_id (INTEGER → units.id)
- common_area_id (INTEGER → common_areas.id)
- requested_by (INTEGER → people.id)
- assigned_to (INTEGER → employees.id)
- priority (VARCHAR(20) CHECK: 'low', 'medium', 'high', 'urgent')
- status (VARCHAR(20) CHECK: 'open', 'in_progress', 'completed', 'cancelled')
- estimated_cost (DECIMAL(10,2))
- actual_cost (DECIMAL(10,2))
- scheduled_date (DATE)
- completion_date (DATE)
- notes (TEXT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

**Restrições:**
- Deve ter `unit_id` OU `common_area_id` (não ambos, não nenhum)

### 4. Views Especializadas

#### 4.1 `resident_units_view`
Exibe informações completas dos moradores com suas unidades.

#### 4.2 `active_service_orders_view`
Lista todas as ordens de serviço em andamento com detalhes completos.

#### 4.3 `current_syndic_view`
Mostra informações do síndico atual.

### 5. Índices para Performance

- **people**: CPF, email, nome
- **units**: building_id, unit_number
- **unit_residents**: unit_id, resident_id
- **reservations**: data, área, morador, status
- **service_orders**: status, prioridade, unidade, área, responsável

### 6. Funções Utilitárias

#### 6.1 `check_availability(area_id, date, start_time, end_time)`
Verifica disponibilidade de área comum para reserva.

#### 6.2 `calculate_age(birth_date)`
Calcula idade baseada na data de nascimento.

#### 6.3 `format_cpf(cpf_number)`
Formata CPF no padrão XXX.XXX.XXX-XX.

#### 6.4 `update_updated_at_column()`
Trigger para atualização automática do campo `updated_at`.

### 7. Casos de Uso Principais

#### 7.1 Cadastro de Morador
1. Inserir dados básicos na tabela `people`
2. Inserir dados específicos na tabela `residents`
3. Associar à unidade através de `unit_residents`

#### 7.2 Reserva de Área Comum
1. Verificar disponibilidade com `check_availability()`
2. Inserir reserva na tabela `reservations`
3. Aguardar aprovação se necessário

#### 7.3 Abertura de Ordem de Serviço
1. Inserir OS na tabela `service_orders`
2. Associar à unidade ou área comum
3. Atribuir funcionário responsável

#### 7.4 Relatórios Gerenciais
- Ocupação por bloco
- Receita de reservas
- Status das ordens de serviço
- Performance dos funcionários

### 8. Segurança e Integridade

#### 8.1 Validações Implementadas
- Formato de CPF e email
- Datas de mandato do síndico
- Horários de reserva
- Status válidos para todas as entidades

#### 8.2 Integridade Referencial
- Cascata para exclusões quando apropriado
- SET NULL para referências opcionais
- Restrições de chave única onde necessário

### 9. Considerações de Performance

#### 9.1 Índices Estratégicos
- Campos de busca frequente indexados
- Índices compostos para consultas específicas
- Análise regular das estatísticas das tabelas

#### 9.2 Otimizações
- Views materializadas para relatórios complexos (futuro)
- Particionamento por data para tabelas históricas (futuro)
- Cache de consultas frequentes (futuro)

### 10. Instalação e Uso

#### 10.1 Ordem de Execução dos Scripts
1. `database_schema.sql` - Cria a estrutura do banco
2. `sample_data.sql` - Insere dados de exemplo
3. `useful_queries.sql` - Consultas e funções úteis

#### 10.2 Requisitos
- PostgreSQL 12 ou superior
- Extensões: nenhuma adicional necessária
- Permissões: CREATE TABLE, CREATE FUNCTION, CREATE TRIGGER

#### 10.3 Exemplo de Uso
```sql
-- Conectar ao PostgreSQL
psql -U username -d database_name

-- Executar scripts na ordem
\i database_schema.sql
\i sample_data.sql
\i useful_queries.sql

-- Verificar instalação
SELECT 'Instalação concluída!' as status;
```

### 11. Manutenção e Monitoramento

#### 11.1 Backup Recomendado
```bash
pg_dump -U username -d database_name > backup_sgmp.sql
```

#### 11.2 Monitoramento
- Verificar crescimento das tabelas principais
- Monitorar performance das consultas
- Atualizar estatísticas regularmente: `ANALYZE;`

#### 11.3 Logs de Auditoria (Futuro)
- Tabela de auditoria para mudanças críticas
- Log de acessos ao sistema
- Histórico de modificações de dados

### 12. Extensões Futuras

#### 12.1 Possíveis Melhorias
- Sistema de notificações
- Controle de acesso baseado em roles
- API REST para integração
- Dashboard web para gestão
- Sistema de cobrança integrado
- Controle de visitantes
- Sistema de multas e advertências

#### 12.2 Escalabilidade
- Replicação para alta disponibilidade
- Sharding por condomínio
- Cache distribuído
- Microserviços especializados