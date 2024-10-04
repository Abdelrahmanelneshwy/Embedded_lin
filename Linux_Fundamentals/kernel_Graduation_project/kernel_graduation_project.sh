#!/bin/bash

# Check if the user provided a pcap file as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_pcap_file>"
    exit 1
fi

pcap_file="$1"

# Verify that the file exists
if [ ! -f "$pcap_file" ]; then
    echo "File not found: $pcap_file"
    exit 1
fi

# Total packets
total_packets=$(tcpdump -r "$pcap_file" 2>/dev/null | wc -l)

# HTTP and HTTPS packets
http_packets=$(tcpdump -r "$pcap_file" -nn  'tcp port 80' 2>/dev/null | wc -l)
https_packets=$(tcpdump -r "$pcap_file" -nn 'tcp port 443' 2>/dev/null | wc -l)

# Top 5 Source IP Addresses
top_src_ips=$(tcpdump -r "$pcap_file" -nn  -q 2>/dev/null | awk '{print $3}' | cut -d. -f1-4 | sort | uniq -c | sort -nr | head -n 5)

# Top 5 Destination IP Addresses
top_dst_ips=$(tcpdump -r "$pcap_file" -nn -q 2>/dev/null | awk '{print $5}' | cut -d. -f1-4 | sort | uniq -c | sort -nr | head -n 5)

# Output the report
echo "----- Network Traffic Analysis Report -----"
echo "1. Total Packets: $total_packets"
echo "2. Protocols:"
echo "   - HTTP: $http_packets packets"
echo "   - HTTPS/TLS: $https_packets packets"
echo ""
echo "3. Top 5 Source IP Addresses:"
echo "$top_src_ips"
echo ""
echo "4. Top 5 Destination IP Addresses:"
echo "$top_dst_ips"
echo "----- End of Report -----"
