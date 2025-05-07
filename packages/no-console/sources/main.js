// Require latest spplice-cpp version
if (!("game" in this)) {
  SendToConsole('disconnect "This package requires the latest version of SppliceCPP. Update here: github.com/p2r3/spplice-cpp/releases"');
  sleep(3000).then(function () {
    SendToConsole('disconnect "This package requires the latest version of SppliceCPP. Update here: github.com/p2r3/spplice-cpp/releases"');
  });
  throw new Error("Terminating script due to version mismatch.");
}

/**
 * Utility funtion, checks if the given file path exists
 * @param {string} path Path to the file or directory, relative to tempcontent
 * @returns {boolean} True if the path exists, false otherwise
 */
function pathExists (path) {
  try { fs.rename(path, path) }
  catch (e) {
    return e.toString() == "Error: fs.rename: New path already occupied";
  }
  return true;
}

do { // Attempt connection with the game's console
  var gameSocket = game.connect();
  sleep(200);
} while (gameSocket === -1);

console.log("Connected to Portal 2 console.");

/**
 * Utility function, cleans up any open sockets and throws an error.
 * This is useful for when the game has closed or when an otherwise
 * critical issue requires us to stop the script.
 */
function doCleanup () {
  // Disconnect from the game's console
  if (gameSocket !== -1) game.disconnect(gameSocket);
  // Throw an error to terminate the script
  throw new Error("Cleanup finished, terminating script.");
}

/**
 * Utility funtion, attempts to read a command from the console. On failure,
 * attempts to reconnect to the socket.
 * @param {number} socket Game socket file descriptor (index)
 * @param {number} bytes How many bytes to request from the socket
 */
function readFromConsole (socket, bytes) {
  try {
    return game.read(socket, bytes);
  } catch (e) {
    console.error(e);
    // Attempt to reconnect to the game's console
    do {
      if (!game.status()) doCleanup();
      var gameSocket = game.connect();
      sleep(200);
    } while (gameSocket === -1);
    return readFromConsole(gameSocket, bytes);
  }
}

/**
 * Utility funtion, attempts to write a command to the console. On failure,
 * attempts to reconnect to the socket.
 * @param {number} socket Game socket file descriptor (index)
 * @param {number} command Command to send to the console
 */
function sendToConsole (socket, command) {
  try {
    return game.send(socket, command);
  } catch (e) {
    console.error(e);
    // Attempt to reconnect to the game's console
    do {
      if (!game.status()) doCleanup();
      var gameSocket = game.connect();
      sleep(200);
    } while (gameSocket === -1);
    return sendToConsole(gameSocket, command);
  }
}

// Time of the currently ongoing run
var totalTicks = 0;
// Last tick count reported by the VScript
var lastTicksReport = 0;
// Whether to expect an elStart event
var expectRoundStart = false;
// Name of the map we're running
var runMap = null;
// Name of the map we were just running
var lastRunMap = null;
// Counts the amount of times `processConsoleOutput` has been called
var consoleTick = 0;
// Whether we're a spectator - resets each round
var amSpectator = false;
// Spectator position and angles for interpolation
var spectatorData = {
  // List of available SteamIDs and index of currently spectated player
  targets: [],
  target: 0,
  // Whether godmode has been enabled
  god: false,
  // Contents of last portal/cube position update from VScript
  // These are the only parameters used by players, NOT spectators
  portals: "",
  cube: ""
};

/**
 * Checks whether the player has the right spplice-cpp version and throws
 * a warning if not.
 */
function processVersionCheck () {
  // Use existence of game.status as a heuristic for spplice-cpp version
  if (!("status" in game)) {
    sendToConsole(gameSocket, 'disconnect "This package requires the latest version of SppliceCPP. Update here: github.com/p2r3/spplice-cpp/releases"');
    doCleanup();
  }
}

// Store the last partially received line until it can be processed
var lastLine = "";

/**
 * Processes output from the Portal 2 console
 */
function processConsoleOutput () {

  // Increment this function's call counter
  consoleTick ++;

  /**
   * Check if the game is still running, and if not, terminate the script.
   * In most cases, this would've already been caught earlier, but we run
   * it here too just to be safe.
   */
  if (consoleTick % 5 === 0 && !game.status()) doCleanup();

  // Receive 1024 bytes from the game console socket
  const buffer = readFromConsole(gameSocket, 1024);
  // If we received nothing, don't proceed
  if (buffer.length === 0) return;

  try {
    // Add the latest buffer to any partial data we had before
    lastLine += buffer;
  } catch (_) {
    // Sometimes, the buffer can't be string-coerced for some reason
    return;
  }

  // Parse output line-by-line
  const lines = lastLine.split("\n");
  lines.forEach(function (line) {

    if (line.indexOf("elStart") !== -1) {
      // Reset run timer
      totalTicks = 0;
      lastTicksReport = 0;
      return;
    };

    // Process timer updates from VScript
    if (line.indexOf("elTimeReport ") === 0) {
      // Parse the fragment of the string containing the tick count
      const ticks = parseInt(line.slice(13));
      // Tick count decrease marks a load - add previous report to total
      if (ticks < lastTicksReport) totalTicks += lastTicksReport;
      // Update previous report
      lastTicksReport = ticks;
      // Draw time on screen
      sendToConsole(gameSocket, "script ::__elRunTicks <- " + (totalTicks + lastTicksReport));
    }

  });

  // Store the last entry of the array as a partially received line
  lastLine = lines[lines.length - 1];

}

// Run each processing function on an interval
while (true) {
  processVersionCheck();
  processConsoleOutput();

  sleep(5);
}
