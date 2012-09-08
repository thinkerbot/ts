ts(1) -- run ts shell test scripts
=============================================

## SYNOPSIS

`ts` [options] TEST_SCRIPT...

`[./test_script]` [options] TESTS...

## DESCRIPTION

**ts** provides functions for writing tests in shell. The test scripts can be
run individually or in a batch format using `ts` as a command.

**ts** makes a test directory available on a per-test basis so it's easy to
sandbox tests that write or manipulate files. **ts** tries to use POSIX
exclusively and so should (hopefully) work on any POSIX-compliant system.

## TEST SCRIPTS

The `ts` command expects script files that define test cases. Test scripts
have the following form:

    [./example]
    #!/bin/sh               # pick a shell, any (POSIX) shell
    . ts                    # source ts to add test functions

    setup () {              # optional setup
      mkdir -p "$test_dir"
    }

    teardown () {           # optional teardown
      rm -r "$test_dir"
    }

    test_a_thing () {       # write tests named like "test_"
      [ -d "$test_dir" ]    # return 0 to pass.
    }

    ts .                    # run the tests

To run, use any of:

    ts example              # run multiple test scripts
    ./example               # run a single test script
    ./example test_a_thing  # run a single test

See the FUNCTIONS section for all functions available in tests.

## OPTIONS

These options control how `ts` operates:

* `-a`:
  Show passing outputs, which are normally filtered.
* `-c`:
  Colorize output. (green/red/yellow - pass/fail/not-executable)
* `-d`: 
  Debug mode. Turns on xtrace (set -x) for the tests and enables -v.
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

Functions provided by **ts**.

* `setup`:
  A setup function run before each test.
* `teardown`:
  A teardown function run after each test.
* `assert COMMAND...`:
  Runs a command and asserts exit status 0.
* `assert_status EXPECTED ACTUAL`:
  Exit 1 unless the numbers EXPECTED and ACTUAL are the same.
* `assert_output EXPECTED ACTUAL`:
  Exit 1 unless the variables EXPECTED and ACTUAL are the same. Reads from
  stdin for '-'.
  
  Using assert_output in a pipeline is often convenient, but be careful you
  don't expect a failing assert_output to exit your test case as, in that
  case, it will only exit the pipeline.  See the GOTCHAS section for more
  details.

**ts** reserves all function names starting with 'ts_' for internal use. When
**ts** is sourced, a 'ts' function is defined to allow `ts .` to run the
tests.

## VARIABLES

Variables provided by **ts** at runtime. Feel free to use any of them but
treat them as read-only.

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

**ts** reserves all variables starting with 'ts\_' for internal use.

## ENVIRONMENT

Default **ts** behavior can be set via environment variables. Options provided
to `ts` override these defaults.

* `TS_USR_DIR` (pwd):
  The user dir. Used to determine the ts tmp dir.
* `TS_TMP_DIR` (`$TS_USR_DIR/tmp`):
  The base tmp dir.
* `TS_COLOR` (false):
  Set to "true" to enable color.
* `TS_DEBUG` (false):
  Set to "true" to enable debug mode.
* `TS_REMOVE_TMP_DIR` (false):
  Set to "true" to remove tmp dir.

In addition these variables adjust the color output.

* `TS_PASS` (green):
  Passing tests.
* `TS_FAIL` (red):
  Failing tests.
* `TS_NOEX` (yellow):
  Non-executable test files.
* `TS_NORM` (normal):
  The normal output color.

For example to turn failures blue:

    export TS_FAIL=$(printf "%b" "\033[0;34m")

**ts** reserves all variables starting with 'TS\_' for internal use.

## EXAMPLES

Basic usage:

    [./example]
    #!/bin/sh
    . ts

    test_pass () {
      true
    }

    test_assert_pass () {
      assert true
    }

    test_assert_status_pass () {
      true
      assert_status 0 $?
    }

    test_assert_output_style_one () {
      out=$(printf "hello world")
      assert_output "hello world" "$out"
    }

    test_assert_output_style_two () {
      printf "hello world" | assert_output "hello world"
    }

    ts .

Run like:

    chmod +x example
    ts example

## GOTCHAS

The assert methods will literally exit the function, so multiple assertions
are ok.

    test_fails_as_expected () {
      assert_output "1" "0"
      assert true
    }

**Beware** doing this as you may accidentally use them in pipelines where a
failure will exit the pipeline and not the test function.

    test_this_has_a_bug_and_does_not_fail () {
      printf "0" | assert_output "1"
      assert true
    }

A safer approach is to always rely on the return status of the function,
instead of the exits from the assert methods.

    test_now_fails_as_expected () {
      printf "0" | assert_output "1" &&
      assert true
    }

## INSTALLATION

Add `ts` to your PATH (or execute it directly). A nice way of doing so is to
clone the repo and add the bin dir to PATH. This allows easy updates via `git
pull` and should make the manpages available via `man ts`.

    git clone git://github.com/thinkerbot/ts.git
    export PATH="$PATH:$(pwd)/ts/bin"

## DEVELOPMENT

Clone the repo as above.  To run the tests (written in `ts`):

    ts test/suite

To generate the manpages:

    make manpages

## COPYRIGHT

TS is Copyright (C) 2011 Simon Chiang <http://github.com/thinkerbot>
