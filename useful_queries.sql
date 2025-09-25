-- ============================================================================
-- SGMP - Sistema de Gerenciamento e Manutenção Predial  
-- Useful Queries and Procedures
-- ============================================================================

-- ============================================================================
-- 1. RESIDENT MANAGEMENT QUERIES
-- ============================================================================

-- Get all residents with their units
SELECT 
    p.full_name,
    p.email,
    p.phone,
    CASE WHEN r.is_owner THEN 'Proprietário' ELSE 'Inquilino' END as tipo,
    b.name as bloco,
    u.unit_number as apartamento,
    u.floor as andar,
    CASE WHEN ur.is_responsible THEN 'Sim' ELSE 'Não' END as responsavel,
    ur.move_in_date as data_mudanca
FROM people p
JOIN residents r ON p.id = r.id  
JOIN unit_residents ur ON r.id = ur.resident_id
JOIN units u ON ur.unit_id = u.id
JOIN buildings b ON u.building_id = b.id
WHERE r.status = 'active' AND ur.move_out_date IS NULL
ORDER BY b.name, u.unit_number;

-- Get residents by building
SELECT 
    b.name as bloco,
    COUNT(DISTINCT ur.resident_id) as total_moradores,
    COUNT(DISTINCT u.id) as total_apartamentos,
    COUNT(DISTINCT u.id) - COUNT(DISTINCT ur.unit_id) as apartamentos_vagos
FROM buildings b
LEFT JOIN units u ON b.id = u.building_id
LEFT JOIN unit_residents ur ON u.id = ur.unit_id AND ur.move_out_date IS NULL
GROUP BY b.id, b.name
ORDER BY b.name;

-- ============================================================================
-- 2. UNIT MANAGEMENT QUERIES  
-- ============================================================================

-- Get vacant units
SELECT 
    b.name as bloco,
    u.unit_number as apartamento, 
    u.floor as andar,
    u.area_sqm as area_m2,
    u.bedrooms as quartos,
    u.bathrooms as banheiros,
    u.parking_spaces as vagas_garagem
FROM units u
JOIN buildings b ON u.building_id = b.id
LEFT JOIN unit_residents ur ON u.id = ur.unit_id AND ur.move_out_date IS NULL
WHERE ur.unit_id IS NULL
ORDER BY b.name, u.unit_number;

-- Get unit occupancy details
SELECT 
    b.name as bloco,
    u.unit_number as apartamento,
    p.full_name as morador,
    p.phone as telefone,
    CASE WHEN ur.is_responsible THEN 'Responsável' ELSE 'Morador' END as tipo,
    CASE WHEN r.is_owner THEN 'Proprietário' ELSE 'Inquilino' END as situacao
FROM units u
JOIN buildings b ON u.building_id = b.id
JOIN unit_residents ur ON u.id = ur.unit_id
JOIN residents r ON ur.resident_id = r.id
JOIN people p ON r.id = p.id
WHERE ur.move_out_date IS NULL
ORDER BY b.name, u.unit_number, ur.is_responsible DESC;

-- ============================================================================
-- 3. COMMON AREAS AND RESERVATIONS
-- ============================================================================

-- Get available common areas for reservation
SELECT 
    ca.name as area,
    ca.description as descricao,
    ca.capacity as capacidade,
    ca.hourly_rate as valor_hora,
    CASE WHEN ca.requires_approval THEN 'Sim' ELSE 'Não' END as precisa_aprovacao,
    ca.operating_hours_start as horario_inicio,
    ca.operating_hours_end as horario_fim
FROM common_areas ca
WHERE ca.is_active = TRUE
ORDER BY ca.name;

-- Get upcoming reservations
SELECT 
    ca.name as area,
    p.full_name as solicitante,
    r.reservation_date as data_reserva,
    r.start_time as horario_inicio,
    r.end_time as horario_fim,
    r.total_cost as valor_total,
    r.status,
    r.notes as observacoes
