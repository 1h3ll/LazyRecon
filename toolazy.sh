#!/bin/bash

# Define colors
BOLD_WHITE='\033[1;97m'
BOLD_BLUE='\033[1;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
GREEN='\033[0;32m'
echo -e "${BOLD_BLUE}Updating...${NC}"; sudo apt update; echo -e "${GREEN}Updated.${NC}"; echo -e "${BOLD_BLUE}Upgrading....${NC}"; sudo apt upgrade -y; echo -e "${GREEN}Upgraded.${NC}"; sudo apt autoremove -y; echo -e "${GREEN}Autoremove Successfull.${NC}";

#Installing GO_Lang
#wget https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
#sudo tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
#echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
wget https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version
sudo rm -r go1.22.5.linux-amd64.tar.gz
sleep 3


#source ~/.zshrc

#Checking GO installation
if go version | grep -q "go version" && go version | grep -q "linux/amd64"; then echo -e "${BOLD_WHITE}Go Lang Installed successfully${NC}";

#Installing HTTPX
echo -e "${BOLD_BLUE}Installing HTTPX....${NC}";
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest;
sudo mv ~/go/bin/httpx /usr/local/bin;
echo -e "${GREEN}Installed Successfully....${NC}";
sleep 3;

#Installing WayBackURLs
echo -e "${BOLD_BLUE}Installing WayBackURLs....${NC}";
sudo go install github.com/tomnomnom/waybackurls@latest;
sudo mv ~/go/bin/waybackurls /usr/local/bin;
echo -e "${GREEN}Installed Successfully....${NC}";
sleep 3;

#Installing Katana
echo -e "${BOLD_BLUE}Installing Katana....${NC}";
sudo go install github.com/projectdiscovery/katana/cmd/katana@latest;
sudo mv ~/go/bin/katana /usr/local/bin;
echo -e "${GREEN}Installed Successfully....${NC}";
sleep 3;

#Installing GAU
echo -e "${BOLD_BLUE}Installing GAU....${NC}";
sudo go install github.com/lc/gau/v2/cmd/gau@latest;
sudo mv ~/go/bin/gau /usr/local/bin;
echo -e "${GREEN}Installed Successfully....${NC}";
sleep 3;

#Installing SubFinder
echo -e "${BOLD_BLUE}Installing SubFinder....${NC}";
sudo go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest;
sudo mv ~/go/bin/subfinder /usr/local/bin;
echo -e "${GREEN}Installed Successfully....${NC}";
sleep 3;

#Installing URO
echo -e "${BOLD_BLUE}Installing URO....${NC}";
pipx install uro;
echo -e "${GREEN}Installed Successfully....${NC}";
sleep 3;

#Installing GF
echo -e "${BOLD_BLUE}Installing GF....${NC}";
sudo go install github.com/tomnomnom/gf@latest;
cd ~;
git clone https://github.com/1ndianl33t/Gf-Patterns;
mkdir .gf;
mv ~/Gf-Patterns/*.json ~/.gf;
echo -e "${GREEN}Installed Successfully....${NC}";
sleep 3;

#Getting Ghauri
echo -e "${BOLD_BLUE}Installing Ghauri....${NC}";
cd ~; mkdir git; cd git;
git clone https://github.com/r0oth3x49/ghauri.git;
cd ghauri; python3 -m pip install --upgrade -r requirements.txt;
python3 -m pip install -e .;
echo -e "${GREEN}Got Ghauri Successfully....${NC}";
sleep 3;

#Getting Xss0rRecon
echo -e "${BOLD_BLUE}Installing Xss0rRecon....${NC}";
cd ~; cd git;
git clone https://github.com/xss0r/xssorRecon.git;
echo -e "${GREEN}Got Xss0rRecon Successfully....${NC}";
sleep 3;

#Getting Seclists
echo -e "${BOLD_BLUE}Installing SecLists....${NC}";
cd ~; cd git;
git clone https://github.com/danielmiessler/SecLists.git;
echo -e "${GREEN}Got SecLists Successfully....${NC}";
sleep 3;

else echo -e "${RED}Go Lang Installation failed for some reason........${NC}"; fi


