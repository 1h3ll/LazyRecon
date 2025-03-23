#!/bin/bash

# Function to handle errors with manual installation solutions
handle_error_with_solution() {
    echo -e "${RED}Error occurred during the execution of $1. Exiting step but continuing with the next installation.${NC}"
    echo "Error during: $1" >> error.log
    echo -e "${YELLOW}Possible Solution for manual installation:${NC}"
    echo -e "${BOLD_WHITE}$2${NC}"
}

# Copy katana, waybackurls, and gau to /usr/bin and /usr/local/bin
for file in katana waybackurls gau; do
    if [ -f "$file" ]; then
        sudo cp "$file" /usr/bin || echo "Failed to copy $file to /usr/bin"
        sudo cp "$file" /usr/local/bin || echo "Failed to copy $file to /usr/local/bin"
        echo "Copied $file to /usr/bin and /usr/local/bin"
    else
        echo "File $file not found in the current directory."
    fi
done

# Initialize a variable for the domain name
domain_name=""
last_completed_option=1
skip_order_check_for_option_4=false
total_merged_urls=0

# Define colors
BOLD_WHITE='\033[1;97m'
BOLD_BLUE='\033[1;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
# Function to handle errors
handle_error() {
    echo -e "${RED}Error occurred during the execution of $1. Exiting.${NC}"
    echo "Error during: $1" >> error.log
    exit 1
}

# Function to show progress with emoji
show_progress() {
    echo -e "${BOLD_BLUE}Current process: $1...⌛️${NC}"
}

# Function to check if a command exists and is executable
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}$1 could not be found or is not installed correctly.${NC}"
        handle_error "$1 installation check"
    else
        echo -e "${BOLD_BLUE}$1 installed correctly.${NC}"
    fi
}

# Clear the terminal
clear

# Function to display options
display_options() {
    echo -e "${BOLD_BLUE}Please select an option:${NC}"
    echo -e "${RED}1: Install all tools${NC}"
    echo -e "${RED}2: Enter a domain name of the target${NC}"
    echo -e "${YELLOW}3: Enumerate and filter domains${NC}"
    echo -e "${YELLOW}4: Crawl and filter URLs${NC}"
    echo -e "${YELLOW}5: Filtering all${NC}"
    echo -e "${YELLOW}6: Create new separated file for Arjun & SQLi testing${NC}"
    echo -e "${YELLOW}7: Getting ready for XSS & URLs with query strings${NC}"
    echo -e "${YELLOW}8: Exit${NC}"
}

