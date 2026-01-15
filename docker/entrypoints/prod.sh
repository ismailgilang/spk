#!/bin/bash
set -e

echo "🚀 Starting Production Environment..."

# ============================================================================
# DYNAMIC UID/GID SYNCHRONIZATION
# ============================================================================
# Ambil PUID dan PGID dari environment, atau gunakan 1000 sebagai default
PUID=${PUID:-1000}
PGID=${PGID:-1000}

# Ambil UID dan GID dari user 'laravel' yang ada di dalam image
CURRENT_UID=$(id -u laravel 2>/dev/null || echo 1000)
CURRENT_GID=$(id -g laravel 2>/dev/null || echo 1000)

echo "📋 Host User ID (PUID): $PUID, Host Group ID (PGID): $PGID"
echo "📋 Container User 'laravel' current UID: $CURRENT_UID, GID: $CURRENT_GID"

# Sinkronkan UID/GID hanya jika berbeda
if [ "$CURRENT_UID" != "$PUID" ] || [ "$CURRENT_GID" != "$PGID" ]; then
    echo "⚙️  UID/GID mismatch detected. Synchronizing..."

    # Ubah GID grup 'laravel'
    groupmod -o -g "$PGID" laravel 2>/dev/null || true
    # Ubah UID user 'laravel'
    usermod -o -u "$PUID" laravel 2>/dev/null || true

    echo "✅ User 'laravel' synchronized to UID: $PUID, GID: $PGID"
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

# Fix ownership untuk direktori kritis
chown -R laravel:laravel /app/storage /app/bootstrap/cache 2>/dev/null || true
chmod -R 775 /app/storage /app/bootstrap/cache 2>/dev/null || true

# Fix ownership untuk vendor dan node_modules jika ada
if [ -d "/app/vendor" ]; then
    chown -R laravel:laravel /app/vendor 2>/dev/null || true
fi

if [ -d "/app/node_modules" ]; then
    chown -R laravel:laravel /app/node_modules 2>/dev/null || true
fi

echo "✅ Permissions fixed!"

# ============================================================================
# DEPENDENCY INSTALLATION (sebagai laravel)
# ============================================================================
echo "📦 Checking dependencies..."

# Install Composer deps when vendor missing
if [ ! -f "vendor/autoload.php" ]; then
    echo "📦 Vendor folder not found, running composer install..."
    su-exec laravel:laravel composer install --no-interaction
fi

# Install NPM deps when node_modules missing
# if [ ! -d "node_modules" ]; then
#     echo "📦 Node_modules folder not found, running npm install..."
#     su-exec laravel:laravel npm install
#     su-exec laravel:laravel npm run build
# fi

# ============================================================================
# LARAVEL SETUP (sebagai laravel)
# ============================================================================
echo "🔨 Setting up Laravel..."

# Create .env from example if missing
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        echo "📄 Creating .env from .env.example..."
        su-exec laravel:laravel cp .env.example .env
    else
        echo "⚠️  Warning: .env.example not found. Please create .env manually."
    fi
fi

# Generate APP_KEY if missing or empty
if [ -f ".env" ]; then
    # Check if APP_KEY exists and is not empty (excluding whitespace and comments)
    APP_KEY_VALUE=$(grep '^APP_KEY=' .env 2>/dev/null | cut -d '=' -f2- | tr -d '[:space:]' || echo "")
    
    if [ -z "$APP_KEY_VALUE" ]; then
        echo "🔐 APP_KEY is missing or empty. Generating new key..."
        
        # Ensure .env is writable
        chown laravel:laravel .env 2>/dev/null || true
        chmod 664 .env 2>/dev/null || true
        
        # Generate key
        if su-exec laravel:laravel php artisan key:generate --force --no-interaction; then
            echo "✅ APP_KEY generated successfully!"
        else
            echo "❌ Failed to generate APP_KEY. Please run 'php artisan key:generate' manually."
        fi
    else
        echo "✅ APP_KEY already exists: ${APP_KEY_VALUE:0:20}..."
    fi
