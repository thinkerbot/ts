ts(1) -- test script
=============================================

## SYNOPSIS

`ts` [options] TEST_SCRIPT...

`[./test_script]` [options] TESTS...

## DESCRIPTION

**ts** provides functions for writing tests in shell. The test scripts can be
run individually or in a batch format using `ts` as a command.

**ts** makes a test directory available on a per-test basis so it's easy to
sandbox tests that write or manipulate files. **ts** tries to use POSIX
exclusively and so should (hopefully) work with any POSIX-compliant shell.

## TEST SCRIPTS

The `ts` command expects script files that define test cases. Test scripts
have the following form:

    [./example]
    #!/bin/sh
    # pick a shell, any (POSIX) shell

    setup () {              # optional setup
      mkdir -p "$ts_test_dir"
    }

    teardown () {           # optional teardown
      rm -r "$ts_test_dir"
    }

    test_true () {          # write tests named like "test_"
      true                  # return 0 to pass.
    }

    . ts                    # source ts to run the tests

To run, use any of:

    ts example              # run multiple test scripts
    ./example               # run a single test script
    ./example test_a_thing  # run a single test

To debug, try using -e to execute the test function in isolation.

    ./example -e test_a_thing    # a most useful pattern

See the FUNCTIONS, EXAMPLES, and TROUBLESHOOT sections for more details.

## OPTIONS

These options control how `ts` operates.

* `-a`:
  Show passing outputs, which are normally filtered.

* `-c`:
  Colorize output. (green/red/yellow - pass/fail/not-executable)

* `-d`:
  Debug mode. Turns on xtrace (set -x) for the tests and enables -v.

* `-e`:
  Exec mode. Runs a test without processing the output and exits.

* `-h`:
  Prints help.

* `-m`:
  Monitor output. Provide a ticker indicating the progress of tests and
  print a summary. Monitor is the default.

* `-q`:
  Quiet output. Shows only stdout, hiding stderr.

* `-r`:
  Remove the tmp dir on complete. Removal is done using `rm -r`.

* `-s`:
  Stream output. Show test progress as it happens. No summary is printed.

* `-t`:
  Set the test tmp dir (default tmp).  The test-specific directories are
  be located under this directory.

* `-v`:
  Verbose output. Display both stdout and stderr for the tests (enabled
  by default).

## FUNCTIONS

Functions provided by **ts**.

* `setup`:

  A setup function run before each test.

* `teardown`:

  A teardown function run after each test.

  **ts** ensures teardown runs by setting a trap for EXIT signals during setup
  and the actual test. As a result, EXIT traps in tests can prevent teardown.

* `assert_status EXPECTED ACTUAL [MESSAGE]`:

  Exit 1 unless the numbers EXPECTED and ACTUAL are the same. Use this to make
  assertions in the middle of a test.

* `assert_output EXPECTED ACTUAL`:

  Return 1 unless the variables EXPECTED and ACTUAL are the same. Reads from
  stdin for '-'.  Also reads ACTUAL from stdin if ACTUAL is unspecified.

  Using assert_output in a pipeline is often convenient but remember this
  assertion only returns, it does not exit. As a result you should either use
  it as the very last command in a test, or follow it with assert_status in a
  multipart test.  See the section on my 'tests aren't failing' for more.

* `skip [MESSAGE]`:

  Skip a test.  Exits 0 but counts as a skip and not a pass.

**ts** reserves all function names starting with 'ts_' for internal use.  Note
that `setup` and `teardown` commands on PATH will be ignored because tests
will shadow them with the corresponding **ts** functions.

## VARIABLES

Variables provided by **ts** at runtime. Feel free to use any of them but
treat them as read-only.

* `ts_test_file`:
  The name of the current test script being run.

* `ts_test_case`:
  The basename of the test file, minus the extname.

* `ts_test_lineno`:
  The line number where the current test is defined.

* `ts_test_name`:
  The name of the current test.

* `ts_test_dir`:
  The test-specific directory.

  The test dir is 'tmp\_dir/test\_case'. **ts** does not create this directory
  automatically. Add that functionality in the setup function as needed.

**ts** reserves all variables starting with 'ts\_' for internal use.

## ENVIRONMENT

The behavior of **ts** can be modified via environment variables. Many of
these may be set using options.

* `TS_USR_DIR` (pwd):
  The user dir. Used to determine the ts tmp dir.

* `TS_TMP_DIR` ($TS\_USR\_DIR/tmp):
  The base tmp dir.

* `TS_COLOR` (false):
  Set to "true" to enable color.

* `TS_DIFF` (diff):
  The diff command used by assert_output.

* `TS_DEBUG` (false):
  Set to "true" to enable debug mode.

* `TS_REMOVE_TMP_DIR` (false):
  Set to "true" to remove tmp dir.