# Function to run step 1 (Install all tools)
install_tools() {
    # Find the current directory path
    CURRENT_DIR=$(pwd)
    
    echo -e "${BOLD_WHITE}You selected: Install all tools${NC}"
    
    show_progress "Installing dependencies"
    sudo apt-get update -y;
    sudo apt-get upgrade -y;
    sudo apt-get dist-upgrade -y;
    sudo apt-get autoremove -y;

    sudo apt-mark hold google-chrome-stable
    sudo apt-get install -y rsync zip unzip p7zip-full wget golang-go
    sudo apt-get install terminator -y
    sudo apt remove python3-structlog -y

    #Moving Python Programs to /usr/local/bin
    sudo mv reflection.py /usr/local/bin/
    sudo mv path-reflection.py /usr/local/bin/
    alias ref='python3 /usr/local/bin/reflection.py
    alias path='python3 /usr/local/bin/path-reflection.py'
    echo "
    #Alias command
    alias ref='python3 /usr/local/bin/reflection.py'
    alias path='python3 /usr/local/bin/path-reflection.py'" | tee -a .bashrc .zshrc
    source ~/.bashrc
    source ~/.zshrc

    # Step 1: Install Python3 virtual environment and structlog in venv
    show_progress "Installing python3-venv and setting up virtual environment"
    sudo pip install structlog --break-system-packages --root-user-action=ignore
    sudo pip install requests --break-system-packages --root-user-action=ignore
    sudo apt install python3-full python3-pip
    sudo apt install pipx
    export PATH="$PATH:/root/.local/bin"
    sleep 3

    # Step 2: Install the latest version of pip
    show_progress "Installing/Upgrading pip"
    sudo apt update && sudo apt install python3-pip -y
    sudo pip3 install --upgrade pip --root-user-action=ignore
    
    # Reinstall setuptools to ensure it's correctly configured
    python3 -m pip install --upgrade --force-reinstall setuptools --break-system-packages --root-user-action=ignore
    
    sleep 3

    # Step 3: Install Go
    show_progress "Installing Go"
    wget https://go.dev/dl/go1.22.5.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.22.5.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    go version
    sudo rm -r go1.22.5.linux-amd64.tar.gz
    sleep 3

    # Step 4: Install Dnsbruter (Skip if the folder already exists)
if [ ! -d "Dnsbruter" ]; then
    show_progress "Installing Dnsbruter"

    # Update and upgrade the system
    sudo apt update && sudo apt upgrade -y

    # Install Python 3.12
    sudo apt install python3.12 -y

    # Install pip for Python 3.12
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3.12 get-pip.py

    # Install pipx and ensure it's in the PATH
    pip install pipx==1.7.1 --break-system-packages --root-user-action=ignore
    pipx ensurepath

    # Verify Python, pip, and pipx installations
    python3 --version
    pip --version
    pipx --version

    # Install Dnsbruter with pip (no dependencies and force reinstall)
    sudo pip install --no-deps --force-reinstall --break-system-packages git+https://github.com/RevoltSecurities/Dnsbruter.git

    # Optionally try installing with pipx as well
    sudo pipx install git+https://github.com/RevoltSecurities/Dnsbruter.git --break-system-packages
    sudo pipx install dnsbruter --force

    # Clone the repository (optional if you want the source code locally)
    sudo git clone https://github.com/RevoltSecurities/Dnsbruter.git
    cd Dnsbruter
    sudo pip install . --break-system-packages --root-user-action=ignore
    cd ..
    sudo rm -r Dnsbruter

    # Ensure that dnsbruter is accessible globally
    if command -v dnsbruter &> /dev/null; then
        echo "Dnsbruter is successfully installed and globally available."
    else
        echo "Dnsbruter installation failed. Please check the installation steps."
    fi

    # Final check to ensure dnsbruter is installed correctly
    if command -v dnsbruter &> /dev/null; then
        echo "Dnsbruter is ready to use. You can run 'dnsbruter -h' to confirm."
        dnsbruter -h
    else
        echo "Dnsbruter installation failed. Please check the installation steps."
    fi

    sleep 3
else
    show_progress "Dnsbruter is already installed. Skipping installation."
fi

    # Step 5: Install Subdominator (Skip if the folder already exists)
if [ ! -d "Subdominator" ]; then
    show_progress "Installing Subdominator"

    # Install Subdominator directly from the GitHub repository
    sudo pip install git+https://github.com/RevoltSecurities/Subdominator.git --break-system-packages --root-user-action=ignore

    # Clone the repository (optional if you need the source code locally)
    sudo git clone https://github.com/RevoltSecurities/Subdominator.git
    cd Subdominator

    # Install from local cloned repository
    sudo pip install . --break-system-packages --root-user-action=ignore

    # Clean up by removing the cloned directory after installation
    cd ..
    sudo sudo rm -r Subdominator

    show_progress "Subdominator installation complete."

    sleep 3
else
    show_progress "Subdominator is already installed. Skipping installation."
fi

    # Step 6: Install SubProber (Skip if the folder already exists)
if [ ! -d "SubProber" ]; then
    show_progress "Installing SubProber"

    # Install SubProber directly from the GitHub repository
    sudo pip install git+https://github.com/RevoltSecurities/Subprober.git --break-system-packages --root-user-action=ignore

    # Clone the repository (optional if you need the source code locally)
    sudo git clone https://github.com/RevoltSecurities/Subprober.git
    cd Subprober

    # Install from local cloned repository
    sudo pip install . --break-system-packages --root-user-action=ignore

    # Clean up by removing the cloned directory after installation
    cd ..
    sudo rm -r Subprober

    show_progress "SubProber installation complete."

    sleep 3
else
    show_progress "SubProber is already installed. Skipping installation."
fi

    # Step 7: Install GoSpider
    show_progress "Installing GoSpider"
    sudo apt install -y gospider
    GO111MODULE=on sudo go install github.com/jaeles-project/gospider@latest
    sleep 3

    # Step 8: Install Hakrawler
    show_progress "Installing Hakrawler"
    go install github.com/hakluke/hakrawler@latest
    sleep 3

    # Step 9: Install Katana
    show_progress "Installing Katana"
    go install github.com/projectdiscovery/katana/cmd/katana@latest

    # Step 10: Install Waybackurls
    show_progress "Installing Waybackurls"
    go install github.com/tomnomnom/waybackurls@latest
    sleep 3

    # Step 11: Install Gau
    show_progress "Installing Gau"
    go install github.com/lc/gau/v2/cmd/gau@latest
    sudo bash -c 'echo -e "[gau]\nwayback = true\ncommoncrawl = true\notx = false" > /root/.gau.toml'
    sleep 3

    # Copy Katana to /usr/local/bin and /usr/bin
    sudo mv ~/go/bin/katana /usr/local/bin/
    sudo mv ~/go/bin/gau /usr/local/bin/
    sudo mv ~/go/bin/waybackurls /usr/local/bin/
    sudo mv ~/go/bin/gf /usr/local/bin/
    sudo mv ~/go/bin/hakrawler /usr/local/bin/
    sleep 3

    # Step 12: Install Uro
    show_progress "Installing Uro"
    sudo pip install uro --break-system-packages --root-user-action=ignore
    sudo uro --help  # Ensure Uro runs with sudo
    sleep 3

    # Step 13: Install Arjun
    show_progress "Installing Arjun"
    sudo apt install -y arjun
    sudo pip3 install arjun --break-system-packages --root-user-action=ignore
    sudo pip install alive_progress --break-system-packages --root-user-action=ignore
    sudo pip install ratelimit --break-system-packages --root-user-action=ignore
    sudo mv /usr/lib/python3.12/EXTERNALLY-MANAGED /usr/lib/python3.12/EXTERNALLY-MANAGED.bak
    sleep 3

    # Step 14: Installing HTTPX
    show_progress "Installing HTTPX"
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    sudo mv ~/go/bin/httpx /usr/local/bin
    
    #For SubFinder
    show_progress "Installing SubFinder"
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    sudo mv ~/go/bin/subfinder /usr/local/bin

    #For URLFinder
    show_progress "Installing URLFinder"
    go install -v github.com/projectdiscovery/urlfinder/cmd/urlfinder@latest
    sudo mv ~/go/bin/urlfinder /usr/local/bin

    #For GF
    show_progress "Installing GF"
    go install github.com/tomnomnom/gf@latest
    cd ~
    git clone https://github.com/1ndianl33t/Gf-Patterns
    mkdir .gf
    mv ~/Gf-Patterns/*.json ~/.gf
    sudo mv ~/go/bin/httpx /usr/local/bin
    sudo rm -r ~/Gf-Patterns

    #Getting Ghauri
    show_progress "Installing Ghauri"
    cd ~; mkdir git; cd git;
    git clone https://github.com/r0oth3x49/ghauri.git
    cd ghauri; python3 -m pip install --upgrade -r requirements.txt
    python3 -m pip install -e . --break-system-packages --root-user-action=ignore;
    sleep 3;

    #Getting Seclists
    show_progress "Downloading Seclists"
    cd ~; cd git;
    git clone https://github.com/danielmiessler/SecLists.git;
    sleep 3;


    # Set specific permissions for installed tools
    sudo chmod 755 /usr/local/bin/waybackurls
    sudo chmod 755 /usr/local/bin/katana
    sudo chmod 755 /usr/local/bin/gau
    sudo chmod 755 /usr/local/bin/uro   
    sudo chmod 755 /usr/local/bin/httpx 
    sudo chmod 755 /usr/local/bin/subfinder
    sudo chmod 755 /usr/local/bin/urlfinder

    # Display installed tools
    echo -e "${BOLD_BLUE}All tools have been successfully installed.${NC}"

# Checking each tool with -h for verification
echo -e "${BOLD_WHITE}Checking installed tools...${NC}"

echo -e "${BOLD_WHITE}1. Dnsbruter:${NC}"
dnsbruter -h > /dev/null 2>&1 && echo "Dnsbruter is installed" || echo "Dnsbruter is not installed correctly"

echo -e "${BOLD_WHITE}2. Subdominator:${NC}"
subdominator -h > /dev/null 2>&1 && echo "Subdominator is installed" || echo "Subdominator is not installed correctly"

echo -e "${BOLD_WHITE}3. SubProber:${NC}"
subprober -h > /dev/null 2>&1 && echo "SubProber is installed" || echo "SubProber is not installed correctly"

echo -e "${BOLD_WHITE}4. GoSpider:${NC}"
gospider -h > /dev/null 2>&1 && echo "GoSpider is installed" || echo "GoSpider is not installed correctly"

echo -e "${BOLD_WHITE}5. Hakrawler:${NC}"
hakrawler --help > /dev/null 2>&1 && echo "Hakrawler is installed" || echo "Hakrawler is not installed correctly"

echo -e "${BOLD_WHITE}6. Katana:${NC}"
katana -h > /dev/null 2>&1 && echo "Katana is installed" || echo "Katana is not installed correctly"

echo -e "${BOLD_WHITE}7. Waybackurls:${NC}"
waybackurls -h > /dev/null 2>&1 && echo "Waybackurls is installed" || echo "Waybackurls is not installed correctly"

echo -e "${BOLD_WHITE}8. Gau:${NC}"
gau -h > /dev/null 2>&1 && echo "Gau is installed" || echo "Gau is not installed correctly"

echo -e "${BOLD_WHITE}9. Uro:${NC}"
uro -h > /dev/null 2>&1 && echo "Uro is installed" || echo "Uro is not installed correctly"

echo -e "${BOLD_WHITE}10. Arjun:${NC}"
arjun -h > /dev/null 2>&1 && echo "Arjun is installed" || echo "Arjun is not installed correctly"

echo -e "${BOLD_WHITE}10. URLFinder:${NC}"
urlfinder -h > /dev/null 2>&1 && echo "URLFinder is installed" || echo "URLFinder is not installed correctly"


# Cyan and White message with tool links for manual installation
echo -e "\n${BOLD_CYAN}If you encounter any issues or are unable to run any of the tools,${NC}"
echo -e "${BOLD_WHITE}please refer to the following links for manual installation:${NC}"
echo -e "${BOLD_WHITE}Waybackurls:${NC} https://github.com/tomnomnom/waybackurls"
echo -e "${BOLD_WHITE}Gau:${NC} https://github.com/lc/gau"
echo -e "${BOLD_WHITE}Uro:${NC} https://github.com/s0md3v/uro"
echo -e "${BOLD_WHITE}Katana:${NC} https://github.com/projectdiscovery/katana"
echo -e "${BOLD_WHITE}Hakrawler:${NC} https://github.com/hakluke/hakrawler"
echo -e "${BOLD_WHITE}GoSpider:${NC} https://github.com/jaeles-project/gospider"
echo -e "${BOLD_WHITE}Arjun:${NC} https://github.com/s0md3v/Arjun"
echo -e "${BOLD_WHITE}Dnsbruter:${NC} https://github.com/RevoltSecurities/Dnsbruter"
echo -e "${BOLD_WHITE}SubProber:${NC} https://github.com/RevoltSecurities/SubProber"
echo -e "${BOLD_WHITE}Subdominator:${NC} https://github.com/RevoltSecurities/Subdominator"
echo -e "${BOLD_WHITE}URLFinder:${NC} https://github.com/projectdiscovery/urlfinder"

# Adding extra space for separation
echo -e "\n\n"
}


# Function to run step 3 (Enumerate and filter domains)
run_step_3() {
    echo -e "${BOLD_WHITE}You selected: Enumerate and filter domains for $domain_name${NC}"
                
    # Step 1: Passive FUZZ domains with wordlist
    show_progress "Passive FUZZ domains with wordlist"
    dnsbruter -d "$domain_name" -w subs-dnsbruter-small.txt -c 200 -wt 100 -o output-dnsbruter.txt -ws wild.txt || handle_error "dnsbruter"
    sleep 5

    # Step 2: Active brute crawling domains
    show_progress "Active brute crawling domains"
    subdominator -d "$domain_name" -o output-subdominator.txt || handle_error "subdominator"
    sleep 5

    # Step 3: Checking if output-dnsbruter.txt was created
    if [ ! -f "output-dnsbruter.txt" ]; then
        echo "Error: output-dnsbruter.txt not found. The dnsbruter command may have failed."
        
        # If dnsbruter failed, use only subdominator output
        if [ -f "output-subdominator.txt" ]; then
            echo "Moving output-subdominator.txt to ${domain_name}-domains.txt"
            mv output-subdominator.txt "${domain_name}-domains.txt"
        else
            echo "Error: output-subdominator.txt not found. The subdominator command may have also failed."
            exit 1
        fi
    else
        # Check if output-subdominator.txt exists, and if both exist, merge the results
        if [ -f "output-subdominator.txt" ]; then
            # Step 4: Merging passive and active results into one file
            show_progress "Merging passive and active results into one file"
            cat output-dnsbruter.txt output-subdominator.txt > "${domain_name}-domains.txt" || handle_error "Merging domains"
        else
            echo "Error: output-subdominator.txt not found. Proceeding with output-dnsbruter.txt only."
            mv output-dnsbruter.txt "${domain_name}-domains.txt"
        fi
    fi

    # Show total subdomains after merging
    total_subdomains=$(wc -l < "${domain_name}-domains.txt")
    echo -e "${RED}Total subdomains after processing: $total_subdomains${NC}"
    sleep 5

    # Step 5: Removing old temporary files
    show_progress "Removing old temporary files"
    if [ -f "output-dnsbruter.txt" ]; then
        rm output-dnsbruter.txt || handle_error "Removing output-dnsbruter.txt"
    fi
    if [ -f "output-subdominator.txt" ]; then
        rm output-subdominator.txt || handle_error "Removing output-subdominator.txt"
    fi
    sleep 3

    # Step 6: Removing duplicate domains
    show_progress "Removing duplicate domains"
    initial_count=$(wc -l < "${domain_name}-domains.txt")
    awk '{sub(/^https?:\/\//, "", $0); sub(/^www\./, "", $0); if (!seen[$0]++) print}' "${domain_name}-domains.txt" > "unique-${domain_name}-domains.txt" || handle_error "Removing duplicates"
    final_count=$(wc -l < "unique-${domain_name}-domains.txt")
    removed_count=$((initial_count - final_count))
    echo -e "${RED}Removed $removed_count duplicate domains.${NC}"
    sleep 3

    # Step 6: Removing old domain list
    show_progress "Removing old domain list"
    rm -r "${domain_name}-domains.txt" || handle_error "Removing old domain list"
    sleep 3

    # Step 7: Filtering ALIVE domain names
    show_progress "Filtering ALIVE domain names"
    subprober -f "unique-${domain_name}-domains.txt" -sc -ar -o "subprober-${domain_name}-domains.txt" -nc -mc 200,301,302,307,308,403,401 -c 20 || handle_error "subprober"
    sleep 5

    # Step 8: Filtering valid domain names
    show_progress "Filtering valid domain names"
    grep -oP 'http[^\s]*' "subprober-${domain_name}-domains.txt" > output-domains.txt || handle_error "grep valid domains"
    sleep 3

    # Step 9: Removing old unique domain list
    show_progress "Removing old unique domain list"
    rm -r "unique-${domain_name}-domains.txt" || handle_error "Removing old unique domain list"
    sleep 3

    # Step 10: Removing old subprober domains file
    show_progress "Removing old subprober domains file"
    rm -r "subprober-${domain_name}-domains.txt" || handle_error "Removing old subprober domains file"
    sleep 3

    # Step 11: Renaming final output
    show_progress "Renaming final output to new file"
    mv output-domains.txt "${domain_name}-domains.txt" || handle_error "Renaming output file"
    sleep 3

    # Step 12: Final filtering of unique domain names
    show_progress "Last step filtering domains"
    awk '{sub(/^https?:\/\//, "http://", $0); sub(/^www\./, "", $0); domain = $0; if (!seen[domain]++) print domain}' "${domain_name}-domains.txt" > "final-${domain_name}-domains.txt" || handle_error "Final filtering"
    sleep 5

    # Step 13: Renaming final file to new file
    show_progress "Renaming final file to new file"
    mv "final-${domain_name}-domains.txt" "${domain_name}-domains.txt" || handle_error "Renaming output file"
    sleep 3

    echo -e "${BOLD_BLUE}Enumeration and filtering process completed successfully. Final output saved as ${domain_name}-domains.txt.${NC}"

    # New message for the user with Y/N option
read -p "$(echo -e "${BOLD_WHITE}Your domain file has been created. Would you like to continue scanning your target domain, including all its subdomains? If so, please enter 'Y'. If you prefer to modify the domain file first, so you can delete these and add your domains, enter 'N', and you can manually proceed with step 4 afterwards. Do you want to continue scanning with all subdomains (Y/N)?: ${NC}")" continue_scan
if [[ "$continue_scan" =~ ^[Yy]$ ]]; then
    skip_order_check_for_option_4=true
    echo -e "${BOLD_BLUE}Automatically continuing with step 4: Crawl and filter URLs...${NC}"
    run_step_4  # Automatically continue to step 4
else
    echo -e "${BOLD_WHITE}Please edit your file ${domain_name}-domains.txt and remove any unwanted subdomains before continuing.${NC}"
    skip_order_check_for_option_4=true
fi
}

# Function to run step 4 (Crawl and filter URLs)
run_step_4() {
    echo -e "${BOLD_WHITE}You selected: Crawl and filter URLs for $domain_name${NC}"

    # Step 1: Crawling with GoSpider
    show_progress "Crawling links with GoSpider"
    gospider -S "${domain_name}-domains.txt" -c 10 -d 5 | tee -a "${domain_name}-gospider.txt" || handle_error "GoSpider crawl"
    sleep 3

    # Step 2: Crawling with Hakrawler
    show_progress "Crawling links with Hakrawler"
    cat "${domain_name}-domains.txt" | hakrawler -d 3 | tee -a "${domain_name}-hakrawler.txt" || handle_error "Hakrawler crawl"
    sleep 3

    # Step 3: Crawling with Katana
    show_progress "Crawling links with Katana"
    cat "${domain_name}-domains.txt" | katana | tee -a "${domain_name}-katana.txt" || handle_error "Katana crawl"
    sleep 3

    # Step 3.1: Crawling with URLFinder
    show_progress "Crawling links with URLFinder"
    cat "${domain_name}-domains.txt" | urlfinder | tee -a "${domain_name}-urlfinder.txt" || handle_error "urlfinder crawl"
    sleep 3

    # Step 4: Crawling with Waybackurls
    show_progress "Crawling links with Waybackurls"
    cat "${domain_name}-domains.txt" | waybackurls | tee -a "${domain_name}-waybackurls.txt" || handle_error "Waybackurls crawl"
    sleep 3

    # Step 5: Crawling with Gau
    show_progress "Crawling links with Gau"
    rm -r /root/.gau.toml
    cat "${domain_name}-domains.txt" | gau | tee -a "${domain_name}-gau.txt" || handle_error "Gau crawl"
    sleep 3

    echo -e "${BOLD_BLUE}Crawling and filtering URLs completed successfully. Output files created for each tool.${NC}"
    
    # Step 6: Filter invalid links on Gospider and Hakrawler
    show_progress "Filtering invalid links on Gospider and Hakrawler"
    grep -oP 'http[^\s]*' "${domain_name}-gospider.txt" > "${domain_name}-gospider1.txt"
    grep -oP 'http[^\s]*' "${domain_name}-hakrawler.txt" > "${domain_name}-hakrawler1.txt"
    sleep 3

    # Step 7: Remove old Gospider and Hakrawler files
    show_progress "Removing old Gospider and Hakrawler files"
    rm -r "${domain_name}-gospider.txt" "${domain_name}-hakrawler.txt"
    sleep 3

    # Step 8: Filter similar URLs with URO tool
    show_progress "Filtering similar URLs with URO tool"
    uro -i "${domain_name}-gospider1.txt" -o urogospider.txt &
    uro_pid_gospider=$!

    uro -i "${domain_name}-hakrawler1.txt" -o urohakrawler.txt &
    uro_pid_hakrawler=$!

    uro -i "${domain_name}-katana.txt" -o urokatana.txt &
    uro_pid_katana=$!

    uro -i "${domain_name}-urlfinder.txt" -o urourlfinder.txt &
    uro_pid_urlfinder=$!

    uro -i "${domain_name}-waybackurls.txt" -o urowaybackurls.txt &
    uro_pid_waybackurls=$!

    uro -i "${domain_name}-gau.txt" -o urogau.txt &
    uro_pid_gau=$!

    # Monitor the processes
    while kill -0 $uro_pid_gospider 2> /dev/null || kill -0 $uro_pid_hakrawler 2> /dev/null || \
          kill -0 $uro_pid_katana 2> /dev/null || kill -0 $uro_pid_urlfinder 2> /dev/null || kill -0 $uro_pid_waybackurls 2> /dev/null || \
          kill -0 $uro_pid_gau 2> /dev/null; do
        echo -e "${BOLD_BLUE}URO tool is still running...⌛️${NC}"
        sleep 30  # Check every 30 seconds
    done

    echo -e "${BOLD_BLUE}URO processing completed. Files created successfully.${NC}"
    sleep 3

    # Step 9: Remove all previous files
show_progress "Removing all previous files"
sudo rm -r "${domain_name}-gospider1.txt" "${domain_name}-hakrawler1.txt" "${domain_name}-katana.txt" "${domain_name}-urlfinder.txt" "${domain_name}-waybackurls.txt" "${domain_name}-gau.txt"
sleep 3

# Step 10: Merge all URO files into one final file
show_progress "Merging all URO files into one final file"
cat urogospider.txt urohakrawler.txt urokatana.txt urourlfinder.txt urowaybackurls.txt urogau.txt > "${domain_name}-links-final.txt"
    
# Create new folder 'urls' and assign permissions
show_progress "Creating 'urls' directory and setting permissions"
sudo mkdir -p urls
sudo chmod 777 urls

# Copy the final file to the 'urls' folder
show_progress "Copying ${domain_name}-links-final.txt to 'urls' directory"
sudo cp "${domain_name}-links-final.txt" urls/

# Display professional message about the URLs
echo -e "${BOLD_WHITE}All identified URLs have been successfully saved in the newly created 'urls' directory.${NC}"
echo -e "${CYAN}These URLs represent potential targets that were not filtered out during the previous steps.${NC}"
echo -e "${CYAN}You can use the file 'urls/${domain_name}-links-final.txt' for further vulnerability testing with tools like Nuclei or any other inspection frameworks to identify additional vulnerabilities.${NC}"
echo -e "${CYAN}We are now continuing with our main purpose of XSS filtration and vulnerability identification.${NC}"

# Display the number of URLs in the final merged file
total_merged_urls=$(wc -l < "${domain_name}-links-final.txt")
echo -e "${BOLD_WHITE}Total URLs merged: ${RED}${total_merged_urls}${NC}"
sleep 3

# Step 11: Remove all 5 previous files
show_progress "Removing all 5 previous files"
sudo rm -r urokatana.txt urohakrawler.txt urowaybackurls.txt urourlfinder.txt urogau.txt urogospider.txt
sleep 3

# Automatically start step 5 after completing step 4
run_step_5
}

# Function to run step 5 (Filtering all)
run_step_5() {
    echo -e "${BOLD_WHITE}You selected: Filtering extensions from the URLs for $domain_name${NC}"

    # Step 14: Filtering extensions from the URLs
    show_progress "Filtering extensions from the URLs"
    cat ${domain_name}-links-final.txt | grep -E -v '\.css($|\s|\?|&|#|/|\.)|\.js($|\s|\?|&|#|/|\.)|\.jpg($|\s|\?|&|#|/|\.)|\.JPG($|\s|\?|&|#|/|\.)|\.PNG($|\s|\?|&|#|/|\.)|\.GIF($|\s|\?|&|#|/|\.)|\.avi($|\s|\?|&|#|/|\.)|\.dll($|\s|\?|&|#|/|\.)|\.pl($|\s|\?|&|#|/|\.)|\.webm($|\s|\?|&|#|/|\.)|\.c($|\s|\?|&|#|/|\.)|\.py($|\s|\?|&|#|/|\.)|\.bat($|\s|\?|&|#|/|\.)|\.tar($|\s|\?|&|#|/|\.)|\.swp($|\s|\?|&|#|/|\.)|\.tmp($|\s|\?|&|#|/|\.)|\.sh($|\s|\?|&|#|/|\.)|\.deb($|\s|\?|&|#|/|\.)|\.exe($|\s|\?|&|#|/|\.)|\.zip($|\s|\?|&|#|/|\.)|\.mpeg($|\s|\?|&|#|/|\.)|\.mpg($|\s|\?|&|#|/|\.)|\.flv($|\s|\?|&|#|/|\.)|\.wmv($|\s|\?|&|#|/|\.)|\.wma($|\s|\?|&|#|/|\.)|\.aac($|\s|\?|&|#|/|\.)|\.m4a($|\s|\?|&|#|/|\.)|\.ogg($|\s|\?|&|#|/|\.)|\.mp4($|\s|\?|&|#|/|\.)|\.mp3($|\s|\?|&|#|/|\.)|\.bat($|\s|\?|&|#|/|\.)|\.dat($|\s|\?|&|#|/|\.)|\.cfg($|\s|\?|&|#|/|\.)|\.cfm($|\s|\?|&|#|/|\.)|\.bin($|\s|\?|&|#|/|\.)|\.jpeg($|\s|\?|&|#|/|\.)|\.JPEG($|\s|\?|&|#|/|\.)|\.ps.gz($|\s|\?|&|#|/|\.)|\.gz($|\s|\?|&|#|/|\.)|\.gif($|\s|\?|&|#|/|\.)|\.tif($|\s|\?|&|#|/|\.)|\.tiff($|\s|\?|&|#|/|\.)|\.csv($|\s|\?|&|#|/|\.)|\.png($|\s|\?|&|#|/|\.)|\.ttf($|\s|\?|&|#|/|\.)|\.ppt($|\s|\?|&|#|/|\.)|\.pptx($|\s|\?|&|#|/|\.)|\.ppsx($|\s|\?|&|#|/|\.)|\.doc($|\s|\?|&|#|/|\.)|\.woff($|\s|\?|&|#|/|\.)|\.xlsx($|\s|\?|&|#|/|\.)|\.xls($|\s|\?|&|#|/|\.)|\.mpp($|\s|\?|&|#|/|\.)|\.mdb($|\s|\?|&|#|/|\.)|\.json($|\s|\?|&|#|/|\.)|\.woff2($|\s|\?|&|#|/|\.)|\.icon($|\s|\?|&|#|/|\.)|\.pdf($|\s|\?|&|#|/|\.)|\.docx($|\s|\?|&|#|/|\.)|\.svg($|\s|\?|&|#|/|\.)|\.txt($|\s|\?|&|#|/|\.)|\.jar($|\s|\?|&|#|/|\.)|\.0($|\s|\?|&|#|/|\.)|\.1($|\s|\?|&|#|/|\.)|\.2($|\s|\?|&|#|/|\.)|\.3($|\s|\?|&|#|/|\.)|\.4($|\s|\?|&|#|/|\.)|\.m4r($|\s|\?|&|#|/|\.)|\.kml($|\s|\?|&|#|/|\.)|\.pro($|\s|\?|&|#|/|\.)|\.yao($|\s|\?|&|#|/|\.)|\.gcn3($|\s|\?|&|#|/|\.)|\.PDF($|\s|\?|&|#|/|\.)|\.egy($|\s|\?|&|#|/|\.)|\.par($|\s|\?|&|#|/|\.)|\.lin($|\s|\?|&|#|/|\.)|\.yht($|\s|\?|&|#|/|\.)' > filtered-extensions-links.txt
    sleep 5

    # Step 15: Renaming filtered extensions file
    show_progress "Renaming filtered extensions file"
    mv filtered-extensions-links.txt "${domain_name}-links-clean.txt"
    sleep 3

    # Step 16: Filtering unwanted domains from the URLs
    show_progress "Filtering unwanted domains from the URLs"
    grep -E "^(https?://)?([a-zA-Z0-9.-]+\.)?${domain_name}" "${domain_name}-links-clean.txt" > "${domain_name}-links-clean1.txt"
    sleep 3

    # Step 17: Removing old filtered file
    show_progress "Removing old filtered file"
    rm -r ${domain_name}-links-clean.txt ${domain_name}-links-final.txt
    sleep 3

    # Step 18: Renaming new filtered file
    show_progress "Renaming new filtered file"
    mv ${domain_name}-links-clean1.txt ${domain_name}-links-clean.txt
    sleep 3

    # Step 19: Running URO tool again to filter duplicate and similar URLs
    show_progress "Running URO tool again to filter duplicate and similar URLs"
    uro -i "${domain_name}-links-clean.txt" -o "${domain_name}-uro.txt" &
    uro_pid_clean=$!

    # Monitor the URO process
    while kill -0 $uro_pid_clean 2> /dev/null; do
        echo -e "${BOLD_BLUE}URO tool is still running for clean URLs...⌛️${NC}"
        sleep 30  # Check every 30 seconds
    done

    echo -e "${BOLD_BLUE}URO processing completed. Files created successfully.${NC}"
    sleep 3

    # Display the number of URLs in the URO output file
    echo -e "${BOLD_WHITE}Total URLs in final output: ${RED}$(wc -l < "${domain_name}-uro.txt")${NC}"
    sleep 3

    # Step 20: Removing old file
    show_progress "Removing old file"
    rm -r "${domain_name}-links-clean.txt"
    sleep 3

    # Step 21: Removing 99% similar parameters with bash command
    show_progress "Removing 99% similar parameters with bash command"
    filtered_output="filtered_output.txt"
    if [[ ! -f "${domain_name}-uro.txt" ]]; then 
        echo "File not found! Please check the path and try again."
        exit 1
    fi
    awk -F'[?&]' '{gsub(/:80/, "", $1); base_url=$1; params=""; for (i=2; i<=NF; i++) {split($i, kv, "="); if (kv[1] != "id") {params = params kv[1]; if (i < NF) {params = params "&";}}} full_url=base_url"?"params; if (!seen[full_url]++) {print $0 > "'"$filtered_output"'";}}' "${domain_name}-uro.txt"
    sleep 5

    # Display the number of URLs in the filtered output file
    echo -e "${BOLD_WHITE}Total filtered URLs: ${RED}$(wc -l < "$filtered_output")${NC}"
    sleep 3

    # Step 22: Removing old file
    show_progress "Removing old file"
    rm -r "${domain_name}-uro.txt"
    sleep 3

    # Step 23: Rename to new file
    show_progress "Rename to new file"
    mv filtered_output.txt "${domain_name}-links.txt"
    sleep 3

    # Step 24: Filtering ALIVE domain names
    show_progress "Filtering ALIVE domain names"
    subprober -f "${domain_name}-links.txt" -sc -ar -o "${domain_name}-links.txt1337" -nc -mc 200,301,302,307,308,403 -c 20 || handle_error "subprober"
    sleep 5

    # Step 25: Removing old file
    show_progress "Removing old file"
    rm -r ${domain_name}-links.txt
    sleep 3

    # Step 26: Filtering valid domain names
    show_progress "Filtering valid domain names"
    grep -oP 'http[^\s]*' "${domain_name}-links.txt1337" > ${domain_name}-links.txt1338 || handle_error "grep valid domains"
    sleep 5

    # Step 27: Removing intermediate file and renaming final output
    show_progress "Final cleanup and renaming"
    rm -r ${domain_name}-links.txt1337
    mv ${domain_name}-links.txt1338 ${domain_name}-links.txt
    sleep 3

    echo -e "${BOLD_BLUE}Filtering process completed successfully. Final output saved as ${domain_name}-links.txt.${NC}"

    # Automatically start step 6 after completing step 5
    run_step_6
}

# Function to run step 6 (Create new separated file for Arjun & SQLi testing)
run_step_6() {
    echo -e "${BOLD_WHITE}You selected: Create new separated file for Arjun & SQLi testing for $domain_name${NC}"

    # Step 1: Preparing URLs with clean extensions
    show_progress "Preparing URLs with clean extensions, created 2 files: arjun-urls.txt and output-php-links.txt"
    cat "${domain_name}-links.txt" | grep -E "\.php($|\s|\?|&|#|/|\.)|\.asp($|\s|\?|&|#|/|\.)|\.aspx($|\s|\?|&|#|/|\.)|\.cfm($|\s|\?|&|#|/|\.)|\.jsp($|\s|\?|&|#|/|\.)" | awk '{if ($0 !~ /\?/) print > "arjun-urls.txt"; else print > "output-php-links.txt";}'
    sleep 3

    # Check if Arjun generated any files
    if [ ! -s arjun-urls.txt ] && [ ! -s output-php-links.txt ]; then
        echo -e "${RED}Arjun did not find any new links or did not create any files.${NC}"
        echo -e "${BOLD_BLUE}Renaming ${domain_name}-links.txt to urls-ready.txt and continuing...${NC}"
        mv "${domain_name}-links.txt" urls-ready.txt || handle_error "Renaming ${domain_name}-links.txt"
        sleep 3
        run_step_7  # Automatically proceed to step 7
        return
    fi

    echo -e "${BOLD_BLUE}URLs prepared successfully and files created.${NC}"
    echo -e "${BOLD_BLUE}arjun-urls.txt and output-php-links.txt have been created.${NC}"

    # Step 2: Running Arjunhe on clean URLs if arjun-urls.txt is present
if [ -s arjun-urls.txt ]; then
    show_progress "Running Arjun on clean URLs"
    arjun -i arjun-urls.txt -oT arjun_output.txt -t 10 -w parametri.txt || handle_error "Arjun command"
    sleep 5

    # Count the number of new links discovered by Arjun
    if [ -f arjun_output.txt ]; then
        new_links_count=$(wc -l < arjun_output.txt)
        echo -e "${BOLD_BLUE}Arjun has completed running on the clean URLs.${NC}"
        echo -e "${BOLD_RED}Arjun discovered ${new_links_count} new links.${NC}"

        # Step 3: Check if output-php-links.txt exists before merging
        if [ -f output-php-links.txt ]; then
            show_progress "Merging Arjun output with PHP links"
            cat arjun_output.txt output-php-links.txt > arjun-final.txt || handle_error "Merging Arjun output"
        else
            echo -e "${YELLOW}Warning: output-php-links.txt not found. Renaming arjun_output.txt to arjun-final.txt and proceeding.${NC}"
            mv arjun_output.txt arjun-final.txt || handle_error "Renaming arjun_output.txt to arjun-final.txt"
        fi
        sleep 5
    else
        echo -e "${RED}Arjun output file was not created. Checking for output-php-links.txt.${NC}"
        if [ -s output-php-links.txt ]; then
            mv output-php-links.txt arjun-final.txt || handle_error "Renaming output-php-links.txt"
        else
            echo -e "${RED}No files found to rename or merge. Please check the input files or conditions that create them.${NC}"
        fi
    fi
else
    echo -e "${RED}Arjun did not find any links to process.${NC}"
    if [ -s output-php-links.txt ]; then
        mv output-php-links.txt arjun-final.txt || handle_error "Renaming output-php-links.txt"
    else
        echo -e "${RED}No output-php-links.txt to rename.${NC}"
    fi
fi

# Step 4: Cleaning up temporary files if Arjun was successful
show_progress "Cleaning up temporary files"
if [[ -f arjun-urls.txt || -f arjun_output.txt || -f output-php-links.txt ]]; then
    [[ -f arjun-urls.txt ]] && rm -r arjun-urls.txt
    [[ -f arjun_output.txt ]] && rm -r arjun_output.txt
    [[ -f output-php-links.txt ]] && rm -r output-php-links.txt
    sleep 3
else
    echo -e "${RED}No Arjun files to remove.${NC}"
fi

echo -e "${BOLD_BLUE}Files merged and cleanup completed. Final output saved as arjun-final.txt.${NC}"

# Step 5: Creating a new file for XSS testing
if [ -f arjun-final.txt ]; then
    show_progress "Creating a new file for XSS testing"
    cat "${domain_name}-links.txt" arjun-final.txt > urls-ready.txt || handle_error "Creating XSS testing file"
    sleep 3

    # Removing the previous links file
    show_progress "Removing the previous links file"
    rm -r "${domain_name}-links.txt" || handle_error "Removing previous links file"
    sleep 3

    echo -e "${BOLD_RED}XSS testing file created successfully as urls-ready.txt.${NC}"
else
    echo -e "${RED}Skipping XSS testing file creation due to missing Arjun output.${NC}"
    mv "${domain_name}-links.txt" urls-ready.txt || handle_error "Renaming ${domain_name}-links.txt"
fi

# Automatically start step 7 after completing step 6
run_step_7
}

# Function to run step 7 (Getting ready for XSS & URLs with query strings)
run_step_7() {
    echo -e "${BOLD_WHITE}You selected: Getting ready for XSS & URLs with query strings for $domain_name${NC}"

    # Step 1: Filtering URLs with query strings
    show_progress "Filtering URLs with query strings"
    grep '=' urls-ready.txt > "$domain_name-query.txt"
    sleep 5
    echo -e "${BOLD_BLUE}Filtering completed. Query URLs saved as ${domain_name}-query.txt.${NC}"

    # Step 2: Renaming the remaining URLs
    show_progress "Renaming remaining URLs"
    mv urls-ready.txt "$domain_name-ALL-links.txt"
    sleep 3
    echo -e "${BOLD_BLUE}All-links URLs saved as ${domain_name}-ALL-links.txt.${NC}"

    # Step 3: Analyzing and reducing the query URLs based on repeated parameters
show_progress "Analyzing query strings for repeated parameters"

# Start the analysis in the background and get the process ID (PID)
(> ibro-xss.txt; > temp_param_names.txt; > temp_param_combinations.txt; while read -r url; do base_url=$(echo "$url" | cut -d'?' -f1); extension=$(echo "$base_url" | grep -oiE '\.php|\.asp|\.aspx|\.cfm|\.jsp'); if [[ -n "$extension" ]]; then echo "$url" >> ibro-xss.txt; else params=$(echo "$url" | grep -oE '\?.*' | tr '?' ' ' | tr '&' '\n'); param_names=$(echo "$params" | cut -d'=' -f1); full_param_string=$(echo "$url" | cut -d'?' -f2); if grep -qx "$full_param_string" temp_param_combinations.txt; then continue; else new_param_names=false; for param_name in $param_names; do if ! grep -qx "$param_name" temp_param_names.txt; then new_param_names=true; break; fi; done; if $new_param_names; then echo "$url" >> ibro-xss.txt; echo "$full_param_string" >> temp_param_combinations.txt; for param_name in $param_names; do echo "$param_name" >> temp_param_names.txt; done; fi; fi; fi; done < "${domain_name}-query.txt"; echo "Processed URLs with unique parameters: $(wc -l < ibro-xss.txt)") &

# Save the process ID (PID) of the background task
analysis_pid=$!

# Monitor the process in the background
while kill -0 $analysis_pid 2> /dev/null; do
    echo -e "${BOLD_BLUE}Analysis tool is still running...⌛️${NC}"
    sleep 30  # Check every 30 seconds
done

# When finished
echo -e "${BOLD_GREEN}Analysis completed. $(wc -l < ibro-xss.txt) URLs with repeated parameters have been saved.${NC}"
rm temp_param_names.txt temp_param_combinations.txt
sleep 3

    # Step 4: Cleanup and rename the output file
    show_progress "Cleaning up intermediate files and setting final output"
    rm -r "${domain_name}-query.txt"
    mv ibro-xss.txt "${domain_name}-query.txt"
    echo -e "${BOLD_BLUE}Cleaned up and renamed output to ${domain_name}-query.txt.${NC}"
    sleep 3
}

# Main script logic

while true; do
    # Display options
    display_options
    read -p "Enter your choice [1-8]: " choice

    # Check if the selected option is in the correct order
    if [[ $choice -ge 2 && $choice -le 7 && $choice -ne 4 ]]; then
        if [[ $choice -gt $((last_completed_option + 1)) ]]; then
            echo -e "${RED}Please respect order one by one from 1-8, you can't skip previous Options${NC}"
            continue
        fi
    fi

    case $choice in
        1)
            install_tools
            last_completed_option=1
            ;;
        2)
            read -p "Please enter a domain name (example.com): " domain_name
            echo -e "${BOLD_WHITE}You selected: Domain name set to $domain_name${NC}"
            last_completed_option=2
            
            # Automatically proceed to Step 3 after setting the domain name
            read -p "$(echo -e "${BOLD_WHITE}Do you want to proceed with domain enumeration and filtering for $domain_name (Y/N)?: ${NC}")" proceed_to_step_3
            if [[ "$proceed_to_step_3" =~ ^[Yy]$ ]]; then
                echo -e "${BOLD_BLUE}Automatically continuing with step 3: Enumerate and filter domains for $domain_name...${NC}"
                run_step_3
                last_completed_option=3
            else
                echo -e "${BOLD_WHITE}You can manually start Step 3 whenever you are ready.${NC}"
            fi
            ;;
        3)
            if [ -z "$domain_name" ]; then
                echo "Domain name is not set. Please select option 2 to set the domain name."
            else
                run_step_3
                last_completed_option=3
            fi
            ;;
        4)
            if [ -z "$domain_name" ]; then
                echo "Domain name is not set. Please select option 2 to set the domain name."
            else
                run_step_4
                last_completed_option=4
            fi
            ;;
        5)
            if [ -z "$domain_name" ]; then
                echo "Domain name is not set. Please select option 2 to set the domain name."
            else
                run_step_5
                last_completed_option=5
            fi
            ;;
        6)
            if [ -z "$domain_name" ]; then
                echo "Domain name is not set. Please select option 2 to set the domain name."
            else
                run_step_6
                last_completed_option=6
            fi
            ;;
        7)
            if [ -z "$domain_name" ]; then
                echo "Domain name is not set. Please select option 2 to set the domain name."
            else
                run_step_7
                last_completed_option=7
            fi
            ;;
        8)
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid option. Please select a number between 1 and 11."
            ;;
    esac
done
