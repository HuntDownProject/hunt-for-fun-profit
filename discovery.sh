#!/bin/sh

crawler_timeout=20
proxy="http://localhost:8888"

echo "Running Discovery for suspected domains" | notify -silent
network_range=`cat discovery.txt | anew discovery_new.txt | notify -silent | dnsx -resp-only -silent -retry 3`
for ip in $network_range;
do
    echo "Discovering range for IPv4 $ip"
    katana -u https://bgp.he.net/ip/$ip -f getroute -ct $crawler_timeout -rl 1 -proxy $proxy -silent | anew network_ranges.txt
done

ranges=`cat network_ranges.txt | notify -silent`
for range in $ranges;
do
    echo "Discovering domains for range $range" | notify -silent
    katana -u https://bgp.he.net/net/$range/ -f getdomains -ct $crawler_timeout -rl 1 -proxy $proxy -silent | anew domains_temp.txt | httpx -silent -title -td -http-proxy $proxy | notify -silent >> final_report.txt
done
