#!/bin/zsh

# Installomator
#
# Downloads and installs an Applications
# 2020 Armin Briegel - Scripting OS X
#
# inspired by the download scripts from William Smith and Sander Schram

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

VERSION='20200311'

# (set to 0 for production, 1 for debugging)
DEBUG=1 

# if this is set to 1, the argument will be picked up at $4 instead of $1
JAMF=0 

if [ "$JAMF" -eq 0 ]; then
    identifier=${1:?"no identifier provided"}
else
    identifier=${4:?"argument $4 required"}
fi

# lowercase the identifier
identifier=$(echo "$identifier" |  tr '[:upper:]' '[:lower:]' )

# each identifier needs to be listed in the case statement below
# for each identifier these three variables must be set:
#
# - name:
#   Name of the installed app.
#   This is used to derive many of the other variables.
#
# - type:
#   The type of the installation. Possible values:
#     - dmg
#     - pkg
#     - zip (not yet implemented)
#     - pkgInDmg (not yet implemented)
#     - pkgInZip (not yet implemented)
# 
# - downloadURL: 
#   URL to download the dmg
#
# - expectedTeamID:
#   10-digit developer team ID
#   obtain this by running 
#
#   Applications (in dmgs or zips)
#   spctl -a -vv /Applications/BBEdit.app
#
#   Pkgs
#   spctl -a -vv -t install ~/Downloads/desktoppr-0.2.pkg
#
#   The team ID is the ten-digit ID at the end of the line starting with 'origin='
# 
# - archiveName: (optional)
#   The name of the downloaded file
#   When not given the archiveName is derived from the name
#
# - appName: (optional)
#   file name of the app bundle in the dmg to verify and copy (include .app)
#   When not given, the App name is derived from the name
#
# - targetDir: (optional)
#   Applications will be copied to this directory
#   Default value is '/Applications' for dmg and zip installations
#   With a pkg the targetDir is used as the install-location. Default is "/"


# todos:

# TODO: add zip support
# TODO: handle pkgs in dmg or zip
# TODO: check for running processes and either abort or prompt user
# TODO: print version of installed software
# TODO: notification when done
# TODO: add remaining MS pkgs

# functions to help with getting info

# will get the latest release download from a github repo
downloadURLFromGit() { # $1 git user name, $2 git repo name
    gitusername=${1?:"no git user name"}
    gitreponame=${2?:"no git repo name"}
    
    downloadURL=$(curl --silent --fail "https://api.github.com/repos/$gitusername/$gitreponame/releases/latest" | awk -F '"' '/browser_download_url/ { print $4 }')
    if [ -z "$downloadURL" ]; then
        echo "could not retrieve download URL for $gitusername/$gitreponame"
        cleanupAndExit 9
    else
        echo "$downloadURL"
        return 0
    fi
}

# identifiers in case statement

