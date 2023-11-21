# k8s-admin-env >> WIP
A local "plug & play" dev env to administer Kubernetes clusters. Enter a nix-shell (containerized environment) with pre-installed tools, you don't need to install anything on your computer except Nix.

You can take a look at the [flake.nix](flake.nix) file to see what tools are being installed. You can add other tools in the `buildInputs` and relaunch the shell to install it (a lot of tools are present in the Nix package repository, if your tool is not you may have to build it by yourself which can be a bit tricky if you don't have any experience with Nix).

## Prerequisites
Install [Nix package manager](https://nixos.org/download).

## Starting
Clone the repository and simply type the following to enter the dev env :
```shell
user@machine ~/k8s-admin-env (main)> nix develop
```
