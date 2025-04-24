switch (GetMapName().tolower()) {
  case "sp_a1_intro1":
    local camera = ppmod.get("ghostAnim");
    camera.SetOrigin(Vector(-1213, 4446, 2727));
    camera.SetAngles(0, 180, 0);
    ppmod.fire("good_morning_vcd", "Kill");
    ppmod.get(Vector(-1232, 4400, 2856.5), 16, "trigger_once").Destroy();
    ppmod.fire("glass_break", "Kill");
    GetPlayer().SetOrigin(Vector(-1213, 4446, 2769));

    ppmod.fire("env_instructor_hint", "Kill");

    ppmod.addscript("entity_box_maker_rm1", "OnEntitySpawned", function () {

      SendToConsole("gameinstructor_enable 1");

      ppmod.interval(function () {
        local box = ppmod.prev("box");
        if (!ppmod.validate(box) || box.GetModelName() != "models/props/metal_box.mdl") {
          SendToConsole("gameinstructor_enable 0");
          activator.Destroy();
        }
      });

      ppmod.wait(function () {
        local instructor = Entities.CreateByClassname("env_instructor_hint");
        instructor.hint_target = "box";
        instructor.hint_static = false;
        instructor.hint_caption = "Press and look up/down to scale";
        instructor.hint_binding = "attack";
        instructor.hint_timeout = 5.2;
        instructor.hint_color = "255 255 255";
        instructor.hint_icon_onscreen = "use_binding";
        instructor.ShowHint();
      }, 0.2);

    }, 0.2);

    local button = ppmod.get("button_1-button");
    local pos = button.GetOrigin();
    local ang = button.GetAngles();
    button.SetOrigin(Vector(-624, 4560, 2800));
    button.SetAngles(-90, 90, 0);

    ppmod.create("props_factory/factory_panel_portalable_128x128.mdl").then(function (panel):(pos, ang) {
      panel.SetOrigin(pos);
      panel.SetAngles(ang + Vector(90, 0, 0));
      panel.modelScale = 1.02;
    });

    break;
  case "sp_a1_intro2":
    local button = ppmod.get("button_1-button");
    local pos = button.GetOrigin();
    local ang = button.GetAngles();
    button.SetOrigin(Vector(-608, 416, 64));
    button.SetAngles(-90, 90, 0);

    ppmod.create("props_factory/factory_panel_portalable_128x128.mdl").then(function (panel):(pos, ang) {
      panel.SetOrigin(pos);
      panel.SetAngles(ang + Vector(90, 0, 0));
      panel.modelScale = 1.02;
    });
    break;
  case "sp_a1_intro3":
    CreateStationaryPortal(1, Vector(-94.7305, 2043.05, -246.258), Vector(-10, -46, -0));
    ppmod.fire("portalgun*", "Kill");
    ppmod.fire("pickup_portalgun_rl", "Kill");
    ppmod.fire("snd_gun_zap", "Kill");
    ppmod.create("prop_weighted_cube").then(function (cube) {
      cube.SetOrigin(Vector(-656, 2674, -150));
      cube.SetAngles(0, 0, 0);
      cube.Skin(3);
    });
    break;
  case "sp_a1_intro4":
    ppmod.fire("portal_emitter_a_lvl3", "Kill");
    ppmod.fire("portal_a_lvl3", "Kill");
    ppmod.fire("section_2_portal_emitter_a1_rm3a", "Kill");
    ppmod.fire("section_2_portal_a1_rm3a", "Kill");
    CreateStationaryPortal(1, Vector(1007.97, -527.391, 58.3613), Vector(-0, 180, 0));
    local grate = ppmod.get(Vector(0, 0, -272.5), 8.0, "func_brush");
    grate.SetOrigin(Vector(0, 0, -160));
    break;
  case "sp_a1_intro5":
    CreateStationaryPortal(1, Vector(0.378906, -415.369, 128.031), Vector(-90, -90.7719, 0));
    ppmod.addscript("room_1_portal", "OnPlayerTeleportToMe", function () {
      CreateStationaryPortal(1, Vector(704, -416, 128.031), Vector(-90, 178.78, 0));
      ppmod.get("_mod_stationary_emitter").Destroy();
    }, 0.5, 1);
    break;
  case "sp_a1_intro6":
    ppmod.fire("room_1_fling_portal*", "Disable");
    ppmod.fire("room_1_fling_portal*", "AddOutput", "Targetname \"\"");
    ppmod.fire("room_2_fling_portal*", "Disable");
    ppmod.fire("room_2_fling_portal*", "AddOutput", "Targetname \"\"");

    CreateStationaryPortal(1, Vector(463.605, -256.031, -69.9688), Vector(-0, -90, -0));
    CreateStationaryPortal(2, Vector(448.148, -255.969, 184.031), Vector(-0, 90, 0));

    local pusher = Entities.CreateByClassname("point_push");
    pusher.SetOrigin(Vector(2079, 384, 128));
    pusher.SetAngles(0, -90, 0);
    pusher.magnitude = 10.0;
    pusher.radius = 128.0;
    pusher.spawnFlags = 22;
    pusher.Enable();

    ppmod.addscript("room_2_entry_door-close_door_rl", "OnTrigger", function () {
      CreateStationaryPortal(2, Vector(1566.7, -0.0390625, -631.969), Vector(-90, -179.711, 0));
      CreateStationaryPortal(1, Vector(1088.03, -161.156, 768.25), Vector(-0, 0, 0));
    });
    break;
    case "sp_a1_intro7":
    local glados_scope = ppmod.get("@glados").GetScriptScope();
    glados_scope.sp_a1_intro7_ComeThroughNag <- function () {};
    CreateStationaryPortal(1, Vector(-640.654, -902.84, 1412.87), Vector(-3.5, 90, 0));
    break;
  case "sp_a2_intro":
    local glados_scope = ppmod.get("@glados").GetScriptScope();
    local _playvcd = glados_scope.GladosPlayVcd;
    glados_scope.GladosPlayVcd <- function (idx):(_playvcd) {
      if (idx == 200 || idx == 201 || idx == 202) return;
      _playvcd(idx);
    };
    ppmod.fire("portalgun*", "Kill");
    ppmod.fire("pickup_portalgun_relay", "Kill");
    ppmod.fire("go_up", "Kill");
    ppmod.fire("snd_gun_zap", "Kill");
    CreateStationaryPortal(1, Vector(-1311.32, 288.031, -10951.6), Vector(-0, 90, 0));
    CreateStationaryPortal(2, Vector(-479.719, 511.969, -10684), Vector(-0, -90, -0));
    ppmod.create("prop_weighted_cube").then(function (cube) {
      cube.SetOrigin(Vector(-479, 452, -10824));
      cube.SetAngles(0, 45, 0);
    });
    break;
  case "sp_a2_laser_intro":
    ppmod.addscript("@wall_left_falling", "OnTrigger", function () {
      ppmod.create("ent_create_portal_reflector_cube").then(function (cube) {
        cube.SetOrigin(Vector(16, 128, 414));
        cube.SetAngles(30, 30, 0);
        cube.Skin(1);
      });
    }, 1.0);
    break;
  case "sp_a2_laser_stairs":
    local pusher = Entities.CreateByClassname("point_push");
    pusher.SetOrigin(Vector(-512, 384, -96));
    pusher.SetAngles(0, -80, 0);
    pusher.magnitude = 10.0;
    pusher.radius = 96.0;
    pusher.spawnFlags = 22;
    pusher.Enable();
    ppmod.addoutput("prop_floor_button", "OnPressed", "prop_weighted_cube", "Skin", "1");
    ppmod.addoutput("prop_floor_button", "OnUnPressed", "prop_weighted_cube", "Skin", "1");
    break;
  case "sp_a2_dual_lasers":
    ppmod.create("ent_create_portal_reflector_cube").then(function (cube) {
      cube.SetOrigin(Vector(95, -130, 944));
      cube.SetAngles(0, 0, 0);
      cube.Skin(1);
    });
    CreateStationaryPortal(1, Vector(-32.002, -287.969, 1216), Vector(-0, 90, 0));
    CreateStationaryPortal(2, Vector(-223.441, 351.969, 1144.03), Vector(-0, -90, -0));
    break;
  case "sp_a2_laser_over_goo":
    CreateStationaryPortal(1, Vector(3583.97, -1312, 89.502), Vector(-0, 180, 0));
    CreateStationaryPortal(2, Vector(3488, -1983.97, 88.0293), Vector(-0, 90, 0));
    ppmod.create("anim_wp/room_transform/arm64x64_interior_rusty.mdl").then(function (arm) {
      arm.SetOrigin(Vector(3232, -1752, 32));
      arm.SetAngles(0, 90, 0);
      arm.SetAnimation("BindPose");
    });
    break;
  case "sp_a2_trust_fling":
    CreateStationaryPortal(1, Vector(1861.23, 768.066, -204.229), Vector(-45.0006, 180, 0));
    CreateStationaryPortal(2, Vector(1861.23, 448.066, -44.2285), Vector(-44.9988, 180, 0));
    ppmod.create("prop_wall_projector").then(function (bridge) {
      bridge.SetOrigin(Vector(-1024, 1282, -14));
      bridge.SetAngles(16, 0, 0);
      bridge.Enable();
    });
    ppmod.hook("malfunctioning_dropper_item_1_maker", "Forcespawn", function () {
      ppmod.wait(function () {
        ppmod.prev("models/props_gameplay/mp_ball.mdl").DisableDraw();
        ppmod.prev("models/props_gameplay/mp_ball.mdl").Kill("", 2.0);
      }, 0.2);
      return true;
    });
    break;
  case "sp_a2_pit_flings":
    ppmod.fire("exit_ledge_player_clip", "Kill");
    ppmod.addscript("proxy", "OnProxyRelay1", function () {
      if (!ppmod.get("_mod_stationary_emitter")) {
        CreateStationaryPortal(1, Vector(351.865, -447.721, -767.969), Vector(-90, 0.252056, 0));
        CreateStationaryPortal(2, Vector(613.709, -513.537, -171.748), Vector(-45.0022, 180, 0));
      }
      return true;
    });
    ppmod.addoutput("prop_floor_button", "OnPressed", "prop_weighted_cube", "Skin", "4");
    ppmod.addoutput("prop_floor_button", "OnUnPressed", "prop_weighted_cube", "Skin", "1");
    ppmod.fire("respawn_box_listener", "Kill");
    break;
  case "sp_a2_fizzler_intro":
    local trigger = ppmod.trigger(Vector(479.5, -432, 64), Vector(18, 8, 18), "trigger_multiple");
    local ref = { lastTime = Time() };
    trigger.spawnFlags = 8;
    trigger.OnStartTouch(function ():(ref) {
      if (Time() - ref.lastTime < 0.5) return;
      if (activator.GetClassname() != "prop_weighted_cube") return;
      local propScope = activator.GetScriptScope();
      if (!("_mod_substitute_owner" in propScope)) return;
      local entScope = propScope._mod_substitute_owner.GetScriptScope();
      if (entScope._mod_scale_factor > 0.7) return;
      ref.lastTime = Time();
      if (activator.GetOrigin().y < -432) {
        activator.SetOrigin(activator.GetOrigin() + Vector(0, 40));
      } else {
        activator.SetOrigin(activator.GetOrigin() - Vector(0, 40));
      }
      printl(activator);
    });
    break;
  case "sp_a2_sphere_peek":
    local ref = { secondPortal = false };
    ppmod.hook("ceiling_panel_area_portal", "Close", function ():(ref) {
      ppmod.wait(function ():(ref) {
        CreateStationaryPortal(1, Vector(-1952, 1568, 439.969), Vector(90, -180, 0));
        CreateStationaryPortal(2, Vector(-767.68, 2112.17, 64.0312), Vector(-90, 90, 0));
        ppmod.fire("box_button", "Press");
        ppmod.hook("prop_weighted_cube", "Use", function ():(ref) {
          if (!ref.secondPortal) {
            ppmod.prev("_mod_stationary_emitter").Destroy();
            CreateStationaryPortal(2, Vector(-799.609, 1835.9, 143.236), Vector(-45, -90, 0));
            ref.secondPortal = true;
          }
          return true;
        });
      }, 0.5);
      return true;
    });
    ppmod.get("prop_laser_catcher").SetOrigin(Vector(-940, 1248, 96));
    break;
  case "sp_a2_ricochet":
    CreateStationaryPortal(1, Vector(1472.65, 1535.97, -737.15), Vector(-0, -90, -0));
    CreateStationaryPortal(2, Vector(1472.7, 1375.7, -1439.97), Vector(-90, 90.564, 0));
    ppmod.addscript("reflecto_cube_dropper-cube_dropper_relay", "OnTrigger", function () {
      ppmod.fire("_mod_stationary_emitter", "Kill");
      ppmod.wait(function () {
        CreateStationaryPortal(1, Vector(1120.03, 1472, -872.031), Vector(-0, 0, 0));
        CreateStationaryPortal(2, Vector(2208, 768.031, -327.969), Vector(-0, 90, 0));
      }, 0.2);
    }, 0.0, 1);
    break;
  case "sp_a2_bridge_intro":
    ppmod.fire("cube_drop_button", "Press");
    CreateStationaryPortal(1, Vector(302.969, -768, 56.0293), Vector(-0, 180, 0));
    CreateStationaryPortal(2, Vector(767.969, 64.543, -438.221), Vector(-0, 180, 0));
    ppmod.addscript("logic_door_open1", "OnTrigger", function () {
      ppmod.prev("_mod_stationary_emitter").Destroy();
      CreateStationaryPortal(2, Vector(192.695, 575.969, 56.0293), Vector(-0, -90, -0));
    }, 0.0, 1);
    break;
  case "sp_a2_bridge_the_gap":
    CreateStationaryPortal(1, Vector(512, -447.969, 1414.46), Vector(-0, 90, 0));
    CreateStationaryPortal(2, Vector(-127.342, -1070, 1290), Vector(12, 90, 0));
    ppmod.create("props_factory/factory_panel_portalable_128x128.mdl").then(function (panel) {
      panel.SetOrigin(Vector(-127.342, -1077.83, 1291.66));
      panel.SetAngles(Vector(12, 90, 0));
    });
    break;
  case "sp_a2_laser_relays":
    CreateStationaryPortal(1, Vector(447.967, -893.908, 56.0293), Vector(-0, 180, 0));
    CreateStationaryPortal(2, Vector(447.967, -604.631, 56.0293), Vector(-0, 180, 0));
    break;
  case "sp_a2_turret_blocker":
    ppmod.get(Vector(-512, -505, 0), 8.0, "npc_portal_turret_floor").Destroy();
    break;
  case "sp_a2_laser_vs_turret":
    ppmod.get("models/props/reflection_cube.mdl").SetOrigin(Vector(64, 96, 302));
    break;
  case "sp_a2_pull_the_rug":
    local button = ppmod.get("prop_floor_button");
    button.SetOrigin(button.GetOrigin() + Vector(0, 0, 36));
    ppmod.create("props_factory/factory_panel_metal_chopped_top_128x128.mdl").then(function (panel):(button) {
      panel.SetOrigin(button.GetOrigin() - Vector(0, 0, 6));
      panel.SetAngles(90, 0, 0);
    });
    ppmod.create("props_factory/factory_panel_metal_chopped_top_128x128.mdl").then(function (panel):(button) {
      panel.SetOrigin(button.GetOrigin() - Vector(0, 0, 18));
      panel.SetAngles(90, 0, 0);
    });
    ppmod.create("props_factory/factory_panel_metal_chopped_top_128x128.mdl").then(function (panel):(button) {
      panel.SetOrigin(button.GetOrigin() - Vector(0, 0, 30));
      panel.SetAngles(90, 0, 0);
    });
    ppmod.fire("prop_wall_projector", "Disable");
    ppmod.hook("@exit_door-door_open_relay", "Trigger", function () {
      if (caller == null) return true;
      ppmod.fire(self, "Trigger", "", 0.2);
    });
    break;
  case "sp_a2_column_blocker":
    ppmod.fire("npc_portal_turret_floor", "Kill");
    CreateStationaryPortal(1, Vector(767.969, 1343.99, 184.031), Vector(-0, 180, 0));
    CreateStationaryPortal(2, Vector(896, -224, 0.03125), Vector(-90, 90, 0));
    local bridge = ppmod.get("prop_wall_projector");
    bridge.SetOrigin(Vector(-640, -288, 16));
    bridge.SetAngles(0, 90, 0);
    bridge.Enable();
    break;
  case "sp_a2_laser_chaining":
    CreateStationaryPortal(1, Vector(-383.969, -640.461, 704), Vector(0, 0, 0));
    CreateStationaryPortal(2, Vector(544, 64, 183.969), Vector(90, 0, 0));
    local highBox = ppmod.get(Vector(-480, 544, 594), 16.0, "prop_weighted_cube");
    highBox.SetOrigin(Vector(580, 260, 298));
    highBox.EnableMotion();
    ppmod.create("prop_wall_projector").then(function (bridge) {
      bridge.SetOrigin(Vector(-512, 384, 16));
      bridge.SetAngles(-12, 0, 0);
      bridge.Enable();
    });
    ppmod.get(Vector(528, 416, 512), 8.0, "func_clip_vphysics").Destroy();
    break;
  case "sp_a2_triple_laser":
    local spawner = ppmod.get("box1_spawner");
    local pusher = Entities.CreateByClassname("point_push");
    pusher.SetOrigin(spawner.GetOrigin());
    pusher.magnitude = -200.0;
    pusher.radius = 128.0;
    pusher.spawnFlags = 20;
    pusher.Enable();
    pusher.Disable("", 2.0);
    for (local i = 0; i < 20; i ++) {
      spawner.ForceSpawn("", i * 0.05);
    }
    break;
  case "sp_a2_bts1":
    CreateStationaryPortal(1, Vector(-9032.03, -1664, 56.0293), Vector(-0, 180, 0));
    CreateStationaryPortal(2, Vector(-9728, -416.031, 448), Vector(-0, -90, -0));
    break;
  case "sp_a2_bts2":
    CreateStationaryPortal(1, Vector(2050.45, -3583.97, 24.0293), Vector(-0, 90, 0));
    CreateStationaryPortal(2, Vector(1984, -2864.03, 152), Vector(-0, -90, -0));
    ppmod.create("prop_weighted_cube").then(function (cube) {
      cube.SetOrigin(Vector(898, -2150, -26));
      cube.SetAngles(0, 45, 0);
    });
    local pusher = Entities.CreateByClassname("point_push");
    pusher.SetOrigin(Vector(898, -2207, -64));
    pusher.SetAngles(0, 90, 0);
    pusher.magnitude = 15.0;
    pusher.radius = 16.0;
    pusher.spawnFlags = 22;
    pusher.Enable();
    ppmod.interval(function () {
      ppmod.fire([Vector(895, -2112, -64), 32.0, "npc_portal_turret_floor"], "Wake");
    });
    break;
  case "sp_a2_bts3":
    CreateStationaryPortal(1, Vector(4160.03, 1013.6, 184.031), Vector(0, 0, 0));
    CreateStationaryPortal(2, Vector(4144.03, 1152.14, 184.031), Vector(0, 0, 0));
    ppmod.addscript("laser_cutter_room_kill_relay", "OnTrigger", function () {
      CreateStationaryPortal(1, Vector(9280.03, 5455.72, -327.969), Vector(0, 0, 0));
      CreateStationaryPortal(2, Vector(9534.37, 5391.97, -391.969), Vector(-0, -90, -0));
      ppmod.wait(function () {
        ppmod.addscript("models/portals/portal1.mdl", "OnPlayerTeleportToMe", function () {
          CreateStationaryPortal(2, Vector(8599.42, 6304.03, -193.131), Vector(-0, 90, 0));
        });
      }, 0.2);
    });
    break;
  case "sp_a2_bts4":
    ppmod.create("prop_weighted_cube").then(function (cube) {
      cube.SetOrigin(Vector(1418, -3472, 7208));
      cube.SetAngles(0, 45, 0);
    });
    CreateStationaryPortal(1, Vector(2064.03, -5184.27, 6712.03), Vector(0, 0, 0));
    CreateStationaryPortal(2, Vector(2080.03, -4919.12, 6712.03), Vector(0, 0, 0));
    ppmod.addscript("@disable_dummyshoot_rl", "OnTrigger", function () {
      CreateStationaryPortal(1, Vector(1503.97, -7205.56, 6712.03), Vector(-0, 180, 0));
      CreateStationaryPortal(2, Vector(1503.97, -7363.18, 6712.03), Vector(-0, 180, 0));
    });
    break;
  case "sp_a2_bts5":
    ppmod.addscript("button", "OnPressed", function () {
      for (local i = 1; i <= 8; i ++) {
        ppmod.fire("intact_pipe_"+i, "Kill");
        ppmod.fire("cut_pipe_"+i, "EnableDraw");
        ppmod.fire("cut_pipe_"+i, "SetAnimation", "toxinpipe"+i+"_laser", 0.1);
      }
      ppmod.fire("destroy_tanks_relay", "Trigger");
    });
    local glados_scope = ppmod.get("@glados").GetScriptScope();
    glados_scope.ToxinDoorIsNowOpenMovingToMonitor <- function () { };
    break;
  case "sp_a2_core":
    ppmod.fire("logic_playerproxy", "SetDropEnabled", "1");
    ppmod.hook("logic_playerproxy", "SetDropEnabled", function () {
      if (caller == null) return true;
      ppmod.fire(self, "SetDropEnabled", "1");
    });
    CreateStationaryPortal(1, Vector(-127.969, 2215.32, -71.9707), Vector(0, 0, 0));
    CreateStationaryPortal(2, Vector(-1824, 0, 831.969), Vector(90, 0, 0));
    ppmod.create("prop_weighted_cube").then(function (cube) {
      cube.SetOrigin(Vector(94.638, -574.705, 20.475));
      cube.SetAngles(0, 20, 0);
    });
    break;
  case "sp_a3_01":
    CreateStationaryPortal(1, Vector(-416.031, 3970.28, 568.031), Vector(-0, 180, 0));
    CreateStationaryPortal(2, Vector(-1590.99, -64.0332, 121.451), Vector(-0, -90, -0));
    ppmod.wait(function () {
      ppmod.addscript("models/portals/portal1.mdl", "OnPlayerTeleportToMe", function () {
        ppmod.fire("_mod_stationary_emitter", "Kill");
        ppmod.wait(function () {
          CreateStationaryPortal(1, Vector(4568.03, 5340.32, -323.969), Vector(0, 0, 0));
          CreateStationaryPortal(2, Vector(4536.03, 3827.67, -323.969), Vector(0, 0, 0));
        }, 0.2);
      }, 0.0, 1);
    }, 0.2);
    ppmod.create("ent_create_portal_weighted_antique").then(function (cube) {
      cube.SetOrigin(Vector(4979, 4935, -717));
      cube.SetAngles(0, 0, 0);
    });
    break;
  case "sp_a3_03":
    ppmod.fire("office_exit_platform_clipbrush", "Kill");
    ppmod.create("ent_create_portal_weighted_antique").then(function (cube) {
      cube.SetOrigin(Vector(-6092, 380, -4949));
      cube.SetAngles(0, 20, 0);
    });
    ppmod.create("ent_create_portal_weighted_antique").then(function (cube) {
      cube.SetOrigin(Vector(-6056, 347, -4949));
      cube.SetAngles(0, 45, 0);
    });
    ppmod.create("ent_create_portal_weighted_antique").then(function (cube) {
      cube.SetOrigin(Vector(-6076, 364, -4900));
      cube.SetAngles(0, 0, 0);
    });
    ppmod.hook("main_elevator_bottom_clipbrush", "Disable", function () {
      if (!ppmod.get("_mod_stationary_emitter")) {
        CreateStationaryPortal(1, Vector(-4980, 1024, -4867.97), Vector(-90, 0, 0));
        CreateStationaryPortal(2, Vector(-6415.98, 2128, -2175.98), Vector(-45, 0, 0));
      }
      return true;
    });
    local target = ppmod.get("big_jump_target");
    target.SetOrigin(Vector(-3858, 1662, -2502));
    break;
  case "sp_a3_jump_intro":
    CreateStationaryPortal(1, Vector(352.281, 735.969, 344.031), Vector(-0, -90, -0));
    CreateStationaryPortal(2, Vector(351.414, 439.969, 24.0293), Vector(-0, -90, -0));
    local trigger = ppmod.get(Vector(-676, 896, 448), 32.0, "trigger_once");
    ppmod.addscript(trigger, "OnStartTouch", function () {
      CreateStationaryPortal(1, Vector(-1120.03, 705.381, 577), Vector(-0, 180, 0));
      CreateStationaryPortal(2, Vector(-1391.97, 1057.36, 992.031), Vector(-0, 0, 0));
    });
    ppmod.hook("crane_X_axis", "Open", function () {
      ppmod.hook("crane_X_axis", "Open", null);
      ppmod.fire("prop_portal", "SetActivatedState", 0);
      ppmod.wait(function () {
        CreateStationaryPortal(1, Vector(-1599.71, 656.031, 984.031), Vector(-0, 90, 0));
      }, 0.2);
      return true;
    });
    ppmod.addscript("open_lower_panel", "OnTrigger", function () {
      CreateStationaryPortal(2, Vector(-1859.97, 1151.82, 1272.03), Vector(0, 0, 0), false);
    }, 1.0);
    ppmod.addscript("close_lower_panel", "OnTrigger", function () {
      ppmod.fire(["models/portals/portal2.mdl"], "SetActivatedState", 0);
    }, 1.0);
    ppmod.addscript("open_upper_panel", "OnTrigger", function () {
      CreateStationaryPortal(2, Vector(-1633.24, 764.031, 1624.03), Vector(0, 90, 0), false);
    }, 1.0);
    ppmod.addscript("close_upper_panel", "OnTrigger", function () {
      ppmod.fire(["models/portals/portal2.mdl"], "SetActivatedState", 0);
    }, 1.0);
    break;
  case "sp_a3_bomb_flings":
    CreateStationaryPortal(1, Vector(67.9688, -224.465, -1351.97), Vector(-0, 180, 0));
    CreateStationaryPortal(2, Vector(129.131, -717.604, 574.711), Vector(-50, 90, 0));
    ppmod.wait(function () {
      ppmod.addscript("models/portals/portal2.mdl", "OnPlayerTeleportToMe", function () {
        CreateStationaryPortal(1, Vector(-224, -64, 8.03125), Vector(-90, 0, 0));
      }, 0.0, 1);
    }, 0.2);
    ppmod.create("prop_wall_projector").then(function (bridge) {
      bridge.SetOrigin(Vector(512, -128, 334));
      bridge.SetAngles(0, 180, 0);
      bridge.Enable();
    });
    ppmod.create("ent_create_portal_weighted_antique").then(function (cube) {
      cube.SetOrigin(Vector(554, -129, 507));
      cube.SetAngles(0, 20, 0);
    });
    ppmod.fire("trigger_portal_cleanser", "Disable");
    break;
  case "sp_a3_crazy_box":
    ppmod.create("ent_create_portal_weighted_antique").then(function (cube) {
      cube.SetOrigin(Vector(2240, -1248, -92));
      cube.SetAngles(0, 30, 0);
    });
    ppmod.fire([Vector(1536, -1463.5, 96), 64.0, "trigger_portal_cleanser"], "Disable");
    CreateStationaryPortal(1, Vector(1725.84, -1786.24, 0.03125), Vector(-90, 90, 0));
    CreateStationaryPortal(2, Vector(1791.95, -1460.97, 115.07), Vector(-45, -90, -0));
    ppmod.wait(function () {
      ppmod.addscript("models/portals/portal2.mdl", "OnPlayerTeleportToMe", function () {
        local vel = GetPlayer().GetVelocity();
        if (vel.Length() < 400) return;
        GetPlayer().SetVelocity(vel * 1.6);
      });
    }, 0.2);
    ppmod.trigger(Vector(1792, -1416, 512), Vector(128, 8, 128)).OnStartTouch(function () {
      CreateStationaryPortal(1, Vector(1312, -1368, 647.969), Vector(90, 179.042, 0));
      CreateStationaryPortal(2, Vector(1143.97, -1472, 1952), Vector(-0, 180, 0));
    }, 0.0, 1);
    ppmod.create("props_factory/factory_panel_metal_chopped_top_128x128.mdl").then(function (panel) {
      panel.SetOrigin(Vector(1308, -1368, 514));
      panel.SetAngles(90, 0, 0);
      panel.DisableDraw();
    });
    local jumpTrigger = ppmod.trigger(Vector(1312, -1368, 584), Vector(64, 64, 64), "trigger_multiple");
    jumpTrigger.OnStartTouch(function () {
      ::MOD_JUMP_ON_SCALE = true;
    });
    jumpTrigger.OnEndTouch(function () {
      ::MOD_JUMP_ON_SCALE = false;
    });
    ppmod.trigger(Vector(1312, -1368, 720), Vector(64, 64, 8)).OnStartTouch(function () {
      GetPlayer().SetOrigin(Vector(1124, -1470, 1896));
      GetPlayer().SetAngles(GetPlayer().GetAngles() + Vector(90, 180));
    });
    ppmod.create("ent_create_portal_weighted_antique").then(function (cube) {
      cube.SetOrigin(Vector(1308, -1365, 556));
      cube.SetAngles(0, 5, 0);
    });
    local cageCenter = Vector(578, -1022, 1684);
    for (local i = 1; i <= 8; i ++) {
      local glassTrigger = ppmod.get("upper_glass_panel_trigger-" + i);
      local pos = glassTrigger.GetOrigin();
      local center = glassTrigger.GetCenter();
      glassTrigger.SetAbsOrigin(pos + (cageCenter - center).Normalize() * 24);
    }
    ppmod.create("paint_sphere").then(function (painter) {
      painter.SetOrigin(Vector(640, -574, 1536));
      painter.radius = 64.0;
      painter.Paint();
    });
    ppmod.fire([Vector(184, -1280, 1600), 8.0, "trigger_once"], "Kill");
    break;
  case "sp_a3_transition01":
    CreateStationaryPortal(1, Vector(-1329.7, -1998.26, -5895.97), Vector(0, 45, 0));
    CreateStationaryPortal(2, Vector(-2560.03, -255.066, -6070.79), Vector(0, 180, 0), false);
    ppmod.create("prop_tractor_beam").then(function (funnel) {
      funnel.SetOrigin(Vector(-1728, -2175, -5952));
      funnel.SetAngles(-90, 0, 0);
      funnel.Enable();
      funnel.SetLinearForce(250);
    });
    ppmod.fire("sphere_entrance_lift_button*", "Kill");
    ppmod.trigger(Vector(-2656, -130, -4852), Vector(32, 32, 32)).OnStartTouch(function () {
      ppmod.fire("sphere_entrance_lift_relay", "Trigger");
    });
    break;
  case "sp_a3_speed_ramp":
    ppmod.fire("paint_sprayer_button_2", "Press");
    ppmod.fire("paint_sprayer_button_3", "Press");
    CreateStationaryPortal(1, Vector(-1600, -896, 368.031), Vector(-90, 0, 0), false);
    CreateStationaryPortal(2, Vector(-212.031, -640, 608), Vector(-0, 180, 0), false);
    ppmod.wait(function () {
      CreateStationaryPortal(1, Vector(-1600, -384, 368.031), Vector(-90, 0, 0), false);
      CreateStationaryPortal(2, Vector(-959.998, -640, 943.961), Vector(90, 0, 0), false);
    }, 3.0);
    ppmod.wait(function () {
      CreateStationaryPortal(1, Vector(576, 0, 16.0312), Vector(-90, 0, 0));
      CreateStationaryPortal(2, Vector(1071.97, 384, 56.0293), Vector(0, 180, 0));
    }, 4.0);
    ppmod.addscript("chamber_exit_a-door_open", "OnTrigger", function () {
      CreateStationaryPortal(1, Vector(-212.031, -640, 608), Vector(-0, 180, 0));
      CreateStationaryPortal(2, Vector(-67.9688, -640, 896), Vector(-0, 0, 0));
    }, 0.0, 1);
    ppmod.get("prop_weighted_cube").SetOrigin(Vector(576, 0, 48));
    local button = ppmod.get(Vector(-1024, 680, 928), 8.0, "prop_under_button");
    button.SetOrigin(Vector(-1152, 680, 700));
    button.SetAngles(90, 0, 0);
    ppmod.fire("ramp_rotator", "Open");
    ppmod.fire("floor_button_1", "Kill");
    break;
  case "sp_a3_speed_flings":
    async(function () {
      for (local i = 0; i < 3; i ++) {
        yield ppmod.create("props_underground/wood_panel_64x128_01.mdl");
        yielded.SetOrigin(Vector(1980 + i * 128, 1520, -448));
        yielded.SetAngles(90, 0, 0);
      }
      for (local i = 0; i < 3; i ++) {
        yield ppmod.create("props_underground/wood_panel_64x128_01.mdl");
        yielded.SetOrigin(Vector(1980 + i * 128, 1426, -448));
        yielded.SetAngles(90, 0, 0);
      }
    })();
    local cube = ppmod.get("prop_weighted_cube");
    cube.SetOrigin(Vector(2171.84, 1474.69, -400));
    cube.SetAngles(0, 132, 0);
    ppmod.create("paint_sphere").then(function (painter) {
      painter.SetOrigin(Vector(2176, 1154, -320));
      painter.radius = 128;
      painter.Paint();
    });
    ppmod.create("paint_sphere").then(function (painter) {
      painter.SetOrigin(Vector(3512, 384, -320));
      painter.paint_type = 2;
      painter.radius = 128;
      painter.Paint();
    });
    ppmod.fire("paint_sprayer_speed", "Start");
    ppmod.fire("paint_sprayer_bounce", "Start");
    CreateStationaryPortal(1, Vector(3647.97, 384, -263.969), Vector(0, 180, 0));
    CreateStationaryPortal(2, Vector(2560, -128, -351.969), Vector(-90, 90, 0), false);
    ppmod.wait(function () {
      CreateStationaryPortal(2, Vector(3583.97, 1152, -7.9707), Vector(-0, 180, 0));
      ppmod.trigger(Vector(2816, -128, -352), Vector(64, 64, 12), "trigger_multiple").OnEndTouch(function () {
        if (activator != GetPlayer()) return;
        local vel = activator.GetVelocity();
        vel.z *= 1.25;
        activator.SetVelocity(vel);
      });
    }, 3.0);
    break;
  case "sp_a3_portal_intro":
    ppmod.create("ent_create_portal_weighted_antique").then(function (cube) {
      cube.SetOrigin(Vector(3362, -96, -2916));
      cube.SetAngles(0, 20, 0);
    });
    ppmod.create("ent_create_portal_weighted_antique").then(function (cube) {
      cube.SetOrigin(Vector(3362, -160, -2916));
      cube.SetAngles(0, 45, 0);
    });
    CreateStationaryPortal(1, Vector(2367.97, -224, -2567.97), Vector(-0, 180, 0));
    CreateStationaryPortal(2, Vector(2176, 975.969, -1991.97), Vector(-0, -90, 0));
    ppmod.get(Vector(2411.67, -96.11, -2559.75), 8.0, "trigger_portal_cleanser").Destroy();
    ppmod.hook("1970s_door2_door_*", "Close", function () { return false });
    ppmod.hook("1970s_door_2_areaportal", "Close", function () { return false });
    ppmod.get(Vector(2432.11, 1203.67, -1983.75), 8.0, "trigger_portal_cleanser").Destroy();
    ppmod.fire("pumproom_entrance_door-door_close", "Kill");
    ppmod.hook("pumproom_door_1_blackbrush", "Enable", function () { return false });
    ppmod.hook("pumproom_door_1_areaportal", "Close", function () { return false });
    ppmod.forent("models/props_bts/vertical_small_piston_body.mdl", function (piston) {
      local door = piston.GetMoveParent();
      local mins = piston.GetBoundingMins();
      local maxs = piston.GetBoundingMaxs();
      local size = (maxs - mins) * 0.5;
      size.z = 8.0;
      local trigger = ppmod.trigger(piston.GetCenter() - Vector(0, 0, maxs.z * 0.5) size, "trigger_multiple");
      trigger.spawnFlags = 8;
      trigger.SetMoveParent(piston);
      trigger.OnStartTouch(function ():(door) {
        door.Close();
      });
    });
    ppmod.create("prop_wall_projector").then(function (bridge) {
      bridge.SetOrigin(Vector(2176, 2384, -1888));
      bridge.SetAngles(-21, -90, 0);
      bridge.Disable();
      ppmod.create("props_underground/wood_panel_64x128_01.mdl").then(function (plank):(bridge) {
        plank.SetOrigin(Vector(2038, 2210, -1891));
        plank.SetAngles(58, 0, 0);
        plank.Disable();
        ppmod.addscript("pump_machine_relay", "OnTrigger", function ():(bridge, plank) {
          bridge.Enable();
          plank.Enable();
          CreateStationaryPortal(1, Vector(2112, 1017.25, -1640.94), Vector(-36.8699, -90, -0));
          CreateStationaryPortal(2, Vector(900.031, 1296.76, -1639.97), Vector(-0, 0, 0));
        });
      });
    });
    ppmod.wait(async(function () {
      for (local i = 0; i < 3; i ++) {
        yield ppmod.create("props_underground/wood_panel_64x128_01.mdl");
        yielded.SetOrigin(Vector(388, -192 + i * 128, 240));
        yielded.SetAngles(90, 90, 0);
      }
      for (local i = 0; i < 3; i ++) {
        yield ppmod.create("props_underground/wood_panel_64x128_01.mdl");
        yielded.SetOrigin(Vector(338 + i * 128, 192, 372));
        yielded.SetAngles(90, 0, 0);
      }
    }), 0.2);
    ppmod.addscript("@pump_machine_stop_relay", "OnTrigger", function () {
      local arrow = ppmod.project("signage/underground_arrow", Vector(364, 0, 48), Vector(0, 0, 0), 0, 64.0);
      arrow.lightFOV = 140.0;
    });
    ppmod.addscript("liftshaft_entrance_door-door_open", "OnTrigger", function () {
      CreateStationaryPortal(1, Vector(4015.97, -191.65, 295.688), Vector(0, 180, 0));
      CreateStationaryPortal(2, Vector(3915.79, 114.105, 5687.32), Vector(-0, -175.236, 0));
      ppmod.create("paint_sphere").then(function (painter) {
        painter.SetOrigin(Vector(3915.79, 114.105, 5687.32));
        painter.radius = 128.0;
        painter.paint_type = 3;
        painter.Paint();
      });
    });
    ppmod.fire("sphere_intro_walkway_brush", "Kill");
    break;
  case "sp_a3_end":
    ppmod.give({ linked_portal_door = 2 }).then(function (ents) {
      local wportals = ents.linked_portal_door;
      wportals[0].SetOrigin(Vector(-320, -896, -5056));
      wportals[0].SetAngles(0, -90, 0);
      wportals[1].SetOrigin(Vector(-2208, -480, 3328));
      wportals[1].SetAngles(0, -90, 0);
      wportals[0].targetname = "_mod_wportal1";
      wportals[1].targetname = "_mod_wportal2";
      wportals[0].SetPartner("_mod_wportal2");
      wportals[1].SetPartner("_mod_wportal1");
      wportals[0].Open();
      wportals[1].Open();
      wportals[1].AddOutput("OnPlayerTeleportToMe", "_mod_wportal*", "Close", "", 0.2);
    });
    break;
  case "sp_a4_intro":
    CreateStationaryPortal(2, Vector(-863.969, -192, 160), Vector(-0, 0, 0));
    CreateStationaryPortal(1, Vector(-655.969, -18.2188, 312.031), Vector(-0, 0, 0));
    ppmod.addscript("@entrance_door2-close_door_rl", "OnTrigger", function () {
      CreateStationaryPortal(1, Vector(1695.59, -767.969, 568.031), Vector(-0, 90, 0));
      CreateStationaryPortal(2, Vector(1120.03, -319.744, 312.031), Vector(0, 0, 0));
    }, 0.0, 1);
    ppmod.hook("button_2_cube_dissolve_trigger", "Enable", function () {
      try {
        ppmod.get("cube_dropper_box").GetMoveParent().Dissolve();
      } catch (e) {
        ppmod.get("cube_dropper_box").Dissolve();
      }
      return true;
    });
    local trigger = ppmod.get("button_2_cube_dissolve_trigger");
    trigger.SetSize(trigger.GetBoundingMins() * 2.0, trigger.GetBoundingMaxs() * 2.0);
    break;
  case "sp_a4_tb_intro":
    CreateStationaryPortal(1, Vector(1664, 896, -511.969), Vector(-90, -90.0792, 0));
    CreateStationaryPortal(2, Vector(1664, 512, 543.969), Vector(90, -89.2207, 0));
    break;
  case "sp_a4_tb_trust_drop":
    CreateStationaryPortal(1, Vector(351.998, 1023.97, 160), Vector(0, -90, 0));
    CreateStationaryPortal(2, Vector(-447.703, 1246, 616), Vector(-30, -90, 0));
    ppmod.create("props_map_editor/arm4_white_30deg.mdl").then(function (panel) {
      panel.SetOrigin(Vector(-447.703, 1216, 608));
      panel.SetAngles(90, -90, 0);
      panel.collisionGroup = 21;
    });
    ppmod.create("props_map_editor/arm4_white_90deg.mdl").then(function (panel) {
      panel.SetOrigin(Vector(-192, 448, 992));
      panel.SetAngles(90, 90, 0);
    });
    ppmod.hook("@exit_door-door_open_relay", "Trigger", function () {
      if (activator == null) return true;
      ppmod.fire(self, "Trigger", "", FrameTime() * 2.0);
    });
    break;
  case "sp_a4_tb_wall_button":
    CreateStationaryPortal(1, Vector(-480.031, 960, 64), Vector(-0, 180, 0));
    CreateStationaryPortal(2, Vector(32, 1535.97, 320), Vector(-0, -90, -0));
    ppmod.wait(function () {
      ppmod.get("models/portals/portal1.mdl").SetActivatedState(0);
      ppmod.get("models/props/portal_emitter.mdl").Skin(0);
      ppmod.create("props/portal_emitter.mdl").then(function (emitter) {
        emitter.SetOrigin(Vector(-471.969, 960, 446.469));
        emitter.SetAngles(0, 0, 0);
        emitter.collisionGroup = 1;
        emitter.targetname = "_mod_map_end_emitter";
      });
    }, 0.2);
    ppmod.hook("tractorbeam_emitter", "Enable", function () {
      ppmod.get("models/props/portal_emitter.mdl").Skin(1);
      CreateStationaryPortal(1, Vector(-480.031, 960, 64), Vector(-0, 180, 0), false);
      return true;
    });
    ppmod.get("flingroom_1_circular_catapult_1_target_1").SetOrigin(Vector(-512, 1232, 0));
    ppmod.create("props_map_editor/arm4_white_90deg.mdl").then(function (panel) {
      panel.SetOrigin(Vector(-416, 960, 64));
      panel.SetAngles(0, 0, 0);
    });
    ppmod.wait(function () {
      ppmod.keyval("targetpanel_*", "Targetname", "");
    }, 2.0);
    local exitTrigger = ppmod.trigger(Vector(544, 960, 256), Vector(128, 192, 128), "trigger_multiple");
    exitTrigger.OnStartTouch(function () {
      ppmod.fire("_mod_map_end_emitter", "Skin", 1);
      CreateStationaryPortal(1, Vector(-471.969, 960, 446.469), Vector(0, 0, 0), false);
    });
    exitTrigger.OnEndTouch(function () {
      ppmod.fire("_mod_map_end_emitter", "Skin", 0);
      CreateStationaryPortal(1, Vector(-480.031, 960, 64), Vector(-0, 180, 0), false);
    });
    break;
  case "sp_a4_tb_polarity":
    ppmod.fire("npc_portal_turret_floor", "Kill");
    CreateStationaryPortal(1, Vector(128, 224.031, 64), Vector(-0, 90, 0));
    CreateStationaryPortal(2, Vector(-575.969, 671.998, 320), Vector(0, 0, 0));
    CreateStationaryPortal(1, Vector(447.969, 480, 64), Vector(-0, 180, 0));
    ppmod.wait(function () {
      ppmod.get("_mod_stationary_emitter").Skin(0);
    }, 0.2);
    ppmod.create("props_factory/factory_panel_metal_chopped_top_128x128.mdl").then(function (panel) {
      panel.SetOrigin(Vector(384, 1376, 2));
      panel.SetAngles(90, 0, 0);
    });
    ppmod.button("prop_floor_button", Vector(384, 1376, 8)).then(function (button) {
      button.OnPressed(function () {
        CreateStationaryPortal(1, Vector(128, 224.031, 64), Vector(-0, 90, 0), false);
        ppmod.prev("_mod_stationary_emitter").Skin(0);
        ppmod.get("_mod_stationary_emitter").Skin(1);
      });
      button.OnUnpressed(function () {
        CreateStationaryPortal(1, Vector(447.969, 480, 64), Vector(-0, 180, 0), false);
        ppmod.get("_mod_stationary_emitter").Skin(0);
        ppmod.prev("_mod_stationary_emitter").Skin(1);
      });
    });
    ppmod.create("prop_wall_projector").then(function (bridge) {
      bridge.SetOrigin(Vector(-256, 96, 240));
      bridge.SetAngles(0, 90, 0);
      bridge.Enable();
    });
    break;
  case "sp_a4_tb_catch":
    CreateStationaryPortal(2, Vector(-439.449, 991.748, 265.688), Vector(-45, 0, 0));
    CreateStationaryPortal(1, Vector(0, 64, -135.969), Vector(-90, 270, 0));
    CreateStationaryPortal(2, Vector(-503.969, -480.002, 608), Vector(0, 0, 0));
    ppmod.button("prop_button", Vector(0, 162, 800), Vector(180, 90, 0)).then(function (button) {
      button.SetTimer(true);
      button.SetDelay(3.0);
      button.OnPressed(function () {
        CreateStationaryPortal(2, Vector(-439.449, 991.748, 265.688), Vector(-45, 0, 0), false);
        ppmod.prev("_mod_stationary_emitter").Skin(0);
        ppmod.get("_mod_stationary_emitter").Skin(2);
        ppmod.wait(function () {
          CreateStationaryPortal(2, Vector(-503.969, -480.002, 608), Vector(0, 0, 0), false);
          ppmod.get("_mod_stationary_emitter").Skin(0);
          ppmod.prev("_mod_stationary_emitter").Skin(2);
        }, 3.0);
      });
    });
    break;
  case "sp_a4_stop_the_box":
    ppmod.fire("flingroom_1_circular_catapult_1", "Kill");
    ppmod.fire("flingroom_1_circular_catapult_1_arm_1", "Skin", 1);
    CreateStationaryPortal(1, Vector(576.031, -64, 950.094), Vector(0, 0, 0));
    CreateStationaryPortal(2, Vector(576.031, -63.7402, 536.031), Vector(0, 0, 0));
    break;
  case "sp_a4_laser_catapult":
    ppmod.fire("trigger_push", "Kill");
    ppmod.fire("04_laser", "TurnOff");
    ppmod.addscript("pushout_fling_panel", "OnTrigger", function () {
      CreateStationaryPortal(1, Vector(38.8516, 192, 55.8516), Vector(-45, 0, 0));
      CreateStationaryPortal(2, Vector(-256.184, -733.907, 75.2218), Vector(-46.1408, 90, 0));
    }, 1.5);
    ppmod.create("props_bts/hanging_stair_128.mdl").then(function (stairs) {
      stairs.SetOrigin(Vector(128, -64, -66));
      stairs.SetAngles(0, 90, 0);
    });
    local platform = ppmod.get("lift_2_door_ride");
    platform.SetOrigin(platform.GetOrigin() - Vector(0, 0, 128));
    platform.SetVelocity(Vector());
    local beam = ppmod.get("lift_2_door_2");
    beam.SetAbsOrigin(beam.GetOrigin() - Vector(0, 0, 128));
    for (local i = 1; i <= 4; i ++) {
      ppmod.fire("exit_panel_"+i+"-proxy", "Kill");
    }
    break;
  case "sp_a4_laser_platform":
    CreateStationaryPortal(1, Vector(895.969, -1472, 192), Vector(0, 180, 0));
    CreateStationaryPortal(2, Vector(-191.186, -1152.03, 328.031), Vector(0, -90, 0));
    local catcher = ppmod.get(Vector(448, -2576, 32), 16.0, "prop_laser_catcher");
    catcher.SetOrigin(Vector(-192, -2572, 282));
    catcher.SetAngles(0, 90, 0);
    ppmod.create("prop_wall_projector").then(function (bridge) {
      bridge.SetOrigin(Vector(-128, -1152, 320));
      bridge.SetAngles(0, -90, 90);
      bridge.Enable();
    });
    ppmod.create("props_factory/factory_panel_metal_chopped_top_128x128.mdl").then(function (panel) {
      panel.SetOrigin(Vector(448, -2562, 64));
      panel.SetAngles(0, 90, 0);
    });
    ppmod.create("prop_wall_projector").then(function (bridge):(catcher) {
      bridge.SetOrigin(Vector(-448, -2048, 0));
      bridge.SetAngles(-25, -90, 0);
      bridge.Disable();
      catcher.AddOutput("OnPowered", bridge, "Disable");
      catcher.AddOutput("OnUnpowered", bridge, "Enable");
    });
    async(function () {
      for (local i = 0; i < 3; i ++) {
        yield ppmod.create("props_bts/hanging_walkway_128d.mdl");
        yielded.SetOrigin(Vector(-188, -1728 - i * 128, -6));
        yielded.SetAngles(0, 0, 0);
      }
    })();
    break;
  case "sp_a4_speed_tb_catch":
    CreateStationaryPortal(1, Vector(511.969, 1376.45, 124.23), Vector(-0, 180, 0));
    CreateStationaryPortal(2, Vector(256, 1600, 607.969), Vector(90, 0, 0));
    ppmod.fire("enable_box_stopper_relay", "Kill");
    ppmod.fire("raise_box_catcher_arms", "Kill");
    ppmod.create("prop_tractor_beam").then(function (funnel) {
      funnel.SetOrigin(Vector(-2064, 2544, 64));
      funnel.SetAngles(0, -90, 0);
      funnel.Enable();
      funnel.SetLinearForce(250);
    });
    // hack hack megahack
    ::TraceLine <- function (s, e, _) { return 1.0 };
    break;
  case "sp_a4_jump_polarity":
    ppmod.fire("antechamber-monster_box_template", "Kill");
    ppmod.fire("paint_sprayer", "Start");
    ppmod.create("props_map_editor/arm4_white_90deg.mdl").then(function (panel) {
      panel.SetOrigin(Vector(2208, -64, 192));
      panel.SetAngles(0, 0, 0);
    });
    ppmod.hook("antechamber-aud_mega_paint_splat_01", "PlaySound", function () {
      ppmod.wait(function () {
        ppmod.fire("tbeam", "SetLinearForce", -250);
        CreateStationaryPortal(1, Vector(416.031, 1026.2, 451.381), Vector(-0, 0, 0));
        CreateStationaryPortal(2, Vector(192, -311.969, 512), Vector(-0, 90, 0));
        CreateStationaryPortal(1, Vector(2143.97, -64.1641, 193.453), Vector(-0, 180, 0));
        ppmod.wait(function () {
          ppmod.get("_mod_stationary_emitter").Skin(0);
        }, 0.2);
      }, 1.0);
      return true;
    });
    local button = ppmod.get("button_1-button");
    ppmod.button("prop_floor_button", button.GetOrigin(), button.GetAngles()).then(function (newButton) {
      newButton.OnPressed(function () {
        CreateStationaryPortal(1, Vector(416.031, 1026.2, 451.381), Vector(-0, 0, 0), false);
        ppmod.fire("tbeam", "SetLinearForce", 250);
        ppmod.fire("tbeam_texture_toggler", "SetTextureIndex", 1);
        ppmod.prev("_mod_stationary_emitter").Skin(0);
        ppmod.get("_mod_stationary_emitter").Skin(1);
      });
      newButton.OnUnpressed(function () {
        CreateStationaryPortal(1, Vector(2143.97, -64.1641, 193.453), Vector(-0, 180, 0), false);
        ppmod.fire("tbeam", "SetLinearForce", -250);
        ppmod.fire("tbeam_texture_toggler", "SetTextureIndex", 0);
        ppmod.get("_mod_stationary_emitter").Skin(0);
        ppmod.prev("_mod_stationary_emitter").Skin(1);
      });
    });
    button.Destroy();
    ppmod.keyval("fling_catapult", "lowerThreshold", 0.38);
    ppmod.addscript("open_fling_panel", "OnTrigger", function () {
      CreateStationaryPortal(1, Vector(768.277, -256.287, 128.031), Vector(-90, 0.381939, 0), false);
      CreateStationaryPortal(2, Vector(927.668, -290.713, 336.033), Vector(-46.1409, 90.3629, 0), false);
      ppmod.wait(function () {
        ::CreateStationaryPortal <- function (...) { };
      }, 0.2);
      ppmod.fire("_mod_stationary_emitter", "Skin", 0);
    }, 4.5);
    ppmod.create("prop_wall_projector").then(function (bridge) {
      bridge.SetOrigin(Vector(192, 0, 640));
      bridge.SetAngles(90, 90, 0);
      bridge.Enable();
    });
    break;
  case "sp_a4_finale1":
    ppmod.create("paint_sphere").then(function (painter) {
      painter.SetOrigin(Vector(-8898, -2054, -260));
      painter.radius = 128.0;
      painter.paint_type = 3;
      painter.Paint();
    });
    CreateStationaryPortal(1, Vector(-9715, -2510, 216), Vector(0, 30, 0));
    CreateStationaryPortal(2, Vector(-8896.55, -2050.64, -259.969), Vector(-90, 8, 0));
    ppmod.wait(function () {
      local emitter = ppmod.prev("_mod_stationary_emitter");
      emitter.targetname = "crusher_platform";
      emitter.SetHook("Kill", function () {
        CreateStationaryPortal(1, Vector(-10882, -1536.03, 648.498), Vector(-0, 180, 0));
        CreateStationaryPortal(2, Vector(-10983.3, -1432.35, -807.402), Vector(-90, -60, 0));
        return true;
      });
    }, 0.2);
    ppmod.fire([Vector(-12840, -1704, -160.42), 8.0, "trigger_once"], "Kill");
    ppmod.fire([Vector(-12832, -2360, -137.29), 8.0, "trigger_once"], "Kill");
    ppmod.fire("final_door-proxy", "OnProxyRelay1");
    ppmod.fire("brush_catwalk_monster_blocker", "Kill");
    ppmod.fire("template_boxmonster", "Kill");
    break;
  case "sp_a4_finale2":
    ppmod.fire("detector_portal1", "Kill");
    ppmod.fire("movelinear_testchamber", "Close", "", 0.2);
    ppmod.addscript("trigger_move_finished", "OnStartTouch", function () {
      CreateStationaryPortal(1, Vector(2249.03, 706.92, -275.684), Vector(0, 0, 0));
      CreateStationaryPortal(2, Vector(12200.6, 11735.2, 8607.97), Vector(90, -179.863, 0));
      ppmod.wait(function () {
        ppmod.addscript("models/portals/portal2.mdl", "OnPlayerTeleportToMe", function () {
          CreateStationaryPortal(1, Vector(379.619, -2559.97, -382.102), Vector(0, 90, 0));
          CreateStationaryPortal(2, Vector(-1088, -127.969, 192), Vector(0, 90, 0));
        }, 0.5);
      }, 0.2);
    });
    ppmod.create("prop_monster_box").then(function (cube) {
      cube.SetOrigin(Vector(-511, 535, -21));
      cube.SetAngles(0, 27, 0);
    });
    ppmod.fire([Vector(-758, -1216, -448), 8.0, "trigger_portal_cleanser"], "Kill");
    ppmod.fire([Vector(-474.297, -1236, -448), 8.0, "trigger_once"], "Kill");
    ppmod.button("prop_floor_button", Vector(-640, -1216, -318), Vector(90, 0, 0)).then(function (button) {
      button.OnPressed(function () {
        ppmod.fire("areaportal_bts_door_2", "Open");
        ppmod.fire("bts_door_2-proxy", "OnProxyRelay1");
        ppmod.fire("bts_door_2-proxy", "Kill", "", 0.2);
      })
    });
    ppmod.fire([Vector(-3152, -1928, -240), 8.0, "trigger_once"], "Kill");
    ppmod.fire([Vector(-3152, -1640, -256), 8.0, "trigger_portal_cleanser"], "Kill");
    ppmod.button("prop_floor_button", Vector(-3152, -1952, -64), Vector(180, 0, 0)).then(function (button) {
      button.OnPressed(function () {
        ppmod.fire("@transition_script", "RunScriptCode", "TransitionFromMap()");
        ppmod.fire("@transition_script", "Kill", "", 0.2);
      })
    });
    ppmod.addscript("exit_door-open_door", "OnTrigger", function () {
      local arrow = ppmod.project("signage/underground_arrow", Vector(-3120, -1952, -256), Vector(0, 0, 0), 0, 64.0);
      arrow.lightFOV = 120.0;
    }, 0.0, 1);
    break;
  case "sp_a4_finale3":
    ppmod.button("prop_floor_button", Vector(-3152, -1952, -64), Vector(180, 0, 0));
    ppmod.create("prop_monster_box").then(function (cube) {
      cube.Use("", 0.4, GetPlayer(), GetPlayer());
    });
    ppmod.fire("autoinstance1-@exit_elevator_cleanser1", "Kill");
    ppmod.fire("autoinstance1-fizzler_models", "Kill");
    CreateStationaryPortal(1, Vector(-383.971, -2546.76, 379.676), Vector(0, 0, 0));
    CreateStationaryPortal(2, Vector(-481.35, -1536.03, -23.9707), Vector(-0, -90, -0));
    async(function () {
      for (local i = 0; i < 3; i ++) {
        yield ppmod.create("props_office/computer_cabinet01.mdl");
        yielded.SetOrigin(Vector(-353.5, -2628 - i * 36, 128));
        yielded.SetAngles(0, 0, 0);
      }
      for (local i = 0; i < 3; i ++) {
        yield ppmod.create("props_office/computer_cabinet01.mdl");
        yielded.SetOrigin(Vector(-331, -2628 - i * 36, 128));
        yielded.SetAngles(0, 0, 0);
      }
    })();
    ppmod.addscript("conveyor_button_pressed", "OnTrigger", function () {
      CreateStationaryPortal(1, Vector(64, 320, -279.969), Vector(-90, -90, 0), false);
      CreateStationaryPortal(2, Vector(-960, 88, -319.969), Vector(-90, 90, 0), false);
      ppmod.wait(function () {
        CreateStationaryPortal(1, Vector(-1275.97, -348.869, -192.947), Vector(0, 0, 0), false);
      }, 3.0);
    });
    local tbeam = ppmod.get("tractorbeam_emitter");
    tbeam.SetOrigin(Vector(-252, 980, -280));
    tbeam.SetAngles(-7.4, 90, 0);
    tbeam.Enable();
    local funnelTrigger = ppmod.get(Vector(-256, 2416, 192), 8.0, "trigger_once");
    funnelTrigger.SetOrigin(funnelTrigger.GetOrigin() - Vector(0, 0, 320));
    ppmod.addscript("door_lair-open_door", "OnTrigger", function () {
      CreateStationaryPortal(1, Vector(-703.969, 5371.78, 248.031), Vector(0, 0, 0));
      CreateStationaryPortal(2, Vector(-703.969, 5376.08, 768.307), Vector(-0, 0, 0));
    });
    break;
  case "sp_a4_finale4":
    ppmod.fire("transition_portal*", "Kill");
    CreateStationaryPortal(1, Vector(-0.0800781, 269.221, 0.0292969), Vector(-90, -89.7913, 0));
    CreateStationaryPortal(1, Vector(-348.866, 779.257, 585.235), Vector(24, -60, 0));

    CreateStationaryPortal(1, Vector(-1680, -760, -2655.97), Vector(-90, 270, 0));
    CreateStationaryPortal(2, Vector(-1682, -330, -1104.03), Vector(90, 90, 0));
    ppmod.wait(function () {
      ppmod.get("_mod_stationary_emitter").Skin(0);
      ppmod.get("_mod_stationary_emitter", ppmod.get("_mod_stationary_emitter")).Skin(0);
    }, 0.2);
    ppmod.addscript("paint_white_sprayer_relay", "OnTrigger", function () {
      CreateStationaryPortal(1, Vector(-348.866, 779.257, 585.235), Vector(24, -60, 0), false);
      CreateStationaryPortal(2, Vector(449.273, -114.072, 0.03125), Vector(-90, -40.8564, 0));
      ppmod.get(Vector(-348.866, 779.257, 585.235), 32.0, "_mod_stationary_emitter").Skin(1);
    }, 3.5);
    ppmod.addscript("socket1_relay", "OnTrigger", function () {
      CreateStationaryPortal(1, Vector(-0.0800781, 269.221, 0.0292969), Vector(-90, -89.7913, 0), false);
      ppmod.get("_mod_stationary_emitter").Skin(1);
      ppmod.get(Vector(-348.866, 779.257, 585.235), 32.0, "_mod_stationary_emitter").Skin(0);
    });
    ppmod.addscript("core2_template", "OnEntitySpawned", function () {
      ppmod.fire("@core02", "ClearParent", "", 7.5);
      ppmod.fire("@core02", "EnableMotion", "", 7.5);
    });
    ppmod.addscript("socket2_relay", "OnTrigger", function () {
      CreateStationaryPortal(1, Vector(-348.866, 779.257, 585.235), Vector(24, -60, 0));
      ppmod.get(Vector(-348.866, 779.257, 585.235), 32.0, "_mod_stationary_emitter").Skin(1);
      ppmod.get("_mod_stationary_emitter").Skin(0);
    });
    ppmod.addscript("core3_template", "OnEntitySpawned", function () {
      ppmod.fire("@core03", "ClearParent", "", 11.4);
      ppmod.fire("@core03", "EnableMotion", "", 11.4);
    });
    ppmod.addscript("stalemate_light_relay", "OnTrigger", function () {
      ppmod.fire("_mod_stationary_emitter", "Kill");
      CreateStationaryPortal(1, Vector(-0.0800781, 269.221, 0.0292969), Vector(-90, -89.7913, 0));
      CreateStationaryPortal(2, Vector(0.195312, 1502.24, 255.969), Vector(90, 90.6443, 0));
    });
    ppmod.addscript("ceiling_relay", "OnTrigger", function () {
      ppmod.fire("_mod_stationary_emitter", "Kill");
      CreateStationaryPortal(2, Vector(384, 32, 1543.97), Vector(90, -178.137, 0));
    }, 2.0);
    break;
  default:
    printl("No map-specific changes applied.");
    break;
}