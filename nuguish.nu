# Git
## git commands

### Shows the sha of the last commit by default, or the last n commits
export def glc [n?: int] [nothing -> string] {
    if $n == null {
        git log --oneline | head -n 2 | tail +2 | cut -d " " -f 1
    } else {
        git log --oneline | head -n (2 + $n) | tail +(2 + $n) | cut -d " " -f 1
    }
}

### Resets the current branch to the last nth commit
export def grw [n?: int] {
    git reset --hard (glc $n)
}

# Docker
## Docker commands

### Builds the docker image and runs it
export def "dbd" [
    --port (-p): string = '8080:8080' # The port mapping for the container on run (8080:8080)
    --tag (-t): string = 'nuguish' # The tag to be used on the build of the image
    --name: string = 'nuguish' # The name of the container to run
    --volume: string # the mapping for the container runtime to bind into a volume (i.e.: ./something:/app/)
    path: path # The path of the context to run docker build on
] {
    let buildhash = (docker build -t $tag $path | tail -1 | cut -d " " -f 3 )
    if $volume == null {
        echo $"docker run --name ($name) -t ($tag) -p ($port) "
    } else {
        echo $"docker run -v ($volume) --name ($name) -t ($tag) -p ($port) "
    }
}

# System
## System commands

### Create directory and cd into it
export def --env mkdircd [
    path: path # path to be generated and cd'd into
] {
    if ((echo $path | path type) == 'dir') {
        error make {msg: "the path already exists"}
    }
    mkdir $path
    cd $path
}

## System Aliases

### MacOS

# Turns on/off the wifi - on by default
export def wifi [
    interface?: string = 'en0' # The interface to be used for the wifi command; defaults to en0
    --off # Turn off the wifi
] {
    if $off {
        networksetup -setairportpower $interface off
    } else {
        networksetup -setairportpower $interface on
    }
}

export alias openfirefox = xargs -I {} open -a "Firefox" -g "{}"

# (https://github.com/nushell/nushell/issues/5068)
export alias fzfbat = fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'  --bind $"enter:become\(($env.EDITOR) {1} +{2})"

### Zoxide
# (https://github.com/nushell/nushell/issues/5068)
# export alias cd = z # I really don't like I can't use if statements in this file... I'll have to find a way to make this work - Disabled by default now though 

### NMAP
export alias nmap_check_for_firewall = sudo nmap -sA -p1-65535 -v -T4
export alias nmap_check_for_vulns = nmap --script=vuln
export alias nmap_detect_versions = sudo nmap -sV -p1-65535 -O --osscan-guess -T4 -Pn
export alias nmap_fast = nmap -F -T5 --version-light --top-ports 300
export alias nmap_fin = sudo nmap -sF -v
export alias nmap_full = sudo nmap -sS -T4 -PE -PP -PS80,443 -PY -g 53 -A -p1-65535 -v
export alias nmap_full_udp = sudo nmap -sS -sU -T4 -A -v -PE -PS22,25,80 -PA21,23,80,443,3389 
export alias nmap_full_with_scripts = sudo nmap -sS -sU -T4 -A -v -PE -PP -PS21,22,23,25,80,113,31339 -PA80,113,443,10042 -PO --script all 
export alias nmap_list_interfaces = nmap --iflist
export alias nmap_open_ports = nmap --open
export alias nmap_ping_scan = nmap -n -sP
export alias nmap_ping_through_firewall = nmap -PS -PA
export alias nmap_slow = sudo nmap -sS -v -T1
export alias nmap_traceroute = sudo nmap -sP -PE -PS22,25,80 -PA21,23,80,3389 -PU -PO --traceroute 
export alias nmap_web_safe_osscan = sudo nmap -p 80,443 -O -v --osscan-guess --fuzzy 

### Generate a random "dockerlike" name
export alias randomdocker = http get https://frightanic.com/goodies_content/docker-names.php


# Kubernetes

def available_namespaces []: nothing -> string {
    kubectl get namespaces | from ssv | get name
}

export def kubens [
    namespace?: string@available_namespaces
] {
    if ($namespace == null) {
        ^kubens
    } else {
        ^kubens $namespace
    }
}

def kube_contexts []: nothing -> string {
    kubectl config get-contexts | from ssv | get name
}

export def kubectx [
    context?: string@kube_contexts
] {
    if ($context == null) {
        ^kubectx
    } else {
        ^kubectx $context
    }
}

