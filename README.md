ts(1) -- run ts shell test scripts
=============================================

## SYNOPSIS

`ts` [options] FILE...
`[ts script]` [options] TESTS...

## DESCRIPTION

**ts** provides functions for writing tests in shell. The test scripts can be
run individually or in a batch format using `ts` as a command.

**ts** makes a test directory available on a per-test basis so it's easy to
sandbox tests that write or manipulate files. **ts** tries to use [POSIX]
exclusively and so should (hopefully) work on any POSIX-compliant systems.

## TEST SCRIPTS

The `ts` command expects script files that define test cases. Test scripts
have the following form:

    #!/bin/sh        # Pick a shell
    . ts             # Source ts to get test functions.

    test_pass () {   # Write tests named like "test_".
      true           # Return 0 to pass.
    }

See the FUNCTIONS section for all functions available in tests.

## OPTIONS

These options control a **ts** script, or `ts` when running ts scripts as a batch.

* `-a`:
  Show passing outputs, which are normally filtered.
* `-c`:
  Colorize output. (green/red/yellow - pass/fail/not-executable)
* `-d`: 
  Debug mode. Turns on xtrace (set -x) for the tests and enables verbose.
* `-h`: 
  Prints help.
* `-m`: 
  Monitor output. Provide a ticker indicating the progress of tests and 
  print a summary. Monitor is the default.
* `-r`: 
  Remove the tmp dir on complete. Removal is done using `rm -r`.
* `-s`: 
  Stream output. Show test progress as it happens. No summary is printed.
* `-t`: 
  Set the test tmp dir (default tmp).  The test-specific directories are
  be located under this directory.
* `-v`: 
  Verbose output. Enables **ts** to display stderr for the tests (normally
  only stdout is shown).

## FUNCTIONS

Functions provided by **ts**. All function names starting with 'ts_' are
reserved for internal use.

* `setup`:
  A setup function run before each test.
* `teardown`:
  A teardown function run after each test.
* `assert COMMAND...`:
  Runs a command and asserts exit status 0.
* `assert_status EXPECTED ACTUAL`:
  Flunks unless the numbers EXPECTED and ACTUAL are the same.
* `assert_output EXPECTED ACTUAL`:
  Flunks unless the variables EXPECTED and ACTUAL are the same. Reads from
  stdin for '-'.

## VARIABLES

Variables provided by **ts** at runtime. All variable names starting with
'ts_' are reserved for internal use.

* `test_file`:
  The name of the current test script being run.
* `test_case`:
  The basename of the test file, minus the extname.  Example:
  'test/test\_stuff.sh' => 'test\_stuff'
* `test_lineno`:
  The line number where the current test is defined.
* `test_name`:
  The name of the current test.
* `test_dir`:
  The test-specific directory.  The test dir is 'tmp\_dir/test\_case'.  **ts**
  does not create this directory automatically.  Add that functionality in
  the setup function as needed.

## EXAMPLES

TODO

## ENVIRONMENT

Defaults for options can be set via environment variables. Options provided by
the user override these defaults. All variable names starting with 'TS_' are
reserved for internal use.

* `TS_USR_DIR`:
  The user dir. By default `pwd`. Used to determine the default tmp dir.
* `TS_TMP_DIR`:
  The base tmp dir. By default `$TS_USR_DIR/tmp`.
* `TS_COLOR`:
  Set to "true" to enable color.
* `TS_DEBUG`:
  Set to "true" to enable debug mode.
* `TS_FILTER`:
  Set to "false" to not filter passing tests.
* `TS_REPORT`:
  Report mode. Valid values are "monitor", "stream", and "raw" (raw output
  is used internally and should not be relied upon externally).
* `TS_MODE`:
  Execution mode. Set to "verbose" to capture stderr.
* `TS_REMOVE_TMP_DIR`:
  Set to "true" to remove tmp dir.

In addition these variables can be set to adjust the color output.

* `TS_PASS`:
   Passing tests.
* `TS_FAIL`:
   Failing tests.
* `TS_NORM`:
   The normal output color.
* `TS_NOEX`:
   Non-executable test files.

For example to turn failures blue:

    export TS_FAIL=$(printf "%b" "\033[0;34m")

## BUGS

## COPYRIGHT

TS is Copyright (C) 2011 Simon Chiang <http://github.com/thinkerbot>
