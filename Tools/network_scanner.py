import subprocess
import ipaddress
import platform
import concurrent.futures
import time
from concurrent.futures import ThreadPoolExecutor

#ping single ip address at a time
def ping(ip):
    """Ping a single IP address."""
    param = '-n' if platform.system().lower() == 'windows' else '-c'
    command = ['ping', param, '1', str(ip)]
    try:
        output = subprocess.check_output(command, stderr=subprocess.STDOUT, universal_newlines=True)
        if platform.system().lower() == 'windows':
            return "TTL=" in output
        else:
            return "1 received" in output or "bytes from" in output
    except subprocess.CalledProcessError:
        return False
#Get MAC address for the given IP address in network
def get_mac_address(ip):
    """Get the MAC address for a given IP using the arp command."""
    if platform.system().lower() == 'windows':
        try:
            output = subprocess.check_output(['arp', '-a', ip], universal_newlines=True)
            for line in output.splitlines():
                if ip in line:
                    parts = line.split()
                    if len(parts) >= 2:
                        return parts[1]
        except Exception:
            return "N/A"
    else:
        try:
            output = subprocess.check_output(['arp', '-n', ip], universal_newlines=True)
            for line in output.splitlines():
                if ip in line:
                    parts = line.split()
                    if len(parts) >= 3:
                        return parts[2]
        except Exception:
            return "N/A"
    return "N/A"

# Find active hosts in the given network using multithreading
def find_active_hosts(network):
    active_hosts = []
    with ThreadPoolExecutor(max_workers=100) as executor:
        futures = {executor.submit(ping, str(ip)): str(ip) for ip in ipaddress.IPv4Network(network)}
        for future in concurrent.futures.as_completed(futures):
            ip = futures[future]
            if future.result():
                active_hosts.append((ip))
    return active_hosts

# Main function to scan the network and find active hosts
if __name__ == "__main__":
    network = input("Enter the network (e.g. 192.168.1.0/24): ")
    try:
        net = ipaddress.IPv4Network(network)
    except ValueError:
        print("Invalid network format. Please use CIDR notation")
        exit(1)
    print(f"Scanning network: {network}")
    start_time = time.time()
    hosts = find_active_hosts(network)
    end_time = time.time()

    active_set = set(hosts)

# Print the results
if __name__ == "__main__":
    print("\nHost status:")
    print(f"{'No.':<5} {'IP Address':<18} {'MAC Address'}")
    for idx, ip in enumerate(net, 1):
        if str(ip) in active_set:
            mac = get_mac_address(str(ip))
            print(f"{idx:<5} {str(ip):<18} {mac}")
        else:
            print(f"{idx:<5} {'-':<18} {'-'}")

    print("\nScan complete.")
    print(f"Total hosts scanned: {net.num_addresses}")
    print(f"Active hosts found: {len(hosts)}")
    print(f"Time taken: {end_time - start_time:.2f} seconds\n")

    print(f"Time taken: {end_time - start_time:.2f} seconds\n")

    input("Press Enter to exit...")