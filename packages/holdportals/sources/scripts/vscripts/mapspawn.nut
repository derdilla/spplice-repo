if (!("Entities" in this)) return;
IncludeScript("ppmod4");
IncludeScript("sl_holdportals");

const PORTAL_ACROSS = 125.538838612; // sqrt((108 ^ 2) + (64 ^ 2))
const PORTAL_ACROSS_HALF = 62.7694193059;
const PORTAL_HOLD_DIST = 96.0;
const EPSILON = 0.0001;

const FAKE_MODEL_BLUE = "models/effects/fakeportalring_blue.mdl";
const FAKE_MODEL_RED = "models/effects/fakeportalring_orange.mdl";

const REAL_MODEL_BLUE = "models/portals/portal1.mdl";
const REAL_MODEL_RED = "models/portals/portal2.mdl";

::allowPortalsThroughPortals <- false;

::fakeHold <- null;
::fakePortals <- [];

::solidEnts <- "phys_bone_follower";

::createFakePortal <- async(function (pos, fvec, id, link = 0, first = true) {

  local model = id == 0 ? FAKE_MODEL_BLUE : FAKE_MODEL_RED;
  yield ppmod.create(model.slice(7));
  local prop = yielded;

  if (!prop.ValidateScriptScope()) return;
  local scope = prop.GetScriptScope();

  scope.fp_id <- id;
  scope.fp_linkage <- link;
  scope.fp_state <- false;

  prop.SetOrigin(pos);
  prop.SetForwardVector(fvec);

  local ang = prop.GetAngles();
  prop.SetAngles(ang.x + 90.0, ang.y, ang.z);

  prop.moveType = 0;
  prop.collisionGroup = 10;

  ::fakePortals.push(prop);

  if (first) {

    yield createFakePortal(pos - fvec * 4.0, -fvec, id, 1, false);
    local backface = yielded;
    backface.SetMoveParent(prop);

    yield ppmod.brush(pos, Vector(0.5, 32, 54), "func_rot_button", ang, true);
    local button = yielded;

    local trigger = ppmod.trigger(pos, Vector(0.5, 32, 54), "trigger_multiple", ang);

    button.collisionGroup = 2;
    button.spawnFlags = 1024;
    button.Lock();

    button.SetMoveParent(prop);
    trigger.SetMoveParent(prop);

    ppmod.addscript(button, "OnUseLocked", function ():(prop) {
      if (::allowPortalsThroughPortals == false) {
        if ((pplayer.eyes.GetOrigin() - prop.GetOrigin()).Length() > 128.0) return;
      }
      if (::fakeHold) ::fakeHold <- null;
      else ::fakeHold <- prop;
      ::togglePortals();
    });

    if (::allowPortalsThroughPortals == true) {
      ppmod.addscript(trigger, "OnStartTouch", function ():(button, prop) {
        button.SetMoveParent(null);
        button.SetAbsOrigin(ppmod.get("@transition_script").GetOrigin() - Vector(0, 0, 256));
      });
      ppmod.addscript(trigger, "OnEndTouch", function ():(button, prop) {
        button.SetAbsOrigin(prop.GetOrigin());
        button.SetMoveParent(prop);
      });
    }

  }

  return prop;

});

::fizzlePortal <- function (id) {

  local model = id == 0 ? REAL_MODEL_BLUE : REAL_MODEL_RED;

  local portal = null;
  while (portal = ppmod.get(model, portal)) {
    portal.SetActivatedState(false);
  }

};

::placePortal <- function (id, link, pos, ang) {
  // i really dont like this but it works
  ang.x -= 90.0;
  ang.x += ang.z;

  SendToConsole("portal_place "+link+" "+id+" "+pos.ToKVString()+" "+ang.ToKVString());
};

::togglePortals <- async(function () {
  foreach (prop in fakePortals) {

    if (!prop.IsValid()) continue;
    if (!prop.ValidateScriptScope()) continue;

    local scope = prop.GetScriptScope();

    scope.fp_state <- !scope.fp_state;

    if (!scope.fp_state) {
      ::fizzlePortal(scope.fp_id);
      prop.EnableDraw();
    } else {
      prop.DisableDraw();
      ::placePortal(scope.fp_id, scope.fp_linkage, prop.GetOrigin(), prop.GetAngles());
    }

  }
});

function getPlaneNormal (p1, p2, p3) {
  local v1 = p2 - p1;
  local v2 = p3 - p1;
  local normal = v1.Cross(v2);
  return normal.Normalize();
}

function isPointBehind (planePoint, normal, testPoint) {
  local vec = testPoint - planePoint;
  return vec.Dot(normal) < -EPSILON;
}

