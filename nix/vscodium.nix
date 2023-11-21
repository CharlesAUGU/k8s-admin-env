{ pkgs }:
pkgs.vscode-with-extensions.override {
  vscode = pkgs.vscodium;
  vscodeExtensions = [
    pkgs.vscode-extensions.bbenoist.nix
    pkgs.vscode-extensions.shardulm94.trailing-spaces
  ];
}