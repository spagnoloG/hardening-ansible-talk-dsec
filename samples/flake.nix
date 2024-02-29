{
  description = "Vagrant environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [];
        };
        
        vagrant_env = with pkgs; [
          vagrant
        ];

        vagrantPlugins = [
            "vagrant-hostsupdater"
            "vagrant-netinfo"
        ];


        # Create a shellHook to install the Vagrant plugins
        setupVagrantPlugins = pkgs.lib.concatMapStrings (plugin: ''
          if ! vagrant plugin list | grep -q ${plugin}; then
            echo "Installing Vagrant plugin: ${plugin}"
            vagrant plugin install ${plugin}
          else
            echo "Vagrant plugin ${plugin} is already installed."
          fi
        '') vagrantPlugins;

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = vagrant_env;

          shellHook = setupVagrantPlugins;
        };
      }
    );
}

