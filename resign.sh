# !/bin/bash

# Colors
GREEN="\033[1;32m"
ORANGE="\033[1;33m"
PURPLE="\033[1;34m"
RED="\033[1;31m"
LINK="\033[1;35m"
RESET="\033[0m"

# Directories 
DIR="`dirname \"$0\"`"

# Certificate name and mobileprovision file
certname="iPhone Distribution: John Doe (XX123XXX123)"
mobileprovision="$DIR/embedded.mobileprovision"
bundle="null.null"

sourcedirectory="$DIR/source/"
outputdirectory="$DIR/output/"

cd "$sourcedirectory"

function fixEntitlements() {
    local plist_file="$1"

    # Ensure entitlements file exists
    if [ ! -f "$plist_file" ]; then
        echo "${RED}✘ Error: Entitlements file not found: $plist_file${RESET}"
        return 1
    fi

    # Fix iCloud environment (force it to 'Production')
    /usr/libexec/PlistBuddy -c "Delete :com.apple.developer.icloud-container-environment" "$plist_file" 2>/dev/null
    /usr/libexec/PlistBuddy -c "Add :com.apple.developer.icloud-container-environment string Production" "$plist_file"

    # Fix iCloud services (force it to array with 'CloudKit')
    /usr/libexec/PlistBuddy -c "Delete :com.apple.developer.icloud-services" "$plist_file" 2>/dev/null
    /usr/libexec/PlistBuddy -c "Add :com.apple.developer.icloud-services array" "$plist_file"
    /usr/libexec/PlistBuddy -c "Add :com.apple.developer.icloud-services:0 string CloudKit" "$plist_file"
}

function signIPA() {
    SOURCEIPA="$1"
    DEVELOPER="$2"
    MOBILEPROV="$3"
    TARGET="$4"
    BUNDLE="$5"

    unzip -qo "$SOURCEIPA" -d extracted

    APPLICATION=$(ls extracted/Payload/)

    cp "$MOBILEPROV" "extracted/Payload/$APPLICATION/embedded.mobileprovision"

    echo "${ORANGE}• Extracting entitlements...${RESET}"
    security cms -D -i "extracted/Payload/$APPLICATION/embedded.mobileprovision" -o t_entitlements_full.plist
    /usr/libexec/PlistBuddy -x -c 'Print:Entitlements' t_entitlements_full.plist > t_entitlements.plist

    fixEntitlements "t_entitlements.plist"

    echo "${GREEN}✔ Resigning with certificate: $DEVELOPER${RESET}"
    find -d extracted \( -name "*.app" -o -name "*.appex" -o -name "*.framework" -o -name "*.dylib" \) > directories.txt

    while IFS='' read -r line || [[ -n "$line" ]]; do
        echo "${PURPLE}→ Signing: ${line##*/}${RESET}"
        /usr/bin/codesign --continue -f -s "$DEVELOPER" --entitlements "t_entitlements.plist" "$line" > /dev/null 2>&1
    done < directories.txt

    echo "${GREEN}✔ Creating signed IPA...${RESET}"
    cd extracted
    zip -qry ../extracted.ipa *
    cd ..
    mv extracted.ipa "$TARGET"

    rm -rf "extracted" directories.txt t_entitlements.plist t_entitlements_full.plist
}

find -d . -type f -name "*.ipa" > files.txt
while IFS='' read -r line || [[ -n "$line" ]]; do
    filename=$(basename "$line" .ipa)
    output="$outputdirectory${filename}_sign.ipa"
    signIPA "$line" "$certname" "$mobileprovision" "$output" "$bundle"
done < files.txt
rm files.txt

echo "\n${GREEN}If you find this script useful, feel free to support me! ☕\n${RESET}${LINK}https://www.buymeacoffee.com/dayanch96${RESET}"