export def kreportns [
    namespace?: string@available_namespaces
]: [string -> string, nothing -> string] {
    mut toppodsresults = ""
    if ($namespace != null) {
        $toppodsresults = (kubectl top pods -n $namespace)
    } else {
        $toppodsresults = (kubectl top pods )
    }

    let avgcpu = echo $toppodsresults | from ssv | get "CPU(cores)" | split column "m" | get column1 | into int | math avg
    let totalcpu = echo $toppodsresults | from ssv | get "CPU(cores)" | split column "m" | get column1 | into int | math sum
    let avgmem = echo $toppodsresults | from ssv | get "MEMORY(bytes)" | split column "M" | get column1 | into int | math avg
    let totalmem = echo $toppodsresults | from ssv | get "MEMORY(bytes)" | split column "M" | get column1 | into int | math sum

    echo $'([
        ["Metric" "Value"];
        ["Total Memory (MB)" $totalmem]
        ["Total CPU (mCPU)" $totalcpu]
    ] | table -i false)
([
        ["Metric" "Value"];
        ["Average Memory (MB)" $avgmem]
        ["Average CPU (mCPU)" $avgcpu]
    ] | table -i false)'
}

export def pod_names [
    namespace?: string@available_namespaces
]: [string -> string, nothing -> string] {
    if ($namespace != null) {
        kubectl get pods -n $namespace | from ssv | get name
    } else {
        kubectl get pods | from ssv | get name
    }
}


export def kreport [] {
    # getting data from K8s
    let topnoderesults = (kubectl top nodes | from ssv)
    let allpods = (kubectl get pods --all-namespaces | from ssv)
    let nodeinformation = (kubectl get nodes -o json | from json)

    # transforming data
    let numallpods = (echo $allpods | length)
    let numsystempods = (echo $allpods | where "NAMESPACE" == "kube-system" | length)
    let numpodsnotsystem = (echo $allpods | where "NAMESPACE" != "kube-system" | length)
    let cpupercent = (echo $topnoderesults | get "CPU%" | split column "%" | get column1 | into int | math avg)
    let mempercent = (echo $topnoderesults | get "MEMORY%" | split column "%" | get column1 | into int | math avg)
    let cpunum = (echo $topnoderesults | get "CPU(cores)" | split column "m" | get column1 | into int | math avg)
    let memnum = (echo $topnoderesults | get "MEMORY(bytes)" | split column "M" | get column1 | into int | math avg)
    let totalcpu = (echo $nodeinformation | get items.status.capacity.cpu | math sum)
    let totalmemory = ((echo $nodeinformation | get items.status.capacity.memory | split column "K" | into int | math sum) / (1024 * 1024))
    let numnodes = (echo $topnoderesults | length)
    let cpuinuse = ($totalcpu * $cpupercent / 100)
    let mcpuinuse = ($totalcpu * 1000 * $cpupercent / 100)
    let memoryinuse = ($totalmemory * $mempercent / 100)
    let memoryinusemb = ($totalmemory * 1024 * $mempercent / 100)

    let totalcpu = (echo $nodeinformation | get items.status.capacity.cpu | into int | math sum)
    let totalmemory = ((echo $nodeinformation | get items.status.capacity.memory | split column "K" | values | first | into int | math sum) / (1024 * 1024))
    let numnodes = (echo $topnoderesults | length)
    let cpuinuse = ($totalcpu * $cpupercent / 100)
    let mcpuinuse = ($totalcpu * 1000 * $cpupercent / 100)
    let memoryinuse = ($totalmemory * $mempercent / 100)
    let memoryinusemb = ($totalmemory * 1024 * $mempercent / 100)

    let table1 = [
        ["Metric", "Value"];
        ["# All Pods", $numallpods]
        ["# Pods in kube-system", $numsystempods]
        ["# Pods elsewhere", $numpodsnotsystem]
        ["# Nodes", $numnodes]
    ] | table -i false

    let table2 = [
        ["Metric", "Value"];
        ["Total CPU", $totalcpu]
        ["Total Memory (GB)", ($totalmemory | math round)]
        ["CPU per Node", ($totalcpu / $numnodes)]
        ["Memory per Node", ($totalmemory / $numnodes | math round)]
    ] | table -i false

    let table3 = [
        ["Metric", "Value"];
        ["# CPU in use (approx.)", ($cpuinuse | math round)]
        ["Memory in use (GB)", ($memoryinuse | math round)]
        ["mCPU/POD", (($mcpuinuse / $numallpods) | math round)]
        ["Memory (MB)/POD", (($memoryinusemb / $numallpods) | math round)]
        ["CPU avg (mCPU)", ($cpunum | math round)]
        ["RAM avg (MB)", ($memnum | math round)]
    ] | table -i false

    echo $"($table1)
($table2)
($table3)"
}

