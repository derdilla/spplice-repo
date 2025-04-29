if (!("Entities" in this)) return;
IncludeScript("ppmod4");
IncludeScript("sl_object-permanence");

::affectedEnts <- pparray([
  "prop_weighted_cube",
  "npc_security_camera",
  "npc_portal_turret_floor",
  "prop_monster_box",
  "prop_paint_bomb",
  "prop_physics",
  "prop_physics_override",
  "prop_exploding_futbol"
]);

::opaqueEnts <- ["phys_bone_follower"];

::thinRay <- function (start, end) {

  if (GetMapName().slice(0, 5) == "sp_a3") {
    return ppmod.ray(start, end, opaqueEnts);
  }

  local fvec = (end - start).Normalize();

  local ray1 = ppmod.ray(start, end, opaqueEnts);
  if (ray1.fraction == 1.0) return ray1;

  local ray2 = ppmod.ray(ray1.point + fvec * 16.0, ray1.point + fvec * 8.0, opaqueEnts);

  if (ray2.fraction == 0.0) return ray1;
  return thinRay(ray1.point + fvec * 16.0, end);

};

::isVisible <- function (ent) {

  local entpos = ent.GetOrigin();
  local eyepos = pplayer.eyes.GetOrigin();
  local eyefvec = pplayer.eyes.GetForwardVector();
  local dot = eyefvec.Dot((entpos - eyepos).Normalize());

  if (thinRay(entpos, eyepos).fraction == 1.0 && dot > 0.45) return true;
  return false;

};

local init = async(function () {

  yield ppmod.player(GetPlayer());
  ::pplayer <- yielded;

  ppmod.interval(function () {
    local ent = null;
    while (ent = Entities.Next(ent)) {
      if (!ent.IsValid()) continue;
      if (affectedEnts.find(ent.GetClassname()) == -1) continue;
      if (!ent.ValidateScriptScope()) continue;

      local scope = ent.GetScriptScope();
      if (!("observed" in scope)) {
        scope.observed <- false;
        scope.wait <- null;
      }

      if (isVisible(ent)) {

        if (!scope.observed) {
          scope.observed <- Time();
        } else if (scope.observed != true) {
          if (Time() - scope.observed >= 0.5) scope.observed <- true;
        }

        if (scope.wait) {
          scope.wait.Destroy();
          scope.wait <- null;
        }

      } else {

        if (scope.observed != true) {
          scope.observed <- false;
        }

        if (scope.observed == true && !scope.wait) {
          scope.wait <- ppmod.wait(function ():(ent) {
            ent.Destroy();
          }, 0.5);
        }

      }

    }
  });

});

ppmod.onauto(init);
