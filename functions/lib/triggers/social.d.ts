/**
 * Social Cloud Function Triggers
 *
 * Firestore triggers for social events:
 * - Message sent → Update lastMessage, send push notifications
 * - Story created → Set expiry, notify friends
 * - Friend request created → Send push notification
 * - Friend request accepted → Grant diamonds, notify users
 * - Voice room created → Notify friends
 */
/**
 * Trigger when a new message is sent in a social chat
 * Updates chat's lastMessage and sends push notifications
 */
export declare const onSocialMessageSent: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").QueryDocumentSnapshot | undefined, {
    chatId: string;
    messageId: string;
}>>;
/**
 * Trigger when a new story is created
 * Sets expiry time and notifies friends
 */
export declare const onStoryCreated: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").QueryDocumentSnapshot | undefined, {
    storyId: string;
}>>;
/**
 * Trigger when a friend request is created
 * Sends push notification to recipient
 */
export declare const onFriendRequestCreated: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").QueryDocumentSnapshot | undefined, {
    friendshipId: string;
}>>;
/**
 * Trigger when a friendship is updated (accepted)
 * Grants diamonds and notifies both users
 */
export declare const onFriendshipUpdated: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").Change<import("firebase-functions/v2/firestore").QueryDocumentSnapshot> | undefined, {
    friendshipId: string;
}>>;
/**
 * Trigger when a voice room is created
 * Notifies host's friends
 */
export declare const onVoiceRoomCreated: import("firebase-functions/core").CloudFunction<import("firebase-functions/v2/firestore").FirestoreEvent<import("firebase-functions/v2/firestore").QueryDocumentSnapshot | undefined, {
    roomId: string;
}>>;
//# sourceMappingURL=social.d.ts.map