#!/bin/bash
# PostgreSQL restore script for church website

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}🗄️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

DB_NAME="mtzionchinagrove_dev"
BACKUP_FILE="$1"

if [ -z "$BACKUP_FILE" ]; then
    print_error "Usage: $0 <backup_file>"
    print_error "Example: $0 backups/church-postgres-backup-20231201_120000.sql.gz"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    print_error "Backup file not found: $BACKUP_FILE"
    exit 1
fi

print_step "Restoring PostgreSQL backup for Church Website..."
print_warning "This will replace all data in database: $DB_NAME"

read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Restore cancelled."
    exit 1
fi

# Check if PostgreSQL container is running
if ! docker ps | grep -q trust-server-postgres-local; then
    print_error "PostgreSQL container is not running. Please start it first."
    exit 1
fi

# Drop existing database and recreate
print_step "Dropping existing database..."
docker exec trust-server-postgres-local psql -U postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
docker exec trust-server-postgres-local psql -U postgres -c "CREATE DATABASE $DB_NAME;"

# Restore from backup
print_step "Restoring database from backup..."
if [[ "$BACKUP_FILE" == *.gz ]]; then
    zcat "$BACKUP_FILE" | docker exec -i trust-server-postgres-local psql -U postgres -d "$DB_NAME"
else
    cat "$BACKUP_FILE" | docker exec -i trust-server-postgres-local psql -U postgres -d "$DB_NAME"
fi

print_success "PostgreSQL restore complete!"
print_success "Database $DB_NAME has been restored from $BACKUP_FILE"