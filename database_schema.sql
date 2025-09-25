-- ============================================================================
-- SGMP - Sistema de Gerenciamento e Manutenção Predial
-- Database Schema Definition
-- ============================================================================

-- Drop existing tables if they exist (for testing purposes)
DROP TABLE IF EXISTS service_orders CASCADE;
DROP TABLE IF EXISTS reservations CASCADE;
DROP TABLE IF EXISTS common_areas CASCADE;
DROP TABLE IF EXISTS unit_residents CASCADE;
DROP TABLE IF EXISTS units CASCADE;
DROP TABLE IF EXISTS buildings CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS syndics CASCADE;
DROP TABLE IF EXISTS residents CASCADE;
DROP TABLE IF EXISTS people CASCADE;

-- ============================================================================
-- 1. PEOPLE MANAGEMENT
-- ============================================================================

-- Base table for all people in the system
CREATE TABLE people (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    mobile_phone VARCHAR(20),
    birth_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_cpf_format CHECK (cpf ~ '^[0-9]{11}$'),
    CONSTRAINT chk_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Residents table (extends people)
CREATE TABLE residents (
    id INTEGER PRIMARY KEY REFERENCES people(id) ON DELETE CASCADE,
    emergency_contact_name VARCHAR(255),
    emergency_contact_phone VARCHAR(20),
    is_owner BOOLEAN DEFAULT FALSE,
    rental_contract_start DATE,
    rental_contract_end DATE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'moved_out'))
);

-- Syndics table (extends people)
CREATE TABLE syndics (
    id INTEGER PRIMARY KEY REFERENCES people(id) ON DELETE CASCADE,
    mandate_start DATE NOT NULL,
    mandate_end DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    
    CONSTRAINT chk_mandate_dates CHECK (mandate_end > mandate_start)
);

-- Employees table (extends people)
CREATE TABLE employees (
    id INTEGER PRIMARY KEY REFERENCES people(id) ON DELETE CASCADE,
    position VARCHAR(100) NOT NULL,
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    work_schedule VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'terminated'))
);

-- ============================================================================
-- 2. BUILDING AND UNIT MANAGEMENT
-- ============================================================================

