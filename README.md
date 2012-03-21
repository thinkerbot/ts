ts(1) -- run ts shell test scripts
=============================================

## SYNOPSIS

`ts` [options] FILE...
`[ts script]` [options]

## DESCRIPTION

**NOTE** this document is not 100% supported yet.

**ts** provides minimal functions for writing tests in shell. Tests are
written in test scripts that source `ts` to define test functions. The test
scripts can be run individually or in a batch format using `ts` as a command.

**ts** makes a test directory available on a per-test basis so it's easy to
sandbox tests that write or manipulate files. **ts** tries to use POSIX
exclusively and so should work on any POSIX-compliant systems.

## FILES

The `ts` command expects script files that define test cases. Test scripts
have the following form:

    #!/bin/sh        # Pick a shell
    . ts             # Source ts to get test functions.

    test_pass () {   # Write tests named like "test_".
    true             # Return (or exit) 0 to pass.
    }

    ts_run           # Call to run ts when the script is run.

See the FUNCTIONS section for all functions available in tests.

## OPTIONS

These options control a **ts** script, or `ts` when running ts scripts as a batch.

* `-c`: 
  Cleanup the test dirs on complete.  Cleanup is done using `rm -r`.
* `-d`: 
  Debug mode.  Normally **ts** only captures stdout for each test.  In debug
  mode stderr is also captured.  This flag is especially useful when using
  `set -x` in the setup method (which will cause an xtrace to be printed
  for each test case in debug mode).
* `-f`: 
  Format output with colors, indentation, etc.
* `-h`: 
  Prints help.
* `-l`: 
  List the tests to be run.
* `-m`: 
  Monitor output.  Rather than providing a stream of results as they are
  generated, provide a ticker indicating the progress of tests.  After all
  tests are done, prints summaries for failing tests.  Combine with -v to
  print summaries of passing tests as well.
* `-r`: 
  Raw output (overrides -fmv).  Print the unprocessed **ts** output.
* `-t`: 
  Set the test tmp dir (default tmp).  The test-specific directories will
  be located under this directory.  Cleanup will remove this and all sub
  directories.
* `-v`: 
  Verbose output.  Show passing outputs, which are normally filtered.

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
* `assert_match EXPECTED ACTUAL`:
  Flunks unless the extended regular expression EXPECTED and variable ACTUAL
  match.  Reads from stdin for '-'.
* `ts_run`:
  Runs each test in the test script.

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

* `TS_USR_DIR`:
  The user dir.  By default `pwd`.  Used to determine the default tmp dir.
* `TS_TMP_DIR`:
  The base tmp dir.  By default `$TS_USR_DIR/tmp`.
* `TS_NAME`:
  The prefix of test functions that will be run by **ts**.  By default 'test\_',
  such that all tests will be run.  Override with the full name of a test to run
  just one test.

## BUGS

TODO

## COPYRIGHT

TS is Copyright (C) 2011 Simon Chiang <http://github.com/thinkerbot>
