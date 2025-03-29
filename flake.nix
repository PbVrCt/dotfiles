{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {...} @ inputs: {
    specialArgs = {inherit inputs;};
    nixosConfigurations = {
      thinkpad = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./base.nix
          inputs.sops-nix.nixosModules.sops
          ./hardware/thinkpad/hardware-configuration.nix
          ./hardware/intel.nix
        ];
      };
      lifebook = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./base.nix
          inputs.sops-nix.nixosModules.sops
          ./hardware/lifebook/hardware-configuration.nix
          ./hardware/intel.nix
        ];
      };
      pc = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./base.nix
          inputs.sops-nix.nixosModules.sops
          ./hardware/pc/hardware-configuration.nix
          ./hardware/nvidia.nix
          ./hardware/amd.nix
        ];
      };
    };
  };
}
