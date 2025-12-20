/**
 * Bot Room Seeder - Cloud Function
 * 
 * Ensures minimum bot-hosted game rooms are always available.
 * Runs on schedule (every hour) and on-demand.
 */

import * as admin from 'firebase-admin';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onCall } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';

const db = admin.firestore();

// AI Bot Personalities
const BOT_PERSONALITIES = [
    { id: 'bot_trickmaster', name: 'TrickMaster', difficulty: 'hard', avatar: '🎭' },
    { id: 'bot_cardshark', name: 'CardShark', difficulty: 'medium', avatar: '🃏' },
    { id: 'bot_luckydice', name: 'LuckyDice', difficulty: 'easy', avatar: '🎲' },
    { id: 'bot_deepthink', name: 'DeepThink', difficulty: 'expert', avatar: '🧠' },
    { id: 'bot_royalace', name: 'RoyalAce', difficulty: 'medium', avatar: '💎' },
];

// Game types to seed
const GAME_TYPES = ['royal_meld', 'marriage'];
const MIN_ROOMS_PER_GAME = 3;

interface Player {
    oderId: string;
    name: string;
    isBot: boolean;
    isReady: boolean;
    difficulty?: string;
}

interface GameRoom {
    id: string;
    gameType: string;
    hostId: string;
    hostName: string;
    roomCode: string;
    status: string;
    isPublic: boolean;
    isBotRoom: boolean;
    players: Player[];
    maxPlayers: number;
    createdAt: FirebaseFirestore.Timestamp;
    config: Record<string, unknown>;
}

/**
 * Generate a unique 6-digit room code
 */
function generateRoomCode(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
}

/**
 * Get random bot personality
 */
function getRandomBot(): typeof BOT_PERSONALITIES[0] {
    return BOT_PERSONALITIES[Math.floor(Math.random() * BOT_PERSONALITIES.length)];
}

/**
 * Create a bot-hosted game room
 */
