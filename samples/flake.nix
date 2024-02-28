{
  description = "Python development environment";

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

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            vagrant_env
          ];
        };
      }
    );
}


