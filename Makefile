# Makefile untuk Manajemen Lingkungan Docker Proyek Laravel
.DEFAULT_GOAL := help
.PHONY: env-init env-check up down down-v restart build rebuild fresh logs ps config shell shell-% artisan composer npm test prod-up prod-down prod-build prod-logs prod-ps prod-config prod-shell prod-shell-%  prune help

# -- Konfigurasi Dasar --
COMPOSE_DEV = docker compose --project-directory . -f docker/compose.yaml --profile dev
COMPOSE_PROD = docker compose --project-directory . -f docker/compose.yaml --profile prod

# -- Mekanisme Argumen --
# Kata pertama = target make, sisanya = ARGS
# Contoh: make artisan migrate:fresh --seed
# MAKECMDGOALS = "artisan migrate:fresh --seed"
# ARGS = "migrate:fresh --seed"
ARGS = $(wordlist 2, 999, $(MAKECMDGOALS))
# EXTRA_ARGS ini hanya diperuntukkan oleh command "prod-build"
# EXTRA_ARGS berfungsi untuk semua keyword selain dari wordlist
# EXTRA_ARGS = "docker build --help"
EXTRA_ARGS := $(filter-out $@,$(MAKECMDGOALS))

# -- Deteksi OS untuk command yang berbeda --
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	SED_INPLACE = sed -i
	DETECTED_OS = Linux
endif
ifeq ($(UNAME_S),Darwin)
	SED_INPLACE = sed -i ''
	DETECTED_OS = macOS
endif

# Untuk Windows (Git Bash / WSL)
ifeq ($(OS),Windows_NT)
	SED_INPLACE = sed -i
	DETECTED_OS = Windows
endif

# ==============================================================================
# -- ENVIRONMENT SETUP --
# ==============================================================================

env-init: ## (Setup) Initialize .env with UID/GID and copy from .env.example if missing
	@echo "🔧 Initializing environment configuration..."
	@echo "📍 Detected OS: $(DETECTED_OS)"
	@echo ""
	@if [ ! -f .env ]; then \
		echo "📄 .env not found. Creating from .env.example..."; \
		cp .env.example .env; \
		echo "✅ .env created"; \
	else \
		echo "✅ .env already exists"; \
	fi
	@echo ""
	@echo "🔐 Setting up PUID/PGID..."
	@CURRENT_UID=$$(id -u); \
	CURRENT_GID=$$(id -g); \
	echo "   Detected UID: $$CURRENT_UID"; \
	echo "   Detected GID: $$CURRENT_GID"; \
	if grep -q "^PUID=" .env; then \
		$(SED_INPLACE) "s/^PUID=.*/PUID=$$CURRENT_UID/" .env; \
		echo "   ✅ PUID updated in .env"; \
	else \
		echo "PUID=$$CURRENT_UID" >> .env; \
		echo "   ✅ PUID added to .env"; \
	fi; \
	if grep -q "^PGID=" .env; then \
		$(SED_INPLACE) "s/^PGID=.*/PGID=$$CURRENT_GID/" .env; \
		echo "   ✅ PGID updated in .env"; \
	else \
		echo "PGID=$$CURRENT_GID" >> .env; \
		echo "   ✅ PGID added to .env"; \
	fi
	@echo ""
	@echo "🎉 Environment initialization complete!"
	@echo ""
	@echo "📋 Current settings:"
	@grep "^PUID=" .env || echo "   PUID not found"
	@grep "^PGID=" .env || echo "   PGID not found"
	@grep "^COMPOSE_PROJECT_NAME=" .env || echo "   COMPOSE_PROJECT_NAME not found"
	@echo ""
	@echo "💡 Next steps:"
	@echo "   1. Review and update .env file if needed"
	@echo "   2. Run 'make up' to start development environment"

env-check: ## (Setup) Check current PUID/PGID settings
	@echo "🔍 Current Environment Settings:"
	@echo "--------------------------------"
	@echo "Host User ID  : $$(id -u)"
	@echo "Host Group ID : $$(id -g)"
	@echo ""
	@if [ -f .env ]; then \
		echo ".env File Settings:"; \
		grep "^PUID=" .env || echo "PUID not set in .env"; \
		grep "^PGID=" .env || echo "PGID not set in .env"; \
	else \
		echo "⚠️  .env file not found. Run 'make env-init' first."; \
	fi
	@echo "--------------------------------"

