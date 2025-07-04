{
  description = "pawuq nixos utils";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      perSystem = { pkgs, ... }: {
        packages = {
          nixos-switch-remote = pkgs.writeShellScriptBin "nixos-switch-remote" ''
            set -eu
            flake="$1"
            flake_output="$2"
            target_host="$3"
            operation="$4"
            SSH_OPTS="''${SSH_OPTS:-}"

            flake_path="$(${pkgs.nix}/bin/nix flake metadata "$flake" --json | ${pkgs.jq}/bin/jq -r '.path')"
            echo "Flake $flake path is $flake_path"

            ${pkgs.nix}/bin/nix-copy-closure --to "$target_host" "$flake_path"

            echo "$target_host: nixos-rebuild $operation --flake \"$flake_path#$flake_output\""
            ${pkgs.openssh}/bin/ssh -t $SSH_OPTS "$target_host" nixos-rebuild $operation --flake "$flake_path#$flake_output"
          '';
        };
      };
    };
}

