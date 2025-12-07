#!/bin/bash

# Marriage Game - Interactive Runtime Testing Helper
# This script helps automate parts of runtime testing

echo "🎴 Marriage Game - Runtime Testing Helper"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Function to display menu
show_menu() {
    echo ""
    echo -e "${BLUE}=== Runtime Testing Menu ===${NC}"
    echo "1. Launch Web App (for testing)"
    echo "2. Open Firebase Console"
    echo "3. Run UI Tests (Interactive)"
    echo "4. Run Multiplayer Sync Tests"
    echo "5. Run Edge Case Tests"
    echo "6. View Test Results"
    echo "7. Generate Test Report"
    echo "8. Exit"
    echo ""
    read -p "Select option (1-8): " choice
    echo ""
}

# Launch web app
launch_app() {
    echo -e "${YELLOW}Launching Flutter web app...${NC}"
    echo "This will start the app on http://localhost:8080"
    echo ""
    
    cd /Users/priyamagoswami/TassClub/TaasClub
    
    # Check if flutter is available
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}❌ Flutter not found in PATH${NC}"
        echo "Please ensure Flutter SDK is installed"
        return 1
    fi
    
    echo "Starting Flutter web server..."
    flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0 &
    
    sleep 5
    echo ""
    echo -e "${GREEN}✅ App should be running at:${NC}"
    echo "   http://localhost:8080"
    echo ""
    echo "Open this URL in multiple browser tabs to test multiplayer"
    echo ""
    read -p "Press Enter to continue..."
}

# Open Firebase console
open_firebase() {
    echo -e "${YELLOW}Opening Firebase Console...${NC}"
    echo ""
    echo "Opening browser to Firebase Console..."
    echo "Please login and navigate to:"
    echo "  • Authentication (for test users)"
    echo "  • Firestore (to monitor game state)"
    echo ""
    
    # Try to open browser
    if command -v open &> /dev/null; then
        open "https://console.firebase.google.com/"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "https://console.firebase.google.com/"
    else
        echo "URL: https://console.firebase.google.com/"
    fi
    
    read -p "Press Enter to continue..."
}

