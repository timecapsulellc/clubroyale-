#!/bin/bash

# Marriage Game Test Runner Script
# Run all Marriage-related tests

echo "🎴 Marriage Game Test Suite"
echo "=============================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found in PATH${NC}"
    echo "Please ensure Flutter is installed and in your PATH"
    exit 1
fi

echo "✅ Flutter found: $(flutter --version | head -1)"
echo ""

# Run deck tests
echo "📦 Running Deck Configuration Tests..."
echo "--------------------------------------"
flutter test test/games/deck_test.dart --reporter=expanded
DECK_RESULT=$?

echo ""
echo ""

# Run Marriage game tests  
echo "🎮 Running Marriage Game Logic Tests..."
echo "--------------------------------------"
flutter test test/games/marriage_game_test.dart --reporter=expanded
GAME_RESULT=$?

echo ""
echo ""

# Summary
echo "=============================="
echo "📊 Test Summary"
echo "=============================="

if [ $DECK_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ Deck Tests: PASSED${NC}"
else
    echo -e "${RED}❌ Deck Tests: FAILED${NC}"
fi

if [ $GAME_RESULT -eq 0 ]; then
    echo -e "${GREEN}✅ Game Logic Tests: PASSED${NC}"
else
    echo -e "${RED}❌ Game Logic Tests: FAILED${NC}"
fi

echo ""

# Overall result
if [ $DECK_RESULT -eq 0 ] && [ $GAME_RESULT -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  SOME TESTS FAILED${NC}"
    exit 1
fi
