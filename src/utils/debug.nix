{lib, ...}:
with lib; {
  # Debug logging function
  log = level: msg: config: let
    shouldLog = config.debug.enable && config.debug.verbosity >= level;
    logPrefix = "[bufrnix] ";
  in
    if shouldLog
    then
      if config.debug.logFile != ""
      then ''
        echo "${logPrefix}${msg}" >> ${config.debug.logFile}
      ''
      else ''
        echo "${logPrefix}${msg}" >&2
      ''
    else "";

  # Function to print commands being executed
  printCommand = cmd: config: let
    shouldPrint = config.debug.enable && config.debug.verbosity >= 2;
  in
    if shouldPrint
    then ''
      echo "[bufrnix] Executing: ${cmd}" >&2
    ''
    else "";

  # Function to time command execution
  timeCommand = cmd: config: let
    shouldTime = config.debug.enable && config.debug.verbosity >= 3;
  in
    if shouldTime
    then ''
      echo "[bufrnix] Starting: ${cmd}" >&2
      TIMEFORMAT="[bufrnix] Command took: %3R seconds"
      time (${cmd})
    ''
    else cmd;
}
