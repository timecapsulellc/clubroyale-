# Manual End-to-End (E2E) Testing Guide 🧪

**Objective:** Validate all core features before Beta Launch.  
**Estimated Time:** 30 Minutes  
**Prerequisite:** Two devices (or one phone + one laptop)

---

## 1. Authentication & Onboarding
*   [ ] **Clean Install:** Open app/url for the first time.
*   [ ] **Age Gate:** Verify "I am 18+" popup appears.
*   [ ] **Login:** Sign in with Google.
*   [ ] **Profile:** Check default avatar and username.
*   [ ] **Wallet:** Verify "Welcome Bonus" (1000 Diamonds) is received.

## 2. Lobby & Room Creation
*   [ ] **Create Room:** Tap "Create Room" → Select "Marriage".
*   [ ] **Settings:** Choose 4 Players, 3 Decks.
*   [ ] **Cost:** Verify 10 Diamonds deducted for creation.
*   [ ] **Room Code:** Note the 6-digit code displayed.

## 3. Multiplayer Join Flow
*   [ ] **Device B:** Open app/url and Login.
*   [ ] **Join:** Enter the 6-digit code from Device A.
*   [ ] **Lobby:** Verify Device B appears in Device A's lobby instantly.
*   [ ] **Bot Add:** Tap "Add Bot" on Device A. Verify Bot appears.
*   [ ] **Ready:** Toggle "Ready" on Device B. Verify status updates on Device A.

## 4. Game Gameplay (Marriage)
*   [ ] **Start:** Device A taps "Start Game".
*   [ ] **Deal:** Verify cards are dealt with animation.
*   [ ] **Sort:** Tap "Sort" button - verify cards organize by suit/sequence.
*   [ ] **Draw/Discard:**
    *   Device A draws a card.
    *   Device A discards a card.
    *   Verify turn moves to Device B.
*   [ ] **Bot Play:** Observe Bot making a move within 5 seconds.

## 5. Real-Time Features
*   [ ] **Chat:** Device A sends "Hello". Verify Device B sees it.
*   [ ] **Voice:** (If permission granted) Toggle Mic ON. Speak. Verify audio.
*   [ ] **Emote:** Click an avatar and send an emoji. Verify animation.

## 6. Game Completion & Settlement
*   [ ] **End Game:** (Fast forward) Finish a round or use "Leave Game" to simulate end.
*   [ ] **Scoreboard:** Verify scores are calculated (e.g., -10, +25).
*   [ ] **Settlement:** Check "Records" screen.
    *   Verify transaction: "Player B pays Player A: 10 units".

## 7. Notifications (FCM)
*   [ ] **Minimize:** Minimize app on Device B.
*   [ ] **Invite:** From Device A (Lobby), invite Device B (if friends).
*   [ ] **Notification:** Verify system notification appears on Device B.

## 8. Store (Simulation)
*   [ ] **Open Store:** Tap "+" on Diamonds.
*   [ ] **UI:** Verify products (100, 500, 1000) are listed.
*   [ ] *Note: Purchase will fail without RevenueCat keys, but UI should load.*

---

**Pass Criteria:**  
✅ No app crashes.  
✅ All real-time events sync < 2 seconds.  
✅ Scores calculate correctly.  
**Fail Criteria:**  
❌ App freeze/crash.  
❌ Cannot join room.  
❌ Cards disappear.

---
** Tester Signature: _________________________  Date: __________**
