import { onRequest } from 'firebase-functions/v2/https';
import { CRITICAL_CONFIG } from '../config/functions-config';

export const healthCheck = onRequest({ ...CRITICAL_CONFIG, cors: true }, (req, res) => {
    res.status(200).json({
        status: 'UP',
        timestamp: new Date().toISOString(),
        environment: process.env.GCLOUD_PROJECT || 'unknown',
        version: '1.0.0'
    });
});
