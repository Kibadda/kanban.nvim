{
  description = "Simple kanban board";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    plenary-nvim = {
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      plenary-nvim,
      ...
    }:
    let
      plugin-overlay = final: prev: {
        plenary-nvim =
          (final.pkgs.vimUtils.buildVimPlugin {
            name = "plenary.nvim";
            src = plenary-nvim;
          }).overrideAttrs
            {
              nvimSkipModule = [
                "plenary._meta._luassert"
                "plenary.neorocks.init"
              ];
            };

        kanban-nvim =
          (final.pkgs.vimUtils.buildVimPlugin {
            name = "kanban.nvim";
            src = self;
          }).overrideAttrs
            {
              dependencies = [ final.plenary-nvim ];
            };
      };

      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            plugin-overlay
          ];
        };
      in
      {
        packages = rec {
          default = kanban-nvim;
          inherit (pkgs) kanban-nvim;
        };
      }
    )
    // {
      overlays.default = plugin-overlay;
    };
}
