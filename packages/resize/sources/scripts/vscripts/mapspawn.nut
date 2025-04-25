/**
 * Commissioned by Questathana
 * Implemented by PortalRunner
 * https://ko-fi.com/portalrunner/commissions
 */

if (!("Entities" in this)) return;
IncludeScript("ppmod");

const MOD_MAX_SCALE = 3.5;
const MOD_MIN_SCALE = 0.2;
const MOD_GUN_RANGE = 1280.0;
::MOD_JUMP_ON_SCALE <- false;

// Exploits a commentary script to create a keyvalued entity
// See maps/build_commentary.js for the rest of the implementation
::CreateScaledEntity <- function (classname, model, scalestr) {

  // Gets the targetname which refers to a specific template
  local shortModelName = ppstring(model).split("/").pop().slice(0, -4);
  local targetname = "_mod_" + shortModelName + "_" + scalestr + "x";

  // Finds the point_template entity for this scaled prop
  local template = ppmod.get(targetname + "_template");

  return ppromise(function (resolve, reject):(template, targetname) {
    template.OnEntitySpawned(function ():(resolve, targetname) {
      // Resolve the ppromise with the last entity created with this targetname
      resolve(ppmod.prev(targetname));
    }, 0.0, 1);
    template.ForceSpawn();
  });

};

// Development function - assists in creating stationary portals
::CreateStationaryPortal <- function (color = 1, pos = null, ang = Vector(), emitter = true) {

  local createEmitter = function (pos = null, ang = Vector()):(color, emitter) {

    if (pos == null) {
      local portal = ppmod.get("models/portals/portal"+ color +".mdl");
      if (!portal) return printl("Portal could not be found!!");
      pos = portal.GetOrigin();
      ang = portal.GetAngles();

      print("\n\nCreateStationaryPortal("+color+", "+pos+", "+ang+");\n\n");

      local old_emitter = ppmod.get("_mod_stationary_emitter");
      if (ppmod.validate(old_emitter)) old_emitter.Destroy();
    }

    if (emitter) ppmod.create("props/portal_emitter.mdl").then(function (emitter):(color, pos, ang) {
      emitter.SetOrigin(pos);
      emitter.SetAngles(ang.x, ang.y, ang.z);
      emitter.Skin(color);
      emitter.collisionGroup = 1;
      emitter.targetname = "_mod_stationary_emitter";
    });

  };

  if (pos == null) {
    ppmod.fire("weapon_portalgun", "FirePortal" + color);
    ppmod.wait(createEmitter, 0.1);
  } else {
    createEmitter(pos, ang);
    SendToConsole("portal_place 0 " + (color - 1) + " " + pos.ToKVString() + " " + ang.ToKVString());
  }

};

// Development function - uses existing portal positions to create
// a script for spawning stationary portals in the same locations
::PortalsToStationaryScript <- function () {
  local p1 = ppmod.get("models/portals/portal1.mdl");
  if (!ppmod.validate(p1)) return printl("First portal not found");
  local p2 = ppmod.get("models/portals/portal2.mdl");
  if (!ppmod.validate(p2)) return printl("Second portal not found");
  ::CreateStationaryPortal(1, p1.GetOrigin(), p1.GetAngles());
  ::CreateStationaryPortal(2, p2.GetOrigin(), p2.GetAngles());
  printl("CreateStationaryPortal(1, "+p1.GetOrigin()+", "+p1.GetAngles()+");");
  printl("CreateStationaryPortal(2, "+p2.GetOrigin()+", "+p2.GetAngles()+");");
};

