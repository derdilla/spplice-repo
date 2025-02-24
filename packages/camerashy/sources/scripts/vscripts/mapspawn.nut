if (!("Entities" in this)) return;
IncludeScript("ppmod");

const CONE_FOV = 30.0;

::coneSolidEnts <- [
  "player",
  "prop_weighted_cube",
  "prop_button",
  "prop_under_button",
  "prop_physics",
  "prop_physics_override",
  "npc_portal_turret_floor",
  "prop_monster_box",
  "simple_physics_prop"
];

::createCone <- function (camera) {

  local isFinale4 = camera.GetName() == "@sphere";

  local cone = CreateProp("prop_dynamic", Vector(), "models/props_map_editor/destination_arrow.mdl", 0);
  cone.targetname = "camera_cone";
  cone.renderMode = 1;
  cone.renderAmt = 100;
  cone.Color("255 0 0");

  local dist = cone.GetBoundingMins().z / 2;
  local fvec = (cone.GetAngles() - Vector(90, 0, 0)).FromAngles().fvec;

  local anchor = Entities.CreateByClassname("info_target");
  anchor.SetOrigin(cone.GetOrigin() + fvec * dist);
  anchor.SetAngles(cone.GetAngles() + Vector(90, 0, 0));
  anchor.targetname = "camera_cone_anchor";

  cone.SetMoveParent(anchor);

  anchor.SetMoveParent(camera);
  if (isFinale4) anchor.SetParentAttachment("eyes");
  else anchor.SetParentAttachment("lens");

  local light = ppmod.project("effects/flashlight001", anchor.GetOrigin(), anchor.GetAngles(), 0, 4096.0);
  light.lightfov = CONE_FOV;
  light.colortransitiontime = 500;
  light.lightcolor = "255 0 0 50000";

  ppmod.hook(light, "TurnOn", function () { return false });
  ppmod.hook(light, "TurnOff", function () { return false });

  local initialpos = camera.GetOrigin();

  local ref = { interval = null, unmount = false };
  ref.interval = ppmod.interval(function ():(light, anchor, cone, camera, initialpos, ref, isFinale4) {

    local start = anchor.GetOrigin();
    light.SetAbsOrigin(start);
    light.angles = anchor.GetAngles().ToKVString();

    if (ref.unmount) return;

    if (!ppmod.validate(camera.GetMoveParent()) && (camera.GetOrigin() - initialpos).LengthSqr() > 1.0) {

      light.lightcolor = "255 0 0 48000";
      ppmod.wait(function ():(light, cone) {
        light.lightcolor = "255 0 0 45000";
        cone.renderAmt = 80;
      }, 0.2);
      ppmod.wait(function ():(light, cone) {
        light.lightcolor = "255 0 0 0";
        cone.renderAmt = 0;
      }, 0.4);
      ppmod.wait(function ():(light, cone) {
        light.lightcolor = "255 0 0 45000";
        cone.renderAmt = 60;
      }, 0.5);
      ppmod.wait(function ():(light, cone) {
        light.lightcolor = "255 0 0 20000";
        cone.renderAmt = 30;
      }, 0.7);
      ppmod.wait(function ():(light, cone) {
        light.lightcolor = "255 0 0 0";
        cone.renderAmt = 0;
      }, 0.8);
      ppmod.wait(function ():(light, cone) {
        light.lightcolor = "255 0 0 10000";
        cone.renderAmt = 5;
      }, 1.0);
      ppmod.wait(function ():(light, anchor, ref) {
        light.Destroy();
        anchor.Destroy();
        ref.interval.Destroy();
      }, 1.1);

      coneSolidEnts.push(camera);
      ref.unmount = true;
      return;
    }

    if (RandomInt(0, 15) == 0) {
      if (RandomInt(0, 1) == 0) {
        light.lightcolor = "255 0 0 48000";
      } else {
        light.lightcolor = "255 0 0 50000";
      }
    }

    if (!cmdInterval) return;

    local end = GetPlayer().GetCenter();
    if (start.z > end.z) end = GetPlayer().EyePosition();
    local dirvec = end - start;
    local len = dirvec.Norm();
    local fvec = anchor.GetForwardVector();

    if (GetMapName().tolower().slice(0, 5) == "sp_a3" && len > 1024.0) return;

    if (GetDeveloperLevel() > 1) {
      DebugDrawLine(start, start + dirvec * 128, 0, 255, 0, false, -1);
      DebugDrawLine(start, start + fvec * 128, 0, 0, 255, false, -1);
    }

    local portalRayEntity = null;
    if (openPortals.len() % 2 == 0) {
      local portalRay = ppmod.ray(start, start + fvec * 4096, coneSolidEnts, true, openPortals);
      if (portalRay.start != start) portalRayEntity = portalRay.entity;
    }

    if (portalRayEntity != GetPlayer()) {
      if (fvec.Dot(dirvec) < cos(CONE_FOV * PI / 360.0)) return;
      if (ppmod.ray(start, end, coneSolidEnts).entity != GetPlayer()) return;
    }

    if (isFinale4) {
      SendToConsole("hurtme 5");
      if (GetPlayer().GetHealth() > 0) return;
    }

    cmdInterval.Destroy();
    cmdInterval <- null;

    ppmod.keyval("weapon_portalgun", "CanFirePortal1", false);
    ppmod.keyval("weapon_portalgun", "CanFirePortal2", false);

    SendToConsole("cl_mouseenable 0");
    SendToConsole("r_drawscreenoverlay 1");
    SendToConsole("r_screenoverlay glass/glassbreak001");
    SendToConsole("snd_playsounds P2Editor.DisconnectItems");
    SendToConsole("sv_regeneration_wait_time 99999999");
    SendToConsole("script GetPlayer().SetHealth(0)");
    ppmod.wait("SendToConsole(\"kill\")", 1.0);

  }, 0, "camera_cone_interval");

  ppmod.brush(camera.GetOrigin() + camera.GetForwardVector() * 4, Vector(3, 3, 3), "func_rot_button", camera.GetAngles(), true).then(function (button):(camera) {

    button.collisionGroup = 2;
    button.spawnFlags = 1024;
    button.SetMoveParent(camera);

    ppmod.addscript(button, "OnPressed", function ():(button, camera) {
      camera.SetMoveParent(null);
      camera.Ragdoll();
      button.Destroy();
    });

  });

};

