-- ============================================================================
-- SGMP - Sistema de Gerenciamento e Manutenção Predial
-- Sample Data for Testing and Demonstration
-- ============================================================================

-- Note: This file should be run after database_schema.sql

-- ============================================================================
-- 1. SAMPLE BUILDINGS
-- ============================================================================

INSERT INTO buildings (name, description, total_floors, units_per_floor) VALUES
('Bloco A', 'Bloco principal com vista para jardim', 10, 4),
('Bloco B', 'Bloco lateral com vista para piscina', 8, 6),
('Bloco C', 'Bloco dos fundos, mais silencioso', 12, 2);

-- ============================================================================
-- 2. SAMPLE UNITS
-- ============================================================================

-- Units for Building A (10 floors, 4 units per floor)
INSERT INTO units (building_id, unit_number, floor, area_sqm, bedrooms, bathrooms, parking_spaces) 
SELECT 
    1,
    LPAD((floor_num * 100 + unit_num)::text, 3, '0'),
    floor_num,
    CASE 
        WHEN unit_num <= 2 THEN 85.5
        ELSE 120.0
    END,
    CASE 
        WHEN unit_num <= 2 THEN 2
        ELSE 3
    END,
    CASE 
        WHEN unit_num <= 2 THEN 2
        ELSE 3
    END,
    1
FROM generate_series(1, 10) AS floor_num,
     generate_series(1, 4) AS unit_num;

-- Units for Building B (8 floors, 6 units per floor) 
INSERT INTO units (building_id, unit_number, floor, area_sqm, bedrooms, bathrooms, parking_spaces)
SELECT 
    2,
    LPAD((floor_num * 100 + unit_num)::text, 3, '0'),
    floor_num,
    75.0,
    2,
    2,
    1
FROM generate_series(1, 8) AS floor_num,
     generate_series(1, 6) AS unit_num;

-- Units for Building C (12 floors, 2 units per floor)
INSERT INTO units (building_id, unit_number, floor, area_sqm, bedrooms, bathrooms, parking_spaces)
SELECT 
    3,
    LPAD((floor_num * 100 + unit_num)::text, 3, '0'),
    floor_num,
    150.0,
    4,
    3,
    2
FROM generate_series(1, 12) AS floor_num,
     generate_series(1, 2) AS unit_num;

-- ============================================================================
-- 3. SAMPLE PEOPLE
-- ============================================================================

-- Sample Residents
INSERT INTO people (full_name, cpf, email, phone, mobile_phone, birth_date) VALUES
('João Silva Santos', '12345678901', 'joao.silva@email.com', '1133334444', '11987654321', '1985-03-15'),
('Maria Oliveira Costa', '98765432109', 'maria.oliveira@email.com', '1133335555', '11987654322', '1990-07-22'),
('Carlos Eduardo Lima', '11122233344', 'carlos.lima@email.com', '1133336666', '11987654323', '1982-11-08'),
('Ana Paula Rodrigues', '55566677788', 'ana.rodrigues@email.com', '1133337777', '11987654324', '1988-01-30'),
('Pedro Henrique Alves', '99988877766', 'pedro.alves@email.com', '1133338888', '11987654325', '1975-09-12'),
('Fernanda Souza Martins', '44433322211', 'fernanda.martins@email.com', '1133339999', '11987654326', '1993-05-18'),
('Roberto Carlos Pereira', '77788899900', 'roberto.pereira@email.com', '1133330000', '11987654327', '1980-12-03'),
('Juliana Ferreira Lima', '33344455566', 'juliana.lima@email.com', '1133331111', '11987654328', '1987-08-25');

-- Sample Employees
INSERT INTO people (full_name, cpf, email, phone, mobile_phone, birth_date) VALUES
('José da Silva Manutenção', '12312312312', 'jose.manutencao@email.com', '1133332222', '11987654329', '1970-04-10'),
('Maria das Dores Limpeza', '45645645645', 'maria.limpeza@email.com', '1133333333', '11987654330', '1975-06-20'),
('Antonio Segurança Noite', '78978978978', 'antonio.seguranca@email.com', '1133334444', '11987654331', '1985-02-14'),
('Francisco Porteiro Dia', '32132132132', 'francisco.porteiro@email.com', '1133335555', '11987654332', '1978-09-05');

