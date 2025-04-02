#!/bin/bash
#  Domain Finder - Full Discovery Tool
# Usage: ./zepto_finder.sh <common_name>

# Initialize
COMMON_NAME="$1"
OUT_DIR="${COMMON_NAME}_results"
mkdir -p "$OUT_DIR"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 1. Find related domains using Certificate Transparency
echo -e "${GREEN}[+] Finding ${COMMON_NAME}-related domains...${NC}"
curl -s "https://crt.sh/?q=%25${COMMON_NAME}%25&output=json" | jq -r '.[].name_value' | \
grep -E "${COMMON_NAME}" | sort -u > "$OUT_DIR/all_domains.txt"

# 2. Discover subdomains for each found domain
echo -e "${GREEN}[+] Discovering subdomains...${NC}"
while read domain; do
    subfinder -d "$domain" -silent >> "$OUT_DIR/all_subdomains.txt"
done < "$OUT_DIR/all_domains.txt"

# 3. Resolve IP addresses
echo -e "${GREEN}[+] Resolving IPs...${NC}"
while read sub; do
    host "$sub" | grep "has address" | awk '{print $1,$4}'
done < "$OUT_DIR/all_subdomains.txt" > "$OUT_DIR/ips.txt"

# 4. Find live HTTP services
echo -e "${GREEN}[+] Checking live services...${NC}"
cat "$OUT_DIR/all_subdomains.txt" | \
httpx -silent -status-code -title -tech-detect -o "$OUT_DIR/live_services.txt"

# 5. Generate final report
echo -e "${GREEN}[+] Generating report...${NC}"
{
    echo "Domain,Subdomain,IP,Status,Title,Technologies"
    while read -r sub; do
        domain=$(echo "$sub" | awk -F'.' '{print $(NF-1)"."$NF}')
        ip=$(grep "$sub" "$OUT_DIR/ips.txt" | awk '{print $2}' | tr '\n' ',')
        service=$(grep "$sub" "$OUT_DIR/live_services.txt")
        echo "\"$domain\",\"$sub\",\"${ip%,}\",\"$service\""
    done < "$OUT_DIR/all_subdomains.txt"
} > "$OUT_DIR/full_report.csv"

echo -e "\n${GREEN}[+] Results saved to ${OUT_DIR}/${NC}"
echo -e "• all_domains.txt      ${YELLOW}(Root domains containing ${COMMON_NAME})${NC}"
echo -e "• all_subdomains.txt   ${YELLOW}(All discovered subdomains)${NC}"
echo -e "• ips.txt              ${YELLOW}(Subdomain to IP mapping)${NC}"
echo -e "• live_services.txt    ${YELLOW}(Active web services)${NC}"
echo -e "• full_report.csv      ${YELLOW}(Complete organized data)${NC}"
