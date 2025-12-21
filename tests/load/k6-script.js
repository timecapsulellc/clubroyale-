import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    stages: [
        { duration: '30s', target: 50 },  // Ramp up to 50 users
        { duration: '1m', target: 100 },  // Stay at 100 users
        { duration: '30s', target: 500 }, // Ramp up to 500 users (Target)
        { duration: '1m', target: 500 },  // Stay at 500 users
        { duration: '30s', target: 0 },   // Ramp down
    ],
    thresholds: {
        http_req_duration: ['p(95)<2000'], // 95% of requests must complete below 2s
        http_req_failed: ['rate<0.01'],    // Error rate must be < 1%
    },
};

const BASE_URL = __ENV.BASE_URL || 'https://us-central1-clubroyale-staging.cloudfunctions.net';

export default function () {
    // Simulate health check / basic ping
    const res = http.get(`${BASE_URL}/healthCheck`);

    check(res, {
        'status is 200': (r) => r.status === 200,
        'latency < 2000ms': (r) => r.timings.duration < 2000,
    });

    sleep(1);
}
