{ pkgs, prometheus-api-client }:
pkgs.python311Packages.buildPythonPackage {
  name = "prometheus-api-client";
  src = prometheus-api-client;
  format = "pyproject";
  buildInputs = with pkgs.python311Packages;
  [
    setuptools
  ];
  propagatedBuildInputs = with pkgs.python311Packages;
  [
    pandas
  ];
}