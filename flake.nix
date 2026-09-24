{
  description = "NixOS Configuration with Niri, Stylix, and Dank Material Shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pixie-sddm = {
      url = "github:xCaptaiN09/pixie-sddm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # opencode CLI pinned to a known-good commit. Main nixpkgs' opencode
    # is broken, so this stays pinned on purpose — do NOT make it follow
    # nixpkgs or `rainbow update` will break it again.
    opencode-pin = {
      url = "github:NixOS/nixpkgs/590d72952b052366ecf4060c8bf711d7f2b0d249";
    };
  };

  outputs = { self, nixpkgs, home-manager, stylix, ... }@inputs:
  let
    system = "x86_64-linux";
    vars = import ./variables.nix;
  in {
    nixosConfigurations.${vars.hostname} = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs vars;
      };
      modules = [
        ./hosts/nixos
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = {
            inherit inputs vars;
          };
          home-manager.users.${vars.username} = import ./modules/home;
        }
      ];
    };
  };
}
