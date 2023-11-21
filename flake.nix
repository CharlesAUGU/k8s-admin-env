{
  description = "k8s-admin-env";
  nixConfig.bash-prompt = "\\[\\e[0m\\][\\[\\e[0;2m\\]nix-develop \\[\\e[0;1m\\]k8s-admin-env \\[\\e[0;93m\\]\\w\\[\\e[0m\\]\\[\\e[0;94m\\]$(__git_ps1)\\[\\e[0m\\]]\\[\\e[0m\\]$ \\[\\e[0m\\]";

  # inputs is an attribute set of all the dependencies of the flake
  inputs = {
    # latest packages list
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # tool that helps having standardized nix flake files
    flake-parts.url = "github:hercules-ci/flake-parts";
    krr = {
      url = "github:robusta-dev/krr";
      flake = false;
    };
    prometrix = {
      url = "github:robusta-dev/prometrix";
      flake = false;
    };
    prometheus-api-client = {
      url = "github:4n4nd/prometheus-api-client-python";
      flake = false;
    };
  };

############################################################################

  # outputs is a function of one argument that takes an attribute set
  # of all the realized inputs, and outputs another attribute set
  # i.e. uses the inputs to build some outputs (packages, apps, shells,..)

  outputs = { self, nixpkgs, flake-parts, krr, prometrix, prometheus-api-client }@inputs:

    # mkFlake is the main function of flake-parts to build a flake with standardized arguments
    flake-parts.lib.mkFlake { inherit self; inherit inputs; } {

      # list of systems to be built upon
      systems = nixpkgs.lib.systems.flakeExposed;

      # make a build for each system
      perSystem = { system, pkgs, lib, config, self', inputs', ... }: {

        packages = {
          # code editor with pre-installed extensions
          vscodium = import ./nix/vscodium.nix { inherit pkgs; };
          # krr and its dependencies
          _krr = import ./nix/krr.nix { inherit pkgs; inherit krr; };
          _prometrix = import ./nix/prometrix.nix { inherit pkgs; inherit prometrix; };
          _prometheus-api-client = import ./nix/prometheus-api-client.nix { inherit pkgs; inherit prometheus-api-client; };
        };

        # Here is the definition of the nix-shell we use for development
        # It comes with all necessary packages + other nice to have tools
        devShells.default = pkgs.mkShell {
              buildInputs = with pkgs; with self'.packages;
                [
                    # Devops #
                    ## Docker ##
                    docker
                    docker-compose
                    lazydocker

                    ## Kubernetes ##
                    ### Managing ###
                    kubectl
                    krew        # kubectl plugins manager
                    kubectx     # command-line tool that allows users to switch between Kubernetes contexts (clusters) and namespaces
                                # https://github.com/ahmetb/kubectx
                    k9s         # terminal-based UI tool that provides a more user-friendly interface for managing Kubernetes clusters
                                # https://github.com/derailed/k9s
                    k8sgpt      # tool for scanning your Kubernetes clusters, diagnosing, and triaging issues in simple English
                                # https://github.com/k8sgpt-ai/k8sgpt
                    minikube
                    helm
                    awscli

                    ### Monitoring ###
                    kubeshark   # wireshark for kubernetes
                                # https://github.com/kubeshark/kubeshark
                    eks-node-viewer # dynamic node usage visualization within a Kubernetes cluster
                                    # https://github.com/awslabs/eks-node-viewer
                    _krr  # CLI tool for optimizing resource allocation in Kubernetes clusters
                          # https://github.com/robusta-dev/krr
                    _prometrix  # krr dependency
                    _prometheus-api-client  # krr dependency

                    ### Security analysis ###
                    rakkess     # understand the privileges each user has across all of the given resources on the cluster
                                # https://github.com/corneliusweig/rakkess
                    kube-score  # static code analysis tool for your Kubernetes manifests objects.
                                # The output is a list of recommendations of what you can improve regarding security and resiliency.
                                # https://github.com/zegl/kube-score
                    kube-bench  # checks whether Kubernetes is deployed securely by running the checks documented in the CIS Kubernetes Benchmark
                                # https://github.com/aquasecurity/kube-bench

                    ### Debugging ###
                    stern       # tool for tailing and filtering logs from multiple Kubernetes pods at the same time.
                                # https://github.com/stern/stern

                    ### Upgrading ###
                    kubepug     # pre-upgrade checker that will help you find deprecated and removed APIs in your Kubernetes
                                # resources before migrating to a new major release
                                # https://github.com/rikatz/kubepug

                    # IDE #
                    vscodium
                    bashInteractive # necessary for vscodium integrated terminal

                    # Utilities #
                    bash-completion
                    jq
                ];
              shellHook = ''
                source <(curl -s https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh);
                source <(kubectl completion bash);
                alias k='kubectl';
                export LANG=C.utf8;
                export KUBECONFIG=$(pwd)/kubeconfig;
                export PATH="$HOME/.krew/bin:$PATH";
                krew install who-can; # command-line tool that helps you determine which users or service accounts;
                                      # have access to specific resources;
                                      # https://github.com/aquasecurity/kubectl-who-can;
                krew install get-all; # list all of the resources (kubectl get all does not...);
                                      # https://github.com/corneliusweig/ketall;
                krew install tree;    # help you to understand the relations between Kubernetes objects in your live cluster;
                                      # https://github.com/ahmetb/kubectl-tree;
                krew install outdated;  # checks if there is an updated version for the used images;
                                        # https://github.com/replicatedhq/outdated;
                krew install cost;    # provides easy CLI access to Kubernetes cost information via Kubecost's APIs;
                                      # https://github.com/kubecost/kubectl-cost;
              '';
            };
      };
    };

############################################################################################

  # nixConfig is an attribute set of values which reflect the values given to nix.conf.
  # This can extend the normal behavior of a user's nix experience by adding flake-specific
  # configuration, such as a binary cache.
  nixConfig = {
    extra-substituers = [
      "https://cache.nixos.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    allow-import-from-derivation = "true";
  };
}
