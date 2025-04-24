/**
 * Bun script for generating entity templates with commentary files.
 * This allows for creating fully keyvalued entities without decompiling.
 * Author: PortalRunner
 */

const { $ } = require("bun");
const fs = require("node:fs");

const MOD_MAX_SCALE = 4.0;
const MOD_MIN_SCALE = 0.2;

// Compiles a VPK file using Wine on Linux
async function makeVPK (source, output) {
  await $`wine "${__dirname}/../../bin/vpk.exe" "${source}"`.quiet();
  fs.renameSync(source + ".vpk", output);
}

// List of all single-player map files queried in no particular order
const maps = [
  "sp_a2_laser_chaining",
  "sp_a2_catapult_intro",
  "sp_a4_intro",
  "sp_a2_fizzler_intro",
  "sp_a3_crazy_box",
  "sp_a4_tb_intro",
  "sp_a1_intro2",
  "sp_a2_bts2",
  "sp_a4_finale3",
  "sp_a2_pull_the_rug",
  "sp_a3_speed_flings",
  "sp_a3_00",
  "sp_a2_bts6",
  "sp_a4_speed_tb_catch",
  "sp_a2_trust_fling",
  "sp_a4_tb_polarity",
  "sp_a1_intro7",
  "sp_a1_intro6",
  "sp_a2_ricochet",
  "sp_a2_laser_relays",
  "sp_a1_intro1",
  "sp_a3_03",
  "sp_a4_tb_trust_drop",
  "sp_a2_laser_vs_turret",
  "sp_a2_laser_stairs",
  "sp_a4_laser_platform",
  "sp_a1_intro3",
  "sp_a2_pit_flings",
  "sp_a1_intro4",
  "sp_a2_bridge_intro",
  "sp_a4_jump_polarity",
  "sp_a3_01",
  "sp_a2_bts4",
  "sp_a3_speed_ramp",
  "sp_a3_jump_intro",
  "sp_a1_wakeup",
  "sp_a2_column_blocker",
  "sp_a4_tb_catch",
  "sp_a4_stop_the_box",
  "sp_a2_bridge_the_gap",
  "sp_a2_bts3",
  "sp_a4_finale1",
  "sp_a2_laser_intro",
  "sp_a3_portal_intro",
  "sp_a4_finale2",
  "sp_a2_dual_lasers",
  "sp_a3_transition01",
  "sp_a2_intro",
  "sp_a2_sphere_peek",
  "sp_a2_triple_laser",
  "sp_a2_turret_blocker",
  "sp_a4_finale4",
  "sp_a4_tb_wall_button",
  "sp_a2_bts1",
  "sp_a2_bts5",
  "sp_a3_bomb_flings",
  "sp_a2_core",
  "sp_a4_laser_catapult",
  "sp_a2_turret_intro",
  "sp_a2_laser_over_goo",
  "sp_a3_end",
  "sp_a1_intro5"
];

// List of all scaleable entities, their model files, and any additional keyvalues
const entities = [
  {
    classname: "prop_weighted_cube",
    model: "models/props/metal_box",
    CubeType: 6,
    SkinType: 0,
    PaintPower: 4,
    NewSkins: 1,
    allowfunnel: 1
  },
  {
    classname: "prop_weighted_cube",
    model: "models/props/reflection_cube",
    CubeType: 6,
    SkinType: 0,
    PaintPower: 4,
    NewSkins: 1,
    allowfunnel: 1
  },
  {
    classname: "prop_weighted_cube",
    model: "models/props_underground/underground_weighted_cube",
    CubeType: 6,
    SkinType: 0,
    PaintPower: 4,
    NewSkins: 1,
    allowfunnel: 1
  },
  {
    classname: "prop_weighted_cube",
    model: "models/npcs/monsters/monster_a_box",
    CubeType: 6,
    SkinType: 0,
    PaintPower: 4,
    NewSkins: 1,
    allowfunnel: 1
  }
];

let output = `"Entities"\n{`;

for (const entity of entities) {
  for (let scale = MOD_MIN_SCALE; scale < MOD_MAX_SCALE + 0.05; scale += 0.1) {

    const scaleString = scale.toFixed(1).replace(".", "-");
    const targetname = `_mod_${entity.model.split("/").pop()}_${scaleString}x`;

    console.log(`Handling "${entity.model}" at ${scaleString}x scale`);

    output += `\n    "entity"\n    {`;

    for (const key of Object.keys(entity)) {
      if (key === "model") continue;
      output += `\n      "${key}" "${entity[key]}"`;
    }

    output += `
      "targetname" "${targetname}"
      "model" "${entity.model}_${scaleString}x.mdl"
      "origin" "65536 65536 65536"
      "angles" "0 0 0"
    }
    "entity"
    {
      "classname" "point_template"
      "targetname" "${targetname}_template"
      "template01" "${targetname}"
      "spawnflags" "2"
    }`;

  }
}

output += "\n}";

fs.mkdirSync(`${__dirname}/.tmp`);
fs.mkdirSync(`${__dirname}/.tmp/maps`);
for (const map of maps) {
  console.log(`Writing commentary file for ${map}`);
  await Bun.write(`${__dirname}/.tmp/maps/${map}_commentary.txt`, output);
}
console.log(`Building VPK file`);
await makeVPK(`${__dirname}/.tmp`, `${__dirname}/../pak02_dir.vpk`);
fs.rmSync(`${__dirname}/.tmp`, { recursive: true, force: true });
