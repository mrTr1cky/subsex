#!/bin/bash

echo "==================================="
echo "      	   SubSex"
echo "        @DevidLuice"
echo "==================================="
echo ""

check_dependency() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "The required tool '$1' is not installed. Please install it and run the script again."; exit 1; }
}

run_subfinder() {
    echo "Enter the domain name #:"
    read domain

    if [ -z "$domain" ]; then
        echo "Domain name cannot be empty. Please enter a valid domain."
        return 1
    fi

    subfinder -d "$domain"
}

run_findomain() {
    echo "Enter the domain name #:"
    read domain

    if [ -z "$domain" ]; then
        echo "Domain name cannot be empty. Please enter a valid domain."
        return 1
    fi

    findomain -t "$domain"
}

run_amass() {
    echo "Enter the domain name #:"
    read domain

    if [ -z "$domain" ]; then
        echo "Domain name cannot be empty. Please enter a valid domain."
        return 1
    fi

    amass enum -d "$domain"
}

run_crtsh() {
    echo "Enter the domain name #:"
    read domain

    if [ -z "$domain" ]; then
        echo "Domain name cannot be empty. Please enter a valid domain."
        return 1
    fi

    crtsh_output="${domain}_crtsh_$(date +%Y%m%d).txt"
    curl -s "https://crt.sh/?q=%.$domain&output=json" | grep -oP '"name_value":"\K[^"]+' | sed 's/\\n/\n/g' | sort -u > "$crtsh_output"
    echo "SSL certificate information saved to $crtsh_output"
}

compare_and_save() {
    echo "Enter the domain name #:"
    read domain

    if [ -z "$domain" ]; then
        echo "Domain name cannot be empty. Please enter a valid domain."
        return 1
    fi

    subfinder_output=$(mktemp)
    findomain_output=$(mktemp)
    amass_output=$(mktemp)
    crtsh_output=$(mktemp)

    echo "Running subfinder..."
    subfinder -d "$domain" > "$subfinder_output"
    echo "Running findomain..."
    findomain -t "$domain" > "$findomain_output"
    echo "Running amass..."
    amass enum -d "$domain" > "$amass_output"
    echo "Fetching SSL certificate information from crt.sh..."
    curl -s "https://crt.sh/?q=%.$domain&output=json" | grep -oP '"name_value":"\K[^"]+' | sed 's/\\n/\n/g' | sort -u > "$crtsh_output"

    result_file="${domain}_combined_$(date +%Y%m%d).txt"
    cat "$subfinder_output" "$findomain_output" "$amass_output" "$crtsh_output" | sort -u > "$result_file"

    echo "Combined and unique results saved to: $result_file"

    rm "$subfinder_output" "$findomain_output" "$amass_output" "$crtsh_output"
}

check_dependency "subfinder"
check_dependency "findomain"
check_dependency "amass"
check_dependency "curl"

while true; do
    cat <<EOF
Select the command to run:

1. Run subfinder.
2. Run findomain for additional domains.
3. Run amass for enumeration.
4. Fetch SSL certificate information from crt.sh
5. Run all and compare results.
6. Exit.
EOF
    read -p "Enter your choice (1/2/3/4/5/6): " choice

    case $choice in
        1) run_subfinder ;;
        2) run_findomain ;;
        3) run_amass ;;
        4) run_crtsh ;;
        5) compare_and_save ;;
        6) echo "Exiting script."; break ;;
        *) echo "Invalid choice. Please enter a number from 1 to 6." ;;
    esac

    echo ""
done
