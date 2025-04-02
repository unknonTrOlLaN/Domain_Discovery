# Domain_Discovery
# Domain Finder - Full Discovery Tool

A comprehensive bash script to discover all domains, subdomains, and IPs associated with a common name.

## Features
- Certificate Transparency log searching
- Subdomain enumeration
- IP resolution
- Live service detection
- Comprehensive reporting

## Installation
```bash
# Install dependencies
sudo apt install jq curl
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# Make script executable
chmod +x domain_finder.sh
                          
