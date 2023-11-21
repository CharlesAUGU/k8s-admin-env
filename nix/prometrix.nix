{ pkgs, prometrix }:
pkgs.python311Packages.buildPythonPackage {
  name = "prometrix";
  src = prometrix;
  format = "pyproject";
  buildInputs = [
    pkgs.python311Packages.poetry-core
  ];
}