-- Sample Syndic
INSERT INTO people (full_name, cpf, email, phone, mobile_phone, birth_date) VALUES
('Dr. Ricardo Mendes Silva', '65465465465', 'ricardo.sindico@email.com', '1133336666', '11987654333', '1965-11-30');

-- ============================================================================
-- 4. ASSIGN ROLES TO PEOPLE
-- ============================================================================

-- Create residents (first 8 people)
INSERT INTO residents (id, emergency_contact_name, emergency_contact_phone, is_owner, status)
SELECT id, 
       'Contato Emergência ' || full_name, 
       '11999888777', 
       CASE WHEN id % 3 = 0 THEN TRUE ELSE FALSE END,
       'active'
FROM people WHERE id <= 8;

-- Create employees (people 9-12)
INSERT INTO employees (id, position, hire_date, salary, work_schedule, status) VALUES
(9, 'Técnico de Manutenção', '2020-01-15', 3500.00, 'Segunda a Sexta, 8h às 17h', 'active'),
(10, 'Auxiliar de Limpeza', '2021-03-10', 2800.00, 'Segunda a Sábado, 6h às 14h', 'active'),
(11, 'Porteiro Noturno', '2019-08-20', 3200.00, 'Segunda a Domingo, 22h às 6h', 'active'),
(12, 'Porteiro Diurno', '2022-01-05', 3000.00, 'Segunda a Domingo, 6h às 18h', 'active');

-- Create syndic (person 13)
INSERT INTO syndics (id, mandate_start, mandate_end, is_current) VALUES
(13, '2024-01-01', '2025-12-31', TRUE);

-- ============================================================================
-- 5. ASSIGN RESIDENTS TO UNITS
-- ============================================================================

-- Assign residents to units
INSERT INTO unit_residents (unit_id, resident_id, is_responsible, move_in_date) VALUES
-- Building A
(1, 1, TRUE, '2023-01-15'),   -- João Silva - A101
(5, 2, TRUE, '2023-03-10'),   -- Maria Oliveira - A201  
(9, 3, TRUE, '2022-11-20'),   -- Carlos Lima - A301
(13, 4, TRUE, '2024-02-01'),  -- Ana Paula - A401
-- Building B  
(41, 5, TRUE, '2023-06-15'),  -- Pedro Henrique - B101
(47, 6, TRUE, '2023-09-01'),  -- Fernanda Martins - B201
-- Building C
(89, 7, TRUE, '2022-08-10'),  -- Roberto Pereira - C101
(91, 8, TRUE, '2024-01-05');  -- Juliana Lima - C201

-- Add some family members (Maria and Carlos share unit A201)
INSERT INTO unit_residents (unit_id, resident_id, is_responsible, move_in_date) VALUES
(5, 3, FALSE, '2023-03-10'); -- Carlos also lives in A201 with Maria

-- ============================================================================
-- 6. COMMON AREAS
-- ============================================================================

INSERT INTO common_areas (name, description, capacity, hourly_rate, requires_approval, operating_hours_start, operating_hours_end) VALUES
('Salão de Festas', 'Salão principal para eventos e comemorações', 80, 150.00, TRUE, '08:00', '23:00'),
('Churrasqueira 1', 'Área de churrasqueira com vista para jardim', 20, 50.00, FALSE, '08:00', '22:00'),
('Churrasqueira 2', 'Segunda área de churrasqueira', 15, 45.00, FALSE, '08:00', '22:00'),
('Salão de Jogos', 'Sala com mesa de sinuca, ping-pong e jogos', 25, 30.00, FALSE, '08:00', '22:00'),
('Quadra Poliesportiva', 'Quadra para futebol, basquete e vôlei', 20, 40.00, FALSE, '06:00', '22:00'),
('Piscina Adulto', 'Piscina principal para adultos', 50, 0.00, FALSE, '06:00', '22:00'),
('Piscina Infantil', 'Piscina para crianças', 20, 0.00, FALSE, '08:00', '20:00'),
('Academia', 'Sala de exercícios com equipamentos', 15, 0.00, FALSE, '05:00', '23:00');

-- ============================================================================
-- 7. SAMPLE RESERVATIONS
-- ============================================================================

