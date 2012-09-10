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

    setup () {              # optional setup
      mkdir -p "$test_dir"
    }

    teardown () {           # optional teardown
      rm -r "$test_dir"
    }

    test_true () {          # write tests named like "test_"
      true                  # return 0 to pass.
    }

    . ts                    # source ts to run the tests

To run, use any of:

    ts example              # run multiple test scripts
    ./example               # run a single test script
    ./example test_a_thing  # run a single test

See the FUNCTIONS, EXAMPLES, and TROUBLESHOOT sections for more details.

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

  **ts** ensures teardown runs by setting a trap for EXIT signals during setup
  and the actual test. As a result, EXIT traps in tests can prevent teardown.

* `assert_status EXPECTED ACTUAL`:

  Exit 1 unless the numbers EXPECTED and ACTUAL are the same. This assertion
  is almost never necessary.

* `assert_output EXPECTED ACTUAL`:

  Exit 1 unless the variables EXPECTED and ACTUAL are the same. Reads from
  stdin for '-'.  Also reads ACTUAL from stdin if ACTUAL is unspecified.

  Using assert_output in a pipeline is often convenient, but be careful you
  don't expect a failing assert_output to exit your test case as, in that
  case, it will only exit the pipeline.  See the EXAMPLES section for more
  details.

**ts** reserves all function names starting with 'ts_' for internal use.

## VARIABLES

Variables provided by **ts** at runtime. Feel free to use any of them but
treat them as read-only.

* `test_file`:
  The name of the current test script being run.

* `test_case`:
  The basename of the test file, minus the extname.

* `test_lineno`:
  The line number where the current test is defined.

* `test_name`:
  The name of the current test.

* `test_dir`:
  The test-specific directory.

  The test dir is 'tmp\_dir/test\_case'. **ts** does not create this directory
  automatically. Add that functionality in the setup function as needed.

**ts** reserves all variables starting with 'ts\_' for internal use.

## ENVIRONMENT

Default **ts** behavior can be set via environment variables. Options provided
to `ts` override these defaults.

* `TS_USR_DIR` (pwd):
  The user dir. Used to determine the ts tmp dir.

* `TS_TMP_DIR` ($TS\_USR\_DIR/tmp):
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

    test_arbitrary_function () {
      echo abc | grep -q b
    }

    test_assert_status () {
      false
      assert_status 1 $?
    }

    test_assert_output_style_one () {
      out=$(printf "hello world")
      assert_output "hello world" "$out"
    }

    test_assert_output_style_two () {
      printf "hello world" | assert_output "hello world"
    }

    test_assert_output_style_three () {
    printf "hello world\n" | assert_output "\
    hello world
    "
    }

    . ts

Run like:

    chmod +x example
    ts example

## TROUBLESHOOT

**My tests aren't running**

Be sure you added `ts .` at the end of your script.

**My tests are failing**

**1)** Are you incrementing a variable in a loop in a pipeline?

See http://mywiki.wooledge.org/BashFAQ/024.

**2)** Is a newline missing from a variable?

Subshells chomp the last newline off of a command.

    test_newline_is_missing_so_this_fails () {
    out=$(echo abc)

    assert_output "\
    abc
    " "$out"
    }

One way around this is to print a sacrificial non-newline character.

    test_newline_is_now_accounted_for () {
    out=$(echo abc; printf x)

    assert_output "\
    abc
    " "${out%x}"
    }

Another way is to pipe into assert_output.

    test_another_newline_strategy () {
    echo abc | assert_output "\
    abc
    "
    }

**My tests aren't failing**

**1)** Are you using asserts in a pipeline?

**ts** assert methods exit failure (rather than return) so this will fail.

    test_multiple_asserts_failing_as_intended () {
      assert_output "1" "0"
      assert_output "0" "0"
    }

However the assert methods in a pipeline will exit the pipeline instead of the
test method so this will not fail.

    test_this_has_a_bug_and_does_not_fail () {
      printf "0" | assert_output "1"
      assert_output "0" "0"
    }

One way around this is to `set -e` in your setup or at the start of the test
so that any failing command (including a pipeline) will cause the function to
exit in failure.

    test_this_now_fails_as_expected () {
      set -e
      printf "0" | assert_output "1"
      assert_output "0" "0"
    }

Another way is to && all the asserts at the end of the test.

    test_this_also_fails_as_expected () {
      printf "0" | assert_output "1" &&
      assert_output "0" "0"
    }

**Teardown isn't running**

Are you setting an EXIT trap? **ts** uses an EXIT trap to ensure that teardown
runs even when setup or a test exits. Resetting an EXIT trap can prevent
teardown from running.

    test_teardown_will_not_run () {
      trap - EXIT
      exit 1
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

Report bugs here: http://github.com/thinkerbot/ts/issues.

## COPYRIGHT

TS is Copyright (C) 2011 Simon Chiang <http://github.com/thinkerbot>
