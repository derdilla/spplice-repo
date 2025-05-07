// This print statement is found in the original mapspawn.nut file
// There's no reason to keep it, other than to maintain normal console output
printl("==== calling mapspawn.nut");

// Ensure we're running on the server's script scope
if (!("Entities" in this)) return;

::__elRunTicks <- 0;
::__elticksToString <- function (t) {

  local output = "";
  local hrs = floor(t / 108000.0);
  local min = floor(t / 1800.0);
  local sec = (t % 1800.0) / 30.0;

  if (hrs != 0) {
    output += format("%d:%s%d:", hrs, (min % 60) < 10 ? "0" : "", min % 60);
  }
  else if (min != 0) {
    output += format("%d:", min);
  }

  if (sec < 10) {
    output += "0";
  }

  output += format("%.3f", sec);

  return output;

};

// The entrypoint function - called once entity I/O has initialized
::__elInit <- function () {
  /**
   * Create a "logic_auto" entity for linking functions on load, but only
   * if we haven't done that already, to ensure we create only one.
   *
   * This is the only entity created by this script. It is harmless, and
   * practically unconfigurable. Almoast every map already has one, we're
   * just making sure that we have one that we can rely on.
   */
  if (Entities.FindByName(null, "__elLogicAuto")) return;
  local auto = Entities.CreateByClassname("logic_auto");
  auto.__KeyValueFromString("Targetname", "__elLogicAuto");
  auto.ConnectOutput("OnNewGame", "__elLoad");
  auto.ConnectOutput("OnLoadGame", "__elLoad");
  ::__elFirstInit();
};

/**
 * On the very first load, since we've only just created a "logic_auto",
 * it cannot yet be used for detecting when the map has fully loaded.
 * Instead, we recursively check for if the player has finished loading,
 * and then manually call the on-load functions.
 */
::__elFirstInit <- function () {
  if (!GetPlayer()) {
    EntFireByHandle(Entities.First(), "RunScriptCode", "::__elFirstInit()", FrameTime(), null, null);
    return;
  } else {
    ::__elTicks <- 0;
    ::__elSetup();
    ::__elLoad();
  }
};

// Called only once on the initial map load
::__elSetup <- function () {
  // Print run start signature
  if (GetMapName() == "sp_a1_intro1") printl("elStart");
};

// Called after the map has finished loading, on every load
::__elLoad <- function () {
  // Store the server time for the start of the current session
  // This is later used as an offset to calculate time since last load
  ::__elSessionOffset <- Time() * 30.0;
  // Start (or resume) elTick recursion
  ::__elTick();
};

// Returns the time in ticks since the last load
::__elGetSessionTicks <- function () {
  return (Time() * 30.0 - ::__elSessionOffset).tointeger();
};

// Called when the map end condition is reached
::__elFinish <- function () {
  // Print run end signature followed by the session time in ticks
  // This is later detected by main.js and used for submitting the run
  printl("\nelFinish " + ::__elGetSessionTicks());
};

/**
 * This function is called on every console tick, i.e. ~30 times per second.
 *
 * We achieve this by recursively running the `script` console command to
 * delay the next execution of the function into the next console tick.
 * This has the added benefit of maintaining the timer during pauses.
 */
::__elTick <- function () {

  // If we're paused (engine frame time is zero), decrement session offset
  // This effectively times paused ticks, albeit not entirely accurately
  if (FrameTime() == 0.0) ::__elSessionOffset --;

  // Print the current session time (the time since the last load)
  // This is monitored in main.js to sum up times of different segments
  printl("elTimeReport " + ::__elGetSessionTicks());

  // Print current run time
  ScriptShowHudMessageAll("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" + ::__elticksToString(::__elRunTicks), FrameTime());

  /**
   * Increment the total tick timer. This is NOT an accurate 30 TPS tick
   * counter, and therefore should not be used for timing runs. It simply
   * counts the amount of __elTick iterations, which makes it safe to use
   * for things like spectator interpolation.
   */
  ::__elTicks ++;

  // Schedule this function for the next console tick
  SendToConsole("script ::__elTick()");

};

// Run the entrypoint function as soon as entity I/O kicks in
EntFireByHandle(Entities.First(), "RunScriptCode", "::__elInit()", 0.0, null, null);