INSERT INTO reservations (common_area_id, resident_id, reservation_date, start_time, end_time, total_cost, status, notes) VALUES
-- Future reservations
(1, 1, CURRENT_DATE + 7, '18:00', '23:00', 750.00, 'pending', 'Aniversário de 40 anos'),
(2, 2, CURRENT_DATE + 3, '12:00', '16:00', 200.00, 'approved', 'Almoço em família'),
(4, 3, CURRENT_DATE + 5, '14:00', '18:00', 120.00, 'approved', 'Torneio de sinuca'),
(5, 4, CURRENT_DATE + 1, '08:00', '10:00', 80.00, 'approved', 'Treino de vôlei'),
-- Past reservations
(1, 5, CURRENT_DATE - 10, '19:00', '23:00', 600.00, 'completed', 'Festa de formatura'),
(3, 6, CURRENT_DATE - 5, '15:00', '19:00', 180.00, 'completed', 'Confraternização'),
(2, 7, CURRENT_DATE - 2, '11:00', '15:00', 200.00, 'completed', 'Churrasco de domingo');

-- Update approval information for approved reservations
UPDATE reservations 
SET approved_by = 13, approval_date = created_at + INTERVAL '2 hours'
WHERE status = 'approved';

-- ============================================================================
-- 8. SAMPLE SERVICE ORDERS
-- ============================================================================

INSERT INTO service_orders (title, description, unit_id, requested_by, assigned_to, priority, status, estimated_cost, scheduled_date, notes) VALUES
-- Unit maintenance
('Vazamento no banheiro', 'Torneira da pia está vazando constantemente', 1, 1, 9, 'high', 'in_progress', 150.00, CURRENT_DATE + 1, 'Agendado para amanhã de manhã'),
('Problema elétrico na cozinha', 'Tomadas não estão funcionando', 5, 2, 9, 'medium', 'open', 200.00, CURRENT_DATE + 3, 'Verificar fiação'),
('Porta do quarto emperrando', 'Porta não fecha completamente', 9, 3, 9, 'low', 'open', 80.00, NULL, ''),
('Ar condicionado não liga', 'Equipamento não responde ao controle', 13, 4, NULL, 'medium', 'open', 300.00, NULL, 'Verificar se é problema elétrico ou do aparelho'),

-- Common area maintenance  
('Limpeza da piscina', 'Piscina está com água turva', NULL, 13, 10, 'high', 'in_progress', 200.00, CURRENT_DATE, 'Tratamento químico necessário'),
('Reparo no salão de festas', 'Algumas cadeiras estão quebradas', NULL, 13, 9, 'medium', 'open', 150.00, CURRENT_DATE + 2, 'Substituir 5 cadeiras'),
('Manutenção da quadra', 'Rede de vôlei precisa ser trocada', NULL, 13, 9, 'low', 'open', 100.00, NULL, '');

-- Update common_area_id for common area service orders
UPDATE service_orders SET common_area_id = 6 WHERE title = 'Limpeza da piscina';
UPDATE service_orders SET common_area_id = 1 WHERE title = 'Reparo no salão de festas';  
UPDATE service_orders SET common_area_id = 5 WHERE title = 'Manutenção da quadra';

-- Add some completed service orders
INSERT INTO service_orders (title, description, unit_id, requested_by, assigned_to, priority, status, estimated_cost, actual_cost, completion_date, notes) VALUES
('Troca de fechadura', 'Solicitação de nova fechadura por segurança', 41, 5, 9, 'medium', 'completed', 120.00, 135.00, CURRENT_DATE - 3, 'Serviço concluído com sucesso');

-- ============================================================================
-- 9. UPDATE STATISTICS (Optional)
-- ============================================================================

-- Update table statistics for better query performance
ANALYZE people;
ANALYZE residents; 
ANALYZE syndics;
ANALYZE employees;
ANALYZE buildings;
ANALYZE units;
ANALYZE unit_residents;
ANALYZE common_areas;
ANALYZE reservations;
ANALYZE service_orders;

-- Display summary information
SELECT 'Data insertion completed successfully!' as status;
SELECT 'Total People: ' || COUNT(*) as count FROM people;
SELECT 'Total Residents: ' || COUNT(*) as count FROM residents;
SELECT 'Total Employees: ' || COUNT(*) as count FROM employees;
SELECT 'Total Units: ' || COUNT(*) as count FROM units;
SELECT 'Total Common Areas: ' || COUNT(*) as count FROM common_areas;
SELECT 'Total Reservations: ' || COUNT(*) as count FROM reservations;
SELECT 'Total Service Orders: ' || COUNT(*) as count FROM service_orders;