case $identifier in
    version)
        # print the script version
        echo "Installomater: version $VERSION"
        exit 0
        ;;
    
    # app descriptions start here
    googlechrome)
        name="Google Chrome"
        type="dmg"
        downloadURL="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
        expectedTeamID="EQHXZ8M8AV"
        ;;
    spotify)
        name="Spotify"
        type="dmg"
        downloadURL="https://download.scdn.co/Spotify.dmg"
        expectedTeamID="2FNC3A47ZF"
        ;;
    bbedit)
        name="BBEdit"
        type="dmg"
        downloadURL=$(curl -s https://versioncheck.barebones.com/BBEdit.xml | grep dmg | sort | tail -n1 | cut -d">" -f2 | cut -d"<" -f1)
        expectedTeamID="W52GZAXT98"
        ;;
    firefox)
        name="Firefox"
        type="dmg"
        downloadURL="https://download.mozilla.org/?product=firefox-latest&amp;os=osx&amp;lang=en-US"
        expectedTeamID="43AQ936H96"
        ;;
    whatsapp)
        name="WhatsApp"
        type="dmg"
        downloadURL="https://web.whatsapp.com/desktop/mac/files/WhatsApp.dmg"
        expectedTeamID="57T9237FN3"
        ;;
    desktoppr)
        name="desktoppr"
        type="pkg"
        downloadURL=$(downloadURLFromGit "scriptingosx" "desktoppr")
        expectedTeamID="JME5BW3F3R"
        ;;
    malwarebytes)
        name="Malwarebytes"
        type="pkg"
        downloadURL="https://downloads.malwarebytes.com/file/mb3-mac"
        expectedTeamID="GVZRY6KDKR"
        ;;
    microsoftoffice365)
        name="MicrosoftOffice365"
        type="pkg"
        downloadURL="https://go.microsoft.com/fwlink/?linkid=525133"
        expectedTeamID="UBF8T346G9"
        ;;   
    microsoftedgeconsumerstable)
        name="MicrosoftEdgeConsumerStable"
        type="pkg"
        downloadURL="https://go.microsoft.com/fwlink/?linkid=2069148"
        expectedTeamID="UBF8T346G9"
        ;;
    microsoftcompanyportal)  
        name="MicrosoftCompanyPortal"
        type="pkg"
        downloadURL="https://go.microsoft.com/fwlink/?linkid=869655"
        expectedTeamID="UBF8T346G9"
        ;;
    microsoftskypeforbusiness)  
        name="MicrosoftSkypeForBusiness"
        type="pkg"
        downloadURL="https://go.microsoft.com/fwlink/?linkid=832978"
        expectedTeamID="UBF8T346G9"
        ;;
    microsoftremotedesktop)  
        name="MicrosoftRemoteDesktop"
        type="pkg"
        downloadURL="https://go.microsoft.com/fwlink/?linkid=868963"
        expectedTeamID="UBF8T346G9"
        ;;
    microsoftteams)  
        name="MicrosoftTeams"
        type="pkg"
        downloadURL="https://go.microsoft.com/fwlink/?linkid=869428"
        expectedTeamID="UBF8T346G9"
        ;;
    microsoftautoupdate)
        name="MicrosoftAutoUpdate§"
        type="pkg"
        downloadURL="https://go.microsoft.com/fwlink/?linkid=830196"
        teamID="UBF8T346G9"
        ;;
    microsoftedgeenterprisestable)
        name="MicrosoftEdgeEnterpriseStable"
        type="pkg"
        downloadURL="https://go.microsoft.com/fwlink/?linkid=2093438"
        teamID="UBF8T346G9"
        ;;
    microsoftsharepointplugin)
        name="MicrosoftSharePointPlugin"
        type="pkg"
        downloadURL="https://go.microsoft.com/fwlink/?linkid=800050"
        teamID="UBF8T346G9"
        ;;

    # note: there are more available MS downloads to add
    # 525133 - Office 2019 for Mac SKUless download (aka Office 365)
    # 2009112 - Office 2019 for Mac BusinessPro SKUless download (aka Office 365 with Teams)
    # 871743 - Office 2016 for Mac SKUless download
    # 830196 - AutoUpdate download
    # 2069148 - Edge (Consumer Stable)
    # 2069439 - Edge (Consumer Beta)
    # 2069340 - Edge (Consumer Dev)
    # 2069147 - Edge (Consumer Canary)
    # 2093438 - Edge (Enterprise Stable)
    # 2093294 - Edge (Enterprise Beta)
    # 2093292 - Edge (Enterprise Dev)
    # 525135 - Excel 2019 SKUless download
    # 871750 - Excel 2016 SKUless download
    # 869655 - InTune Company Portal download
    # 823060 - OneDrive download
    # 820886 - OneNote download
    # 525137 - Outlook 2019 SKUless download
    # 871753 - Outlook 2016 SKUless download
    # 525136 - PowerPoint 2019 SKUless download
    # 871751 - PowerPoint 2016 SKUless download
    # 868963 - Remote Desktop
    # 800050 - SharePoint Plugin download
    # 832978 - Skype for Business download
    # 869428 - Teams
    # 525134 - Word 2019 SKUless download
    # 871748 - Word 2016 SKUless download

        
    # these description exist for testing and are intentionally broken
    brokendownloadurl)
        name="Google Chrome"
        type="dmg"
        downloadURL="https://broken.com/broken.dmg"
        expectedTeamID="EQHXZ8M8AV"
        ;;
    brokenappname)
        name="brokenapp"
        type="dmg"
        downloadURL="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
        expectedTeamID="EQHXZ8M8AV"
        ;;
    brokenteamid)
        name="Google Chrome"
        type="dmg"
        downloadURL="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
        expectedTeamID="broken"
        ;;
    *)
        # unknown identifier
        echo "unknown identifier $identifier"
        exit 1
        ;;
esac

# functions
cleanupAndExit() { # $1 = exit code
    if [ "$DEBUG" -eq 0 ]; then
        # remove the temporary working directory when done
        echo "Deleting $tmpDir"
        rm -Rf "$tmpDir"
    fi
    
    if [ -n "$dmgmount" ]; then
        # unmount disk image
        echo "Unmounting $dmgmount"
        hdiutil detach "$dmgmount"
    fi
    exit "$1"
}

consoleUser() {
    scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }'
}

runAsUser() {  
    cuser=$(consoleUser)
    if [[ $cuser != "loginwindow" ]]; then
        uid=$(id -u "$cuser")
        launchctl asuser $uid sudo -u $cuser "$@"
    fi
}

displaydialog() { # $1: message
    message=${1:-"Message"}
    runAsUser /usr/bin/osascript -e "button returned of (display dialog \"$message\" buttons {\"Not Now\", \"Quit and Update\"} default button \"Quit and Update\")"
}


