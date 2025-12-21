/**
 * Economy Agent
 * Diamond flow optimization, spending analysis, and economy health monitoring
 */
import { z } from 'genkit';
/**
 * Analyze economy health for a user
 */
export declare const analyzeEconomyHealthFlow: import("genkit").CallableFlow<z.ZodObject<{
    userData: z.ZodObject<{
        userId: z.ZodString;
        diamondBalance: z.ZodNumber;
        diamondsEarnedTotal: z.ZodNumber;
        diamondsSpentTotal: z.ZodNumber;
        purchaseHistory: z.ZodArray<z.ZodObject<{
            date: z.ZodString;
            amount: z.ZodNumber;
            type: z.ZodEnum<["iap", "ad_reward", "bonus"]>;
        }, "strip", z.ZodTypeAny, {
            type: "iap" | "ad_reward" | "bonus";
            date: string;
            amount: number;
        }, {
            type: "iap" | "ad_reward" | "bonus";
            date: string;
            amount: number;
        }>, "many">;
        spendingHistory: z.ZodArray<z.ZodObject<{
            date: z.ZodString;
            amount: z.ZodNumber;
            category: z.ZodEnum<["game_entry", "cosmetics", "gifts", "tips"]>;
        }, "strip", z.ZodTypeAny, {
            date: string;
            category: "game_entry" | "cosmetics" | "gifts" | "tips";
            amount: number;
        }, {
            date: string;
            category: "game_entry" | "cosmetics" | "gifts" | "tips";
            amount: number;
        }>, "many">;
        lastSevenDaysActivity: z.ZodObject<{
            gamesPlayed: z.ZodNumber;
            diamondsWon: z.ZodNumber;
            diamondsLost: z.ZodNumber;
            adsWatched: z.ZodNumber;
        }, "strip", z.ZodTypeAny, {
            gamesPlayed: number;
            diamondsWon: number;
            diamondsLost: number;
            adsWatched: number;
        }, {
            gamesPlayed: number;
            diamondsWon: number;
            diamondsLost: number;
            adsWatched: number;
        }>;
        accountAgeDays: z.ZodNumber;
        isPremium: z.ZodBoolean;
    }, "strip", z.ZodTypeAny, {
        userId: string;
        diamondBalance: number;
        diamondsEarnedTotal: number;
        diamondsSpentTotal: number;
        purchaseHistory: {
            type: "iap" | "ad_reward" | "bonus";
            date: string;
            amount: number;
        }[];
        spendingHistory: {
            date: string;
            category: "game_entry" | "cosmetics" | "gifts" | "tips";
            amount: number;
        }[];
        lastSevenDaysActivity: {
            gamesPlayed: number;
            diamondsWon: number;
            diamondsLost: number;
            adsWatched: number;
        };
        accountAgeDays: number;
        isPremium: boolean;
    }, {
        userId: string;
        diamondBalance: number;
        diamondsEarnedTotal: number;
        diamondsSpentTotal: number;
        purchaseHistory: {
            type: "iap" | "ad_reward" | "bonus";
            date: string;
            amount: number;
        }[];
        spendingHistory: {
            date: string;
            category: "game_entry" | "cosmetics" | "gifts" | "tips";
            amount: number;
        }[];
        lastSevenDaysActivity: {
            gamesPlayed: number;
            diamondsWon: number;
            diamondsLost: number;
            adsWatched: number;
        };
        accountAgeDays: number;
        isPremium: boolean;
    }>;
}, "strip", z.ZodTypeAny, {
    userData: {
        userId: string;
        diamondBalance: number;
        diamondsEarnedTotal: number;
        diamondsSpentTotal: number;
        purchaseHistory: {
            type: "iap" | "ad_reward" | "bonus";
            date: string;
            amount: number;
        }[];
        spendingHistory: {
            date: string;
            category: "game_entry" | "cosmetics" | "gifts" | "tips";
            amount: number;
        }[];
        lastSevenDaysActivity: {
            gamesPlayed: number;
            diamondsWon: number;
            diamondsLost: number;
            adsWatched: number;
        };
        accountAgeDays: number;
        isPremium: boolean;
    };
}, {
    userData: {
        userId: string;
        diamondBalance: number;
        diamondsEarnedTotal: number;
        diamondsSpentTotal: number;
        purchaseHistory: {
            type: "iap" | "ad_reward" | "bonus";
            date: string;
            amount: number;
        }[];
        spendingHistory: {
            date: string;
            category: "game_entry" | "cosmetics" | "gifts" | "tips";
            amount: number;
        }[];
        lastSevenDaysActivity: {
            gamesPlayed: number;
            diamondsWon: number;
            diamondsLost: number;
            adsWatched: number;
        };
        accountAgeDays: number;
        isPremium: boolean;
    };
}>, z.ZodObject<{
    userId: z.ZodString;
    healthScore: z.ZodNumber;
    burnRate: z.ZodNumber;
    runwayDays: z.ZodNumber;
    riskLevel: z.ZodEnum<["healthy", "watch", "at_risk", "critical"]>;
    recommendations: z.ZodArray<z.ZodString, "many">;
    suggestedRewards: z.ZodArray<z.ZodObject<{
        type: z.ZodEnum<["daily_bonus", "ad_reward", "achievement", "comeback"]>;
        amount: z.ZodNumber;
        reason: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        type: "achievement" | "daily_bonus" | "ad_reward" | "comeback";
        reason: string;
        amount: number;
    }, {
        type: "achievement" | "daily_bonus" | "ad_reward" | "comeback";
        reason: string;
        amount: number;
    }>, "many">;
}, "strip", z.ZodTypeAny, {
    riskLevel: "critical" | "healthy" | "watch" | "at_risk";
    userId: string;
    recommendations: string[];
    healthScore: number;
    burnRate: number;
    runwayDays: number;
    suggestedRewards: {
        type: "achievement" | "daily_bonus" | "ad_reward" | "comeback";
        reason: string;
        amount: number;
    }[];
}, {
    riskLevel: "critical" | "healthy" | "watch" | "at_risk";
    userId: string;
    recommendations: string[];
    healthScore: number;
    burnRate: number;
    runwayDays: number;
    suggestedRewards: {
        type: "achievement" | "daily_bonus" | "ad_reward" | "comeback";
        reason: string;
        amount: number;
    }[];
}>, z.ZodTypeAny>;
/**
 * Analyze spending patterns for a user
 */
