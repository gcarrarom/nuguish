# NuGUIsh

This is the nuguish module. It implements some of the [oh-my-guish](https://github.com/gcarrarom/oh-my-guish) commands for [NuShell](https://www.nushell.sh/).

## Installation

The installation of this module depends on a working installation of NuShell. Please refer to the [NuShell installation instructions](https://www.nushell.sh/install.html) for more information.

It also depends on adding a new modules path to the NuShell configuration. You can do this by adding the following line to your `env.nu` file: ($nu.env-path)

```shell
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.default-config-dir | path join 'modules') # add <nushell-config-dir>/modules <- this line
```

Then you should be able to clone your modules (including this one) to the `modules` directory and add the nuguish module to your NuShell configuration file.

```shell
git clone https://github.com/gcarrarom/nuguish.git ($nu.default-config-dir | path join modules/nuguish)
echo "use modules/noguish/nuguish.nu *\n" | save --append $nu.config-path
```

## Updates

To update the module, you can simply pull the changes from the repository and restart NuShell.

```shell
cd ($nu.default-config-dir | path join modules/nuguish)
git pull
```