::openPortals <- pparray([]);

ppmod.onauto(async(function () {

  local mapname = GetMapName().tolower();

  ppmod.onportal(function (shot) {
    if (openPortals.includes(shot.portal)) return;
    openPortals.push(shot.portal);
  });

  ::cmdInterval <- ppmod.interval(function () {
    SendToConsole("cl_mouseenable 1");
    SendToConsole("r_screenoverlay \"\"");
    SendToConsole("sv_regeneration_wait_time 1.0");
  });

  SendToConsole("sv_cheats 1");
  SendToConsole("r_portal_use_dlights 1");
  SendToConsole("mat_ambient_light_r -0.025");
  SendToConsole("mat_ambient_light_g -0.025");
  SendToConsole("mat_ambient_light_b -0.025");
  SendToConsole("alias +mouse_menu \"script ::toggleFlashlight()\"");

  ppmod.forent("env_projectedtexture", function (light) {
    light.Destroy();
  });

  yield ppmod.create("props_map_editor/destination_arrow.mdl");
  yielded.Destroy();

  local actname = mapname.slice(0, 5);
  if (mapname == "sp_a4_finale4") {

    createCone(ppmod.get("@sphere"));

  } else if (actname == "sp_a3" || actname == "sp_a4") {

    local ref = { startpos = null, interval = null };
    ref.interval = ppmod.interval(function ():(ref, actname, mapname) {

      local pos = GetPlayer().GetOrigin();

      if (ref.startpos == null) {
        ref.startpos = pos;
        return;
      }

      if ((pos - ref.startpos).Length2DSqr() < 1.0) return;
      ref.interval.Destroy();

      local heuristic = actname == "sp_a3" ? "npc_bullseye" : "models/props_bts/glados_screenborder_curve.mdl";

      ppmod.forent(heuristic, function (bullseye):(pos, ref, actname) {
        if (bullseye.GetName() == "@cave_exit_lift") return;
        if ((bullseye.GetOrigin() - pos).Length() < 1024.0) return;

        if (actname == "sp_a3") {
          local campos = bullseye.GetOrigin() - Vector(0, 0, 32);
          local fvec = bullseye.GetForwardVector() * 64;
          if (ppmod.ray(campos, campos + Vector(64, 0)).fraction != 1.0) fvec = Vector(-64, 0);
          else if (ppmod.ray(campos, campos + Vector(-64, 0)).fraction != 1.0) fvec = Vector(64, 0);
          else if (ppmod.ray(campos, campos + Vector(0, 64)).fraction != 1.0) fvec = Vector(0, -64);
          else if (ppmod.ray(campos, campos + Vector(0, -64)).fraction != 1.0) fvec = Vector(0, 64);
          campos = ppmod.ray(campos, campos - fvec).point;
        }

        local fvec = -bullseye.GetLeftVector() * 32.0;
        local campos = bullseye.GetOrigin() + fvec;

        if (ppmod.ray(campos, pos, coneSolidEnts).entity == GetPlayer()) {
          return;
        }

        ppmod.create("npc_security_camera").then(function (camera):(bullseye, campos, fvec, actname) {
          camera.SetOrigin(campos);
          camera.SetForwardVector(fvec);
          camera.Skin(1);
          camera.Enable();
          camera.SetMoveParent(bullseye);

          createCone(camera);

          if (actname == "sp_a4") {
            camera.collisionGroup = 1;
            local glass = bullseye.FirstMoveChild();
            ppmod.hook(glass, "Enable", function ():(camera) {
              camera.SetMoveParent(null);
              camera.Ragdoll();
              camera.EnableMotion();
              camera.Wake();
              return true;
            });
          }
        });
      });

    }, 0.2);

  } else {
    ppmod.forent("npc_security_camera", function (camera) {
      createCone(camera);
      camera.Enable();
    });
  }

  local pplayer = ppmod.player(GetPlayer());

  local flashlight = ppmod.project("effects/flashlight001", Vector(), Vector(), 0, 1024.0);
  flashlight.lightfov = 50.0;
  flashlight.colortransitiontime = 1.0;
  flashlight.lightcolor = "255 255 255 0";

  ppmod.hook(flashlight, "TurnOn", function () { return false });
  ppmod.hook(flashlight, "TurnOff", function () { return false });

  ::flashlightEnabled <- false;
  ppmod.interval(function ():(flashlight, pplayer) {

    if (flashlightEnabled) {
      if (RandomInt(0, 15) == 0) {
        if (RandomInt(0, 1) == 0) {
          flashlight.lightcolor = "255 255 255 10000";
        } else {
          flashlight.lightcolor = "255 255 255 10005";
        }
      }
    } else {
      flashlight.lightcolor = "255 255 255 0";
    }

    flashlight.SetAbsOrigin(pplayer.eyes.GetOrigin());
    flashlight.angles = pplayer.eyes.GetAngles().ToKVString();

  });

  local weaponstrip = Entities.CreateByClassname("player_weaponstrip");

  ::toggleFlashlight <- function ():(mapname, flashlight, weaponstrip, pplayer) {
    flashlightEnabled = !flashlightEnabled;

    if (flashlightEnabled) {
      flashlight.lightcolor = "255 255 255 10000";
      weaponstrip.Strip();
      ppmod.fire("viewmodel", "DisableDraw", "", 0.5);
      SendToConsole("snd_playsounds HL2Player.Use");
    } else {
      ppmod.fire("viewmodel", "EnableDraw");
      ppmod.fire("viewmodel", "EnableDraw", "", 0.5);
      if (mapname == "sp_a1_intro1" || mapname == "sp_a1_intro2") return;
      if (mapname == "sp_a1_intro3" && ppmod.get("portalgun")) return;
      if (mapname == "sp_a2_intro" && ppmod.get("portalgun")) return;
      GivePlayerPortalgun();
      if (mapname.slice(0, 5) == "sp_a1") return;
      UpgradePlayerPortalgun();
      if (
        mapname.slice(0, 5) == "sp_a4" ||
        (mapname == "sp_a3_transition01" && !ppmod.get("potatos_prop")) ||
        mapname == "sp_a3_speed_ramp" ||
        mapname == "sp_a3_speed_flings" ||
        mapname == "sp_a3_portal_intro" ||
        mapname == "sp_a3_end"
      ) UpgradePlayerPotatogun();
    }
  };

  if (mapname == "sp_a2_intro") {
    ppmod.addscript("pickup_portalgun_relay", "OnTrigger", function () {
      if (flashlightEnabled) toggleFlashlight();
    });
  } else if (mapname == "sp_a1_intro3") {
    ppmod.addscript("pickup_portalgun_rl", "OnTrigger", function () {
      if (flashlightEnabled) toggleFlashlight();
    });
  }

}));
