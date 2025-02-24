if (!("Entities" in this)) return;
IncludeScript("ppmod");

::mptPortal1 <- null;
::mptPortal2 <- null;

::playerNextPos <- [Vector(), Vector()];
::playerPrevAng <- [Vector(), Vector()];
::playerPrevVel <- [Vector(), Vector()];

::mptPushProps <- [
  "prop_physics",
  "prop_physics_override",
  "prop_weighted_cube",
  "prop_monster_box",
  "npc_portal_turret_floor",
  "npc_security_camera"
];

::mptAssign <- async(function (portal, pportal) {

  local curr = null;
  while (curr = ppmod.get("prop_portal", curr)) {
    local scope = curr.GetScriptScope();
    if ("_midpoint_portal_flag" in scope) continue;
    curr.SetLinkageGroupID(0);
  }

  yield pportal.GetActivatedState();
  if (!yielded) return;

  local partner = null;
  while (partner = Entities.FindByClassname(partner, "prop_portal")) {
    if (partner == portal) continue;
    local scope = partner.GetScriptScope();
    if ("_midpoint_portal_flag" in scope) continue;
    yield ppmod.portal(partner).GetActivatedState();
    if (yielded) break;
  }
  if (!partner) return;

  yield pportal.GetColor();
  if (yielded == 1) {
    ::mptPortal1 <- portal;
    ::mptPortal2 <- partner;
  } else {
    ::mptPortal2 <- portal;
    ::mptPortal1 <- partner;
  }

  mptPortal1.SetLinkageGroupID(1);
  mptPortal2.SetLinkageGroupID(2);

  local midpoint = (mptPortal1.GetOrigin() + mptPortal2.GetOrigin()) * 0.5;
  local midpoint1 = midpoint + mptPortal2.GetForwardVector() * 32.0;
  local midpoint2 = midpoint + mptPortal1.GetForwardVector() * 32.0;

  local processPortal = function (portal) {

    portal.DisableDraw();
    portal.SetSize(Vector(-2, -32, -54), Vector(2, 34, 54));

    local scope = portal.GetScriptScope();
    if ("_midpoint_portal_flag" in scope) return;
    scope._midpoint_portal_flag <- true;

    portal.OnPlayerTeleportFromMe(function () {
      local player = GetPlayer();
      player.SetOrigin(::playerNextPos[0]);
      player.SetAngles(::playerPrevAng[0]);
      player.SetVelocity(::playerPrevVel[0]);
    });

    // hack !!!
    local act = GetMapName().tolower().slice(0, 5);
    if (act != "sp_a3" && act != "sp_a4") {
      local pportal = ppmod.portal(portal);
      pportal.OnTeleport(function (ent):(portal) {
        if (ent == GetPlayer()) return;
        ent.SetOrigin(portal.GetOrigin() - portal.GetForwardVector() * 8.0);
      });
    } else {
      local push = Entities.CreateByClassname("point_push");
      push.magnitude = 100;
      push.spawnFlags = 22;
      push.SetMoveParent(portal);
      push.SetLocalOrigin("0 0 0", FrameTime());
      push.SetLocalAngles("0 0 0", FrameTime());
      push.Enable("", FrameTime());
    }

  };

  SendToConsole("portal_place 1 1 "+ midpoint1.ToKVString() +" "+ mptPortal2.GetAngles().ToKVString());
  ppmod.wait(function ():(processPortal, midpoint1, midpoint2) {

    local portal1 = Entities.FindByClassnameNearest("prop_portal", midpoint1, 8.0);
    processPortal(portal1);

    SendToConsole("portal_place 2 0 "+ midpoint2.ToKVString() +" "+ mptPortal1.GetAngles().ToKVString());
    ppmod.wait(function ():(processPortal, portal1, midpoint2) {

      local portal2 = Entities.FindByClassnameNearest("prop_portal", midpoint2, 8.0);
      while (!portal2 || portal1 == portal2) portal2 = Entities.FindByClassnameWithin(portal2, "prop_portal", midpoint2, 8.0);

      processPortal(portal2);

    }, FrameTime());

  }, FrameTime());

});

