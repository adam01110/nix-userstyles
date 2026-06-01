{userStyles}: let
  inherit
    (builtins)
    # keep-sorted start
    filter
    head
    isString
    # keep-sorted end
    ;

  userStyleDefaults = {
    defaultSites = true;
    sites = [];
  };

  normalizeUserStyle = userStyle:
    if isString userStyle
    then userStyleDefaults // {name = userStyle;}
    else
      userStyleDefaults
      // userStyle
      // {
        name = userStyle.name or (throw "userStyle attrsets must set `name`");
      };

  userStyleConfigs = map normalizeUserStyle userStyles;

  catppuccinStyleConfigs = filter (style: style.name != "discord") userStyleConfigs;
  discordStyleConfigs = filter (style: style.name == "discord") userStyleConfigs;

  buildDiscordStyle = discordStyleConfigs != [];
  discordStyleConfig =
    if buildDiscordStyle
    then head discordStyleConfigs
    else userStyleDefaults // {name = "discord";};

  documentSelector = style: defaultSelectors:
    (
      if style.defaultSites
      then defaultSelectors
      else []
    )
    ++ style.sites;
in {
  inherit
    # keep-sorted start
    buildDiscordStyle
    catppuccinStyleConfigs
    discordStyleConfig
    documentSelector
    userStyleConfigs
    # keep-sorted end
    ;
}