-- Buildings/Blocks table
CREATE TABLE buildings (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    total_floors INTEGER NOT NULL,
    units_per_floor INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Units/Apartments table  
CREATE TABLE units (
    id SERIAL PRIMARY KEY,
    building_id INTEGER NOT NULL REFERENCES buildings(id) ON DELETE CASCADE,
    unit_number VARCHAR(20) NOT NULL,
    floor INTEGER NOT NULL,
    area_sqm DECIMAL(8,2),
    bedrooms INTEGER DEFAULT 0,
    bathrooms INTEGER DEFAULT 0,
    parking_spaces INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'occupied' CHECK (status IN ('occupied', 'vacant', 'maintenance')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(building_id, unit_number)
);

-- Many-to-many relationship between units and residents
CREATE TABLE unit_residents (
    id SERIAL PRIMARY KEY,
    unit_id INTEGER NOT NULL REFERENCES units(id) ON DELETE CASCADE,
    resident_id INTEGER NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
    is_responsible BOOLEAN DEFAULT FALSE,
    move_in_date DATE NOT NULL,
    move_out_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(unit_id, resident_id)
);

-- ============================================================================
-- 3. COMMON AREAS MANAGEMENT
-- ============================================================================

-- Common areas table
CREATE TABLE common_areas (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    capacity INTEGER,
    hourly_rate DECIMAL(8,2) DEFAULT 0.00,
    requires_approval BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    operating_hours_start TIME,
    operating_hours_end TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Reservations table
CREATE TABLE reservations (
    id SERIAL PRIMARY KEY,
    common_area_id INTEGER NOT NULL REFERENCES common_areas(id) ON DELETE CASCADE,
    resident_id INTEGER NOT NULL REFERENCES residents(id) ON DELETE CASCADE,
    reservation_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    total_cost DECIMAL(8,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled', 'completed')),
    approved_by INTEGER REFERENCES syndics(id),
    approval_date TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_reservation_times CHECK (end_time > start_time),
    CONSTRAINT chk_future_reservation CHECK (reservation_date >= CURRENT_DATE)
);

-- ============================================================================
-- 4. SERVICE ORDERS (MAINTENANCE)
-- ============================================================================

-- Service orders table
CREATE TABLE service_orders (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    unit_id INTEGER REFERENCES units(id) ON DELETE SET NULL,
    common_area_id INTEGER REFERENCES common_areas(id) ON DELETE SET NULL,
    requested_by INTEGER NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    assigned_to INTEGER REFERENCES employees(id) ON DELETE SET NULL,
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'completed', 'cancelled')),
    estimated_cost DECIMAL(10,2),
    actual_cost DECIMAL(10,2),
    scheduled_date DATE,
    completion_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_location CHECK (
        (unit_id IS NOT NULL AND common_area_id IS NULL) OR 
        (unit_id IS NULL AND common_area_id IS NOT NULL)
    )
);

-- ============================================================================
-- 5. INDEXES FOR PERFORMANCE
-- ============================================================================

-- People indexes
CREATE INDEX idx_people_cpf ON people(cpf);
CREATE INDEX idx_people_email ON people(email);
CREATE INDEX idx_people_name ON people(full_name);

-- Units indexes
CREATE INDEX idx_units_building ON units(building_id);
CREATE INDEX idx_units_number ON units(unit_number);
CREATE INDEX idx_unit_residents_unit ON unit_residents(unit_id);
CREATE INDEX idx_unit_residents_resident ON unit_residents(resident_id);

-- Reservations indexes
CREATE INDEX idx_reservations_date ON reservations(reservation_date);
CREATE INDEX idx_reservations_area ON reservations(common_area_id);
CREATE INDEX idx_reservations_resident ON reservations(resident_id);
CREATE INDEX idx_reservations_status ON reservations(status);

-- Service orders indexes
CREATE INDEX idx_service_orders_status ON service_orders(status);
CREATE INDEX idx_service_orders_priority ON service_orders(priority);
CREATE INDEX idx_service_orders_unit ON service_orders(unit_id);
CREATE INDEX idx_service_orders_area ON service_orders(common_area_id);
CREATE INDEX idx_service_orders_assigned ON service_orders(assigned_to);

-- ============================================================================
-- 6. TRIGGERS FOR AUTOMATIC UPDATES
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to people table
CREATE TRIGGER update_people_updated_at 
    BEFORE UPDATE ON people 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Apply trigger to service_orders table
CREATE TRIGGER update_service_orders_updated_at 
    BEFORE UPDATE ON service_orders 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 7. VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View for complete resident information with units
CREATE VIEW resident_units_view AS
SELECT 
    p.id,
    p.full_name,
    p.email,
    p.phone,
    r.is_owner,
    r.status as resident_status,
    b.name as building_name,
    u.unit_number,
    u.floor,
    ur.is_responsible,
    ur.move_in_date,
    ur.move_out_date
FROM people p
JOIN residents r ON p.id = r.id
JOIN unit_residents ur ON r.id = ur.resident_id
JOIN units u ON ur.unit_id = u.id
JOIN buildings b ON u.building_id = b.id
WHERE r.status = 'active' AND ur.move_out_date IS NULL;

-- View for active service orders with details
CREATE VIEW active_service_orders_view AS
SELECT 
    so.id,
    so.title,
    so.description,
    so.priority,
    so.status,
    so.created_at,
    so.scheduled_date,
    requester.full_name as requested_by_name,
    employee.full_name as assigned_to_name,
    emp.position as employee_position,
    COALESCE(b.name || ' - ' || u.unit_number, ca.name) as location
FROM service_orders so
JOIN people requester ON so.requested_by = requester.id
LEFT JOIN employees emp ON so.assigned_to = emp.id
LEFT JOIN people employee ON emp.id = employee.id
LEFT JOIN units u ON so.unit_id = u.id
LEFT JOIN buildings b ON u.building_id = b.id
LEFT JOIN common_areas ca ON so.common_area_id = ca.id
WHERE so.status IN ('open', 'in_progress');

-- View for current syndic
CREATE VIEW current_syndic_view AS
SELECT 
    p.id,
    p.full_name,
    p.email,
    p.phone,
    s.mandate_start,
    s.mandate_end
FROM people p
JOIN syndics s ON p.id = s.id
WHERE s.is_current = TRUE;

COMMENT ON TABLE people IS 'Base table for all people in the condominium system';
COMMENT ON TABLE residents IS 'Residents of the condominium';
COMMENT ON TABLE syndics IS 'Syndics (condominium managers)';
COMMENT ON TABLE employees IS 'Maintenance and service employees';
COMMENT ON TABLE buildings IS 'Buildings/blocks in the condominium';
COMMENT ON TABLE units IS 'Individual units/apartments';
COMMENT ON TABLE unit_residents IS 'Association between units and residents';
COMMENT ON TABLE common_areas IS 'Common areas available for reservation';
COMMENT ON TABLE reservations IS 'Reservations of common areas';
COMMENT ON TABLE service_orders IS 'Maintenance and service requests';