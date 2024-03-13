# [Falco](https://falco.org/)

<br />

### Installation

<br />

```bash
curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | apt-key add -
echo "deb https://download.falco.org/packages/deb stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list
apt-get update -y
apt-get -y install linux-headers-$(uname -r)
apt-get install -y falco
systemctl enable falco
systemctl start falco
```

### Check logs and events

<br />

```bash
journalctl -fu falco
```

### Clean up

```bash
apt-get remove falco
```