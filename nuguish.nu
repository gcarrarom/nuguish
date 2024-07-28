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
export def mkdircd [
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
export alias wifi = networksetup -setairportpower en0
export alias openfirefox = xargs -I {} open -a "Firefox" -g "{}"

export alias fzfbat = fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'  --bind $"enter:become\(($env.EDITOR) {1} +{2})"

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

### Get output type for kubernetes memory output
def memoryoutput [] {
    [
        "G"
        "Gi"
        "M"
        "Mi"
        "K"
        "Ki"
    ]
}

# ### convert kubernetes memory into proper values
# def convertk8smemory [
#     kubernetes_memory: string
#     output_format: string@memoryoutput = G
# ] {
#     if ($kubernetes_memory =~ "G") {
#         if ($kubernetes_memory =~ "Gi") {
#             let memory_before_conversion = (echo $kubernetes_memory | sed 's/Gi//g' | into int)
#             let kubernetes_total_meory = ($memory_before_conversion * 1024 * 1024 * 1024 | into int | into int)
#         } else {
#             let memory_before_conversion = (echo $kubernetes_memory | sed 's/G//g' | into int)
#             let kubernetes_total_memory = ($memory_before_conversion * 1000 * 1000 * 1000 | into int | into int)
#         }
#     } else if ($kubernetes_memory =~ "M") {
#         if ($kubernetes_memory =~ "Mi") {
#             let memory_before_conversion = (echo $kubernetes_memory | sed 's/Mi//g' | into int)
#             let kubernetes_total_memory = ($memory_before_conversion * 1024 * 1024  | into int)
#         } else {
#             let memory_before_conversion = (echo $kubernetes_memory | sed 's/M//g' | into int)
#             let kubernetes_total_memory = ($memory_before_conversion * 1000 * 1000  | into int)
#         }
#     } else {
#         if ($kubernetes_memory =~ "K") {
#             let memory_before_conversion = (echo $kubernetes_memory | sed 's/Ki//g' | into int)
#             let kubernetes_total_memory = ($memory_before_conversion * 1024  | into int)
#         } else {
#             let memory_before_conversion = (echo $kubernetes_memory | sed 's/K//g' | into int)
#             let kubernetes_total_memory = ($memory_before_conversion * 1000  | into int)
#         }
#     }


#     if ($output_format == "G") {
#         $kubernetes_total_memory / (1000 * 1000 * 1000)
#     } 
#     else if ($output_format == "Gi") {
#         $kubernetes_total_memory / (1024 * 1024 * 1024)
#     } 
#     else if ($output_format == "M") {
#         $kubernetes_total_memory / (1000 * 1000)
#     } 
#     else if ($output_format == "Mi") {
#         $kubernetes_total_memory / (1024 * 1024)
#     } 
#     else if ($output_format == "K") {
#         $kubernetes_total_memory / (1000)
#     } 
#     else if ($output_format == "Ki") {
#         $kubernetes_total_memory / (1024)
#     } 

# }

# def convertk8scpu [
#     cpu_kubernetes: string
# ] {
#     if ($cpu_kubernetes =~ "m" ) {
#         let new_cpu_value = (echo $cpu_kubernetes | sed 's/m//g' | into int)
#     } else {

#         let new_cpu_value = (($cpu_kubernetes | into int) * 1000 | into int)
#     }
#     echo $new_cpu_value
# }

def available_namespaces [] {
    kubectl get namespaces | from ssv | get name
}

export def kreportns [
    namespace?: string@available_namespaces
] {
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
] {
    if ($namespace != null) {
        kubectl get pods -n $namespace | from ssv | get name
    } else {
        kubectl get pods | from ssv | get name
    }
}

export def kgp [
    --namespace (-n): string@available_namespaces
    --all (-a)
] {
    if ($all) {
        kubectl get pods --all-namespaces | from ssv
    } else if ($namespace != null) {
        kubectl get pods -n $namespace | from ssv
    } else {
        kubectl get pods | from ssv
    }
}


export def ktp [
    --namespace (-n): string@available_namespaces
] {
    if ($namespace != null) {
        kubectl top pods -n $namespace | from ssv
    } else {
        kubectl top pods | from ssv
    }
}

export def ktno [] {
    kubectl top nodes | from ssv
} 

export def kreport [] {
    let topnoderesults = (kubectl top nodes | from ssv)
    let allpods = (kubectl get pods --all-namespaces | from ssv)
    let nodeinformation = (kubectl get nodes -o json | from json)

    let numallpods = (echo $allpods | length)
    let numsystempods = (echo $allpods | where "NAMESPACE" == "kube-system" | length)
    let numpodsnotsystem = (echo $allpods | where "NAMESPACE" != "kube-system" | length)
    let cpupercent = (echo $topnoderesults | get "CPU%" | split column "%" | get column1 | into int | math avg)
    let mempercent = (echo $topnoderesults | get "MEMORY%" | split column "%" | get column1 | into int | math avg)
    let cpunum = (echo $topnoderesults | get "CPU(cores)" | split column "m" | get column1 | into int | math avg)
    let memnum = (echo $topnoderesults | get "MEMORY(bytes)" | split column "M" | get column1 | into int | math avg)
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
export alias klf = kubectl logs -f
export alias kgpall = kgp --all
export alias kdelp = kubectl delete pod
export alias kdelns = kubectl delete namespace
export alias kdelpall = kubectl delete pods --all
export alias kds = kubectl describe service
export alias kdp = kubectl describe pod
export alias kdno = kubectl describe node
export alias keti = kubectl exec -ti
export alias kgpwatch = viddy --shell nu "kubectl get pods | from ssv"
export alias ktpwatch = viddy --shell nu "kubectl top pods | from ssv"
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

export def --wrapped gitc [ profile_name: any url: any ...args] {
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
    cd ..

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
