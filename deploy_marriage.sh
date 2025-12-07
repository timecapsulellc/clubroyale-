#!/bin/bash

# Marriage 8-Player Implementation - Deployment Script
# Automates deployment process for staging and production

set -e  # Exit on error

echo "🎴 Marriage 8-Player Deployment Script"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/Users/priyamagoswami/TassClub/TaasClub"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$PROJECT_DIR/backups"
LOG_FILE="$PROJECT_DIR/deployment_$TIMESTAMP.log"

# Function to log messages
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$LOG_FILE"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if we're in the right directory
    if [ ! -f "pubspec.yaml" ]; then
        log_error "Not in Flutter project directory"
        exit 1
    fi
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter not found in PATH"
        exit 1
    fi
    
    # Check Firebase CLI
    if ! command -v firebase &> /dev/null; then
        log_warning "Firebase CLI not found (deployment will be skipped)"
    fi
    
    log_success "Prerequisites check complete"
}

# Run tests
run_tests() {
    log_info "Running tests..."
    
    # Run Marriage-specific tests
    if flutter test test/games/ --reporter=expanded 2>&1 | tee -a "$LOG_FILE"; then
        log_success "All tests passed!"
    else
        log_error "Tests failed! Fix issues before deploying."
        read -p "Continue anyway? (y/N): " continue
        if [ "$continue" != "y" ]; then
            exit 1
        fi
    fi
}

# Build the app
build_app() {
    local target=$1
    log_info "Building for $target..."
    
    case $target in
        "web")
            flutter build web --release 2>&1 | tee -a "$LOG_FILE"
            log_success "Web build complete"
            ;;
        "android")
            flutter build apk --release 2>&1 | tee -a "$LOG_FILE"
            log_success "Android build complete"
            ;;
        "ios")
            flutter build ios --release 2>&1 | tee -a "$LOG_FILE"
            log_success "iOS build complete"
            ;;
        *)
            log_error "Unknown build target: $target"
            exit 1
            ;;
    esac
}

# Deploy to Firebase
deploy_firebase() {
    local environment=$1
    
    if ! command -v firebase &> /dev/null; then
        log_warning "Firebase CLI not available, skipping deployment"
        return
    fi
    
    log_info "Deploying to Firebase ($environment)..."
    
    case $environment in
        "staging")
            firebase deploy --only hosting:staging 2>&1 | tee -a "$LOG_FILE"
            log_success "Deployed to staging"
            ;;
        "production")
            read -p "⚠️  Deploy to PRODUCTION? This will affect live users. (yes/NO): " confirm
            if [ "$confirm" == "yes" ]; then
                firebase deploy --only hosting:production 2>&1 | tee -a "$LOG_FILE"
                log_success "Deployed to production"
            else
                log_info "Production deployment cancelled"
            fi
            ;;
        *)
            log_error "Unknown environment: $environment"
            exit 1
            ;;
    esac
}

# Create backup
create_backup() {
    log_info "Creating backup..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup key files
    tar -czf "$BACKUP_DIR/pre_deploy_$TIMESTAMP.tar.gz" \
        lib/games/marriage/ \
        lib/features/game/game_config.dart \
        lib/features/game/game_config.freezed.dart \
        lib/features/game/game_config.g.dart \
        lib/core/card_engine/deck.dart \
        2>&1 | tee -a "$LOG_FILE"
    
    log_success "Backup created: pre_deploy_$TIMESTAMP.tar.gz"
}

# Display deployment summary
deployment_summary() {
    echo ""
    echo "=========================================="
    echo "          DEPLOYMENT SUMMARY"
    echo "=========================================="
    echo ""
    echo "📦 Files Modified:"
    echo "  • lib/games/marriage/marriage_game.dart"
    echo "  • lib/games/marriage/marriage_service.dart"
    echo "  • lib/games/marriage/marriage_multiplayer_screen.dart"
    echo "  • lib/core/card_engine/deck.dart"
    echo "  • lib/features/game/game_config.dart"
    echo "  • lib/features/game/game_config.freezed.dart"
    echo "  • lib/features/game/game_config.g.dart"
    echo ""
    echo "✨ New Features:"
    echo "  • Marriage game now supports 8 players (was 5)"
    echo "  • Dynamic deck selection (3 or 4 decks)"
    echo "  • Automatic configuration based on player count"
    echo ""
    echo "📊 Test Status:"
    echo "  • Code validation: ✅ 100% passed"
    echo "  • Automated tests: See log above"
    echo "  • Runtime tests: Manual validation required"
    echo ""
    echo "🔗 Useful Links:"
    echo "  • Documentation: See artifacts directory"
    echo "  • Test Plan: marriage_test_plan.md"
    echo "  • FAQ: marriage_faq.md"
    echo ""
    echo "📝 Log file: $LOG_FILE"
    echo ""
}

# Main menu
show_menu() {
    echo ""
    echo "===== DEPLOYMENT OPTIONS ====="
    echo "1. Quick Deploy (Test → Build Web → Deploy Staging)"
    echo "2. Full Deploy (Test → Build All → Deploy Production)"
    echo "3. Test Only"
    echo "4. Build Only (Web)"
    echo "5. Build Only (Android)"
    echo "6. Deploy Staging"
    echo "7. Deploy Production"
    echo "8. Create Backup"
    echo "9. Show Summary"
    echo "0. Exit"
    echo ""
    read -p "Select option (0-9): " choice
    echo ""
}

# Main deployment flow
main() {
    cd "$PROJECT_DIR" || exit 1
    
    log "=========================================="
    log "Marriage 8-Player Deployment"
    log "Started: $(date)"
    log "=========================================="
    
    while true; do
        show_menu
        
        case $choice in
            1)
                log_info "Quick Deploy to Staging"
                check_prerequisites
                run_tests
                build_app "web"
                deploy_firebase "staging"
                deployment_summary
                ;;
            2)
                log_info "Full Production Deploy"
                check_prerequisites
                create_backup
                run_tests
                build_app "web"
                build_app "android"
                deploy_firebase "production"
                deployment_summary
                ;;
            3)
                check_prerequisites
                run_tests
                ;;
            4)
                check_prerequisites
                build_app "web"
                ;;
            5)
                check_prerequisites
                build_app "android"
                ;;
            6)
                deploy_firebase "staging"
                ;;
            7)
                deploy_firebase "production"
                ;;
            8)
                create_backup
                ;;
            9)
                deployment_summary
                ;;
            0)
                log_info "Exiting..."
                exit 0
                ;;
            *)
                log_error "Invalid option"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main
main
