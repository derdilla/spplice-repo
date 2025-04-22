if (!("Entities" in this)) return;
IncludeScript("ppmod");

::ppanfBlockingEntities <- [
  "prop_testchamber_door",
  "trigger_portal_cleanser"
];

::forcePlacePortal <- function (id) {

  local start = GetPlayer().EyePosition();
  local end = start + pplayer.eyes.GetForwardVector() * 128;

  local ray = ppmod.ray(start, end, ::ppanfBlockingEntities);

  if (ray.fraction != 1.0) {

    local portal = null;
    while (portal = ppmod.get("prop_portal", portal)) {
      if (portal.GetModelName()[21] - 49 == id) {
        portal.Fire("SetActivatedState", 0);
      }
    }

    return;

  }

  local bpos = end + pplayer.eyes.GetForwardVector() * 2;
  local ang = pplayer.eyes.GetAngles();

  local portal = null;
  while (portal = ppmod.get("prop_portal", portal)) {
    if (portal.GetModelName()[21] - 49 == id) {
      portal.SetOrigin(end);
      portal.SetForwardVector(Vector() - pplayer.eyes.GetForwardVector());
    }
  }

  ppmod.wait(function ():(id, end, bpos, ang) {
    SendToConsole("portal_place 0 "+id+" "+end.x+" "+end.y+" "+end.z+" "+(-ang.x)+" "+(ang.y + 180)+" 0");
    SendToConsole("portal_place 1 "+id+" "+bpos.x+" "+bpos.y+" "+bpos.z+" "+ang.x+" "+ang.y+" 0");
  }, FrameTime());

}

ppmod.onauto(async(function () {

  local mapname = GetMapName().tolower();
  local player = GetPlayer();

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

  ::pplayer <- ppmod.player(player);
  yield pplayer.init();

  // Direct all attack inputs to the forcePlacePortal function
  // This will still fire regular portals, which then get replaced
  pplayer.oninput("+attack", "forcePlacePortal(0)");
  pplayer.oninput("+attack2", "forcePlacePortal(1)");

  // Fizzle all map portals upon contact with a fizzler
  ppmod.addoutput("trigger_portal_cleanser", "OnFizzle", "prop_portal", "Fizzle");

}));

ppmod.onauto(function () {

  SendToConsole("sv_player_collide_with_laser 0");
  SendToConsole("sv_portal_placement_never_fail 1");
  SendToConsole("portal_draw_ghosting 0");

}, true);
