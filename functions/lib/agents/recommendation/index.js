"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.recommendGames = exports.suggestFriends = exports.rankFeed = void 0;
/**
 * Recommendation Agent - Index
 */
var recommendationAgent_1 = require("./recommendationAgent");
Object.defineProperty(exports, "rankFeed", { enumerable: true, get: function () { return recommendationAgent_1.rankFeedFlow; } });
Object.defineProperty(exports, "suggestFriends", { enumerable: true, get: function () { return recommendationAgent_1.recommendFriendsFlow; } });
Object.defineProperty(exports, "recommendGames", { enumerable: true, get: function () { return recommendationAgent_1.recommendGamesFlow; } });
//# sourceMappingURL=index.js.map