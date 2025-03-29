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
          ./hardware/modules/intel_hardware_decoding.nix
        ];
      };
      lifebook = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./base.nix
          inputs.sops-nix.nixosModules.sops
          ./hardware/lifebook/hardware-configuration.nix
          ./hardware/modules/intel_hardware_decoding.nix
        ];
      };
      pc = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./base.nix
          inputs.sops-nix.nixosModules.sops
          ./hardware/pc/hardware-configuration.nix
          # ./hardware/modules/amd.nix
          ./hardware/nvidia.nix
        ];
      };
    };
  };
}