ppmod.onauto(function () {

  // This map name is used in valve.rc to return to menu after generating soundcache
  // Using the credits specifically gives us the space menu background
  if (GetMapName() == "SP_A5_CREDITS") {
    SendToConsole("disconnect");
    return;
  }

  // Force commentary on to make use of custom commentary scripts
  SendToConsole("commentary 1;commentary 0;commentary 1");

  SendToConsole("hud_saytext_time 0");
  SendToConsole("sv_cheats 1");
  SendToConsole("sv_alternateticks 0");

  local mod = {
    pplayer = ppmod.player(GetPlayer()),
    pitch = null,
    entity = null,
    lastUsed = null,
    rayents = [
      "prop_weighted_cube",
      "phys_bone_follower"
    ],
    buttonTimeout = null,
    voidpos = Vector(65536, 65536, 65536)
  };

  SendToConsole("alias +attack2 +attack");
  mod.pplayer.oninput("+attack", function ():(mod) {

    local start = mod.pplayer.eyes.GetOrigin();
    local end = start + mod.pplayer.eyes.GetForwardVector() * MOD_GUN_RANGE;

    local ent = ppmod.ray(start, end, mod.rayents).entity;
    if (!ppmod.validate(ent)) {
      if (!mod.pplayer.holding()) return;
      ent = mod.lastUsed;
    }
    if (ent.GetClassname() != "prop_weighted_cube") {
      if (!mod.pplayer.holding()) return;
      ent = mod.lastUsed;
    }

    // If MOD_JUMP_ON_SCALE is set, force player to jump when scaling props under them
    // This is hacky, and should only be used in specific scenarios
    if (MOD_JUMP_ON_SCALE) {
      if (ent.GetOrigin().z < mod.pplayer.ent.GetOrigin().z) {
        SendToConsole("+jump");
        ppmod.wait("SendToConsole(\"-jump\")", FrameTime() * 2);
      }
    }

    // Check if we've targeted an already scaled prop
    local scope = ent.GetScriptScope();
    if ("_mod_substitute_owner" in scope) {
      // Redirect targeting to actual source entity
      ent = scope._mod_substitute_owner;
      scope = ent.GetScriptScope();
    }

    if (!("_mod_scale_factor" in scope)) {
      scope._mod_default_mins <- ent.GetBoundingMins();
      scope._mod_default_maxs <- ent.GetBoundingMaxs();
      scope._mod_scale_factor <- 1.0;
      scope._mod_substitute <- null;
    }

    // Pass Dissolve inputs through to the substitute prop
    ppmod.hook(ent, "Dissolve", function () {
      if (activator == null) return true;
      if (!self.ValidateScriptScope()) return true;
      local scope = self.GetScriptScope();
      if (!("_mod_substitute" in scope)) return true;
      if (!ppmod.validate(scope._mod_substitute)) return true;
      scope._mod_substitute.Dissolve();
      return true;
    });

    // Keep track of the most recently used prop
    // This is used when scaling a held prop that is slightly out of LOS
    if (!("InputUse" in scope)) {
      scope.InputUse <- function ():(mod) {
        mod.lastUsed = self;
        return true;
      }
    }

    mod.entity = ent;
    mod.pitch = mod.pplayer.eyes.GetAngles().x;

  });

  SendToConsole("alias -attack2 -attack");
  mod.pplayer.oninput("-attack", function ():(mod) {
    mod.entity = null;
    mod.pitch = null;
  });

  // Draw an outline around the currently highlighted prop
  ppmod.interval(function ():(mod) {

    if (mod.pplayer.holding()) return;

    local start = mod.pplayer.eyes.GetOrigin();
    local end = start + mod.pplayer.eyes.GetForwardVector() * MOD_GUN_RANGE;

    local ent = ppmod.ray(start, end, mod.rayents).entity;
    if (!ppmod.validate(ent)) return;
    if (ent.GetClassname() != "prop_weighted_cube") return;

    local c = ent.GetCenter();
    local f = ent.GetForwardVector();
    local u = ent.GetUpVector();
    local l = ent.GetLeftVector();
    local mins = ent.GetBoundingMins();
    local maxs = ent.GetBoundingMaxs();

    // Compute the 8 bounding box corners
    local corners = [
      c + f * mins.x + u * mins.z + l * mins.y,
      c + f * maxs.x + u * mins.z + l * mins.y,
      c + f * mins.x + u * maxs.z + l * mins.y,
      c + f * maxs.x + u * maxs.z + l * mins.y,
      c + f * mins.x + u * mins.z + l * maxs.y,
      c + f * maxs.x + u * mins.z + l * maxs.y,
      c + f * mins.x + u * maxs.z + l * maxs.y,
      c + f * maxs.x + u * maxs.z + l * maxs.y
    ];

    // Define the 12 edges of the box (pairs of corner indices)
    local edges = [
      [0, 1], [0, 2], [0, 4], [3, 1], [3, 2], [3, 7],
      [5, 1], [5, 4], [5, 7], [6, 2], [6, 4], [6, 7]
    ];

    // Draw the edges
    foreach (edge in edges) {
      DebugDrawLine(corners[edge[0]], corners[edge[1]], 0, 255, 0, false, -1);
    }

  });

  ppmod.interval(function ():(mod) {

    // Remove the portalgun if the player has one
    local pgun = ppmod.get("weapon_portalgun");
    if (ppmod.validate(pgun)) {
      pgun.Destroy();
      ppmod.fire("viewmodel", "DisableDraw");
    }

    if (!mod.entity || !mod.pitch) return;
    if (!ppmod.validate(mod.entity)) return;

    local ent = mod.entity;
    local scope = ent.GetScriptScope();
    local scale = scope._mod_scale_factor;

    local currPitch = mod.pplayer.eyes.GetAngles().x;
    local pitchDiff = mod.pitch - currPitch;
    local scaleDiff = 0.0;

    if (pitchDiff > 2.0) { // Player looked up
      mod.pitch = currPitch;
      // The max size for laser cubes is reduced,
      // otherwise they become too big to carry at their largest
      if (
        scale > MOD_MAX_SCALE - 0.05
        || (ent.GetModelName() == "models/props/reflection_cube.mdl" && scale > 3.25)
      ) {
        SendToConsole("snd_playsounds P2Editor.MenuIncrement");
        return;
      }
      scaleDiff = 0.1;
    } else if (pitchDiff < -2.0) { // Player looked down
      mod.pitch = currPitch;
      if (scale < MOD_MIN_SCALE + 0.05) {
        SendToConsole("snd_playsounds P2Editor.MenuDecrement");
        return;
      }
      scaleDiff = -0.1;
    } else return; // Player didn't move their mouse much

    scale += scaleDiff;

    SendToConsole("snd_playsounds P2Editor.TileDoubleClick");

    // Save new scale factor in entity script scope
    scale = round(scale, 1);
    scope._mod_scale_factor = scale;

    // Retrieve entity position and angles for positioning replacement prop
    local pos = ent.GetOrigin();
    local ang = ent.GetAngles();
    // Move the entity to the world void position, disable all movement and collision
    ent.collisionGroup = 21;
    ent.moveType = 0;
    ent.SetOrigin(mod.voidpos);

    if (ppmod.validate(scope._mod_substitute)) {
      // If a substitute exists, use its position and angles instead
      pos = scope._mod_substitute.GetOrigin();
      ang = scope._mod_substitute.GetAngles();
      // Remove children from substitute
      local child = null;
      while (child = scope._mod_substitute.NextMoveChild(child)) {
        child.SetMoveParent(null);
      }
      // Remove existing scaled substitute prop
      scope._mod_substitute.Kill();
    }

    // If scale is being reset, move the original prop back into place
    if (scale < 1.1 && scale > 0.9) {
      ent.collisionGroup = 24;
      ent.moveType = 6;
      ent.SetOrigin(pos);
      ent.SetAngles(ang);
      // Update the cube's skin
      if (ent.GetClassname() == "prop_weighted_cube") {
        local mapname = GetMapName().tolower();
        if (mapname.slice(0, 5) == "sp_a1") ent.Skin(3);
        else if (mapname == "sp_a2_pit_flings") ent.Skin(1);
        else ent.Skin(0);
      }
      // If we were holding the resized prop, start holding this one too
      local holding = mod.pplayer.holding();
      if (holding) {
        holding.Destroy();
        ent.Use("", 0.0, mod.pplayer.ent, mod.pplayer.ent);
      } else {
        ent.Wake();
      }
      // If the resized prop had a child, reparent it to this entity
      if ("_mod_child" in scope && ppmod.validate(scope._mod_child)) {
        scope._mod_child.SetMoveParent(ent);
        scope._mod_child.SetLocalOrigin("0 0 0");
        scope._mod_child.SetLocalAngles("25 0 0");
        scope._mod_child.modelScale = 1.0;
      }
      return;
    }

    // Ragdoll any security cameras upon rescaling
    if (ent.GetClassname() == "npc_security_camera") {
      ent.Ragdoll();
    }

    // Get a fixed-point string representing the scale factor
    local fixed = floor(scale + 0.01) + "-" + round(scale % 1.0 * 10);

    // Create a substitute for this entity with the scaled version of the model
    CreateScaledEntity(ent.GetClassname(), ent.GetModelName(), fixed).then(function (prop):(mod, ent, pos, ang, scale, scaleDiff) {

      // If we were holding the prop before, pick up the resized one
      local holding = mod.pplayer.holding();
      if (holding) {
        holding.Destroy();
        prop.Use("", 0.0, mod.pplayer.ent, mod.pplayer.ent);
      }

      // Replace the targetname immediately to avoid conflicts
      prop.targetname = ent.GetName();

      // Teleport the new prop to the position of the original entity
      prop.SetOrigin(pos + Vector(0, 0, (scaleDiff > 0.0 ? 20.0 : 18.1) * scaleDiff));
      prop.SetAngles(ang);
      // Temporarily freeze the prop to stabilize fast back-to-back scaling
      if (!holding) {
        prop.DisableMotion();
        prop.EnableMotion("", 0.1);
      }

      // Run FCPS on the player if the prop intersects them
      if (!MOD_JUMP_ON_SCALE && ppmod.intersect(prop, mod.pplayer.ent)) {
        SendToConsole("debug_fixmyposition");
      }

      // Fix cube behavior and skins by setting the correct cube type
      if (ent.GetClassname() == "prop_weighted_cube") {
        local model = ppstring(ent.GetModelName()).split("/")[2];
        local mapname = GetMapName().tolower();
        switch (model) {
          case "metal_box.mdl": {
            prop.CubeType = 0;
            // All act 1 cubes are rusted
            if (mapname.slice(0, 5) == "sp_a1") {
              prop.Skin(3);
              prop.SkinType = 1;
            } else if (mapname == "sp_a2_pit_flings") {
              // Pit Flings uses the Companion Cube skin
              prop.Skin(1);
            }
            break;
          }
          case "reflection_cube.mdl": {
            // The first 3 chapter 2 maps use rusty laser cubes
            if (mapname == "sp_a2_laser_intro") {
              prop.Skin(1);
            } else if (mapname == "sp_a2_laser_stairs") {
              prop.Skin(1);
            } else if (mapname == "sp_a2_dual_lasers") {
              prop.Skin(1);
            }
            // Doing this instantly causes crashes, hence the delay
            ppmod.fire(prop, "AddOutput", "CubeType 2", 0.5);
            break;
          }
          case "underground_weighted_cube.mdl": {
            prop.CubeType = 4;
            break;
          }
        }
        // Temporarily disable buttons that intersect with freshly scaled cubes
        // This prevents doors from getting reverse step-DADed
        ppmod.forent("trigger_portal_button", function (button):(prop) {
          if (!ppmod.intersect(button, prop)) return;
          button.Disable();
        });
        if (ppmod.validate(mod.buttonTimeout)) mod.buttonTimeout.Destroy();
        mod.buttonTimeout = ppmod.wait(function () {
          ppmod.fire("trigger_portal_button", "Enable");
        }, 0.2);
      } else if (ent.GetClassname() == "npc_security_camera") {
        // Resized security cameras get ragdolled
        ent.Ragdoll();
      }

      // Store a handle to this prop in the original entity's script scope
      local entScope = ent.GetScriptScope();
      entScope._mod_substitute <- prop;

      // Keep track of the original entity in the substitute's script scope
      local propScope = prop.GetScriptScope();
      propScope._mod_substitute_owner <- ent;

      // Resize new prop's bounding box
      prop.SetSize(entScope._mod_default_mins * scale, entScope._mod_default_maxs * scale);

      // Fizzle the original prop when the substitute gets fizzled
      // This fixes issues with cubes not auto-respawning
      prop.OnFizzled(function ():(ent) {
        if (!ppmod.validate(ent)) return;
        ent.Dissolve();
      });

      // Forward call to the Use hook (if any) of the original entity
      ppmod.hook(prop, "Use", function ():(ent) {
        ent.GetScriptScope().InputUse.bindenv(this)();
        return true;
      });

      // If the entity had a child, restore it and set its scale factor
      if ("_mod_child" in entScope && ppmod.validate(entScope._mod_child)) {
        entScope._mod_child.SetMoveParent(prop);
        entScope._mod_child.SetLocalOrigin("0 0 0");
        entScope._mod_child.SetLocalAngles("25 0 0");
        if (scale < 1.0) {
          entScope._mod_child.modelScale = 0.4 + scale * 0.6;
        } else {
          entScope._mod_child.modelScale = scale;
        }
        // Don't render the prop itself
        prop.DisableDraw();
      }

    });

  });

  // Look for and replace Frankenturrets with regular cubes
  // I'd love to be able to scale these too, but fuck they're complicated
  if (GetMapName().tolower().slice(0, 5) == "sp_a4") {
    // Check every 0.2 seconds for new Frankenturrets
    ppmod.interval(function () {
      ppmod.forent("prop_monster_box", function (monster) {
        // Don't replace if the Frankenturret already has a parent
        if (ppmod.validate(monster.GetMoveParent())) return;
        // Create a new prop_weighted_cube to act as the physical cube
        ppmod.create("prop_weighted_cube").then(function (cube):(monster) {
          // Move the cube to where the Frankenturret was
          cube.SetOrigin(monster.GetOrigin());
          cube.SetAngles(monster.GetAngles());
          cube.targetname = monster.GetName();
          // Don't render the actual cube, it's used only for physics
          cube.DisableDraw();
          // Set the cube as the Frankenturret's parent
          monster.SetMoveParent(cube);
          monster.SetLocalOrigin("0 0 0", FrameTime());
          monster.SetLocalAngles("25 0 0", FrameTime());
          cube.GetScriptScope()._mod_child <- monster;
          // Disable all collisions for the Frankenturret, it's used only for visuals
          monster.collisionGroup = 21;
          monster.SetSize(Vector(), Vector());
          // Forward some inputs to the parent cube
          local forwardInputs = ["Use", "Dissolve", "SilentDissolve", "Silentdissolve", "Kill"];
          foreach (input in forwardInputs) {
            ppmod.hook(monster, input, function ():(input) {
              if (activator == null) return true;
              ppmod.fire(self.GetMoveParent(), input, "", 0.0, activator, caller);
              if (input != "Use") {
                self.SetMoveParent(null);
                self.Kill();
              }
              return false;
            });
          }
        });
      });
    }, 0.2);
  }

  // Apply map-specific changes
  IncludeScript("mapchanges.nut");

});
