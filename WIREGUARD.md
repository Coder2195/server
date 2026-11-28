This computer

```

[Interface]
PrivateKey = PRIVATE_CLIENT_KEY
Address = 10.8.0.2/24
Table = off
MTU = 1360

# this is for allowing two connections ig idfk
PostUp = sysctl -w net.ipv4.conf.all.rp_filter=2
PostUp = sysctl -w net.ipv4.conf.wg0.rp_filter=2

# routing or smth
PostUp = ip rule add from 10.8.0.2 table 200
PostUp = ip route replace default dev %i table 200

# routing docker container stuff
PostUp = iptables -t mangle -A PREROUTING -i %i -j CONNMARK --set-mark 200
PostUp = iptables -t mangle -A PREROUTING -i br-+ -j CONNMARK --restore-mark
PostUp = iptables -t mangle -A OUTPUT -j CONNMARK --restore-mark
PostUp = ip rule add fwmark 200 table 200

# TCP MSS clamping
PostUp = iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
PostDown = iptables -t mangle -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu


# cleanup
PostDown = ip rule del from 10.8.0.2 table 200 2>/dev/null || true
PostDown = ip rule del fwmark 200 table 200 2>/dev/null || true
PostDown = ip route flush table 200 2>/dev/null || true
PostDown = iptables -t mangle -D PREROUTING -i %i -j CONNMARK --set-mark 200 2>/dev/null || true
PostDown = iptables -t mangle -D PREROUTING -i br-+ -j CONNMARK --restore-mark 2>/dev/null || true
PostDown = iptables -t mangle -D OUTPUT -j CONNMARK --restore-mark 2>/dev/null || true


[Peer]
PublicKey = VPS_PUBLIC_KEY
Endpoint = VPS_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

VPS

```
[Interface]
PrivateKey = PRIVATE_VPS_KEY
Address = 10.8.0.1/24
ListenPort = 51820
MTU = 1360


PreUp = sysctl -w net.ipv4.ip_forward=1

# allows me to not get locked out by allowing ports
PostUp = iptables -t nat -A PREROUTING -i eth0 -p tcp --dport VPS_PORT -j RETURN
PostUp = iptables -t nat -A PREROUTING -i eth0 -p udp --dport 51820 -j RETURN

# forward remaining to client
PostUp = iptables -t nat -A PREROUTING -i eth0 -p tcp -j DNAT --to-destination 10.8.0.2
PostUp = iptables -t nat -A PREROUTING -i eth0 -p udp -j DNAT --to-destination 10.8.0.2

# allow forwarded traffic through chain
PostUp = iptables -A FORWARD -i eth0 -o %i -d 10.8.0.2 -j ACCEPT
PostUp = iptables -A FORWARD -i %i -o eth0 -s 10.8.0.2 -j ACCEPT

# TCP MSS clamping
PostUp = iptables -t mangle -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
PostDown = iptables -t mangle -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# cleanup
PostDown = iptables -t nat -D PREROUTING -i eth0 -p tcp --dport VPS_PORT -j RETURN
PostDown = iptables -t nat -D PREROUTING -i eth0 -p udp --dport 51820 -j RETURN
PostDown = iptables -t nat -D PREROUTING -i eth0 -p tcp -j DNAT --to-destination 10.8.0.2
PostDown = iptables -t nat -D PREROUTING -i eth0 -p udp -j DNAT --to-destination 10.8.0.2
PostDown = iptables -D FORWARD -i eth0 -o %i -d 10.8.0.2 -j ACCEPT
PostDown = iptables -D FORWARD -i %i -o eth0 -s 10.8.0.2 -j ACCEPT

[Peer]
PublicKey = PUBLIC_CLIENT_KEY
AllowedIPs = 10.8.0.2/32
```

VPS_PORT is the vps ssh port
