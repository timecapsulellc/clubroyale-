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

import { onDocumentCreated, onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { getFirestore, FieldValue, Timestamp, Firestore } from 'firebase-admin/firestore';
import { getMessaging, Messaging } from 'firebase-admin/messaging';

// Lazy initialization to avoid calling before initializeApp()
let _db: Firestore | null = null;
let _messaging: Messaging | null = null;

const db = (): Firestore => {
    if (!_db) _db = getFirestore();
    return _db;
};

const messaging = (): Messaging => {
    if (!_messaging) _messaging = getMessaging();
    return _messaging;
};

// =====================================================
// MESSAGE TRIGGERS
// =====================================================

/**
 * Trigger when a new message is sent in a social chat
 * Updates chat's lastMessage and sends push notifications
 */
export const onSocialMessageSent = onDocumentCreated(
    'chats/{chatId}/messages/{messageId}',
    async (event) => {
        const message = event.data?.data();
        const { chatId, messageId } = event.params;

        if (!message) return;

        const senderId = message.senderId as string;
        const content = message.content as { text?: string } | undefined;
        const messageType = message.type as string;

        // 1. Update chat's lastMessage
        await db().collection('chats').doc(chatId).update({
            'lastMessage': {
                text: getMessagePreview(messageType, content?.text),
                senderId: senderId,
                timestamp: FieldValue.serverTimestamp(),
                type: messageType,
            },
            'updatedAt': FieldValue.serverTimestamp(),
        });

        // 2. Get chat participants and send push notifications
        const chatDoc = await db().collection('chats').doc(chatId).get();
        const chatData = chatDoc.data();
        if (!chatData) return;

        const participants = chatData.participants as string[] || [];

        // Send push to all participants except sender
        for (const userId of participants) {
            if (userId === senderId) continue;

            // Check if user is online (skip if online)
            const userDoc = await db().collection('users').doc(userId).get();
            const userData = userDoc.data();
            if (userData?.isOnline) continue;

            // Get sender name
            const senderDoc = await db().collection('users').doc(senderId).get();
            const senderName = senderDoc.data()?.displayName || 'Someone';

            // Get FCM token
            const fcmToken = userData?.fcmToken;
            if (!fcmToken) continue;

            try {
                await messaging().send({
                    token: fcmToken,
                    notification: {
                        title: senderName,
                        body: getMessagePreview(messageType, content?.text),
                    },
                    data: {
                        type: 'chat_message',
                        chatId: chatId,
                        messageId: messageId,
                        senderId: senderId,
                    },
                    android: {
                        priority: 'high',
                        notification: {
                            channelId: 'chat_messages',
                        },
                    },
                    apns: {
                        payload: {
                            aps: {
                                badge: 1,
                                sound: 'default',
                            },
                        },
                    },
                });
            } catch (error) {
                console.error(`Failed to send push to ${userId}:`, error);
            }
        }
    }
);

// =====================================================
// STORY TRIGGERS
// =====================================================

/**
 * Trigger when a new story is created
 * Sets expiry time and notifies friends
 */
export const onStoryCreated = onDocumentCreated(
    'stories/{storyId}',
    async (event) => {
        const story = event.data?.data();
        const { storyId } = event.params;

        if (!story) return;

        const userId = story.userId as string;

        // 1. Set expiry if not already set (24 hours from creation)
        if (!story.expiresAt) {
            const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
            await db().collection('stories').doc(storyId).update({
                expiresAt: Timestamp.fromDate(expiresAt),
            });
        }

        // 2. Get user's friends and notify them
        const friendsSnapshot = await db()
            .collection('users')
            .doc(userId)
            .collection('friends')
            .get();

        const friendIds = friendsSnapshot.docs.map(doc => doc.id);

        // 3. Send push notifications to close friends (optional, can be expensive)
        // For now, just log the event
        console.log(`Story ${storyId} created by ${userId}, ${friendIds.length} friends to notify`);

        // 4. Track analytics
        await db().collection('analytics').add({
            event: 'story_created',
            userId: userId,
            storyId: storyId,
            storyType: story.mediaType,
            timestamp: FieldValue.serverTimestamp(),
        });
    }
);

// =====================================================
// FRIENDSHIP TRIGGERS
// =====================================================

/**
 * Trigger when a friend request is created
 * Sends push notification to recipient
 */
export const onFriendRequestCreated = onDocumentCreated(
    'friendships/{friendshipId}',
    async (event) => {
        const friendship = event.data?.data();
        const { friendshipId } = event.params;

        if (!friendship) return;

        // Only trigger for pending requests
        if (friendship.status !== 'pending') return;

        const initiatedBy = friendship.initiatedBy as string;
        const users = friendship.users as string[];
        const recipientId = users.find(id => id !== initiatedBy);

        if (!recipientId) return;

        // Get initiator name
        const initiatorDoc = await db().collection('users').doc(initiatedBy).get();
        const initiatorName = initiatorDoc.data()?.displayName || 'Someone';

        // Get recipient's FCM token
        const recipientDoc = await db().collection('users').doc(recipientId).get();
        const fcmToken = recipientDoc.data()?.fcmToken;

        if (fcmToken) {
            try {
                await messaging().send({
                    token: fcmToken,
                    notification: {
                        title: 'Friend Request',
                        body: `${initiatorName} wants to be your friend`,
                    },
                    data: {
                        type: 'friend_request',
                        friendshipId: friendshipId,
                        fromUserId: initiatedBy,
                    },
                    android: {
                        notification: {
                            channelId: 'social',
                        },
                    },
                });
            } catch (error) {
                console.error(`Failed to send friend request push to ${recipientId}:`, error);
            }
        }

        // Grant diamonds for social activity
        await db().collection('users').doc(initiatedBy).update({
            diamondBalance: FieldValue.increment(5),
            'diamondsByOrigin.socialActivity': FieldValue.increment(5),
        });
    }
);

/**
 * Trigger when a friendship is updated (accepted)
 * Grants diamonds and notifies both users
 */
export const onFriendshipUpdated = onDocumentUpdated(
    'friendships/{friendshipId}',
    async (event) => {
        const before = event.data?.before.data();
        const after = event.data?.after.data();

        if (!before || !after) return;

        // Check if status changed from pending to accepted
        if (before.status !== 'pending' || after.status !== 'accepted') return;

        const users = after.users as string[];

        // Grant diamonds to both users for new friendship
        for (const userId of users) {
            await db().collection('users').doc(userId).update({
                diamondBalance: FieldValue.increment(10),
                'diamondsByOrigin.socialActivity': FieldValue.increment(10),
            });

            // Get the other user's name
            const otherId = users.find(id => id !== userId);
            if (!otherId) continue;

            const otherDoc = await db().collection('users').doc(otherId).get();
            const otherName = otherDoc.data()?.displayName || 'A user';

            // Send push notification
            const userDoc = await db().collection('users').doc(userId).get();
            const fcmToken = userDoc.data()?.fcmToken;

            if (fcmToken) {
                try {
                    await messaging().send({
                        token: fcmToken,
                        notification: {
                            title: 'New Friend! 🎉',
                            body: `You and ${otherName} are now friends! +10 💎`,
                        },
                        data: {
                            type: 'friend_accepted',
                            friendId: otherId,
                        },
                    });
                } catch (error) {
                    console.error(`Failed to send friend accepted push to ${userId}:`, error);
                }
            }
        }
    }
);

// =====================================================
// VOICE ROOM TRIGGERS
// =====================================================

/**
 * Trigger when a voice room is created
 * Notifies host's friends
 */
export const onVoiceRoomCreated = onDocumentCreated(
    'voice_rooms/{roomId}',
    async (event) => {
        const room = event.data?.data();
        const { roomId } = event.params;

        if (!room) return;

        const hostId = room.hostId as string;
        const title = room.title as string || 'Voice Room';

        // Get host's friends
        const friendsSnapshot = await db()
            .collection('users')
            .doc(hostId)
            .collection('friends')
            .get();

        // Get host name
        const hostDoc = await db().collection('users').doc(hostId).get();
        const hostName = hostDoc.data()?.displayName || 'Someone';

        // Send push to friends (limit to avoid excessive notifications)
        const friendsToNotify = friendsSnapshot.docs.slice(0, 20);

        for (const friendDoc of friendsToNotify) {
            const friendId = friendDoc.id;
            const userDoc = await db().collection('users').doc(friendId).get();
            const fcmToken = userDoc.data()?.fcmToken;

            if (fcmToken) {
                try {
                    await messaging().send({
                        token: fcmToken,
                        notification: {
                            title: '🎙️ Voice Room',
                            body: `${hostName} started "${title}"`,
                        },
                        data: {
                            type: 'voice_room_invite',
                            roomId: roomId,
                            hostId: hostId,
                        },
                    });
                } catch (error) {
                    // Silent fail for individual notification errors
                }
            }
        }

        console.log(`Voice room ${roomId} created by ${hostId}, notified ${friendsToNotify.length} friends`);
    }
);

// =====================================================
// HELPER FUNCTIONS
// =====================================================

function getMessagePreview(type: string, text?: string): string {
    switch (type) {
        case 'text':
            return text?.substring(0, 100) || 'Sent a message';
        case 'image':
            return '📷 Photo';
        case 'video':
            return '🎬 Video';
        case 'audio':
            return '🎤 Voice message';
        case 'gameInvite':
            return '🎮 Game invite';
        case 'diamondGift':
            return '💎 Diamond gift';
        case 'gameResult':
            return '🏆 Game result';
        default:
            return 'Sent a message';
    }
}
