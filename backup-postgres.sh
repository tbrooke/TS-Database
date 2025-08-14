#!/bin/bash
# PostgreSQL backup script for church website

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_NAME="mtzionchinagrove_dev"
BACKUP_FILE="church-postgres-backup-${TIMESTAMP}.sql"
COMPRESSED_FILE="${BACKUP_FILE}.gz"

print_step "Creating PostgreSQL backup for Church Website..."

# Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Check if PostgreSQL container is running
if ! docker ps | grep -q trust-server-postgres-local; then
    print_error "PostgreSQL container is not running. Please start it first."
    exit 1
fi

# Create backup
print_step "Backing up database: $DB_NAME"
docker exec trust-server-postgres-local pg_dump -U postgres -d "$DB_NAME" > "$BACKUP_DIR/$BACKUP_FILE"

# Compress the backup
print_step "Compressing backup..."
gzip "$BACKUP_DIR/$BACKUP_FILE"

print_success "Backup created: $BACKUP_DIR/$COMPRESSED_FILE"

# Keep only last 10 backups
print_step "Cleaning old backups (keeping last 10)..."
cd "$BACKUP_DIR"
ls -t church-postgres-backup-*.sql.gz 2>/dev/null | tail -n +11 | xargs -r rm

print_success "PostgreSQL backup complete!"
echo "Backup file: $BACKUP_DIR/$COMPRESSED_FILE"

# Show backup size
if [ -f "$BACKUP_DIR/$COMPRESSED_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$COMPRESSED_FILE" | cut -f1)
    echo "Backup size: $BACKUP_SIZE"
fi

echo "To restore: ./restore-postgres.sh $COMPRESSED_FILE"