# ! /bin/zsh

# declare a var `appMap` of type list[map] where `map : {name: string, path: string}`
declare -A appMap_whatsapp=(["name"]="whatsapp" ["path"]="https://web.whatsapp.com")
declare -A appMap_telegram=(["name"]="telegram" ["path"]="https://web.telegram.org")
declare -A appMap_wikipedia=(["name"]="wikipedia" ["path"]="https://www.wikipedia.org")
declare -A appMap_hianime=(["name"]="hianime" ["path"]="https://hianime.to/most-popular")
declare -A appMap_googlesearch=(["name"]="googlesearch" ["path"]="https://www.google.com/search?q=")
declare -A appMap_pull_requests=(["name"]="pull-requests" ["path"]="https://dev.azure.com/Algoriza/Monshaat/_git/InternalPortal/pullrequests?_a=active")
appMap=(appMap_whatsapp appMap_telegram appMap_wikipedia appMap_hianime appMap_googlesearch appMap_pull_requests)
argOne=$1
argTwo=$2

# define function `launchApp` that takes a string `appPath` and opens the app in the browser
launchApp() {
    appPath=$1
    appName=$2
    echo "launching: $appPath"
    google-chrome-stable --app="$appPath"

}

# initialize a var `matches` of type list[{name: string, path: string}]
matches=()

# if `argOne` is one character long, then iterate over `appMap` and find all apps whose name starts with `argOne`
if [[ ${#argOne} -eq 1 ]]; then
    for app in "${appMap[@]}"; do
        declare -n currentApp=$app
        if [[ ${currentApp["name"]:0:1} == $argOne ]]; then
            matches+=("${currentApp["name"]}:${currentApp["path"]}")
        fi
    done
fi

# if `argOne` is equal to g: then launch google search
if [[ $argOne == "g:" ]]; then
    # define variable query to be equal to `argTwo`
    query=$argTwo
    # if `query` is empty then prompt the user to enter a query
    if [[ -z $query ]]; then
        read -p "Enter your search query: " query
    fi
    launchApp "https://www.google.com/search?q=$query"
    exit 0
fi

# if matches length is 1, set `appToLaunch` to the only element in `matches`
if [[ ${#matches[@]} -eq 1 ]]; then
    appPath=$(echo ${matches[0]} | cut -d':' -f2-)
    appName=$(echo ${matches[0]} | cut -d':' -f1)
    launchApp $appPath $appName
    exit 0
fi

# if `matches` is not empty, use fzf to prompt the user to select an app and once they do
# set `appToLaunch` to the selected app
if [[ ${#matches[@]} -ne 0 ]]; then
    selectedApp=$(printf "%s\n" "${matches[@]}" | cut -d':' -f1 | fzf)
    for app in "${matches[@]}"; do
        appName=$(echo $app | cut -d':' -f1)
        appPath=$(echo $app | cut -d':' -f2-)
        if [[ $appName == $selectedApp ]]; then
            launchApp $appPath $appName
            break
        fi
    done
    exit 0
fi

echo "No matched found for $argOne"
