# SGMP - Diagrama Entidade-Relacionamento (ER)

## Descrição Conceitual do Modelo

### Entidades Principais e Relacionamentos

```
PEOPLE (Base)
├── RESIDENTS (ISA)
├── EMPLOYEES (ISA)  
└── SYNDICS (ISA)

BUILDINGS
└── UNITS (1:N)
    └── UNIT_RESIDENTS (N:M with RESIDENTS)

COMMON_AREAS
└── RESERVATIONS (1:N)
    └── approved_by → SYNDICS (N:1)
    └── resident_id → RESIDENTS (N:1)

SERVICE_ORDERS
├── requested_by → PEOPLE (N:1)
├── assigned_to → EMPLOYEES (N:1)
├── unit_id → UNITS (N:1)
└── common_area_id → COMMON_AREAS (N:1)
```

## Entidades Detalhadas

### 1. PEOPLE (Entidade Base)
**Atributos:**
- 🔑 id (PK)
- full_name
- cpf (UNIQUE)
- email (UNIQUE)
- phone, mobile_phone
- birth_date
- created_at, updated_at

**Especializa-se em:**
- RESIDENTS (Moradores)
- EMPLOYEES (Funcionários)
- SYNDICS (Síndicos)

### 2. RESIDENTS (Herda de PEOPLE)
**Atributos Específicos:**
- emergency_contact_name
- emergency_contact_phone
- is_owner (boolean)
- rental_contract_start, rental_contract_end
- status (active/inactive/moved_out)

**Relacionamentos:**
- N:M com UNITS através de UNIT_RESIDENTS
- 1:N com RESERVATIONS
- 1:N com SERVICE_ORDERS (como solicitante)

### 3. EMPLOYEES (Herda de PEOPLE)
**Atributos Específicos:**
- position
- hire_date
- salary
- work_schedule
- status (active/inactive/terminated)

**Relacionamentos:**
- 1:N com SERVICE_ORDERS (como responsável)

### 4. SYNDICS (Herda de PEOPLE)
**Atributos Específicos:**
- mandate_start, mandate_end
- is_current (boolean)

**Relacionamentos:**
- 1:N com RESERVATIONS (aprovações)

### 5. BUILDINGS
**Atributos:**
- 🔑 id (PK)
- name
- description
- total_floors
- units_per_floor
- created_at

**Relacionamentos:**
- 1:N com UNITS

### 6. UNITS
**Atributos:**
- 🔑 id (PK)
- 🔗 building_id (FK → BUILDINGS)
- unit_number
- floor
- area_sqm
- bedrooms, bathrooms
- parking_spaces
- status (occupied/vacant/maintenance)
- created_at

**Relacionamentos:**
- N:1 com BUILDINGS
- N:M com RESIDENTS através de UNIT_RESIDENTS
- 1:N com SERVICE_ORDERS

### 7. UNIT_RESIDENTS (Entidade Associativa)
**Atributos:**
- 🔑 id (PK)
- 🔗 unit_id (FK → UNITS)
- 🔗 resident_id (FK → RESIDENTS)
- is_responsible (boolean)
- move_in_date, move_out_date
- created_at

**Função:** Relaciona moradores com suas unidades, permitindo histórico

### 8. COMMON_AREAS
**Atributos:**
- 🔑 id (PK)
- name
- description
- capacity
- hourly_rate
- requires_approval (boolean)
- is_active (boolean)
- operating_hours_start, operating_hours_end
- created_at

**Relacionamentos:**
- 1:N com RESERVATIONS
- 1:N com SERVICE_ORDERS

### 9. RESERVATIONS
**Atributos:**
- 🔑 id (PK)
- 🔗 common_area_id (FK → COMMON_AREAS)
- 🔗 resident_id (FK → RESIDENTS)
- 🔗 approved_by (FK → SYNDICS)
- reservation_date
- start_time, end_time
- total_cost
- status (pending/approved/rejected/cancelled/completed)
- approval_date
- notes
- created_at

