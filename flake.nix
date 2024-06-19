{
  description = "A personal website to jot down thoughts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    anemone-theme = {
      url = "github:Speyll/anemone";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, anemone-theme}: #{
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
	themeName = ((builtins.fromTOML (builtins.readFile "${anemone-theme}/theme.toml")).name);
      in {
        # derivation for building the website
        packages.website = pkgs.stdenv.mkDerivation rec {
          pname = "static-website";
          version = "0.0.1";
          src = builtins.path { path = ./.; name = "ngildenhuys.github.io";};
          nativeBuildInputs = [pkgs.zola];
	  configurePhase =''
	    mkdir -p themes/${themeName}
	    cp -r ${anemone-theme}/* "themes/${themeName}"
	  '';
          buildPhase = "zola build";
          installPhase = "cp -r public $out";
        };

        # output package of the nix flake
        defaultPackage = self.packages.${system}.website;

	# development environment
        devShell = pkgs.mkShell  {
          packages = with pkgs; [
            zola
          ];
	  shellHook = ''
	    mkdir -p themes
	    ln -sn "${anemone-theme}" "themes/${themeName}"
	  '';
        };
      }
    );
  #}
}
