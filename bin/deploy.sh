#!/bin/bash
# ============================================================================
# Production Deployment Script
#
# Alur Kerja:
# 1. Cek prasyarat (docker, .env).
# 2. Setup environment variables (PUID/PGID).
# 3. (Opsional) Build image lokal jika --build-local digunakan.
# 4. Tarik image Docker dari registry.
# 5. Jalankan `docker compose up` untuk memperbarui layanan.
# 6. Cleanup docker images yang tidak terpakai.
#
# Catatan: Skrip ini berasumsi `git pull` dan `docker login` sudah
#          dilakukan di tahap sebelumnya (misal: di dalam GitLab CI).
# ============================================================================

set -e

# --- Konfigurasi & Warna ---
# Pindah ke direktori root proyek
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Tentukan warna jika terminal mendukungnya
if test -t 1; then
    ncolors=$(tput colors 2>/dev/null || echo 0)
    if test -n "$ncolors" && test "$ncolors" -ge 8; then
        BOLD="$(tput bold)"
        YELLOW="$(tput setaf 3)"
        GREEN="$(tput setaf 2)"
        RED="$(tput setaf 1)"
        BLUE="$(tput setaf 4)"
        NC="$(tput sgr0)" # No Color
    fi
fi

# --- Fungsi Bantuan ---
info() {
    echo "${BOLD}${GREEN}==>${NC}${BOLD} $1${NC}"
}

warning() {
    echo "${BOLD}${YELLOW}==>${NC}${BOLD} $1${NC}"
}

error() {
    echo "${BOLD}${RED}==> ERROR:${NC}${BOLD} $1${NC}" >&2
    exit 1
}

debug() {
    if [[ "$DEBUG" == "1" ]]; then
        echo "${BOLD}${BLUE}[DEBUG]${NC} $1"
    fi
}

# --- Deteksi Docker Compose ---
# Cek apakah 'docker compose' (v2) ada
if docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
# Jika tidak, cek 'docker-compose' (v1)
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    error "Tidak dapat menemukan perintah 'docker compose' atau 'docker-compose'. Mohon install Docker Compose."
fi
info "Menggunakan perintah Docker Compose: ${COMPOSE_CMD}"


# --- Fungsi Utama ---

check_prerequisites() {
    info "Memeriksa prasyarat..."

    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker tidak ditemukan. Mohon install Docker."
    fi

    if ! docker info > /dev/null 2>&1; then
        error "Docker daemon tidak berjalan. Mohon jalankan Docker."
    fi

    # Check .env file
    if [ ! -f ".env" ]; then
        error ".env tidak ditemukan. Mohon buat .env dari .env.example dan sesuaikan konfigurasi."
    fi

    echo "✅ Prasyarat terpenuhi."
}

set_environment() {
    info "Menyiapkan environment deployment..."

    # Source .env file
    if [ -f ".env" ]; then
        set -a  # automatically export all variables
        source .env
        set +a
        debug "Environment variables loaded from .env"
    fi

    # Auto-detect PUID dan PGID jika tidak ada di .env atau kosong
    CURRENT_UID=$(id -u)
    CURRENT_GID=$(id -g)

    # Override PUID jika tidak di-set atau kosong
    if [ -z "$PUID" ] || [ "$PUID" = "" ]; then
        export PUID=$CURRENT_UID
        warning "PUID tidak di-set di .env, menggunakan UID host: $PUID"
    else
        export PUID
        info "Menggunakan PUID dari .env: $PUID"
    fi

    # Override PGID jika tidak di-set atau kosong
    if [ -z "$PGID" ] || [ "$PGID" = "" ]; then
        export PGID=$CURRENT_GID
        warning "PGID tidak di-set di .env, menggunakan GID host: $PGID"
    else
        export PGID
        info "Menggunakan PGID dari .env: $PGID"
    fi

    # Set image tag untuk production
    # Priority: 1. CI variables, 2. .env, 3. default
    if [ -n "$CI_REGISTRY_IMAGE" ] && [ -n "$CI_COMMIT_SHORT_SHA" ]; then
        export IMAGE_LATEST="${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHORT_SHA}"
        info "Menggunakan image dari CI/CD: ${IMAGE_LATEST}"
    elif [ -n "$CI_REGISTRY_IMAGE" ]; then
        export IMAGE_LATEST="${CI_REGISTRY_IMAGE}:latest"
        info "Menggunakan image dari .env: ${IMAGE_LATEST}"
    else
        # Fallback to local image name
        export IMAGE_LATEST="${COMPOSE_PROJECT_NAME:-psb}:latest"
        warning "CI_REGISTRY_IMAGE tidak di-set, menggunakan image lokal: ${IMAGE_LATEST}"
    fi

    info "Konfigurasi Deployment:"
    echo "   PUID: ${PUID}"
    echo "   PGID: ${PGID}"
    echo "   Image: ${IMAGE_LATEST}"
    echo "   Project: ${COMPOSE_PROJECT_NAME:-psb}"
}