async function createBotRoom(gameType: string): Promise<string> {
    const hostBot = getRandomBot();
    const roomCode = generateRoomCode();
    const roomId = `bot_room_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    // Create host player entry
    const hostPlayer: Player = {
        oderId: hostBot.id,
        name: `${hostBot.avatar} ${hostBot.name}`,
        isBot: true,
        isReady: true,
        difficulty: hostBot.difficulty,
    };

    // Add 1-2 additional bot players
    const additionalBots = Math.floor(Math.random() * 2) + 1;
    const players: Player[] = [hostPlayer];

    for (let i = 0; i < additionalBots; i++) {
        const bot = getRandomBot();
        if (!players.some(p => p.oderId === bot.id)) {
            players.push({
                oderId: bot.id,
                name: `${bot.avatar} ${bot.name}`,
                isBot: true,
                isReady: true,
                difficulty: bot.difficulty,
            });
        }
    }

    const gameRoom: Omit<GameRoom, 'id'> = {
        gameType,
        hostId: hostBot.id,
        hostName: `${hostBot.avatar} ${hostBot.name}`,
        roomCode,
        status: 'waiting',
        isPublic: true,
        isBotRoom: true,
        players,
        maxPlayers: 8,
        createdAt: admin.firestore.Timestamp.now(),
        config: {
            unitsPerPlay: gameType === 'marriage' ? 10 : 1,
            totalRounds: 5,
            difficulty: hostBot.difficulty,
            autoStart: true, // Auto-start when enough players join
            minPlayersToStart: 2,
        },
    };

    await db.collection('games').doc(roomId).set({ ...gameRoom, id: roomId });
    logger.info(`Created bot room: ${roomId} for ${gameType} hosted by ${hostBot.name}`);

    return roomId;
}

/**
 * Count active bot rooms for a game type
 */
async function countActiveBotRooms(gameType: string): Promise<number> {
    const snapshot = await db.collection('games')
        .where('gameType', '==', gameType)
        .where('isBotRoom', '==', true)
        .where('status', '==', 'waiting')
        .get();

    return snapshot.size;
}

/**
 * Clean up stale rooms (older than 24 hours, or test mode)
 */
async function cleanupStaleRooms(): Promise<number> {
    const cutoff = new Date();
    cutoff.setHours(cutoff.getHours() - 24);

    const snapshot = await db.collection('games')
        .where('status', '==', 'waiting')
        .where('createdAt', '<', admin.firestore.Timestamp.fromDate(cutoff))
        .get();

    const batch = db.batch();
    let count = 0;

    snapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
        count++;
    });

    if (count > 0) {
        await batch.commit();
        logger.info(`Cleaned up ${count} stale rooms`);
    }

    return count;
}

/**
 * Ensure minimum bot rooms exist for each game type
 */
async function ensureMinimumBotRooms(gameType: string, minRooms: number): Promise<number> {
    const currentCount = await countActiveBotRooms(gameType);
    const needed = minRooms - currentCount;

    if (needed <= 0) {
        logger.info(`${gameType}: Already has ${currentCount} bot rooms (min: ${minRooms})`);
        return 0;
    }

    logger.info(`${gameType}: Creating ${needed} bot rooms to reach minimum of ${minRooms}`);

    for (let i = 0; i < needed; i++) {
        await createBotRoom(gameType);
    }

    return needed;
}

// ==========================================
// EXPORTED CLOUD FUNCTIONS
// ==========================================

/**
 * Scheduled function - runs every hour
 */
export const seedBotRoomsScheduled = onSchedule(
    {
        schedule: 'every 1 hours',
        region: 'us-central1',
        timeoutSeconds: 120,
    },
    async () => {
        logger.info('Starting scheduled bot room seeding...');

        // Step 1: Cleanup stale rooms
        await cleanupStaleRooms();

        // Step 2: Seed bot rooms for each game type
        let totalCreated = 0;
        for (const gameType of GAME_TYPES) {
            const created = await ensureMinimumBotRooms(gameType, MIN_ROOMS_PER_GAME);
            totalCreated += created;
        }

        logger.info(`Bot room seeding complete. Created ${totalCreated} new rooms.`);
    }
);

/**
 * Callable function - for manual triggering or admin
 */
export const seedBotRoomsManual = onCall(
    {
        region: 'us-central1',
        timeoutSeconds: 60,
    },
    async (request) => {
        // Optional: Add admin check here
        // if (!request.auth?.token.admin) throw new Error('Unauthorized');

        logger.info('Manual bot room seeding triggered...');

        await cleanupStaleRooms();

        let totalCreated = 0;
        for (const gameType of GAME_TYPES) {
            const created = await ensureMinimumBotRooms(gameType, MIN_ROOMS_PER_GAME);
            totalCreated += created;
        }

        return { success: true, roomsCreated: totalCreated };
    }
);

/**
 * Cleanup function - removes ALL non-playing rooms (for reset)
 */
export const cleanupAllWaitingRooms = onCall(
    {
        region: 'us-central1',
        timeoutSeconds: 120,
    },
    async () => {
        logger.info('Cleaning up ALL waiting rooms...');

        const snapshot = await db.collection('games')
            .where('status', '==', 'waiting')
            .get();

        const batch = db.batch();
        let count = 0;

        snapshot.docs.forEach(doc => {
            batch.delete(doc.ref);
            count++;
        });

        if (count > 0) {
            await batch.commit();
        }

        // Re-seed bot rooms
        let totalCreated = 0;
        for (const gameType of GAME_TYPES) {
            const created = await ensureMinimumBotRooms(gameType, MIN_ROOMS_PER_GAME);
            totalCreated += created;
        }

        logger.info(`Cleaned ${count} rooms, created ${totalCreated} new bot rooms`);
        return { cleaned: count, created: totalCreated };
    }
);
