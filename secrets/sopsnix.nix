# sops-nix: Decrypts and exposes sops secrets. Makes referencing them from the nixos config easy.
# The owner can access them at /run/secrets/$SECRET
{config, ...}: let
  user = "${config.userDefinedGlobalVariables.username}";
in {
  config.sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/home/${user}/.config/keys.txt";
    defaultSopsFormat = "yaml";
    secrets = {
      RESTIC_PASSWORD = {owner = user;};
      ANTHROPIC_API_KEY = {owner = user;};
      OPENAI_API_KEY = {owner = user;};
      OPENROUTER_API_KEY = {owner = user;};
      AWS_ACCESS_KEY = {owner = user;};
      AWS_SECRET_ACCESS_KEY = {owner = user;};
      TWITTER_PASSWORD = {owner = user;};
      TWITTER_CODE = {owner = user;};
      TWITTER_SESSION = {owner = user;};
      "git/USER_NAME" = {owner = user;};
      "git/USER_EMAIL" = {owner = user;};
    };
  };
}
# Imrpovement: Provide the secrets through systemd services
# owner = "secretsService";

