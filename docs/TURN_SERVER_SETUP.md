# TURN Server Setup Guide (Coturn)

## Why You Need a TURN Server

WebRTC uses peer-to-peer connections, but many users are behind NAT/firewalls that block direct connections. A TURN server acts as a relay when direct connections fail.

**STUN servers** (free, provided by Google) help with simple NAT traversal but don't work for:
- Symmetric NAT
- Strict firewalls
- Corporate networks

**TURN servers** relay all traffic and work in 100% of network conditions.

---

## Option 1: Self-Hosted Coturn (Recommended for Production)

### VPS Requirements
- 1 vCPU, 1GB RAM minimum
- Public IP address
- Open ports: 3478 (TCP/UDP), 5349 (TLS), 49152-65535 (UDP)
- Providers: DigitalOcean ($5/mo), Vultr ($5/mo), Hetzner ($4/mo)

### Docker Deployment

```bash
# Create config directory
mkdir -p /etc/coturn

# Create configuration file
cat > /etc/coturn/turnserver.conf << 'EOF'
# TURN server configuration
listening-port=3478
tls-listening-port=5349

# Relay ports
min-port=49152
max-port=65535

# Authentication (change these!)
realm=taasclub.com
user=taasclub:your-secure-password-here

# Enable fingerprint for security
fingerprint

# Long-term credential mechanism
lt-cred-mech

# Logging
log-file=/var/log/turnserver.log
verbose

# External IP (replace with your server's public IP)
external-ip=YOUR_PUBLIC_IP_HERE
EOF

# Run Coturn with Docker
docker run -d \
  --name coturn \
  --network=host \
  -v /etc/coturn/turnserver.conf:/etc/coturn/turnserver.conf:ro \
  coturn/coturn \
  -c /etc/coturn/turnserver.conf
```

### Firewall Rules

```bash
# Ubuntu/Debian
sudo ufw allow 3478/tcp
sudo ufw allow 3478/udp
sudo ufw allow 5349/tcp
sudo ufw allow 49152:65535/udp

# Or with iptables
sudo iptables -A INPUT -p tcp --dport 3478 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 3478 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 49152:65535 -j ACCEPT
```

---

## Option 2: Free TURN Services (For Development)

### Metered.ca (Free Tier)
1. Sign up at https://www.metered.ca/stun-turn
2. Get 500MB free per month
3. Use their TURN URLs in your app

### Twilio TURN (Pay-as-you-go)
1. Sign up at https://www.twilio.com
2. Navigate to Network Traversal Service
3. Get credentials from dashboard

---

## Configuring in Flutter

Update the TURN server config in `lib/features/rtc/audio_service.dart`:

```dart
static const List<Map<String, dynamic>> iceServers = [
  // Free STUN (always include these)
  {'urls': 'stun:stun.l.google.com:19302'},
  {'urls': 'stun:stun1.l.google.com:19302'},
  
  // Your TURN server (replace with your values)
  {
    'urls': 'turn:your-server-ip.com:3478',
    'username': 'taasclub',
    'credential': 'your-secure-password-here',
  },
  
  // TLS TURN (more reliable through firewalls)
  {
    'urls': 'turns:your-server-ip.com:5349',
    'username': 'taasclub',
    'credential': 'your-secure-password-here',
  },
];
```

---

## Testing Your TURN Server

Use this online tool to verify your TURN server works:
https://webrtc.github.io/samples/src/content/peerconnection/trickle-ice/

Enter your TURN URL and credentials to test connectivity.

---

## Cost Estimates

| Option | Monthly Cost | Data Limit |
|--------|-------------|------------|
| Self-hosted (DigitalOcean) | $5-10 | Unlimited |
| Self-hosted (Hetzner) | $4 | Unlimited |
| Metered.ca Free | $0 | 500MB |
| Twilio | Pay-per-GB | ~$0.40/GB |

---

## Security Best Practices

1. **Use unique credentials per room** - Generate temporary credentials via Cloud Functions
2. **Enable TLS (port 5349)** - Encrypt TURN traffic
3. **Set bandwidth limits** - Prevent abuse
4. **Monitor usage** - Set up alerts for unusual traffic

---

*For production, always self-host your TURN server for reliability and cost control.*