local init = async(function () {

  SendToConsole("sv_cheats 1");
  SendToConsole("sv_player_collide_with_laser 0");

  ppmod.keyval("weapon_portalgun", "CanFirePortal1", false);
  ppmod.keyval("weapon_portalgun", "CanFirePortal2", false);

  yield ppmod.player(GetPlayer());
  ::pplayer <- yielded;

  local startDelay = 0.2;

  switch (GetMapName().tolower()) {
    case "sp_a1_intro1":
    case "sp_a1_intro2":
      return;
    case "sp_a1_intro3":
      EntFire("portalgun*", "Kill");
      EntFire("snd_gun_zap", "Kill");
      ppmod.get(Vector(25, 1958, -299), 8, "trigger_once").Destroy();
      break;
    case "sp_a2_intro":
      startDelay = 20;
      ppmod.get(Vector(-1552, 448, -10924), 8, "trigger_once").Destroy();
      ppmod.get(Vector(-1256, 448, -10928), 8, "trigger_once").Destroy();
      EntFire("portalgun*", "Kill");
      EntFire("player_near_portalgun", "Kill");
      break;
    case "sp_a3_01":
      startDelay = 14;
      break;
    case "sp_a3_jump_intro":
      startDelay = 8;
      break;
  }

  ppmod.wait(function () {
    local startpos = GetPlayer().GetOrigin();
    local fvec = pplayer.eyes.GetForwardVector().Normalize2D();
    local rvec = pplayer.eyes.GetLeftVector().Normalize2D();
    ::mapStartInterval <- ppmod.interval(async(function ():(startpos, fvec, rvec) {

      local pos = pplayer.eyes.GetOrigin();
      if ((pos - startpos).Length2D() < 32.0) return;
      startpos.z = pos.z;

      ::mapStartInterval.Destroy();

      local mapname = GetMapName().tolower();
      if (mapname == "sp_a1_intro3") {
        yield ::createFakePortal(Vector(32, 1958, -243), Vector(0, -1), 0);
      } else {
        yield ::createFakePortal(startpos + fvec * 128 - rvec * 48, rvec, 0);
        if (mapname.slice(0, 5) != "sp_a1") {
          yield ::createFakePortal(startpos + fvec * 128 + rvec * 48, -rvec, 1);
        }
      }
      ::togglePortals();

    }));
  }, startDelay);

  ppmod.interval(function () {

    ppmod.keyval("weapon_portalgun", "CanFirePortal1", false);
    ppmod.keyval("weapon_portalgun", "CanFirePortal2", false);
    EntFire("weapon_portalgun", "Kill");
    EntFire("viewmodel", "DisableDraw");

    if (!::fakeHold) {
      EntFire("prop_weighted_cube", "EnablePickup");
      return;
    }
    if (!::fakeHold.IsValid()) {
      ::fakeHold <- null;
      return;
    }
    EntFire("prop_weighted_cube", "DisablePickup");

    local start = pplayer.eyes.GetOrigin();
    local fvec = pplayer.eyes.GetForwardVector() * PORTAL_HOLD_DIST;
    local rvec = pplayer.eyes.GetLeftVector() * 32;
    local uvec = pplayer.eyes.GetUpVector() * 54;
    local vel = GetPlayer().GetVelocity() * (1.0 / 60);

    local dest = [
      pplayer.eyes.GetOrigin() + fvec + vel - rvec + uvec,
      pplayer.eyes.GetOrigin() + fvec + vel + rvec + uvec,
      pplayer.eyes.GetOrigin() + fvec + vel + rvec - uvec,
      pplayer.eyes.GetOrigin() + fvec + vel - rvec - uvec
    ];

    local hits = array(4);
    for (local i = 0; i < 4; i ++) {
      hits[i] = ppmod.ray(start, dest[i], solidEnts).point;
      // DebugDrawBox(hits[i], Vector(-1,-1,-1), Vector(1,1,1), 255, 0, 0, 100, -1);
    }

    local normal = null, p1, p2, p3, p4;
    for (local i = 0; i < 4; i ++) {
      p1 = hits[i], p2 = hits[(i+1)%4], p3 = hits[(i+2)%4], p4 = hits[(i+2)%4];

      normal = getPlaneNormal(p1, p2, p3);
      if (!isPointBehind(p1, normal, p4)) break;
    }

    local pos = (p1 + p3) * 0.5;

    local v1 = (pos - p1).Normalize();
    local v2 = (pos - p2).Normalize();

    local points = [
      pos + v1 * PORTAL_ACROSS_HALF,
      pos + v2 * PORTAL_ACROSS_HALF,
      pos - v1 * PORTAL_ACROSS_HALF,
      pos - v2 * PORTAL_ACROSS_HALF
    ];

    local minfrac = 1.0;
    for (local i = 0; i < 4; i ++) {
      local frac = ppmod.ray(points[i] - normal * PORTAL_HOLD_DIST, points[i], solidEnts).fraction;
      if (frac > 0.8 && frac < minfrac) minfrac = frac; // the >0.8 is a hack :/
    }
    pos -= normal * (1.0 - minfrac) * PORTAL_HOLD_DIST;

    local fixang = Vector();
    if (fabs(fabs(normal.z) - 1) < EPSILON) {
      normal = Vector(0, 0, normal.z);
      fixang.y = pplayer.eyes.GetAngles().y + 180.0;
    }

    ::fakeHold.SetAbsOrigin(pos);
    ::fakeHold.SetForwardVector(-normal);

    local ang = ::fakeHold.GetAngles() + fixang;
    ::fakeHold.SetAngles((ang.x + 90.0) % 360.0, ang.y, ang.z);

  });

});

ppmod.onauto(init);
