{ pkgs, krr }:
pkgs.python311Packages.buildPythonPackage {
  name = "krr";
  src = krr;
  format = "pyproject";
  buildInputs = [
    pkgs.python311Packages.poetry-core
  ];
  propagatedBuildInputs = with pkgs.python311Packages;
  [
    typer
    pydantic
    kubernetes
    rich
    numpy
    slack-sdk
    aiostream
    alive-progress
  ];
}