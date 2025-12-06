# LiveKit Server Setup Guide

## Why LiveKit?

LiveKit is an **open-source** WebRTC SFU (Selective Forwarding Unit) that's perfect for:
- 4-player video calls (card game)
- Spectator mode (many viewers, few publishers)
- Low latency real-time communication

**Advantages over raw WebRTC:**
- No mesh topology (scales better)
- Simulcast support (adaptive quality)
- Built-in recording
- Excellent Flutter SDK

---

## Option 1: LiveKit Cloud (Quick Start)

For development and small deployments:

1. Sign up at https://cloud.livekit.io
2. Create a project
3. Get your API key and secret
4. Use their hosted servers (free tier available)

**Free tier includes:**
- 50 participant-hours/month
- 10 concurrent participants

---

## Option 2: Self-Hosted LiveKit (Production)

### VPS Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 2 vCPU | 4+ vCPU |
| RAM | 2GB | 4GB+ |
| Bandwidth | 100 Mbps | 1 Gbps |
| Storage | 10GB | 50GB+ (if recording) |

**Estimated cost:** $10-40/month

### Docker Deployment

```yaml
# docker-compose.yml
version: '3.8'

services:
  livekit:
    image: livekit/livekit-server:latest
    command: --config /etc/livekit.yaml
    ports:
      - "7880:7880"     # HTTP API
      - "7881:7881"     # RTC over TCP
      - "7882:7882/udp" # RTC over UDP
      - "50000-60000:50000-60000/udp" # WebRTC ports
    volumes:
      - ./livekit.yaml:/etc/livekit.yaml
    restart: unless-stopped
```

### Configuration File

```yaml
# livekit.yaml
port: 7880
rtc:
  port_range_start: 50000
  port_range_end: 60000
  use_external_ip: true
  
keys:
  # Generate with: openssl rand -base64 32
  taasclub_api_key: your_api_secret_here

# For production, add TLS
# turn:
#   enabled: true
#   domain: your-domain.com
#   cert_file: /path/to/cert.pem
#   key_file: /path/to/key.pem
```

### Generate API Keys

```bash
# Generate a secure API secret
openssl rand -base64 32
```

### Firewall Rules

```bash
# Ubuntu/Debian
sudo ufw allow 7880/tcp  # HTTP API
sudo ufw allow 7881/tcp  # RTC TCP
sudo ufw allow 7882/udp  # RTC UDP
sudo ufw allow 50000:60000/udp  # WebRTC
```

---

## Configuration in Your App

### 1. Cloud Functions (.env)

Add to `functions/.env`:
```
LIVEKIT_API_KEY=taasclub_api_key
LIVEKIT_API_SECRET=your_api_secret_here
```

### 2. Flutter (video_service.dart)

Update `LiveKitConfig.serverUrl`:
```dart
class LiveKitConfig {
  // For LiveKit Cloud
  static const String serverUrl = 'wss://your-project.livekit.cloud';
  
  // For self-hosted
  // static const String serverUrl = 'wss://your-server.com:7880';
}
```

---

## Testing Your Setup

### Using LiveKit CLI

```bash
# Install CLI
brew install livekit-cli
# or
curl -sSL https://get.livekit.io/cli | bash

# Test connection
livekit-cli room list \
  --url wss://your-server.com:7880 \
  --api-key your_api_key \
  --api-secret your_api_secret
```

### Using Web Playground

Visit https://meet.livekit.io and enter your server URL to test.

---

## Cost Comparison

| Option | Monthly Cost | Best For |
|--------|-------------|----------|
| LiveKit Cloud Free | $0 | Development |
| LiveKit Cloud Pro | $50+ | Small production |
| Self-hosted (DigitalOcean) | $10-20 | Medium production |
| Self-hosted (Hetzner) | $5-15 | Budget production |

---

## Security Best Practices

1. **Short-lived tokens** - Set token TTL to 24 hours max
2. **Use HTTPS/WSS** - Always use TLS in production
3. **Firewall** - Only expose required ports
4. **API key rotation** - Rotate keys periodically
5. **Rate limiting** - Limit token generation requests

---

## Troubleshooting

### Connection fails
- Check firewall ports are open
- Verify server URL starts with `wss://`
- Ensure token hasn't expired

### Video quality issues
- Enable simulcast in room options
- Check bandwidth (min 2 Mbps per participant)
- Use adaptive stream

### Audio echo
- Enable DTX (discontinuous transmission)
- Use noise suppression

---

*For detailed documentation, visit: https://docs.livekit.io*
