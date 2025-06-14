/* Bufrnix Debug Utilities

   Comprehensive debugging and logging utilities for Bufrnix operations.
   Provides structured logging, command execution tracing, performance timing,
   and environment variable-based configuration overrides.
   
   Features:
   - Configurable verbosity levels (INFO, DEBUG, TRACE)
   - Timestamp logging with log file support
   - Command execution formatting and timing
   - Environment variable overrides for debug settings
   - Error context enhancement
   
   Type: DebugUtils :: AttrSet
*/
{lib, ...}:
with lib; {
  /* Environment variable check script for debug configuration overrides.
  
     Generates shell script code that checks for BUFRNIX_DEBUG environment
     variables and overrides debug settings accordingly.
     
     Environment Variables:
     - BUFRNIX_DEBUG: Enable debug mode
     - BUFRNIX_DEBUG_LEVEL: Set verbosity level (1-3)  
     - BUFRNIX_DEBUG_LOG: Specify log file path
     
     Type: envVarCheck :: String
  */
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

  /* Debug logging function with timestamps and configurable verbosity levels.
  
     Provides structured logging with timestamps, log level prefixes, and
     optional file output. Only logs messages that meet the configured
     verbosity threshold.
     
     Arguments:
       level: Verbosity level (1=INFO, 2=DEBUG, 3=TRACE)
       msg: Log message string
       config: Bufrnix configuration containing debug settings
     
     Log Levels:
       1 - INFO: Basic operation information
       2 - DEBUG: Detailed execution steps
       3 - TRACE: Comprehensive timing and performance data
     
     Type: log :: Int -> String -> AttrSet -> String
     
     Example:
       log 1 "Starting protoc generation" config
       => "2024-01-15 10:30:45 [bufrnix] INFO: Starting protoc generation"
  */
  log = level: msg: config: let
    shouldLog = config.debug.enable && config.debug.verbosity >= level;
    logPrefix = "[bufrnix] ";
    levelPrefix =
      if level == 1
      then "INFO: "
      else if level == 2
      then "DEBUG: "
      else if level == 3
      then "TRACE: "
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

  /* Function to print commands being executed with formatted output.
  
     Formats and displays commands before execution when debug verbosity
     is 2 or higher. Useful for troubleshooting protoc command generation
     and plugin execution.
     
     Arguments:
       cmd: Command string to be executed
       config: Bufrnix configuration containing debug settings
     
     Type: printCommand :: String -> AttrSet -> String
     
     Example:
       printCommand "protoc --go_out=. example.proto" config
       => "2024-01-15 10:30:45 [EXEC] protoc --go_out=. example.proto"
  */
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

  /* Function to time command execution with enhanced context and performance monitoring.
  
     Wraps command execution with timing instrumentation when debug verbosity
     is 3 (TRACE) or higher. Measures execution duration and preserves exit status
     while providing detailed performance information.
     
     Arguments:
       cmd: Command string to be executed with timing
       config: Bufrnix configuration containing debug settings
     
     Returns the original command wrapped with timing instrumentation,
     or the original command unchanged if timing is disabled.
     
     Type: timeCommand :: String -> AttrSet -> String
     
     Example:
       timeCommand "protoc --go_out=. example.proto" config
       => Enhanced command with start/end timing and duration reporting
  */
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
      duration=$(awk -v end="$end_time" -v start="$start_time" 'BEGIN{print end - start}')
      echo "${timestamp} [bufrnix] TRACE: Command completed in $duration seconds with status $cmd_status" >&2
      if [ $cmd_status -ne 0 ]; then
        echo "${timestamp} [bufrnix] ERROR: Command failed with status $cmd_status" >&2
      fi
      (exit $cmd_status) # Preserve original exit status
    ''
    else cmd;

  /* Function to provide enhanced error context with stack traces when possible.
  
     Generates error output with timestamps and optional bash stack traces
     for debugging failures in protoc code generation. Exits with the
     specified exit code after displaying the error.
     
     Arguments:
       msg: Error message to display
       exitCode: Exit code to use when terminating
     
     Type: enhanceError :: String -> Int -> String
     
     Example:
       enhanceError "protoc compilation failed" 1
       => "2024-01-15 10:30:45 [bufrnix] ERROR: protoc compilation failed"
          Stack trace: [if bash available]
          exit 1
  */
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

  /* Function to initialize debug configuration with environment variable overrides.
  
     Generates shell script code that initializes debug configuration variables,
     starting with values from the Nix configuration and allowing environment
     variables to override them. Also handles log file directory creation.
     
     Arguments:
       config: Bufrnix configuration containing debug settings
     
     Returns shell script code that sets debug_enable, debug_verbosity,
     and debug_logfile variables based on config and environment.
     
     Type: getDebugConfig :: AttrSet -> String
     
     Environment Variable Overrides:
       BUFRNIX_DEBUG: Override debug.enable
       BUFRNIX_DEBUG_LEVEL: Override debug.verbosity  
       BUFRNIX_DEBUG_LOG: Override debug.logFile
  */
  getDebugConfig = config: ''
    # Initialize with config values
    debug_enable=${
      if config.debug.enable
      then "true"
      else "false"
    }
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
