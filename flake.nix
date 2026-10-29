{
  description = "WordCraft development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          rustc
          cargo
          rustfmt
          clippy
          pkg-config
          clang
          cmake
          wayland
          libxkbcommon
          fontconfig
          freetype
          vulkan-loader
          libGL
        ];

        shellHook = ''
          export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
            pkgs.wayland
            pkgs.libxkbcommon
            pkgs.fontconfig
            pkgs.freetype
            pkgs.vulkan-loader
            pkgs.libGL
          ]}:''${LD_LIBRARY_PATH:-}"
        '';
      };
    };
}