export declare const analyzeSpendingFlow: import("genkit").CallableFlow<z.ZodObject<{
    userData: z.ZodObject<{
        userId: z.ZodString;
        spendingHistory: z.ZodArray<z.ZodObject<{
            date: z.ZodString;
            amount: z.ZodNumber;
            category: z.ZodEnum<["game_entry", "cosmetics", "gifts", "tips"]>;
            context: z.ZodOptional<z.ZodString>;
        }, "strip", z.ZodTypeAny, {
            date: string;
            category: "game_entry" | "cosmetics" | "gifts" | "tips";
            amount: number;
            context?: string | undefined;
        }, {
            date: string;
            category: "game_entry" | "cosmetics" | "gifts" | "tips";
            amount: number;
            context?: string | undefined;
        }>, "many">;
        recentGames: z.ZodArray<z.ZodObject<{
            stakeLevel: z.ZodNumber;
            result: z.ZodEnum<["win", "loss"]>;
            amount: z.ZodNumber;
        }, "strip", z.ZodTypeAny, {
            amount: number;
            result: "win" | "loss";
            stakeLevel: number;
        }, {
            amount: number;
            result: "win" | "loss";
            stakeLevel: number;
        }>, "many">;
    }, "strip", z.ZodTypeAny, {
        userId: string;
        spendingHistory: {
            date: string;
            category: "game_entry" | "cosmetics" | "gifts" | "tips";
            amount: number;
            context?: string | undefined;
        }[];
        recentGames: {
            amount: number;
            result: "win" | "loss";
            stakeLevel: number;
        }[];
    }, {
        userId: string;
        spendingHistory: {
            date: string;
            category: "game_entry" | "cosmetics" | "gifts" | "tips";
            amount: number;
            context?: string | undefined;
        }[];
        recentGames: {
            amount: number;
            result: "win" | "loss";
            stakeLevel: number;
        }[];
    }>;
}, "strip", z.ZodTypeAny, {
    userData: {
        userId: string;
        spendingHistory: {
            date: string;
            category: "game_entry" | "cosmetics" | "gifts" | "tips";
            amount: number;
            context?: string | undefined;
        }[];
        recentGames: {
            amount: number;
            result: "win" | "loss";
            stakeLevel: number;
        }[];
    };
}, {
    userData: {
        userId: string;
        spendingHistory: {
            date: string;
            category: "game_entry" | "cosmetics" | "gifts" | "tips";
            amount: number;
            context?: string | undefined;
        }[];
        recentGames: {
            amount: number;
            result: "win" | "loss";
            stakeLevel: number;
        }[];
    };
}>, z.ZodObject<{
    userId: z.ZodString;
    primaryCategory: z.ZodString;
    spendingVelocity: z.ZodEnum<["conservative", "moderate", "aggressive"]>;
    peakSpendingTime: z.ZodString;
    averageBetSize: z.ZodNumber;
    riskAppetite: z.ZodNumber;
    insights: z.ZodArray<z.ZodString, "many">;
}, "strip", z.ZodTypeAny, {
    userId: string;
    insights: string[];
    primaryCategory: string;
    spendingVelocity: "moderate" | "aggressive" | "conservative";
    peakSpendingTime: string;
    averageBetSize: number;
    riskAppetite: number;
}, {
    userId: string;
    insights: string[];
    primaryCategory: string;
    spendingVelocity: "moderate" | "aggressive" | "conservative";
    peakSpendingTime: string;
    averageBetSize: number;
    riskAppetite: number;
}>, z.ZodTypeAny>;
/**
 * Optimize reward distribution for a user
 */
