if (!("Entities" in this)) return;
IncludeScript("ppmod");

::disableOnButtons <- true;

::magnetEnts <- [
  "prop_weighted_cube",
  "prop_physics",
  "prop_physics_override",
  "npc_security_camera",
  "npc_portal_turret_floor",
  "npc_personality_core",
  "prop_monster_box"
];

::solidEnts <- [
  "phys_bone_follower",
  "func_brush",
  "func_door_rotating"
];
::rayPortals <- [];

::dropperModels <- [
  "models/props_backstage/item_dropper_wrecked.mdl",
  "models/props_backstage/item_dropper.mdl",
  "models/props_underground/underground_boxdropper.mdl"
];
::dropperClassname <- "prop_dynamic";
::mapDroppers <- [];

::isInDropper <- function (point) {
  for (local i = 0; i < mapDroppers.len(); i ++) {
    local dropper = mapDroppers[i];
    if (
      point.z > dropper[0].z &&
      point.x > dropper[0].x && point.x < dropper[1].x &&
      point.y > dropper[0].y && point.y < dropper[1].y
    ) return true;
  }
  return false;
};

::processEntity <- function (ent) {

  local scope = ent.GetScriptScope();
  local pos = ent.GetOrigin();
  local fvec = ent.GetForwardVector();

  local width_x = (ent.GetBoundingMaxs().x - ent.GetBoundingMins().x);
  local width_y = (ent.GetBoundingMaxs().y - ent.GetBoundingMins().y);
  local half_width_max = max(width_x, width_y) / 2.0 + 0.5;

  if (!("_magnet" in scope)) {

    scope._magnet <- Entities.CreateByClassname("point_push");
    scope._magnet.radius = 8.0;
    scope._magnet.magnitude = 0.0;
    scope._magnet.spawnFlags = 2 + 4 + 16;
    scope._magnet.Enable();

    scope._powered <- false;

    if (ent.GetModelName() == "models/props/reflection_cube.mdl") {
      ppmod.create("point_laser_target").then(function (catcher):(ent, half_width_max) {

        if (ent.IsValid()) ent.GetScriptScope()._catcher <- catcher;
        else return catcher.Destroy();

        catcher.SetSize(ent.GetBoundingMins(), ent.GetBoundingMaxs());

        catcher.AddScript("OnPowered", function ():(ent, catcher) {
          if (!ent.IsValid()) return catcher.Destroy();
          local scope = ent.GetScriptScope();
          scope._powered = true;
        });
        catcher.AddScript("OnUnpowered", function ():(ent, catcher) {
          if (!ent.IsValid()) return catcher.Destroy();
          local scope = ent.GetScriptScope();
          scope._powered = false;
        });

      });
    }

  }

  scope._magnet.SetAbsOrigin(pos);
  if ("_catcher" in scope) {
    scope._catcher.SetAbsOrigin(pos);
    scope._catcher.SetForwardVector(fvec);
  }

  if (isInDropper(pos)) {
    scope._magnet.magnitude = 0.0;
    return;
  }

  if (disableOnButtons) {
    if (
      scope._powered ||
      Entities.FindByClassnameWithin(null, "prop_floor_button", pos, 8) ||
      Entities.FindByClassnameWithin(null, "prop_under_floor_button", pos, 8)
    ) {
      scope._magnet.magnitude = 0.0;
      return;
    }
  }

  local cant_sleep = ent.GetClassname().slice(0, 4) == "npc_";

  local vec = [
    Vector(1, 0),
    Vector(-1, 0),
    Vector(0, 1),
    Vector(0, -1),
  ];

  local portals = (rayPortals.len() % 2 == 0) ? rayPortals : null;

  local closest_i = 0, closest_frac = 1.0;
  for (local i = 0; i < vec.len(); i ++) {
    local frac = ppmod.ray(pos, pos + vec[i] * 4096, null, true, portals).fraction;
    if (frac < closest_frac) {
      closest_i = i;
      closest_frac = frac;
    }
    if (frac == 0.0) break;
  }

  local dist = closest_frac * 4096;

  if (closest_frac == 0.0) {
    scope._magnet.magnitude = 0.0;
    ent.Wake();
  } else if (!cant_sleep && dist < half_width_max) {
    scope._magnet.magnitude = 0.0;
    ent.Sleep();
  } else {
    scope._magnet.SetForwardVector(vec[closest_i]);
    scope._magnet.magnitude = 50.0;
  }

};

ppmod.onauto(function () {

  local playername = GetPlayer().GetName();
  if (playername) compilestring(playername)();

  SendToConsole("sv_alternateticks 0");
  SendToConsole("portal_pointpush_think_rate 0");

  if (GetMapName().tolower() == "sp_a1_intro1") {

    ppmod.wait(function () {
      SendToConsole("gameinstructor_enable 1");
    }, 9.5);
    ppmod.wait(function () {
      SendToConsole("gameinstructor_enable 0");
    }, 15.0);

    ppmod.wait(function () {

      local instructor = Entities.CreateByClassname("env_instructor_hint");

      instructor.hint_static = true;
      instructor.hint_caption = "Toggle Difficulty";
      instructor.hint_binding = "mouse_menu";
      instructor.hint_timeout = 5;
      instructor.hint_color = "255 255 255";
      instructor.hint_icon_onscreen = "use_binding";

      instructor.ShowHint();

    }, 10.0);

    dropperModels.push("cube_clip");
    dropperClassname = "func_clip_vphysics";

    // Setup routine taken from Maxwell mod
    local camera = ppmod.get("ghostAnim");
    camera.SetOrigin(Vector(-1213, 4446, 2727));
    camera.SetAngles(0,180,0);
    GetPlayer().SetOrigin(Vector(-1213, 4446, 2769));

    SendToConsole("map_wants_save_disable 0");

    ppmod.fire("good_morning_vcd", "Kill");
    ppmod.runscript("@glados", "GladosPlayVcd(\"PreHub01RelaxationVaultIntro01\")");
    ppmod.get(Vector(-1232, 4400, 2856.5), 16, "trigger_once").Destroy();
    ppmod.fire("glass_break", "Kill");

  }

  for (local i = 0; i < dropperModels.len(); i ++) {
    ppmod.forent(dropperModels[i], function (dropper) {
      if (dropper.GetClassname() != dropperClassname) return;
      mapDroppers.push([
        dropper.GetBoundingMins() + dropper.GetOrigin(),
        dropper.GetBoundingMaxs() + dropper.GetOrigin()
      ]);
    });
  }

  ppmod.onportal(function (info) {
    if (!info.first) return;
    rayPortals.push(info.portal);
  });

  ppmod.interval(function () {
    for (local i = 0; i < magnetEnts.len(); i ++) {
      ppmod.forent(magnetEnts[i], function (ent) {
        ppmod.detach(processEntity, ent);
      });
    }
  });

  local text = ppmod.text("", 0, 1);
  text.SetSize(4);
  text.SetFade(0.2, 0.2);

  ppmod.alias("+mouse_menu", function ():(text) {

    disableOnButtons = !disableOnButtons;
    GetPlayer().targetname = ("disableOnButtons = " + disableOnButtons);

    if (disableOnButtons) {
      text.SetColor("80 255 100")
      text.SetText("      Enabled easy mode\n");
      text.Display(3.0);
    } else {
      text.SetColor("255 80 80")
      text.SetText("      Enabled hard mode\n");
      text.Display(3.0);
    }

  });

});