# ==============================================================================
# -- DEVELOPMENT --
# ==============================================================================

up: ## (Dev) Start all containers in the background
	@echo "🚀 Starting development environment..."
	@if [ ! -f .env ]; then \
		echo "⚠️  .env not found. Running env-init first..."; \
		$(MAKE) env-init --no-print-directory; \
		echo ""; \
	fi
	@$(COMPOSE_DEV) up -d $(ARGS)

down: ## (Dev) Stop all containers
	@echo "🛑 Stopping development environment..."
	@$(COMPOSE_DEV) down

down-v: ## (Dev) Stop containers AND remove volumes (database will be reset)
	@echo "💣 Stopping and removing volumes..."
	@echo "⚠️  WARNING: This will delete all database data!"
	@printf "Are you sure? [y/N] "; \
	read ans; \
	case "$$ans" in \
		y|Y) \
			$(COMPOSE_DEV) down -v; \
			echo "✅ Volumes removed"; \
			;; \
		*) \
			echo "❌ Cancelled"; \
			;; \
	esac

restart: ## (Dev) Restart all containers
	@echo "🔄 Restarting services: $(or $(ARGS), all)"
	@$(COMPOSE_DEV) restart $(ARGS)

build: ## (Dev) Build or rebuild services
	@echo "🛠️ Building: $(or $(ARGS), all)"
	@$(COMPOSE_DEV) build $(ARGS)

rebuild: ## (Dev) Rebuild all services from scratch
	@$(MAKE) build --no-print-directory
	@$(MAKE) up ARGS="--force-recreate" --no-print-directory
	@echo "✨ Rebuilt and started."

fresh: ## (Dev) Refresh services with fresh database
	@echo "🌊 Creating fresh environment..."
	@$(MAKE) down-v --no-print-directory
	@$(MAKE) up --no-print-directory
	@echo "🌿 Fresh database ready."

logs: ## (Dev) View logs from all or specific services
	@echo "📋 Logs: $(or $(ARGS), all)"
	@$(COMPOSE_DEV) logs -f $(ARGS)

ps: ## (Dev) Show running development containers
	@$(COMPOSE_DEV) ps

config: ## (Dev) Show docker compose configuration
	@$(COMPOSE_DEV) config

shell: shell-app ## (Dev) Enter the main 'app' container shell

shell-%: ## (Dev) Enter a specific container shell (e.g., make shell-app, make shell-mysql)
	@echo "🚪 Entering '$*' container..."
	@$(COMPOSE_DEV) exec $(*) sh -c 'command -v bash >/dev/null 2>&1 && exec bash || exec sh'

artisan: ## (Dev) Run Laravel Artisan command (e.g., make artisan migrate)
	@echo "⚡ Running: php artisan $(ARGS)"
	@$(COMPOSE_DEV) exec app php artisan $(ARGS)

composer: ## (Dev) Run Composer inside container (e.g., make composer install)
	@echo "📦 Running: composer $(ARGS)"
	@$(COMPOSE_DEV) exec app composer $(ARGS)

npm: ## (Dev) Run NPM inside container (e.g., make npm install)
	@echo "📦 Running: npm $(ARGS)"
	@$(COMPOSE_DEV) exec app npm $(ARGS)

test: ## (Dev) Run Laravel tests (e.g., make test --filter=UserTest)
	@echo "🧪 Running tests: $(or $(ARGS), all)"
	@$(COMPOSE_DEV) exec app php artisan test $(ARGS)

# ==============================================================================
# -- PRODUCTION --
# ==============================================================================

prod-up: ## (Prod) Start production containers
	@echo "🚀 Starting production environment..."
	@if [ ! -f .env ]; then \
		echo "❌ Error: .env not found. Create .env first!"; \
		exit 1; \
	fi
	@$(COMPOSE_PROD) up -d $(ARGS)

prod-down: ## (Prod) Stop production containers
	@echo "🛑 Stopping production environment..."
	@$(COMPOSE_PROD) down $(ARGS)

