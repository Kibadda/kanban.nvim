{
  description = "Simple kanban board";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    plugin-overlay = final: prev: {
      kanban-nvim = (final.pkgs.vimUtils.buildVimPlugin {
        name = "kanban.nvim";
        src = self;
      }).overrideAttrs {
        doCheck = false;
      };
    };

    supportedSystems = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          plugin-overlay
        ];
      };
    in {
      packages = rec {
        default = kanban-nvim;
        inherit (pkgs) kanban-nvim;
      };
    })
    // {
      overlays.default = plugin-overlay;
    };
}