FROM reservations r
JOIN common_areas ca ON r.common_area_id = ca.id
JOIN residents res ON r.resident_id = res.id
JOIN people p ON res.id = p.id
WHERE r.reservation_date >= CURRENT_DATE
ORDER BY r.reservation_date, r.start_time;

-- Check availability for specific area and date
-- Example: Check if Salão de Festas is available on 2024-03-15 from 18:00 to 22:00
CREATE OR REPLACE FUNCTION check_availability(
    p_area_id INTEGER,
    p_date DATE,
    p_start_time TIME,
    p_end_time TIME
) RETURNS BOOLEAN AS $$
DECLARE
    conflict_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO conflict_count
    FROM reservations
    WHERE common_area_id = p_area_id
    AND reservation_date = p_date
    AND status NOT IN ('cancelled', 'rejected')
    AND (
        (start_time <= p_start_time AND end_time > p_start_time) OR
        (start_time < p_end_time AND end_time >= p_end_time) OR
        (start_time >= p_start_time AND end_time <= p_end_time)
    );
    
    RETURN conflict_count = 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 4. SERVICE ORDERS MANAGEMENT
-- ============================================================================

-- Get open service orders
SELECT 
    so.id,
    so.title as titulo,
    so.description as descricao,
    COALESCE(b.name || ' - Apt ' || u.unit_number, ca.name) as local,
    requester.full_name as solicitante,
    employee.full_name as responsavel,
    emp.position as cargo_responsavel,
    so.priority as prioridade,
    so.status,
    so.estimated_cost as custo_estimado,
    so.scheduled_date as data_agendada,
    so.created_at as data_abertura
FROM service_orders so
JOIN people requester ON so.requested_by = requester.id
LEFT JOIN employees emp ON so.assigned_to = emp.id  
LEFT JOIN people employee ON emp.id = employee.id
LEFT JOIN units u ON so.unit_id = u.id
LEFT JOIN buildings b ON u.building_id = b.id
LEFT JOIN common_areas ca ON so.common_area_id = ca.id
WHERE so.status IN ('open', 'in_progress')
ORDER BY 
    CASE so.priority 
        WHEN 'urgent' THEN 1
        WHEN 'high' THEN 2  
        WHEN 'medium' THEN 3
        WHEN 'low' THEN 4
    END,
    so.created_at;

-- Get service orders by employee
SELECT 
    e.position as cargo,
    p.full_name as funcionario,
    COUNT(CASE WHEN so.status IN ('open', 'in_progress') THEN 1 END) as os_abertas,
    COUNT(CASE WHEN so.status = 'completed' THEN 1 END) as os_concluidas,
    SUM(CASE WHEN so.status = 'completed' THEN so.actual_cost ELSE 0 END) as valor_total_executado
FROM employees e
JOIN people p ON e.id = p.id
LEFT JOIN service_orders so ON e.id = so.assigned_to
WHERE e.status = 'active'
GROUP BY e.id, e.position, p.full_name
ORDER BY p.full_name;

-- ============================================================================
-- 5. FINANCIAL REPORTS
-- ============================================================================

-- Monthly reservation revenue
SELECT 
    EXTRACT(YEAR FROM r.reservation_date) as ano,
    EXTRACT(MONTH FROM r.reservation_date) as mes,
    ca.name as area,
    COUNT(*) as total_reservas,
    SUM(r.total_cost) as receita_total
FROM reservations r
JOIN common_areas ca ON r.common_area_id = ca.id
WHERE r.status = 'completed'
GROUP BY EXTRACT(YEAR FROM r.reservation_date), EXTRACT(MONTH FROM r.reservation_date), ca.id, ca.name
ORDER BY ano DESC, mes DESC, ca.name;

-- Service orders cost summary
SELECT 
    EXTRACT(YEAR FROM so.created_at) as ano,
    EXTRACT(MONTH FROM so.created_at) as mes,
    COUNT(*) as total_os,
    COUNT(CASE WHEN so.status = 'completed' THEN 1 END) as os_concluidas,
    SUM(so.estimated_cost) as custo_estimado_total,
    SUM(so.actual_cost) as custo_real_total,
    AVG(so.actual_cost) as custo_medio_por_os
