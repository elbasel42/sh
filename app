# ! /bin/zsh

# declare a var `appMap` of type list[map] where `map : {name: string, path: string}`
declare -A appMap_whatsapp=(["name"]="whatsapp" ["path"]="https://web.whatsapp.com")
declare -A appMap_telegram=(["name"]="telegram" ["path"]="https://web.telegram.org")
declare -A appMap_wikipedia=(["name"]="wikipedia" ["path"]="https://www.wikipedia.org")
declare -A appMap_googlemeet=(["name"]="googlemeet" ["path"]="https://meet.google.com")
declare -A appMap_hianime=(["name"]="hianime" ["path"]="https://hianime.to/most-popular")
appMap=(appMap_whatsapp appMap_telegram appMap_wikipedia appMap_googlemeet appMap_hianime)

# define function `launchApp` that takes a string `appPath` and opens the app in the browser
launchApp() {
    appPath=$1
    appName=$2
    echo "launching: $appPath"
    google-chrome-stable --app="$appPath"

}

argOne=$1

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