## kubernetes aliases

export alias kubectl = kubecolor

### logs
export alias kl = kubectl logs
export alias klf = kubectl logs -f

### Pods
export alias kgp = kubectl get pods
export alias kgpall = kgp --all
export alias kdelp = kubectl delete pod
export alias kdelpall = kubectl delete pods --all
export alias kdp = kubectl describe pod
export alias ktp = kubectl top pods
export alias kgpwatch = viddy --shell nu "kubectl get pods | from ssv"
export alias ktpwatch = viddy --shell nu "kubectl top pods | from ssv"
export alias kep = kubectl edit pod

### Ingress
export alias kgi = kubectl get ingress
export alias kdeli = kubectl delete ingress
export alias kdi = kubectl describe ingress
export alias kgiall = kgi --all
export alias kdi = kubectl describe ingress
export alias kei = kubectl edit ingress

### Exec
export alias keti = kubectl exec -ti

### Namespace
export alias kdelns = kubectl delete namespace
export alias kgns = kubectl get namespaces
export alias kdns = kubectl describe namespace
export alias kcns = kubectl create namespace
export alias kens = kubectl edit namespace

### ConfigMap
export alias kgcm = kubectl get configmap
export alias kdelcm = kubectl delete configmap
export alias kdcm = kubectl describe configmap
export alias kccm = kubectl create configmap
export alias kgcmjson = kgcm -o json
export alias kgcmyaml = kgcm -o yaml
export alias kecm = kubectl edit configmap

### Secrets
export alias kgsec = kubectl get secrets
export alias kdelsec = kubectl delete secrets
export alias kdsec = kubectl describe secrets
export alias kcsec = kubectl create secrets
export alias kesec = kubectl edit secrets

### Services
export alias kds = kubectl describe service
export alias kgs = kubectl get services
export alias kgsall = kgs --all
export alias kdsall = kubectl describe services --all
export alias kgsjson = kgs -o json
export alias kgsjsonall = kgsall -o json
export alias kgswatch = viddy --shell nu "kubectl get services | from ssv"
export alias kes = kubectl edit service

### Nodes
export alias kdno = kubectl describe node
export alias ktn = kubectl top nodes
export alias ktnowatch = viddy --shell nu "kubectl top nodes | from ssv"


# Azure
## Azure commands

def azure_accounts [] {
    az account list -o json | from json | get name
}

export def azacc [
    name?: string@azure_accounts
] {
    mut account_name = ""
    if ($name == null) {
        $account_name = (az account list -o json | from json | get name | input list --fuzzy "Select an account")
    } else {
        $account_name = $name
    }

    az account set --subscription $account_name
}

def azure_groups [] {
    az group list -o json | from json | get name
}

export def azgroup [
    name?: string@azure_groups
] {
    mut group_name = ""
    if ($name == null) {
        $group_name = (az group list -o json | from json | get name | input list --fuzzy "Select a Resource Group")
    } else if ($name != "all") {
        $group_name = $name
    }

    az configure --defaults $"group=($group_name)"
}

# Git 

## Aliases
export alias gl = git pull
export alias gp = git push
export alias gaa = git add --all
export alias gc = git commit -m
export alias gcm = git commit -m
export alias gco = git checkout
export alias gcb = git checkout -b
export alias gs = git status
export alias gst = git status
export alias gss = git status -s
export alias gcam = git commit -am

## Functions

def get_profile_config_path [] {
    return ($nu.home-path | path join ".git_profiles.yml")
}

def get_profile_config [
    path: path = get_profile_config_path
] {
    let YAML_FILE = get_profile_config_path
    if not ($YAML_FILE | path exists) {
        echo $"Creating file ($YAML_FILE)"
        echo "profiles: {}" | save -f $YAML_FILE
    }
    return (open ($nu.home-path | path join ".git_profiles.yml"))
}

export def "git profile list" [] {
    let config = get_profile_config
    echo $config.profiles | transpose key value | each {|record| [["Profile", "Name", "Email"]; [$record.key, $record.value.user.name, $record.value.user.email]] } | flatten
}

def gitprofiles [] {
    let config = get_profile_config
    return ($config | get profiles | transpose key value | get key)
}