# UI Tests Interactive
run_ui_tests() {
    echo -e "${BLUE}=== UI Tests with 8 Players ===${NC}"
    echo ""
    echo "Prerequisites:"
    echo "  ✓ App must be running"
    echo "  ✓ Open 8 browser tabs/windows"
    echo "  ✓ Create room and join with 8 players"
    echo ""
    read -p "Have you completed prerequisites? (y/n): " ready
    
    if [ "$ready" != "y" ]; then
        echo "Please complete prerequisites first"
        return
    fi
    
    echo ""
    echo -e "${YELLOW}Test 1.1: Opponent Display (8 Players)${NC}"
    echo "----------------------------------------"
    echo "1. Look at Player 1's screen"
    echo "2. Count visible opponents (should be 7)"
    echo "3. Check if all names/avatars are visible"
    echo ""
    read -p "Are all 7 opponents visible? (y/n): " result
    
    if [ "$result" == "y" ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
        read -p "Describe issue: " issue
        echo "Issue logged: $issue"
    fi
    
    echo ""
    echo -e "${YELLOW}Test 1.2: Hand Display (21 Cards)${NC}"
    echo "----------------------------------------"
    echo "1. Check Player 1's hand"
    echo "2. Count cards (should be 21)"
    echo "3. Verify cards are selectable"
    echo ""
    read -p "Are all 21 cards properly displayed? (y/n): " result
    
    if [ "$result" == "y" ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
    fi
    
    echo ""
    echo -e "${YELLOW}Test 1.3: Turn Indicator${NC}"
    echo "----------------------------------------"
    echo "1. Watch as each player takes a turn"
    echo "2. Verify turn order: P1→P2→P3→P4→P5→P6→P7→P8→P1"
    echo "3. Check if indicators update correctly"
    echo ""
    read -p "Does turn rotation work correctly? (y/n): " result
    
    if [ "$result" == "y" ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
    fi
    
    echo ""
    echo -e "${YELLOW}Test 1.4: Responsive Layout${NC}"
    echo "----------------------------------------"
    echo "1. Resize browser window"
    echo "2. Test: Desktop (1920x1080), Tablet (768x1024), Mobile (375x667)"
    echo "3. Check if layout adapts properly"
    echo ""
    read -p "Does layout work on all screen sizes? (y/n): " result
    
    if [ "$result" == "y" ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Multiplayer Sync Tests
run_multiplayer_tests() {
    echo -e "${BLUE}=== Multiplayer Sync Tests ===${NC}"
    echo ""
    
    echo -e "${YELLOW}Test 2.1: Real-Time Updates${NC}"
    echo "----------------------------------------"
    echo "1. Open 3 browser tabs with different players"
    echo "2. Player 1: Draw card from deck"
    echo "3. Check if all tabs update within 2 seconds"
    echo ""
    read -p "Did all tabs update in real-time? (y/n): " result
    
    if [ "$result" == "y" ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
        read -p "How long did it take (seconds)?: " latency
        echo "Latency logged: ${latency}s"
    fi
    
    echo ""
    echo -e "${YELLOW}Test 2.2: Player Disconnection${NC}"
    echo "----------------------------------------"
    echo "1. Close one player's tab during game"
    echo "2. Continue playing with remaining players"
    echo "3. Reopen disconnected player's tab"
    echo ""
    read -p "Did game handle disconnection gracefully? (y/n): " result
    
    if [ "$result" == "y" ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Edge Case Tests
run_edge_tests() {
    echo -e "${BLUE}=== Edge Case Tests ===${NC}"
    echo ""
    
    echo -e "${YELLOW}Test 3.1: Deck Exhaustion${NC}"
    echo "----------------------------------------"
    echo "1. Play until deck has few cards remaining"
    echo "2. Try to draw from deck when empty"
    echo "3. Check behavior"
    echo ""
    read -p "Did game handle empty deck gracefully? (y/n): " result
    
    if [ "$result" == "y" ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
    fi
    
    echo ""
    echo -e "${YELLOW}Test 3.2: Simultaneous Actions${NC}"
    echo "----------------------------------------"
    echo "1. Two players try to act at same time"
    echo "2. Check if only valid action succeeds"
    echo "3. Verify no data corruption"
    echo ""
    read -p "Were simultaneous actions handled correctly? (y/n): " result
    
    if [ "$result" == "y" ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ FAIL${NC}"
        ((TESTS_FAILED++))
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# View Results
view_results() {
    echo -e "${BLUE}=== Test Results Summary ===${NC}"
    echo ""
    echo "Total Tests Run: $((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    echo -e "${YELLOW}Skipped: $TESTS_SKIPPED${NC}"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed!${NC}"
    else
        echo -e "${YELLOW}⚠️  Some tests failed. Please review and fix issues.${NC}"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Generate Report
generate_report() {
    echo -e "${YELLOW}Generating test report...${NC}"
    
    REPORT_FILE="marriage_test_results_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$REPORT_FILE" << EOF
Marriage Game - Runtime Test Results
====================================
Date: $(date)
Tester: $(whoami)

Summary:
- Total Tests: $((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))
- Passed: $TESTS_PASSED
- Failed: $TESTS_FAILED
- Skipped: $TESTS_SKIPPED

Pass Rate: $(( TESTS_PASSED * 100 / (TESTS_PASSED + TESTS_FAILED + 1) ))%

Status: $([ $TESTS_FAILED -eq 0 ] && echo "✅ Ready for Production" || echo "⚠️  Needs Fixes")
EOF

    echo ""
    echo -e "${GREEN}✅ Report generated: $REPORT_FILE${NC}"
    echo ""
    cat "$REPORT_FILE"
    echo ""
    read -p "Press Enter to continue..."
}

# Main loop
while true; do
    show_menu
    
    case $choice in
        1) launch_app ;;
        2) open_firebase ;;
        3) run_ui_tests ;;
        4) run_multiplayer_tests ;;
        5) run_edge_tests ;;
        6) view_results ;;
        7) generate_report ;;
        8) 
            echo "Exiting..."
            view_results
            exit 0
            ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
done
