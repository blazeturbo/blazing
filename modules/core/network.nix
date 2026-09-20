# Networking: Cloudflare DNS everywhere, and it STAYS.
# insertNameservers alone wasn't enough: ~10s after every connect, the
# Freebox DHCP/RA pushed its own servers back over ours. So NetworkManager
# is told to never touch DNS at all (dns = "none") and the static
# networking.nameservers below own /etc/resolv.conf instead. DHCP still
# handles addresses and routes. Tradeoff: captive portals on foreign
# networks (cafes/hotels) may need their local DNS - if a portal page
# won't load, temporarily comment the dns line out and rebuild.
{
  networking.networkmanager.dns = "none";

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];
}
