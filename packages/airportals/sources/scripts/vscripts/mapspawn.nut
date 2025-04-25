if (!("Entities" in this)) return;
IncludeScript("ppmod");

::ppanfBlockingEntities <- [
  "prop_testchamber_door",
  "trigger_portal_cleanser"
];

ppmod.onauto(function () {

  local pplayer = ppmod.player(GetPlayer());

  ppmod.onportal(function (shot):(pplayer) {

    if (!shot.weapon) return;
    shot.portal.SetActivatedState(0);

    local pos = pplayer.eyes.GetOrigin();
    local ang = pplayer.eyes.GetAngles();
    local fvec = pplayer.eyes.GetForwardVector();

    local target = pos + fvec * 128.0;

    local ray = ppmod.ray(pos, target, ::ppanfBlockingEntities);
    if (ray.entity) return;

    local targetF = ray.point;
    local targetB = targetF + fvec * 2.0;

    local id = shot.color - 1;
    SendToConsole("portal_place 1 "+id+" "+targetF.x+" "+targetF.y+" "+targetF.z+" "+(-ang.x)+" "+(ang.y + 180)+" 0");
    SendToConsole("portal_place 2 "+id+" "+targetB.x+" "+targetB.y+" "+targetB.z+" "+ang.x+" "+ang.y+" 0");

  });

  local mapname = GetMapName().tolower();
  switch (mapname) {
    // This is the startup map
    // We place the player next to the portal gun to skip the start
    case "sp_a1_intro3":
      player.SetOrigin(Vector(102, 1910, -324));
      player.SetAngles(Vector(28.75, 148.27));
      break;
    // Pull The Rug and Jailbreak have a giant fizzler covering the whole map
    // This makes the blocking entities list not consider it
    case "sp_a2_pull_the_rug":
    case "sp_a2_bts1":
      ::ppanfBlockingEntities <- ["prop_testchamber_door"];
      break;
    default:
      break;
  }

  // Fizzle all map portals upon contact with a fizzler
  ppmod.addoutput("trigger_portal_cleanser", "OnFizzle", "prop_portal", "Fizzle");

  ppmod.forent("prop_portal", function (portal) {
    if (portal.GetName() == "") return;
    portal.SetLinkageGroupID(1);
  });

});

ppmod.onauto(function () {

  SendToConsole("sv_player_collide_with_laser 0");
  SendToConsole("sv_portal_placement_never_fail 1");
  SendToConsole("portal_draw_ghosting 0");

}, true);
