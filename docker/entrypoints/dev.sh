#!/bin/bash
set -e

echo "🚀 Starting Development Environment..."

# ============================================================================
# DYNAMIC UID/GID SYNCHRONIZATION
# ============================================================================
# Ambil PUID dan PGID dari environment, atau gunakan 1000 sebagai default
PUID=${PUID:-1000}
PGID=${PGID:-1000}

# Ambil UID dan GID dari user 'appuser' yang ada di dalam image
CURRENT_UID=$(id -u appuser 2>/dev/null || echo 1000)
CURRENT_GID=$(id -g appuser 2>/dev/null || echo 1000)

echo "📋 Host User ID (PUID): $PUID, Host Group ID (PGID): $PGID"
echo "📋 Container User 'appuser' current UID: $CURRENT_UID, GID: $CURRENT_GID"

# Sinkronkan UID/GID hanya jika berbeda
if [ "$CURRENT_UID" != "$PUID" ] || [ "$CURRENT_GID" != "$PGID" ]; then
    echo "⚙️  UID/GID mismatch detected. Synchronizing..."

    # Ubah GID grup 'appuser'
    groupmod -o -g "$PGID" appuser 2>/dev/null || true
    # Ubah UID user 'appuser'
    usermod -o -u "$PUID" appuser 2>/dev/null || true

    echo "✅ User 'appuser' synchronized to UID: $PUID, GID: $PGID"
else
    echo "✅ UID/GID already in sync."
fi

# ============================================================================
# MULTI-OS PERMISSION FIX
# ============================================================================
echo "🔧 Fixing permissions for mounted volumes..."

# Detect if running on WSL/Windows based on mounted volume permissions
if [ "$(stat -c '%u' /app 2>/dev/null || stat -f '%u' /app)" = "0" ] || [ ! -w /app/storage 2>/dev/null ]; then
    echo "⚠️  Detected permission issues (likely WSL/Windows). Fixing..."
fi

# Pastikan direktori Laravel ada
mkdir -p /app/storage/framework/{sessions,views,cache} \
    /app/storage/logs \
    /app/bootstrap/cache

# Fix ownership untuk direktori kritis (gunakan numeric UID/GID untuk menghindari name resolution)
chown -R ${PUID}:${PGID} /app/storage /app/bootstrap/cache 2>/dev/null || true
chmod -R 775 /app/storage /app/bootstrap/cache 2>/dev/null || true

# Fix ownership untuk vendor dan node_modules jika ada
if [ -d "/app/vendor" ]; then
    chown -R ${PUID}:${PGID} /app/vendor 2>/dev/null || true
fi

if [ -d "/app/node_modules" ]; then
    chown -R ${PUID}:${PGID} /app/node_modules 2>/dev/null || true
fi

echo "✅ Permissions fixed!"

# ============================================================================
# DEPENDENCY INSTALLATION
# ============================================================================
echo "📦 Checking dependencies..."

# Install Composer deps when vendor missing
if [ ! -f "vendor/autoload.php" ]; then
    echo "📦 Vendor folder not found, running composer install..."
    su-exec ${PUID}:${PGID} composer install --no-interaction
fi

# Install NPM deps when node_modules missing
if [ ! -d "node_modules" ]; then
    echo "📦 Node_modules folder not found, running npm install..."
    su-exec ${PUID}:${PGID} npm install
    su-exec ${PUID}:${PGID} npm run build
fi

# ============================================================================
# LARAVEL SETUP
# ============================================================================
echo "🔨 Setting up Laravel..."

# Create .env from example if missing
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        echo "📄 Creating .env from .env.example..."
        su-exec ${PUID}:${PGID} cp .env.example .env
    fi
fi

# Generate APP_KEY if missing
if [ -f ".env" ] && [ -z "$(grep '^APP_KEY=' .env | cut -d '=' -f2-)" ]; then
    echo "🔐 APP_KEY is empty. Generating new key..."
    su-exec ${PUID}:${PGID} php artisan key:generate
fi

# Recreate storage symlink
if [ -L public/storage ] || [ -e public/storage ]; then
    echo "🧹 Removing existing storage link..."
    rm -rf public/storage
fi

echo "🔗 Creating fresh storage link..."
su-exec ${PUID}:${PGID} php artisan storage:link

# Final ownership check
echo "🔍 Final permission check..."
chown -R ${PUID}:${PGID} /app/storage /app/bootstrap/cache 2>/dev/null || true

# ============================================================================
# DATABASE & MIGRATION CHECK
# ============================================================================

# Check if auto-migration is disabled
if [ "${SKIP_AUTO_MIGRATE:-false}" = "true" ]; then
    echo "⏭️  Auto-migration is disabled (SKIP_AUTO_MIGRATE=true)"
