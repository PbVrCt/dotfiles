{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  # inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

  inputs.sops-nix.url = "github:mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {...} @ inputs: {
    specialArgs = {inherit inputs;};
    nixosConfigurations = {
      thinkpad = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./base.nix
          ./private.nix
          inputs.sops-nix.nixosModules.sops
          ./hosts/thinkpad/hardware-configuration.nix
          ./hosts/thinkpad/intel.nix
        ];
      };
      lifebook = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./base.nix
          inputs.sops-nix.nixosModules.sops
          ./hosts/lifebook/hardware-configuration.nix
          ./hosts/lifebook/intel.nix
        ];
      };
      pc = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./base.nix
          inputs.sops-nix.nixosModules.sops
          ./hosts/pc/hardware-configuration.nix
          ./hosts/pc/nvidia.nix
          ./hosts/pc/amd.nix
        ];
      };
    };
  };
}