In addition these variables adjust the color output.

* `TS_PASS` (green):
  Passing tests.

* `TS_FAIL` (red):
  Failing tests.

* `TS_SKIP` (yellow):
  Skipped tests.

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

    test_skip_test () {
    skip "skipping this one"
    false
    }

    . ts

Run like:

    chmod +x example
    ts example

Shared examples:

    [./common_tests]
    test_it_should_pick_lines_with_abc () {
    printf "%s\n" "1 abc" "2 xyz" "3 abc" |
    ${picker} | assert_output "\
    1 abc
    3 abc
    "
    }

    [./test_grep_abc]
    #!/bin/sh
    picker="grep abc"
    . ts . ./common_tests
    . ts

    [./test_sed_abc]
    #!/bin/sh
    picker="sed -ne /abc/p"
    . ts . ./common_tests
    . ts

Run like:

    chmod +x test_grep_abc test_sed_abc
    ts test_grep_abc test_sed_abc

Background jobs work fine, just be sure to cleanup:

    [./background]
    #!/bin/sh

    teardown () {
      jobs -p | xargs kill -9
      true
    }

    test_background_job () {
      sleep 3 &
      true
    }

    . ts

## TROUBLESHOOT

**My tests aren't running**

Be sure you added `. ts` at the end of your script.

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

**1)** Are you using assert_output in a pipeline?

**ts** assert methods return failure (rather than exit) so this will pass.

    test_multiple_asserts_not_failing_as_intended () {
      assert_output "1" "0"
      assert_output "0" "0"
    }

The reason is that exit within a pipeline has shell-specific behavior. For
instance if you run this with different values of shell you will get 0 for
bash and dash, and 1 for zsh and ksh.

    $shell <<DOC
    yes | exit 1
    exit 0
    DOC
    echo $?

As a result you cannot get consistent behavior if assert_output exits rather
than returns; in bash/dash a failing assert_output in a pipeline would be
ignored while in ksh/zsh it would be respected. So what do you do if you want
multiple assertions?

One way is to && all the asserts at the end of the test.

    test_this_fails_as_expected () {
      printf "0" | assert_output "1" &&
      assert_output "0" "0"
    }

Another way is to use assert_status. Unlike assert_output, assert_status exits
(it does not return). This is ok because there is no good reason to use assert
status in a pipeline - the intent is to use it as a breakout from a multipart
test. As a result you can use a message with assert_status to track progress.

    test_this_also_fails_as_expected () {
      printf "0" | assert_output "1"
      assert_status "0" $? "checking the pipeline"
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

**I'm using DASH (maybe you're on ubuntu)**

DASH is quirky. Last I checked you cannot concatenate options like you can in
other shells, so when launching scripts individually (the only time this
applies) you must separate options out.

    ./test_script -s -c  # this
    ./test_script -sc    # not this!

Shared examples do not work with DASH - the `. ts . files...` syntax relies on
the dot operator to set arguments which dot in DASH does not do. There isn't
actually anything in the POSIX spec that says it should, but it's a break in
the conventions used by other shells.

**I'm using BusyBox (maybe you're on alpine)**

The `diff` in BusyBox only outputs unified format, which isn't what the POSIX
spec asks for.  That means parts of the `ts` test suite written to expect the
default POSIX output cannot pass.  These tests are skipped.  This quirk of
BusyBox should not affect your tests, but note the output of your tests may
change a little when run vs BusyBox.

## INSTALLATION

Add `ts` to your PATH (or execute it directly). A nice way of doing so is to
clone the repo and add the bin dir to PATH. This allows easy updates via `git
pull` and should make the manpages available via `man ts`.

    git clone git://github.com/thinkerbot/ts.git
    export PATH="$PATH:$(pwd)/ts/bin"

If you're using [homebrew](http://brew.sh/) on OSX you can tap
[goodlittlescript](https://github.com/goodlittlescript/homebrew-gls).

    brew tap goodlittlescript/homebrew-gls
    brew install ts

## DEVELOPMENT

Clone the repo as above.  To run the tests (written in `ts`):

    ./test/suite

To run the tests on latest image/shell combinations, or a specific image/shell combination (requires [docker](https://www.docker.com/)):

    # latest for several major distros
    ./test/distributions

    # pick a image/shell you specifically care about
    ./test/distribution ubuntu:16.04 /bin/bash

    # add -d to get a shell to debug failures
    ./test/distribution -d ubuntu:16.04 /bin/bash

To generate the manpages:

    make manpages

Report bugs here: http://github.com/thinkerbot/ts/issues.

## CONTRIBUTORS

Thanks for the help!

* Angelo Lakra (github.com/alakra)
* Thomas Adam (github.com/ThomasAdam)

## COPYRIGHT

TS is Copyright (C) 2011 Simon Chiang <http://github.com/thinkerbot>