**Relacionamentos:**
- N:1 com COMMON_AREAS
- N:1 com RESIDENTS
- N:1 com SYNDICS (aprovação)

### 10. SERVICE_ORDERS
**Atributos:**
- 🔑 id (PK)
- 🔗 unit_id (FK → UNITS) [opcional]
- 🔗 common_area_id (FK → COMMON_AREAS) [opcional]
- 🔗 requested_by (FK → PEOPLE)
- 🔗 assigned_to (FK → EMPLOYEES) [opcional]
- title, description
- priority (low/medium/high/urgent)
- status (open/in_progress/completed/cancelled)
- estimated_cost, actual_cost
- scheduled_date, completion_date
- notes
- created_at, updated_at

**Relacionamentos:**
- N:1 com UNITS (opcional - para manutenção de apartamentos)
- N:1 com COMMON_AREAS (opcional - para manutenção de áreas comuns)
- N:1 com PEOPLE (solicitante)
- N:1 com EMPLOYEES (responsável)

## Regras de Negócio Implementadas

### Integridade Referencial
1. **People → Specializations**: Cascata na exclusão
2. **Buildings → Units**: Cascata na exclusão
3. **Units → Unit_Residents**: Cascata na exclusão
4. **Service Orders locations**: Deve ter unit_id OU common_area_id (não ambos)

### Constraints de Domínio
1. **CPF**: Exatamente 11 dígitos numéricos
2. **Email**: Formato válido de email
3. **Datas**: Datas de fim posteriores às de início
4. **Horários**: Horário fim posterior ao início
5. **Status**: Valores pré-definidos válidos

### Constraints de Unicidade
1. **CPF**: Único em todo o sistema
2. **Email**: Único em todo o sistema
3. **Unit Number**: Único por building
4. **Unit-Resident**: Combinação única (não duplicar associações ativas)

## Cardinalidades Principais

```
PEOPLE 1 ──────── N RESIDENTS
PEOPLE 1 ──────── N EMPLOYEES  
PEOPLE 1 ──────── N SYNDICS

BUILDINGS 1 ──── N UNITS
RESIDENTS N ──── M UNITS (via UNIT_RESIDENTS)

COMMON_AREAS 1 ─ N RESERVATIONS
RESIDENTS 1 ──── N RESERVATIONS
SYNDICS 1 ────── N RESERVATIONS (aprovações)

PEOPLE 1 ──────── N SERVICE_ORDERS (solicitante)
EMPLOYEES 1 ───── N SERVICE_ORDERS (responsável)
UNITS 1 ───────── N SERVICE_ORDERS
COMMON_AREAS 1 ─ N SERVICE_ORDERS
```

## Views Materializadas Conceituais

### resident_units_view
Combina informações de moradores com suas unidades atuais.

### active_service_orders_view  
Lista todas as ordens de serviço abertas ou em progresso.

### current_syndic_view
Exibe informações do síndico atual.

## Índices Estratégicos

### Performance Indexes
- **people**: (cpf), (email), (full_name)
- **units**: (building_id), (unit_number), (building_id, unit_number)
- **unit_residents**: (unit_id), (resident_id), (unit_id, resident_id)
- **reservations**: (reservation_date), (common_area_id), (status)
- **service_orders**: (status), (priority), (assigned_to)

## Extensibilidade

O modelo permite futuras extensões como:
- Sistema de cobrança (taxas condominiais)
- Controle de visitantes
- Sistema de multas
- Histórico de comunicados
- Controle de assembleia
- Sistema de votação eletrônica

---

**Legenda:**
- 🔑 = Chave Primária
- 🔗 = Chave Estrangeira
- ISA = Relacionamento de herança/especialização
- N:M = Relacionamento muitos-para-muitos
- 1:N = Relacionamento um-para-muitos