export declare const optimizeRewardsFlow: import("genkit").CallableFlow<z.ZodObject<{
    userId: z.ZodString;
    currentBalance: z.ZodNumber;
    recentActivity: z.ZodObject<{
        lastLoginDays: z.ZodNumber;
        gamesPlayedLast7Days: z.ZodNumber;
        adsWatchedLast7Days: z.ZodNumber;
    }, "strip", z.ZodTypeAny, {
        lastLoginDays: number;
        gamesPlayedLast7Days: number;
        adsWatchedLast7Days: number;
    }, {
        lastLoginDays: number;
        gamesPlayedLast7Days: number;
        adsWatchedLast7Days: number;
    }>;
    economyHealth: z.ZodEnum<["healthy", "watch", "at_risk", "critical"]>;
}, "strip", z.ZodTypeAny, {
    userId: string;
    currentBalance: number;
    recentActivity: {
        lastLoginDays: number;
        gamesPlayedLast7Days: number;
        adsWatchedLast7Days: number;
    };
    economyHealth: "critical" | "healthy" | "watch" | "at_risk";
}, {
    userId: string;
    currentBalance: number;
    recentActivity: {
        lastLoginDays: number;
        gamesPlayedLast7Days: number;
        adsWatchedLast7Days: number;
    };
    economyHealth: "critical" | "healthy" | "watch" | "at_risk";
}>, z.ZodObject<{
    dailyReward: z.ZodNumber;
    bonusMultiplier: z.ZodNumber;
    specialOffer: z.ZodOptional<z.ZodString>;
    urgency: z.ZodEnum<["none", "low", "medium", "high"]>;
    message: z.ZodString;
}, "strip", z.ZodTypeAny, {
    message: string;
    dailyReward: number;
    bonusMultiplier: number;
    urgency: "high" | "medium" | "low" | "none";
    specialOffer?: string | undefined;
}, {
    message: string;
    dailyReward: number;
    bonusMultiplier: number;
    urgency: "high" | "medium" | "low" | "none";
    specialOffer?: string | undefined;
}>, z.ZodTypeAny>;
declare const _default: {
    analyzeEconomyHealthFlow: import("genkit").CallableFlow<z.ZodObject<{
        userData: z.ZodObject<{
            userId: z.ZodString;
            diamondBalance: z.ZodNumber;
            diamondsEarnedTotal: z.ZodNumber;
            diamondsSpentTotal: z.ZodNumber;
            purchaseHistory: z.ZodArray<z.ZodObject<{
                date: z.ZodString;
                amount: z.ZodNumber;
                type: z.ZodEnum<["iap", "ad_reward", "bonus"]>;
            }, "strip", z.ZodTypeAny, {
                type: "iap" | "ad_reward" | "bonus";
                date: string;
                amount: number;
            }, {
                type: "iap" | "ad_reward" | "bonus";
                date: string;
                amount: number;
            }>, "many">;
            spendingHistory: z.ZodArray<z.ZodObject<{
                date: z.ZodString;
                amount: z.ZodNumber;
                category: z.ZodEnum<["game_entry", "cosmetics", "gifts", "tips"]>;
            }, "strip", z.ZodTypeAny, {
                date: string;
                category: "game_entry" | "cosmetics" | "gifts" | "tips";
                amount: number;
            }, {
                date: string;
                category: "game_entry" | "cosmetics" | "gifts" | "tips";
                amount: number;
            }>, "many">;
            lastSevenDaysActivity: z.ZodObject<{
                gamesPlayed: z.ZodNumber;
                diamondsWon: z.ZodNumber;
                diamondsLost: z.ZodNumber;
                adsWatched: z.ZodNumber;
            }, "strip", z.ZodTypeAny, {
                gamesPlayed: number;
                diamondsWon: number;
                diamondsLost: number;
                adsWatched: number;
            }, {
                gamesPlayed: number;
                diamondsWon: number;
                diamondsLost: number;
                adsWatched: number;
            }>;
            accountAgeDays: z.ZodNumber;
            isPremium: z.ZodBoolean;
        }, "strip", z.ZodTypeAny, {
            userId: string;
            diamondBalance: number;
            diamondsEarnedTotal: number;
            diamondsSpentTotal: number;
            purchaseHistory: {
                type: "iap" | "ad_reward" | "bonus";
                date: string;
                amount: number;
            }[];
            spendingHistory: {
                date: string;
                category: "game_entry" | "cosmetics" | "gifts" | "tips";
                amount: number;
            }[];
            lastSevenDaysActivity: {
                gamesPlayed: number;
                diamondsWon: number;
                diamondsLost: number;
                adsWatched: number;
            };
            accountAgeDays: number;
            isPremium: boolean;
        }, {
            userId: string;
            diamondBalance: number;
            diamondsEarnedTotal: number;
            diamondsSpentTotal: number;
            purchaseHistory: {
                type: "iap" | "ad_reward" | "bonus";
                date: string;
                amount: number;
            }[];
            spendingHistory: {
                date: string;
                category: "game_entry" | "cosmetics" | "gifts" | "tips";
                amount: number;
            }[];
            lastSevenDaysActivity: {
                gamesPlayed: number;
                diamondsWon: number;
                diamondsLost: number;
                adsWatched: number;
            };
            accountAgeDays: number;
            isPremium: boolean;
        }>;
    }, "strip", z.ZodTypeAny, {
        userData: {
            userId: string;
            diamondBalance: number;
            diamondsEarnedTotal: number;
            diamondsSpentTotal: number;
            purchaseHistory: {
                type: "iap" | "ad_reward" | "bonus";
                date: string;
                amount: number;
            }[];
            spendingHistory: {
                date: string;
                category: "game_entry" | "cosmetics" | "gifts" | "tips";
                amount: number;
            }[];
            lastSevenDaysActivity: {
                gamesPlayed: number;
                diamondsWon: number;
                diamondsLost: number;
                adsWatched: number;
            };
            accountAgeDays: number;
            isPremium: boolean;
        };
    }, {
        userData: {
            userId: string;
            diamondBalance: number;
            diamondsEarnedTotal: number;
            diamondsSpentTotal: number;
            purchaseHistory: {
                type: "iap" | "ad_reward" | "bonus";
                date: string;
                amount: number;
            }[];
            spendingHistory: {
                date: string;
                category: "game_entry" | "cosmetics" | "gifts" | "tips";
                amount: number;
            }[];
            lastSevenDaysActivity: {
                gamesPlayed: number;
                diamondsWon: number;
                diamondsLost: number;
                adsWatched: number;
            };
            accountAgeDays: number;
            isPremium: boolean;
        };
    }>, z.ZodObject<{
        userId: z.ZodString;
        healthScore: z.ZodNumber;
        burnRate: z.ZodNumber;
        runwayDays: z.ZodNumber;
        riskLevel: z.ZodEnum<["healthy", "watch", "at_risk", "critical"]>;
        recommendations: z.ZodArray<z.ZodString, "many">;
        suggestedRewards: z.ZodArray<z.ZodObject<{
            type: z.ZodEnum<["daily_bonus", "ad_reward", "achievement", "comeback"]>;
            amount: z.ZodNumber;
            reason: z.ZodString;
        }, "strip", z.ZodTypeAny, {
            type: "achievement" | "daily_bonus" | "ad_reward" | "comeback";
            reason: string;
            amount: number;
        }, {
            type: "achievement" | "daily_bonus" | "ad_reward" | "comeback";
            reason: string;
            amount: number;
        }>, "many">;
    }, "strip", z.ZodTypeAny, {
        riskLevel: "critical" | "healthy" | "watch" | "at_risk";
        userId: string;
        recommendations: string[];
        healthScore: number;
        burnRate: number;
        runwayDays: number;
        suggestedRewards: {
            type: "achievement" | "daily_bonus" | "ad_reward" | "comeback";
            reason: string;
            amount: number;
        }[];
    }, {
        riskLevel: "critical" | "healthy" | "watch" | "at_risk";
        userId: string;
        recommendations: string[];
        healthScore: number;
        burnRate: number;
        runwayDays: number;
        suggestedRewards: {
            type: "achievement" | "daily_bonus" | "ad_reward" | "comeback";
            reason: string;
            amount: number;
        }[];
    }>, z.ZodTypeAny>;
    analyzeSpendingFlow: import("genkit").CallableFlow<z.ZodObject<{
        userData: z.ZodObject<{
            userId: z.ZodString;
            spendingHistory: z.ZodArray<z.ZodObject<{
                date: z.ZodString;
                amount: z.ZodNumber;
                category: z.ZodEnum<["game_entry", "cosmetics", "gifts", "tips"]>;
                context: z.ZodOptional<z.ZodString>;
            }, "strip", z.ZodTypeAny, {
                date: string;
                category: "game_entry" | "cosmetics" | "gifts" | "tips";
                amount: number;
                context?: string | undefined;
            }, {
                date: string;
                category: "game_entry" | "cosmetics" | "gifts" | "tips";
                amount: number;
                context?: string | undefined;
            }>, "many">;
            recentGames: z.ZodArray<z.ZodObject<{
                stakeLevel: z.ZodNumber;
                result: z.ZodEnum<["win", "loss"]>;
                amount: z.ZodNumber;
            }, "strip", z.ZodTypeAny, {
                amount: number;
                result: "win" | "loss";
                stakeLevel: number;
            }, {
                amount: number;
                result: "win" | "loss";
                stakeLevel: number;
            }>, "many">;
        }, "strip", z.ZodTypeAny, {
            userId: string;
            spendingHistory: {
                date: string;
                category: "game_entry" | "cosmetics" | "gifts" | "tips";
                amount: number;
                context?: string | undefined;
            }[];
            recentGames: {
                amount: number;
                result: "win" | "loss";
                stakeLevel: number;
            }[];
        }, {
            userId: string;
            spendingHistory: {
                date: string;
                category: "game_entry" | "cosmetics" | "gifts" | "tips";
                amount: number;
                context?: string | undefined;
            }[];
            recentGames: {
                amount: number;
                result: "win" | "loss";
                stakeLevel: number;
            }[];
        }>;
    }, "strip", z.ZodTypeAny, {
        userData: {
            userId: string;
            spendingHistory: {
                date: string;
                category: "game_entry" | "cosmetics" | "gifts" | "tips";
                amount: number;
                context?: string | undefined;
            }[];
            recentGames: {
                amount: number;
                result: "win" | "loss";
                stakeLevel: number;
            }[];
        };
    }, {
        userData: {
            userId: string;
            spendingHistory: {
                date: string;
                category: "game_entry" | "cosmetics" | "gifts" | "tips";
                amount: number;
                context?: string | undefined;
            }[];
            recentGames: {
                amount: number;
                result: "win" | "loss";
                stakeLevel: number;
            }[];
        };
    }>, z.ZodObject<{
        userId: z.ZodString;
        primaryCategory: z.ZodString;
        spendingVelocity: z.ZodEnum<["conservative", "moderate", "aggressive"]>;
        peakSpendingTime: z.ZodString;
        averageBetSize: z.ZodNumber;
        riskAppetite: z.ZodNumber;
        insights: z.ZodArray<z.ZodString, "many">;
    }, "strip", z.ZodTypeAny, {
        userId: string;
        insights: string[];
        primaryCategory: string;
        spendingVelocity: "moderate" | "aggressive" | "conservative";
        peakSpendingTime: string;
        averageBetSize: number;
        riskAppetite: number;
    }, {
        userId: string;
        insights: string[];
        primaryCategory: string;
        spendingVelocity: "moderate" | "aggressive" | "conservative";
        peakSpendingTime: string;
        averageBetSize: number;
        riskAppetite: number;
    }>, z.ZodTypeAny>;
    optimizeRewardsFlow: import("genkit").CallableFlow<z.ZodObject<{
        userId: z.ZodString;
        currentBalance: z.ZodNumber;
        recentActivity: z.ZodObject<{
            lastLoginDays: z.ZodNumber;
            gamesPlayedLast7Days: z.ZodNumber;
            adsWatchedLast7Days: z.ZodNumber;
        }, "strip", z.ZodTypeAny, {
            lastLoginDays: number;
            gamesPlayedLast7Days: number;
            adsWatchedLast7Days: number;
        }, {
            lastLoginDays: number;
            gamesPlayedLast7Days: number;
            adsWatchedLast7Days: number;
        }>;
        economyHealth: z.ZodEnum<["healthy", "watch", "at_risk", "critical"]>;
    }, "strip", z.ZodTypeAny, {
        userId: string;
        currentBalance: number;
        recentActivity: {
            lastLoginDays: number;
            gamesPlayedLast7Days: number;
            adsWatchedLast7Days: number;
        };
        economyHealth: "critical" | "healthy" | "watch" | "at_risk";
    }, {
        userId: string;
        currentBalance: number;
        recentActivity: {
            lastLoginDays: number;
            gamesPlayedLast7Days: number;
            adsWatchedLast7Days: number;
        };
        economyHealth: "critical" | "healthy" | "watch" | "at_risk";
    }>, z.ZodObject<{
        dailyReward: z.ZodNumber;
        bonusMultiplier: z.ZodNumber;
        specialOffer: z.ZodOptional<z.ZodString>;
        urgency: z.ZodEnum<["none", "low", "medium", "high"]>;
        message: z.ZodString;
    }, "strip", z.ZodTypeAny, {
        message: string;
        dailyReward: number;
        bonusMultiplier: number;
        urgency: "high" | "medium" | "low" | "none";
        specialOffer?: string | undefined;
    }, {
        message: string;
        dailyReward: number;
        bonusMultiplier: number;
        urgency: "high" | "medium" | "low" | "none";
        specialOffer?: string | undefined;
    }>, z.ZodTypeAny>;
};
export default _default;
//# sourceMappingURL=economyAgent.d.ts.map