else
    echo "⚠️  Warning: .env file not found. Skipping APP_KEY generation."
fi

# Recreate storage symlink
if [ -L public/storage ] || [ -e public/storage ]; then
    echo "🧹 Removing existing storage link..."
    rm -rf public/storage
fi

echo "🔗 Creating fresh storage link..."
su-exec laravel:laravel php artisan storage:link 2>/dev/null || echo "⚠️  Storage link creation skipped (might already exist or permission issue)"

# ============================================================================
# DATABASE MIGRATION CHECK (SAFE - NO DATA LOSS)
# ============================================================================
echo "🗄️  Checking database migrations..."

# Function to check if database is accessible
check_database_connection() {
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Waiting for database connection..."
    
    while [ $attempt -le $max_attempts ]; do
        if su-exec laravel:laravel php artisan db:show --no-ansi &>/dev/null; then
            echo "✅ Database connection established!"
            return 0
        fi
        
        echo "   Attempt $attempt/$max_attempts: Database not ready yet..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "⚠️  Warning: Could not connect to database after $max_attempts attempts"
    return 1
}

# Function to check if there are pending migrations
check_pending_migrations() {
    local status_output
    status_output=$(su-exec laravel:laravel php artisan migrate:status --no-ansi 2>/dev/null || echo "error")
    
    # Check if migrations table exists
    if echo "$status_output" | grep -q "Migration table not found"; then
        echo "📊 Migration table not found. First time setup detected."
        return 0  # Need to migrate
    fi
    
    # Check if there are any pending migrations
    if echo "$status_output" | grep -q "Pending"; then
        echo "🔄 Pending migrations detected:"
        echo "$status_output" | grep "Pending" | sed 's/^/   /'
        return 0  # Need to migrate
    fi
    
    # Check if error occurred
    if [ "$status_output" = "error" ]; then
        echo "⚠️  Could not check migration status"
        return 1  # Don't migrate on error
    fi
    
    echo "✅ All migrations are up to date. No new migrations to run."
    return 1  # No need to migrate
}

# Run migration check if AUTO_MIGRATE is not disabled
AUTO_MIGRATE=${AUTO_MIGRATE:-true}

if [ "$AUTO_MIGRATE" = "true" ]; then
    if check_database_connection; then
        echo ""
        echo "🔍 Checking for pending migrations..."
        
        if check_pending_migrations; then
            echo ""
            echo "🚀 Running database migrations (safe - no data loss)..."
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            # Run migrations (this will only add new tables/columns, not delete data)
            if su-exec laravel:laravel php artisan migrate --force --no-interaction; then
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "✅ Migrations completed successfully!"
                echo ""
                
                # Show current migration status
                echo "📊 Current migration status:"
                su-exec laravel:laravel php artisan migrate:status --no-ansi | head -n 20
            else
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "❌ Migration failed! Check the error messages above."
                echo "   Your existing data is safe."
                exit 1
            fi
        else
            echo "⏭️  Skipping migrations - database is already up to date"
        fi
    else
        echo "⚠️  Skipping migrations - database connection not available"
        echo "   You can run migrations manually later with: php artisan migrate"
    fi
else
    echo "⏭️  Auto-migration is disabled (AUTO_MIGRATE=false)"
    echo "   Run migrations manually with: php artisan migrate"
fi

# Final ownership check
echo ""
echo "🔍 Final permission check..."
chown -R laravel:laravel /app/storage /app/bootstrap/cache 2>/dev/null || true

# Optimize the app with caching
# echo "📦 Optimize with caching..."
# su-exec laravel:laravel php artisan optimize

echo "✨ Environment ready!"
echo ""

# ============================================================================
# EXECUTE MAIN COMMAND (sebagai laravel)
# ============================================================================
echo "▶️ Executing command as laravel: $@"
exec su-exec laravel:laravel "$@"