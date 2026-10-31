{ pkgs ? import <nixpkgs> {} }:

let
  nixpkgs = import (builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs";
    ref = "nixos-unstable";
  }) { };

  wordcraftSrc = pkgs.lib.cleanSource ./.;

  vendorHashes = nixpkgs.runCommand "vendor-hashes" {
    buildInputs = [ nixpkgs.cargo nixpkgs.rustc nixpkgs.nix ];
    src = wordcraftSrc;
    CARGO_HOME = "$(pwd)/.cargo-home";
  } ''
    set -eu
    export CARGO_HOME="$(pwd)/.cargo-home"
    mkdir -p "$CARGO_HOME"
    cp -r $src/* .
    cargo vendor --locked --versioned-dirs vendor
    echo "{" > $out/hashes.nix
    for crate in vendor/*/; do
      name=$(basename "$crate")
      if [ -f "$crate/.cargo-checksum.json" ]; then
        hash=$(nix hash path "$crate" --base32 --truncate 2>/dev/null || nix hash path "$crate" --base32)
        echo "  \"$name\" = \"$hash\";" >> $out/hashes.nix
      fi
    done
    echo "}" >> $out/hashes.nix
  '';

in vendorHashes
