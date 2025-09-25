#!/bin/bash

# ============================================================================
# SGMP - Sistema de Gerenciamento e Manutenção Predial
# Database Installation Script
# ============================================================================

echo "==============================================="
echo "  SGMP Database Installation Script"
echo "==============================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if PostgreSQL is available
check_postgresql() {
    print_status "Checking PostgreSQL availability..."
    if command -v psql >/dev/null 2>&1; then
        print_success "PostgreSQL client found"
        return 0
    else
        print_error "PostgreSQL client (psql) not found. Please install PostgreSQL."
        return 1
    fi
}

# Function to get database connection parameters
get_db_params() {
    echo ""
    print_status "Database connection parameters:"
    
    read -p "Database host [localhost]: " DB_HOST
    DB_HOST=${DB_HOST:-localhost}
    
    read -p "Database port [5432]: " DB_PORT
    DB_PORT=${DB_PORT:-5432}
    
    read -p "Database name: " DB_NAME
    while [[ -z "$DB_NAME" ]]; do
        print_warning "Database name is required."
        read -p "Database name: " DB_NAME
    done
    
    read -p "Username: " DB_USER
    while [[ -z "$DB_USER" ]]; do
        print_warning "Username is required."
        read -p "Username: " DB_USER
    done
    
    # Set connection string
    DB_CONNECTION="host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER"
}

# Function to test database connection
test_connection() {
    print_status "Testing database connection..."
    if psql "$DB_CONNECTION" -c "SELECT version();" >/dev/null 2>&1; then
        print_success "Database connection successful"
        return 0
    else
        print_error "Failed to connect to database. Please check your credentials."
        return 1
    fi
}

# Function to execute SQL file
execute_sql_file() {
    local file=$1
    local description=$2
    
    print_status "$description"
    
    if [[ ! -f "$file" ]]; then
        print_error "File $file not found!"
        return 1
    fi
    
    if psql "$DB_CONNECTION" -f "$file" >/dev/null 2>&1; then
        print_success "$description completed successfully"
        return 0
    else
        print_error "$description failed"
        return 1
    fi
}

# Function to run installation
run_installation() {
    local install_sample_data=false
    local run_tests=false
    
    echo ""
    print_status "Installation options:"
    
    read -p "Install sample data? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_sample_data=true
    fi
    
    read -p "Run tests after installation? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        run_tests=true
    fi
    
    echo ""
    print_status "Starting SGMP database installation..."
    echo ""
    
    # Step 1: Create database schema
    if ! execute_sql_file "database_schema.sql" "Creating database schema..."; then
        return 1
    fi
    
    # Step 2: Install sample data (optional)
    if [[ "$install_sample_data" == true ]]; then
        if ! execute_sql_file "sample_data.sql" "Installing sample data..."; then
            return 1
        fi
    fi
    
    # Step 3: Load useful queries
    if ! execute_sql_file "useful_queries.sql" "Loading useful queries and functions..."; then
        return 1
    fi
    
    # Step 4: Run tests (optional)
    if [[ "$run_tests" == true ]]; then
        print_status "Running database tests..."
        if psql "$DB_CONNECTION" -f "test_database.sql"; then
            print_success "All tests passed!"
        else
            print_warning "Some tests failed, but installation may still be successful"
        fi
    fi
    
    return 0
}

# Function to display post-installation info
show_success_info() {
    echo ""
    echo "==============================================="
    print_success "SGMP Database Installation Complete!"
    echo "==============================================="
    echo ""
    echo "Your SGMP database is now ready to use!"
    echo ""
    echo "📊 Database Statistics:"
    echo "   • 11 tables created"
    echo "   • 3 specialized views"
    echo "   • Multiple utility functions"
    echo "   • Comprehensive indexing"
    echo ""
    echo "📚 Next Steps:"
    echo "   1. Review DATABASE_DOCUMENTATION.md for detailed info"
    echo "   2. Check useful_queries.sql for example queries"
    echo "   3. Start building your application!"
    echo ""
    echo "🔗 Connection string used:"
    echo "   $DB_CONNECTION"
    echo ""
    echo "✨ Happy coding!"
    echo ""
}

# Main execution
main() {
    # Check prerequisites
    if ! check_postgresql; then
        exit 1
    fi
    
    # Get database parameters
    get_db_params
    
    # Test connection
    if ! test_connection; then
        exit 1
    fi
    
    # Run installation
    if run_installation; then
        show_success_info
    else
        print_error "Installation failed. Please check the error messages above."
        exit 1
    fi
}

# Run main function
main "$@"