export def "git profile remove" [
    profile_name: string@gitprofiles # The name of the profile to be removed
] {
    let YAML_FILE = get_profile_config_path
    let config = get_profile_config

    if not ($profile_name in $config.profiles) {
        error make {msg: "Profile does not exist"}
    }

    let new_profiles = ($config | get profiles | reject $profile_name)
    let $new_config = $config | upsert profiles $new_profiles
    echo $new_config | to yaml | save -f $YAML_FILE
    echo $"Profile '($profile_name)' removed from ($YAML_FILE)" | ansi gradient --fgstart '0x40c9ff' --fgend '0xe81cff'
}

export def "git profile set" [
    profile_name: string # The name of the profile to be added
    name: string # The name of the user
    email: string # The email of the user
] {

    let YAML_FILE = get_profile_config_path
    let config = get_profile_config

    echo "Adding profile '($profile_name)' to ($YAML_FILE)"


    let new_profiles = ($config | get profiles | upsert $profile_name {user: {name: $name, email: $email}})
    let $new_config = $config | upsert profiles $new_profiles
    echo $new_config | to yaml | save -f $YAML_FILE
    echo $"Profile '($profile_name)' added to ($YAML_FILE)" | ansi gradient --fgstart '0x40c9ff' --fgend '0xe81cff'
}

export def "git profile add" [
    profile_name: string # The name of the profile to be added
    name: string # The name of the user
    email: string # The email of the user
] {

    let YAML_FILE = get_profile_config_path
    let config = get_profile_config

    if ($profile_name in $config.profiles) {
        error make {msg: "Profile already exists"}
    }
    echo "Adding profile '($profile_name)' to ($YAML_FILE)"


    let new_profiles = ($config | get profiles | upsert $profile_name {user: {name: $name, email: $email}})
    let $new_config = $config | upsert profiles $new_profiles
    echo $new_config | to yaml | save -f $YAML_FILE
    echo $"Profile '($profile_name)' added to ($YAML_FILE)" | ansi gradient --fgstart '0x40c9ff' --fgend '0xe81cff'
}

export def --wrapped gitc [ 
    profile_name: string@gitprofiles # The name of the profile to be used 
    url: any ...args
] {
    let YAML_FILE = ($nu.home-path | path join ".git_profiles.yml")

    # Clone the repository with provided arguments
    git clone $url ...$args

    # Extract the repository name from the URL
    let repo_name = ($url | path basename | into string | str replace ".git" "")
    mut last_arg = ""
    # Determine if a custom path argument is provided
    if (($args | length) > 0) {
        $last_arg = ($args | last)
    }

    sleep  2sec

    # Initialize repo_path to default repo_name
    mut repo_path = $repo_name

    # Check if last argument is a valid path
    if ($last_arg | path exists) {
        $repo_path = $last_arg
    }
    # Read and parse the YAML file for the profile details
    let config = (open ($nu.home-path | path join .git_profiles.yml))

    # Look up the Git configuration details from the parsed
    let name = ($config.profiles | get $profile_name | get user | get name)
    let email = ($config.profiles | get $profile_name | get user | get email)

    if ($name == "" or $email == "") {
        echo $"Incomplete configuration for profile '($profile_name)' in ($YAML_FILE)"
        return
    }

    # Set the Git configuration for the cloned repository
    cd $repo_path
    git config user.name $name
    git config user.email $email

    echo $"Repository cloned and Git user configuration set for profile: ($profile_name)" | ansi gradient --fgstart '0x40c9ff' --fgend '0xe81cff'
}

# gently try to delete merged branches, excluding the checked out one
export def ggdb [] {
    git branch --merged | lines | where $it !~ '\*' | str trim | where $it != 'master' and $it != 'main' | each { |it| git branch -d $it }
}

### Git Add Commit Push
export def gacp [
    message: string # The commit message
] {
    git add --all; git commit -m $message; git push
}

### Git checkout worktree on the same parent folder
export def gcow [
    branch: string # The branch to checkout
] {
    # Get the parent folder of the current git repository
    let parent = (git rev-parse --show-toplevel | path dirname)
    # Get the name of the remote repository
    let remote_name = (git remote get-url origin | split column "/" | get column2 | split column "." | get column1 | to text)
    # Generate the name of the folder for the worktree to be created
    let worktree_name = (echo $"($remote_name)-($branch)" | str replace "/" "-")
    git worktree add ($parent | path join $worktree_name) $"origin/($branch)"
}
