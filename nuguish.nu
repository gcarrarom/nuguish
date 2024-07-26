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
    let avgmem = echo $toppodsresults | from ssv | get "MEMORY(bytes)" | split column "M" | get column1 | into int| math avg
    let totalmem = echo $toppodsresults | from ssv | get "MEMORY(bytes)" | split column "M" | get column1 | into int| math sum

    echo $"
    NS TOTAL USAGE:
    Memory \(MB) = ($totalmem)
    CPU \(mCPU)  = ($totalcpu)

    NS AVG USAGE:
    Memory \(MB) = ($avgmem)
    CPU \(mCPU)  = ($avgcpu)
    "
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

    # output
    echo "
    #all pods:              $numallpods
    #pods in kube-system:   $numsystempods
    #pods elsewhere:        $numpodsnotsystem
    #nodes:                 $numnodes

    Total CPU:              $totalcpu
    Total Memory(GB):       $totalmemory
    CPU per Node:           $(echo $totalcpu / $numnodes | bc)
    Memory per Node:        $(echo $totalmemory / $numnodes | bc)

    CPU in use:             $cpuinuse
    Memory in use(GB):      $memoryinuse

    mCPU/POD:               $(echo $mcpuinuse / $numallpods | bc)
    Memory(MB)/POD:         $(echo $memoryinusemb / $numallpods | bc)

    CPU avg(m cpu): $cpunum = $cpupercent%
    RAM avg(MB): $memnum = $mempercent%"

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
export alias gss = git status -s
export alias gcam = git commit -am


## Functions

### Git Add Commit Push
export def gacp [
    message: string # The commit message
] {
    git add --all ; git commit -m $message; git push
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
    git worktree add -b $branch ($parent | path join $worktree_name) origin/$branch
}