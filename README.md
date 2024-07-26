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

Then you should be able to clone your modules (including this one) to the `modules` directory.

```shell
git clone github.com/gcarrarom/nuguish $nu.default-config-dir/modules/nuguish
```

Now you can add the nuguish module to your NuShell configuration file. You can do this by adding the following line to your `config.nu` file: ($nu.config-path)

```shell
use nuguish *
```
