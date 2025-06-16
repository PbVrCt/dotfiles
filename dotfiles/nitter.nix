{config, ...}: {
  services.nitter = {
    enable = true;
    sessionsFile = config.sops.secrets."TWITTER_SESSION".path;
    server.port = 8081;
    preferences = {
      replaceYouTube = "youtube.com";
      replaceTwitter = "x.com";
    };
  };
}