installFromDMG() {
    # mount the dmg
    echo "Mounting $tmpDir/$archiveName"
    # set -o pipefail
    if ! dmgmount=$(hdiutil attach "$tmpDir/$archiveName" -nobrowse -readonly | tail -n 1 | cut -c 54- ); then
        echo "Error mounting $tmpDir/$archiveName"
        cleanupAndExit 3
    fi
    echo "Mounted: $dmgmount"

    # check if app exists
    if [ ! -e "$dmgmount/$appName" ]; then
        echo "could not find: $dmgmount/$appName"
        cleanupAndExit 8
    fi

    # verify with spctl
    echo "Verifying: $dmgmount/$appName"
    if ! teamID=$(spctl -a -vv "$dmgmount/$appName" 2>&1 | awk '/origin=/ {print $NF }' ); then
        echo "Error verifying $dmgmount/$appName"
        cleanupAndExit 4
    fi

    echo "Team ID: $teamID (expected: $expectedTeamID )"

    if [ "($expectedTeamID)" != "$teamID" ]; then
        echo "Team IDs do not match!"
        cleanupAndExit 5
    fi

    # check for root
    if [ "$(whoami)" != "root" ]; then
        # not running as root
        if [ "$DEBUG" -eq 0 ]; then
            echo "not running as root, exiting"
            cleanupAndExit 6
        fi
    
        echo "DEBUG enabled, skipping copy and chown steps"
        return 0
    fi

    # remove existing application
    if [ -e "$targetDir/$appName" ]; then
        echo "Removing existing $targetDir/$appName"
        rm -Rf "$targetDir/$appName"
    fi

    # copy app to /Applications
    echo "Copy $dmgmount/$appName to $targetDir"
    if ! ditto "$dmgmount/$appName" "$targetDir/$appName"; then
        echo "Error while copying!"
        cleanupAndExit 7
    fi


    # set ownership to current user
    currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
    if [ -n "$currentUser" ]; then
        echo "Changing owner to $currentUser"
        chown -R "$currentUser" "$targetDir/$appName" 
    else
        echo "No user logged in, not changing user"
    fi
}

installFromPKG() {
    # verify with spctl
    echo "Verifying: $archiveName"
    if ! teamID=$(spctl -a -vv -t install "$archiveName" 2>&1 | awk '/origin=/ {print $NF }' ); then
        echo "Error verifying $archiveName"
        cleanupAndExit 4
    fi

    echo "Team ID: $teamID (expected: $expectedTeamID )"

    if [ "($expectedTeamID)" != "$teamID" ]; then
        echo "Team IDs do not match!"
        cleanupAndExit 5
    fi
    
    # skip install for DEBUG
    if [ "$DEBUG" -ne 0 ]; then
        echo "DEBUG enabled, skipping installation"
        return 0
    fi
    
    # check for root
    if [ "$(whoami)" != "root" ]; then
        # not running as root
        echo "not running as root, exiting"
        cleanupAndExit 6    
    fi

    # install pkg
    echo "Installing $archiveName to $targetDir"
    if ! installer -pkg "$archiveName" -tgt "$targetDir" ; then
        echo "error installing $archiveName"
        cleanupAndExit 9
    fi
}

# main

# extract info from data
if [ -z "$archiveName" ]; then
    case $type in
        dmg|pkg|zip)
            archiveName="${name}.$type"
            ;;
        pkgInDmg)
            archiveName="${name}.dmg"
            ;;
        pkgInZip)
            archiveName="${name}.zip"
            ;;
        *)
            echo "Cannot handle type $type"
            cleanupAndExit 99
            ;;
    esac
fi

if [ -z "$appName" ]; then
    # when not given derive from name
    appName="$name.app"
fi

if [ -z "$targetDir" ]; then
    case $type in
        dmg|zip)
            targetDir="/Applications"
            ;;
        pkg*)
            targetDir="/"
            ;;
        *)
            echo "Cannot handle type $type"
            cleanupAndExit 99
            ;;
    esac
fi

# determine tmp dir
if [ "$DEBUG" -eq 1 ]; then
    # for debugging use script dir as working directory
    tmpDir=$(dirname "$0")
else
    # create temporary working directory
    tmpDir=$(mktemp -d )
fi

# change directory to temporary working directory
echo "Changing directory to $tmpDir"
if ! cd "$tmpDir"; then
    echo "error changing directory $tmpDir"
    #rm -Rf "$tmpDir"
    cleanupAndExit 1
fi

# TODO: when user is logged in, and app is running, prompt user to quit app

if [ -f "$archiveName" ] && [ "$DEBUG" -eq 1 ]; then
    echo "$archiveName exists and DEBUG enabled, skipping download"
else
    # download the dmg
    echo "Downloading $downloadURL to $archiveName"
    if ! curl --location --fail --silent "$downloadURL" -o "$archiveName"; then
        echo "error downloading $downloadURL"
        cleanupAndExit 2
    fi
fi

case $type in
    dmg)
        installFromDMG
        ;;
    pkg)
        installFromPKG
        ;;
    *)
        echo "Cannot handle type $type"
        cleanupAndExit 99
        ;;
esac


# TODO: notify when done

# all done!
cleanupAndExit 0