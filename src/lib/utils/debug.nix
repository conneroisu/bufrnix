{lib, ...}:
with lib; {
  # Environment variable for debug mode
  envVarCheck = ''
    # Check for environment variables to override debug settings
    if [ -n "$BUFRNIX_DEBUG" ]; then
      debug_enable=true
      if [ -n "$BUFRNIX_DEBUG_LEVEL" ]; then
        debug_verbosity=$BUFRNIX_DEBUG_LEVEL
      else
        debug_verbosity=1
      fi
      if [ -n "$BUFRNIX_DEBUG_LOG" ]; then
        debug_logfile="$BUFRNIX_DEBUG_LOG"
      fi
    fi
  '';

  # Debug logging function with timestamps and log levels
  log = level: msg: config: let
    shouldLog = config.debug.enable && config.debug.verbosity >= level;
    logPrefix = "[bufrnix] ";
    levelPrefix = 
      if level == 1 then "INFO: "
      else if level == 2 then "DEBUG: "
      else if level == 3 then "TRACE: "
      else "";
    timestamp = "$(date '+%Y-%m-%d %H:%M:%S')";
    fullMessage = "${timestamp} ${logPrefix}${levelPrefix}${msg}";
  in
    if shouldLog
    then
      if config.debug.logFile != ""
      then ''
        echo "${fullMessage}" >> ${config.debug.logFile}
      ''
      else ''
        echo "${fullMessage}" >&2
      ''
    else "";

  # Function to print commands being executed with formatting
  printCommand = cmd: config: let
    shouldPrint = config.debug.enable && config.debug.verbosity >= 2;
    timestamp = "$(date '+%Y-%m-%d %H:%M:%S')";
  in
    if shouldPrint
    then ''
      echo "${timestamp} [bufrnix] DEBUG: Executing command:" >&2
      echo "  ${cmd}" >&2
    ''
    else "";

  # Function to time command execution with enhanced context
  timeCommand = cmd: config: let
    shouldTime = config.debug.enable && config.debug.verbosity >= 3;
    timestamp = "$(date '+%Y-%m-%d %H:%M:%S')";
  in
    if shouldTime
    then ''
      echo "${timestamp} [bufrnix] TRACE: Starting command execution" >&2
      echo "  ${cmd}" >&2
      start_time=$(date +%s.%N)
      { ${cmd}; cmd_status=$?; } 
      end_time=$(date +%s.%N)
      duration=$(echo "$end_time - $start_time" | bc)
      echo "${timestamp} [bufrnix] TRACE: Command completed in $duration seconds with status $cmd_status" >&2
      if [ $cmd_status -ne 0 ]; then
        echo "${timestamp} [bufrnix] ERROR: Command failed with status $cmd_status" >&2
      fi
      (exit $cmd_status) # Preserve original exit status
    ''
    else cmd;

  # Function to provide error context with stack traces when possible
  enhanceError = msg: exitCode: ''
    echo "$(date '+%Y-%m-%d %H:%M:%S') [bufrnix] ERROR: ${msg}" >&2
    if [ -n "$BASH_VERSION" ]; then
      echo "Stack trace:" >&2
      for i in $(seq 0 $((\$\{#FUNCNAME[@]} - 1))); do
        echo "  $i: \$\{BASH_SOURCE[$i]}:\$\{BASH_LINENO[$i-1]} \$\{FUNCNAME[$i]}()" >&2
      done
    fi
    exit ${toString exitCode}
  '';

  # Function to enable debug mode based on environment variables
  getDebugConfig = config: ''
    # Initialize with config values
    debug_enable=${if config.debug.enable then "true" else "false"}
    debug_verbosity=${toString config.debug.verbosity}
    debug_logfile="${config.debug.logFile}"
    
    # Check environment variables
    if [ -n "$BUFRNIX_DEBUG" ]; then
      debug_enable=true
      if [ -n "$BUFRNIX_DEBUG_LEVEL" ]; then
        debug_verbosity=$BUFRNIX_DEBUG_LEVEL
      fi
      if [ -n "$BUFRNIX_DEBUG_LOG" ]; then
        debug_logfile="$BUFRNIX_DEBUG_LOG"
      fi
    fi
    
    # Create log file directory if needed
    if [ -n "$debug_logfile" ] && [ "$debug_enable" = "true" ]; then
      mkdir -p "$(dirname "$debug_logfile")" 2>/dev/null || true
      touch "$debug_logfile" 2>/dev/null || echo "Warning: Could not create log file $debug_logfile" >&2
    fi
  '';
}
