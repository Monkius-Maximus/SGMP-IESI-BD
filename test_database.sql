-- ============================================================================
-- SGMP - Sistema de Gerenciamento e Manutenção Predial
-- Database Installation and Functionality Tests
-- ============================================================================

-- This script tests the database functionality after installation
-- Run this after executing database_schema.sql and sample_data.sql

\echo '=== SGMP Database Functionality Tests ==='
\echo ''

-- Test 1: Check if all tables were created
\echo '1. Checking table creation...'
SELECT 
    COUNT(*) as total_tables,
    string_agg(table_name, ', ' ORDER BY table_name) as table_names
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

\echo ''

-- Test 2: Check data insertion
\echo '2. Checking data insertion...'
SELECT 'People' as entity, COUNT(*) as count FROM people
UNION ALL
SELECT 'Residents', COUNT(*) FROM residents  
UNION ALL
SELECT 'Employees', COUNT(*) FROM employees
UNION ALL
SELECT 'Syndics', COUNT(*) FROM syndics
UNION ALL
SELECT 'Buildings', COUNT(*) FROM buildings
UNION ALL
SELECT 'Units', COUNT(*) FROM units
UNION ALL
SELECT 'Common Areas', COUNT(*) FROM common_areas
UNION ALL
SELECT 'Reservations', COUNT(*) FROM reservations
UNION ALL
SELECT 'Service Orders', COUNT(*) FROM service_orders;

\echo ''

-- Test 3: Check views creation
\echo '3. Checking views...'
SELECT view_name 
FROM information_schema.views 
WHERE table_schema = 'public'
ORDER BY view_name;

\echo ''

-- Test 4: Test relationships and joins
\echo '4. Testing relationships - Residents with Units:'
SELECT 
    p.full_name as morador,
    b.name as bloco,
    u.unit_number as apartamento,
    CASE WHEN ur.is_responsible THEN 'Responsável' ELSE 'Morador' END as tipo
FROM people p
JOIN residents r ON p.id = r.id
JOIN unit_residents ur ON r.id = ur.resident_id
JOIN units u ON ur.unit_id = u.id
JOIN buildings b ON u.building_id = b.id
WHERE ur.move_out_date IS NULL
ORDER BY b.name, u.unit_number
LIMIT 5;

\echo ''

-- Test 5: Test functions
\echo '5. Testing utility functions:'
\echo 'CPF Formatting:'
SELECT format_cpf('12345678901') as cpf_formatado;

\echo 'Age Calculation:'
SELECT calculate_age('1990-03-15'::DATE) as idade;

\echo ''

-- Test 6: Test availability function
\echo '6. Testing availability function:'
SELECT check_availability(1, CURRENT_DATE + 7, '18:00', '20:00') as disponivel_salao_festas;

\echo ''

-- Test 7: Test complex query with current syndic
\echo '7. Current Syndic Information:'
SELECT * FROM current_syndic_view;

\echo ''

-- Test 8: Test service orders view
\echo '8. Active Service Orders (first 3):'
SELECT 
    id,
    titulo,
    local,
    solicitante,
    prioridade,
    status
FROM active_service_orders_view
LIMIT 3;

\echo ''

-- Test 9: Building occupancy summary
\echo '9. Building Occupancy Summary:'
SELECT 
    bloco,
    total_apartamentos,
    apartamentos_ocupados,
    apartamentos_vagos,
    taxa_ocupacao_pct || '%' as taxa_ocupacao
FROM (
    SELECT 
        b.name as bloco,
        COUNT(u.id) as total_apartamentos,
        COUNT(ur.unit_id) as apartamentos_ocupados,
        COUNT(u.id) - COUNT(ur.unit_id) as apartamentos_vagos,
        ROUND(COUNT(ur.unit_id)::DECIMAL / COUNT(u.id) * 100, 2) as taxa_ocupacao_pct
    FROM buildings b
    JOIN units u ON b.id = u.building_id
    LEFT JOIN unit_residents ur ON u.id = ur.unit_id AND ur.move_out_date IS NULL
    GROUP BY b.id, b.name
    ORDER BY b.name
) occupancy;

\echo ''

-- Test 10: Upcoming reservations
\echo '10. Upcoming Reservations:'
SELECT 
    ca.name as area,
    p.full_name as solicitante,
    r.reservation_date as data,
    r.start_time as inicio,
    r.end_time as fim,
    r.status
FROM reservations r
JOIN common_areas ca ON r.common_area_id = ca.id
JOIN residents res ON r.resident_id = res.id
JOIN people p ON res.id = p.id
WHERE r.reservation_date >= CURRENT_DATE
ORDER BY r.reservation_date, r.start_time
LIMIT 5;

\echo ''

-- Test 11: Constraint validation test
\echo '11. Testing constraints (should show constraint names):'
SELECT 
    tc.constraint_name,
    tc.constraint_type,
    tc.table_name
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'public' 
AND tc.constraint_type IN ('FOREIGN KEY', 'CHECK', 'UNIQUE')
ORDER BY tc.table_name, tc.constraint_type;

\echo ''

-- Test 12: Index verification
\echo '12. Checking indexes:'
SELECT 
    schemaname,
    tablename,
    indexname
FROM pg_indexes 
WHERE schemaname = 'public'
AND indexname NOT LIKE '%_pkey'
ORDER BY tablename, indexname;

\echo ''

-- Final status
\echo '=== Database Test Summary ==='
SELECT 
    'Database schema created successfully!' as status,
    CURRENT_TIMESTAMP as test_completed_at;

\echo ''
\echo 'All tests completed! If no errors appeared above, the database is ready for use.'
\echo 'You can now start using the SGMP system with the provided sample data.'
\echo ''