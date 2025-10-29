{
  description = "Elixir 1.19.1 with Erlang OTP 28";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Build Elixir 1.19.1 from source
        elixir_1_19 = pkgs.beam.packages.erlang.elixir.overrideAttrs (oldAttrs: rec {
          version = "1.19.1";
          src = pkgs.fetchFromGitHub {
            owner = "elixir-lang";
            repo = "elixir";
            rev = "v${version}";
            sha256 = "sha256-0rJx1BoJGDS0FsXyngBfQL3LhhNZvwh+TLQZjqOPFQw=";
          };
        });
      in {
        packages = {
          elixir = elixir_1_19;
          erlang = pkgs.beam.interpreters.erlang;
        };
      }
    );
}