build_local_image() {
    info "Membangun image produksi secara lokal..."

    local project_name=${CI_REGISTRY_IMAGE:-$COMPOSE_PROJECT_NAME}
    # local project_name=${COMPOSE_PROJECT_NAME:-"psb"}
    local image_tag="${project_name}:latest"

    info "Image akan di-tag sebagai: ${image_tag}"

    if ! docker build -f docker/Dockerfile -t "$image_tag" --target production . --no-cache; then
        error "Gagal membangun image Docker lokal."
    fi

    echo "✅ Image lokal berhasil dibangun: ${image_tag}"
}

pull_docker_images() {
    if [[ "$LOCAL_TEST" == "1" ]]; then
        warning "Mode Tes Lokal: Melewati 'docker pull'."
        info "Menggunakan image lokal: ${IMAGE_LATEST}"
        return
    fi

    info "Menarik image Docker terbaru: ${IMAGE_LATEST}"

    if ! docker pull "$IMAGE_LATEST"; then
        error "Gagal menarik image Docker. Pastikan:
  1. Image ada di registry
  2. Docker sudah login ke registry (docker login)
  3. IMAGE_LATEST benar: ${IMAGE_LATEST}"
    fi

    echo "✅ Image berhasil ditarik: ${IMAGE_LATEST}"
}

update_services() {
    info "Memperbarui dan menjalankan layanan produksi..."

    # Gunakan --project-directory . agar Docker Compose selalu menggunakan root sebagai basis
    if ! $COMPOSE_CMD --project-directory . -f docker/compose.yaml --profile prod up -d --force-recreate --remove-orphans; then
        error "Gagal menjalankan '${COMPOSE_CMD} up'."
    fi

    echo "✅ Layanan berhasil diperbarui."
}

cleanup_docker() {
    info "Membersihkan image Docker lama yang tidak terpakai..."
    docker image prune -a -f || warning "Cleanup gagal, tapi bukan masalah kritis."
    echo "✅ Cleanup selesai."
}

show_status() {
    info "Status Kontainer Produksi:"
    $COMPOSE_CMD --project-directory . -f docker/compose.yaml --profile prod ps

    echo ""
    info "Logs terakhir dari app-prod:"
    $COMPOSE_CMD --project-directory . -f docker/compose.yaml --profile prod logs --tail=20 app-prod
}

main() {
    echo "${BOLD}🚀 Memulai Proses Deployment ke Produksi...${NC}"
    echo "=============================================="
    echo ""

    cd "$PROJECT_ROOT" || exit 1

    # --- Argument Parsing ---
    BUILD_LOCALLY=0
    SKIP_PULL=0
    DEBUG=0

    while [[ $# -gt 0 ]]; do
        case $1 in
            --build-local)
                BUILD_LOCALLY=1
                info "Mode: Build Lokal"
                shift
                ;;
            --skip-pull)
                SKIP_PULL=1
                info "Mode: Skip Pull"
                shift
                ;;
            --debug)
                DEBUG=1
                info "Mode: Debug aktif"
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --build-local    Build image secara lokal (tidak pull dari registry)"
                echo "  --skip-pull      Skip pulling image dari registry"
                echo "  --debug          Tampilkan debug information"
                echo "  --help, -h       Tampilkan help ini"
                echo ""
                echo "Environment Variables:"
                echo "  PUID            User ID untuk container (default: current user)"
                echo "  PGID            Group ID untuk container (default: current group)"
                echo "  CI_REGISTRY_IMAGE    Docker registry image URL"
                echo "  CI_COMMIT_SHORT_SHA  Git commit SHA untuk image tag"
                echo ""
                exit 0
                ;;
            *)
                warning "Unknown option: $1"
                shift
                ;;
        esac
    done
    # --- End Argument Parsing ---

    check_prerequisites
    set_environment

    # --- Build Local Image if requested ---
    if [[ "$BUILD_LOCALLY" -eq 1 ]]; then
        build_local_image
        export LOCAL_TEST=1  # Force local test mode
    fi
    # --- End Build Local Image ---

    # --- Pull or Skip based on flags ---
    if [[ "$SKIP_PULL" -eq 0 ]]; then
        pull_docker_images
    else
        warning "Skipping docker pull as requested"
    fi
    # --- End Pull ---

    update_services
    cleanup_docker

    echo ""
    show_status

    echo ""
    echo "=============================================="
    echo "${BOLD}${GREEN}🎉 Deployment Selesai!${NC}"
    echo "=============================================="
    echo ""
    echo "💡 Useful commands:"
    echo "   Logs: docker compose -f docker/compose.yaml --profile prod logs -f app-prod"
    echo "   Shell: docker compose -f docker/compose.yaml --profile prod exec app-prod bash"
    echo "   Status: docker compose -f docker/compose.yaml --profile prod ps"
    echo ""
}

# --- Jalankan Skrip ---
main "$@"