else
    echo "🗄️  Checking database connection..."

    # Wait for database to be ready (max 30 seconds)
    WAIT_TIME=0
    MAX_WAIT=30
    DB_READY=false

    while [ $WAIT_TIME -lt $MAX_WAIT ]; do
        # Try to connect to database with timeout
        if timeout 5 su-exec ${PUID}:${PGID} php -r "
            require 'vendor/autoload.php';
            \$app = require_once 'bootstrap/app.php';
            \$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
            try {
                DB::connection()->getPdo();
                exit(0);
            } catch (Exception \$e) {
                exit(1);
            }
        " >/dev/null 2>&1; then
            DB_READY=true
            break
        fi
        
        echo "⏳ Waiting for database... (${WAIT_TIME}s/${MAX_WAIT}s)"
        sleep 3
        WAIT_TIME=$((WAIT_TIME + 3))
    done

    # Check for pending migrations if database is ready
    if [ "$DB_READY" = true ]; then
        echo "✅ Database connection established."
        
        # Create migrations table if it doesn't exist
        echo "📊 Ensuring migrations table exists..."
        su-exec ${PUID}:${PGID} php artisan migrate:install 2>/dev/null || true
        
        # Get list of migration files
        echo "🔍 Scanning migration files..."
        MIGRATION_FILES=$(find database/migrations -name "*.php" -type f 2>/dev/null | sort)
        TOTAL_FILES=$(echo "$MIGRATION_FILES" | wc -l)
        
        if [ -z "$MIGRATION_FILES" ] || [ "$TOTAL_FILES" -eq 0 ]; then
            echo "✅ No migration files found."
        else
            echo "📁 Found $TOTAL_FILES migration file(s)"
            
            # Get list of ran migrations from database
            MIGRATED_LIST=$(su-exec ${PUID}:${PGID} php -r "
                require 'vendor/autoload.php';
                \$app = require_once 'bootstrap/app.php';
                \$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();
                try {
                    \$migrations = DB::table('migrations')->pluck('migration')->toArray();
                    echo implode('\n', \$migrations);
                } catch (Exception \$e) {
                    // Table might not exist yet
                    exit(0);
                }
            " 2>/dev/null)
            
            # Count pending migrations
            PENDING_COUNT=0
            PENDING_MIGRATIONS=""
            
            for file in $MIGRATION_FILES; do
                # Extract migration name from filename (remove path and .php)
                MIGRATION_NAME=$(basename "$file" .php)
                
                # Check if this migration has been run
                if ! echo "$MIGRATED_LIST" | grep -qF "$MIGRATION_NAME"; then
                    PENDING_COUNT=$((PENDING_COUNT + 1))
                    PENDING_MIGRATIONS="$PENDING_MIGRATIONS
  - $MIGRATION_NAME"
                fi
            done
            
            if [ $PENDING_COUNT -gt 0 ]; then
                echo "🔄 Found $PENDING_COUNT pending migration(s):"
                echo "$PENDING_MIGRATIONS"
                echo ""
                echo "▶️  Running migrations..."
                
                # Run migrations with error handling
                MIGRATION_OUTPUT=$(su-exec ${PUID}:${PGID} php artisan migrate --force 2>&1)
                MIGRATION_EXIT_CODE=$?
                
                if [ $MIGRATION_EXIT_CODE -eq 0 ]; then
                    echo "✅ Migrations completed successfully!"
                    echo "$MIGRATION_OUTPUT" | grep -E "(INFO|Migrating:|Migrated:)" || true
                else
                    echo "⚠️  Migration encountered errors (exit code: ${MIGRATION_EXIT_CODE})"
                    echo ""
                    echo "📄 Migration output:"
                    echo "$MIGRATION_OUTPUT"
                    echo ""
                    echo "💡 Possible causes:"
                    echo "   - Non-idempotent migrations (trying to add existing columns)"
                    echo "   - Syntax errors in migration files"
                    echo "   - Database permission issues"
                    echo ""
                    echo "💡 To skip auto-migration, set: SKIP_AUTO_MIGRATE=true"
                    echo "   Then run migrations manually: make artisan migrate --force"
                    echo ""
                    echo "⚠️  Application will continue to start..."
                fi
            else
                echo "✅ All migrations are up to date (0 pending)"
            fi
        fi
        
        # Optional: Run seeders in development (uncomment if needed)
        # if [ "${DB_SEED:-false}" = "true" ]; then
        #     echo ""
        #     echo "🌱 Running database seeders..."
        #     su-exec ${PUID}:${PGID} php artisan db:seed --force
        # fi
    else
        echo "⚠️  Database not ready after ${MAX_WAIT}s."
        echo "⚠️  Skipping migration check."
        echo ""
        echo "💡 Possible causes:"
        echo "   - Database container not started"
        echo "   - Wrong database credentials in .env"
        echo "   - Network issues between containers"
        echo ""
        echo "💡 Check database logs: make logs mysql"
        echo "💡 Or disable auto-migration: SKIP_AUTO_MIGRATE=true"
    fi
fi

# Optimize the app with caching (optional in dev, uncomment if needed)
# echo "📦 Optimize with caching..."
# su-exec ${PUID}:${PGID} php artisan optimize

echo "✨ Environment ready!"
echo ""

# ============================================================================
# EXECUTE MAIN COMMAND
# ============================================================================
echo "▶️ Executing command as UID:GID ${PUID}:${PGID}: $@"

# Execute command with numeric UID/GID
exec su-exec ${PUID}:${PGID} "$@"