prod-build: ## (Prod) Build production images
	@echo "🛠️ Building production images..."
	@bash -c '\
		# Load .env \
		source ./.env 2>/dev/null || true; \
		project_name="$${CI_REGISTRY_IMAGE:-$$COMPOSE_PROJECT_NAME}"; \
		image_tag="$${project_name}:latest"; \
		echo "🔧 Membangun image produksi secara lokal..."; \
		echo "Image akan di-tag sebagai: $$image_tag"; \
		# Forward optional args (hapus -- di depan jika ada) \
		args="$${EXTRA_ARGS#-- }"; \
		# Jalankan docker build \
		if docker build -f docker/Dockerfile -t "$$image_tag" --target production . $$args; then \
			echo "🎉 Berhasil membangun image: $$image_tag"; \
		else \
			echo "❌ Gagal membangun image Docker lokal (exit code $$?)"; \
			exit 1; \
		fi \
	'

prod-logs: ## (Prod) View production logs (default: app-prod)
	@echo "📋 Production logs: $(or $(ARGS), app-prod)"
	@$(COMPOSE_PROD) logs -f $(or $(ARGS), app-prod)

prod-logs-%: ## (Prod) View logs from specific production service
	@echo "📋 Production logs: $*"
	@$(COMPOSE_PROD) logs -f $*

prod-ps: ## (Prod) Show production containers status
	@echo "📊 Production containers status..."
	@$(COMPOSE_PROD) ps $(ARGS)

prod-config: ## (Prod) Show production docker compose configuration
	@$(COMPOSE_PROD) config $(ARGS)

prod-shell: prod-shell-app-prod ## (Prod) Shell into main production container

prod-shell-%: ## (Prod) Shell into specific production container
	@echo "🚪 Entering production container: $*"
	@$(COMPOSE_PROD) exec $* sh -c 'command -v bash >/dev/null 2>&1 && exec bash || exec sh'

# ==============================================================================
# -- UTILITAS --
# ==============================================================================

prune: ## (Util) Clean up unused Docker containers, networks, and images
	@echo "🧹 Pruning unused Docker objects..."
	@echo "⚠️  This will remove:"
	@echo "   - All stopped containers"
	@echo "   - All networks not used by at least one container"
	@echo "   - All dangling images"
	@echo "   - All build cache"
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker system prune -af; \
		echo "✅ Cleanup complete"; \
	else \
		echo "❌ Cancelled"; \
	fi

status: ## (Util) Show comprehensive status of all services
	@echo "📊 Development Environment Status"
	@echo "=================================="
	@if [ -f .env ]; then \
		echo "✅ .env file exists"; \
		echo "   PUID: $$(grep '^PUID=' .env | cut -d= -f2)"; \
		echo "   PGID: $$(grep '^PGID=' .env | cut -d= -f2)"; \
	else \
		echo "❌ .env file missing"; \
	fi
	@echo ""
	@echo "Docker Containers:"
	@$(COMPOSE_DEV) ps
	@echo ""
	@echo "Host Info:"
	@echo "   User ID : $$(id -u)"
	@echo "   Group ID: $$(id -g)"

# ==============================================================================
# -- HELP --
# ==============================================================================
help:
	@echo ""
	@echo "⚡ Laravel Docker Environment Manager"
	@echo "======================================"
	@echo ""
	@echo "Usage: make <command> [arguments]"
	@echo ""
	@echo "📝 Quick Start:"
	@echo "  1. make env-init    # Setup environment"
	@echo "  2. make up          # Start development"
	@echo "  3. make logs        # View logs"
	@echo ""
	@echo "🔧 Environment Setup:"
	@grep -E '^(env-init|env-check):.*?##' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[33m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "🚀 Development Commands:"
	@grep -E '^(up|down|down-v|restart|build|rebuild|fresh|logs|ps|config|status):.*?##' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "💻 Container Interaction:"
	@grep -E '^(shell|shell-|artisan|composer|npm|test):.*?##' $(MAKEFILE_LIST) \
	| grep -v "shell-%" \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "🏭 Production Commands:"
	@grep -E '^(prod-up|prod-down|prod-build|prod-logs|prod-ps|prod-config|prod-shell):.*?##' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[35m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "🛠️  Utilities:"
	@grep -E '^(prune):.*?##' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "💡 Examples:"
	@echo "  make artisan migrate:fresh --seed"
	@echo "  make composer require package/name"
	@echo "  make npm run build"
	@echo "  make shell-mysql"
	@echo "  make logs app"
	@echo ""

# ==============================================================================
# -- CATCH ALL --
# ==============================================================================
%:
	@:
