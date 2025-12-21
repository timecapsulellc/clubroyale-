"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.healthCheck = void 0;
const https_1 = require("firebase-functions/v2/https");
const functions_config_1 = require("../config/functions-config");
exports.healthCheck = (0, https_1.onRequest)({ ...functions_config_1.CRITICAL_CONFIG, cors: true }, (req, res) => {
    res.status(200).json({
        status: 'UP',
        timestamp: new Date().toISOString(),
        environment: process.env.GCLOUD_PROJECT || 'unknown',
        version: '1.0.0'
    });
});
//# sourceMappingURL=health.js.map