FROM service_orders so
WHERE so.created_at >= CURRENT_DATE - INTERVAL '12 months'
GROUP BY EXTRACT(YEAR FROM so.created_at), EXTRACT(MONTH FROM so.created_at)
ORDER BY ano DESC, mes DESC;

-- ============================================================================
-- 6. MANAGEMENT DASHBOARDS
-- ============================================================================

-- Current syndic information
SELECT 
    p.full_name as sindico_atual,
    p.email,
    p.phone as telefone,
    s.mandate_start as inicio_mandato,
    s.mandate_end as fim_mandato,
    CURRENT_DATE - s.mandate_start as dias_no_cargo,
    s.mandate_end - CURRENT_DATE as dias_restantes
FROM people p
JOIN syndics s ON p.id = s.id
WHERE s.is_current = TRUE;

-- Building occupancy summary
SELECT 
    b.name as bloco,
    b.total_floors as andares,
    b.units_per_floor as apts_por_andar,
    COUNT(u.id) as total_apartamentos,
    COUNT(ur.unit_id) as apartamentos_ocupados,
    COUNT(u.id) - COUNT(ur.unit_id) as apartamentos_vagos,
    ROUND(COUNT(ur.unit_id)::DECIMAL / COUNT(u.id) * 100, 2) as taxa_ocupacao_pct
FROM buildings b
JOIN units u ON b.id = u.building_id
LEFT JOIN unit_residents ur ON u.id = ur.unit_id AND ur.move_out_date IS NULL
GROUP BY b.id, b.name, b.total_floors, b.units_per_floor
ORDER BY b.name;

-- Active employees summary
SELECT 
    e.position as cargo,
    COUNT(*) as quantidade,
    AVG(e.salary) as salario_medio,
    MIN(e.hire_date) as funcionario_mais_antigo,
    MAX(e.hire_date) as funcionario_mais_recente
FROM employees e
WHERE e.status = 'active'
GROUP BY e.position
ORDER BY quantidade DESC;

-- ============================================================================
-- 7. UTILITY FUNCTIONS
-- ============================================================================

-- Function to calculate age
CREATE OR REPLACE FUNCTION calculate_age(birth_date DATE) 
RETURNS INTEGER AS $$
BEGIN
    RETURN EXTRACT(YEAR FROM AGE(birth_date));
END;
$$ LANGUAGE plpgsql;

-- Function to format CPF
CREATE OR REPLACE FUNCTION format_cpf(cpf_number VARCHAR(11))
RETURNS VARCHAR(14) AS $$
BEGIN
    IF LENGTH(cpf_number) = 11 THEN
        RETURN SUBSTRING(cpf_number, 1, 3) || '.' || 
               SUBSTRING(cpf_number, 4, 3) || '.' ||
               SUBSTRING(cpf_number, 7, 3) || '-' ||
               SUBSTRING(cpf_number, 10, 2);
    ELSE
        RETURN cpf_number;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 8. SAMPLE USAGE OF THE FUNCTIONS
-- ============================================================================

-- Example: Check if Salão de Festas (id=1) is available on a specific date
-- SELECT check_availability(1, '2024-03-15', '18:00', '22:00') as disponivel;

-- Example: Show residents with formatted CPF and age
SELECT 
    p.full_name as nome,
    format_cpf(p.cpf) as cpf_formatado,
    calculate_age(p.birth_date) as idade,
    p.email
FROM people p
JOIN residents r ON p.id = r.id
WHERE r.status = 'active'
ORDER BY p.full_name;

-- Example: Monthly statistics
SELECT 
    'Resumo do Sistema' as categoria,
    (SELECT COUNT(*) FROM residents WHERE status = 'active') as moradores_ativos,
    (SELECT COUNT(*) FROM employees WHERE status = 'active') as funcionarios_ativos,
    (SELECT COUNT(*) FROM reservations WHERE reservation_date >= CURRENT_DATE) as reservas_futuras,
    (SELECT COUNT(*) FROM service_orders WHERE status IN ('open', 'in_progress')) as os_abertas;