ppmod.onauto(function () {

  SendToConsole("sv_cheats 1");
  SendToConsole("cl_debugoverlaysthroughportals 1");
  SendToConsole("sv_player_collide_with_laser 0");
  SendToConsole("portal_draw_ghosting 0");

  if (GetMapName().tolower() == "sp_a1_intro1") {
    local camera = ppmod.get("ghostAnim");
    camera.SetOrigin(Vector(-1213, 4446, 2727));
    camera.SetAngles(0,180,0);
    ppmod.fire("good_morning_vcd", "Kill");
    ppmod.fire("open_portal_relay", "Trigger");
    ppmod.fire("portal_red_0_deactivate_rl", "Kill");
    ppmod.fire("portal_blue_0_deactivate_rl", "Kill");
    ppmod.get(Vector(-1232, 4400, 2856.5), 16, "trigger_once").Destroy();
    ppmod.fire("glass_break", "Kill");
    ppmod.addoutput([Vector(-688, 3536, 2712), 32.0, "trigger_once"], "OnStartTouch", "@exit_door-close_door_rl", "Trigger");
  }

  ::pplayer <- ppmod.player(GetPlayer());

  ppmod.onportal(function (shot) {

    local scope = shot.portal.GetScriptScope();
    if ("_output_flag" in scope) return;
    scope._output_flag <- true;

    local portal = shot.portal;
    local pportal = ppmod.portal(portal);

    ppmod.wait(function ():(portal, pportal, scope) {
      if ("_midpoint_portal_flag" in scope) return;
      ::mptAssign(portal, pportal);
    }, FrameTime() * 2.0);

    portal.OnPlacedSuccessfully(function ():(portal, pportal) {
      ::mptAssign(portal, pportal);
    });
    scope.InputSetActivatedState <- function ():(portal, pportal) {
      ppmod.wait(function ():(portal, pportal) {
        ::mptAssign(portal, pportal);
      }, 0.1);
      return true;
    };

  });

  ::lastPortalShot <- Time();

  ppmod.alias("+attack", function () {
    if (Time() - ::lastPortalShot < 0.2) return;
    ::lastPortalShot = Time();

    ppmod.forent("weapon_portalgun", function (pgun) {
      if (pgun.GetMoveParent() != GetPlayer()) return;
      if (ppmod.validate(::mptPortal1) && ppmod.validate(::mptPortal2)) {
        SendToConsole("change_portalgun_linkage_id 1");
        pgun.FirePortal1("", FrameTime() * 2.0);
      } else {
        pgun.FirePortal1();
      }
    });
  });

  ppmod.alias("+attack2", function () {
    if (GetMapName().tolower().slice(0, 5) == "sp_a1") return;
    if (Time() - ::lastPortalShot < 0.2) return;
    ::lastPortalShot = Time();

    ppmod.forent("weapon_portalgun", function (pgun) {
      if (pgun.GetMoveParent() != GetPlayer()) return;
      if (ppmod.validate(::mptPortal1) && ppmod.validate(::mptPortal2)) {
        SendToConsole("change_portalgun_linkage_id 2");
        pgun.FirePortal2("", FrameTime() * 2.0);
      } else {
        pgun.FirePortal2();
      }
    });
  });

  ppmod.interval(function () {

    ::playerNextPos[0] = ::playerNextPos[1];
    ::playerNextPos[1] = GetPlayer().GetOrigin() + GetPlayer().GetVelocity() * FrameTime();

    ::playerPrevAng[0] = ::playerPrevAng[1];
    ::playerPrevAng[1] = ::pplayer.eyes.GetAngles();

    ::playerPrevVel[0] = ::playerPrevVel[1];
    ::playerPrevVel[1] = GetPlayer().GetVelocity();

    if (!ppmod.validate(::mptPortal1) || !ppmod.validate(::mptPortal2)) return;
    local pos1 = ::mptPortal1.GetOrigin(), pos2 = ::mptPortal2.GetOrigin();
    if (pos1.equals(Vector()) || pos2.equals(Vector())) return;

    local midpoint = (pos1 + pos2) * 0.5;
    DebugDrawBox(midpoint, Vector(-8, -8, -8), Vector(8, 8, 8), 0, 255, 0, 80, -1);
    DebugDrawLine(pos1, pos2, 0, 255, 0, false, -1);

  });

});
