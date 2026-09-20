# Networking: Cloudflare DNS everywhere.
# NetworkManager keeps managing connections (DHCP etc.), but
# insertNameservers prepends 1.1.1.1 / 1.0.0.1 (+ IPv6 equivalents)
# ahead of whatever the Freebox hands out via DHCP — so every lookup
# hits Cloudflare first, on every network, with zero per-connection setup.
{
  networking.networkmanager.insertNameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];
}
