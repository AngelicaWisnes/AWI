
###################################################################
# NOTE: PLANNING ON CREATING AN AUTOMATIC REACT DEPENDENCY BUMPER #
###################################################################


class StatusElement {
  [string]$dependencyName; # The name of the dependency
  [string]$originalVersion; # The version of the dependency that was installed before the script ran
  [string]$latestVersion; # The latest released version of the dependency
  [string]$currentVersion; # The version of the dependency that is currently installed after updating
  [int]$numberOfDowngrades = 0; # The number of times the dependency was downgraded
  [bool]$isLatestVersion = $false; # Updated to true If, and only If
}


function Get-DependencyUpdateStatusList {
  $dependencies = Get-Dependencies
  $statusList = @()

  foreach ($dependency in $dependencies) {
    $statusElement = [StatusElement]::new()
    $statusElement.dependencyName = $dependency.name
    $statusElement.originalVersion = $dependency.version
    $statusElement.latestVersion = Get-LatestVersion -dependencyName $dependency.name
    $statusElement.currentVersion = $statusElement.latestVersion

    $testResult = Run-Test
    while ($testResult -ne 'success') {
      $statusElement.currentVersion = Get-PreviousVersion -dependencyName $dependency.name -currentVersion $statusElement.currentVersion
      $statusElement.numberOfDowngrades++
      $testResult = Run-Test
    }

    If ($statusElement.currentVersion -eq $statusElement.latestVersion) {
      $statusElement.isLatestVersion = $true
    }

    $statusList += $statusElement
  }

  Return $statusList
}

function Test-ReactApp {
  param (
    [string]$subAppPath
  )

  # Navigate to the sub-app directory
  Set-Location -Path $subAppPath

  # Run the tests and capture the output
  $testOutput = pnpm test --json | Out-String
  $testResult = $testOutput | ConvertFrom-Json

  # Extract the required information
  $didPass = $testResult.numFailedTestSuites -eq 0 -and $testResult.numFailedTests -eq 0
  $numberOfFailedTestSuites = $testResult.numFailedTestSuites
  $numberOfFailedTests = $testResult.numFailedTests

  # Return the results as a custom object
  Return [pscustomobject]@{
    didPass                  = $didPass
    numberOfFailedTestSuites = $numberOfFailedTestSuites
    numberOfFailedTests      = $numberOfFailedTests
  }
}



<#
Create the powershell function "get depencency-update-status-list" according to these requirements:
- Get a list of all dependencies (both dev and standard) from my react project
- Generate an empty list of StatusElements
- Iterate through every dependency, and do the following
- - Create a statusElement for the current dependency with the originalVersion, and currentVersion
- - Update dependency to the latest version using pnpm, and update the statusElement.latestVersion
- - Enter a loop that will do the following
- - - run "pnpm test" to check If the project is still working
- - - If no errors are found, update the statusElement.currentVersion to the current / latest version and exit this inner loop

- - - If errors are found, do the following
- - - - Downgrade the dependency to the latest version released before the current version
- - - - Update the statusElement.currentVersion to the downgraded version
- - - - Increment the statusElement.numberOfDowngrades
- - Check If the current version is the latest version, and update the statusElement.isLatestVersion to true If it is
- - Add the statusElement to the list of StatusElements
- Return the list of StatusElements

Then create the powershell function "update all dependencies" that will do the following:
- call "get depencency-update-status-list" function and save statusList to variable $originalStatusList
- enter a loop that will do the following
- - call "get depencency-update-status-list" function and save statusList to variable $newStatusList
- - check If $originalStatusList is equal to $newStatusList
- - - If they are equal, exit the loop
- - - If they are not equal, set $originalStatusList to $newStatusList and continue the loop
- Return the final list of StatusElements




Options:
  -h, --help                        [boolean]                  Show help
      --version                     [boolean]                  Show version number
      --all                         [boolean]                  The opposite of `onlyChanged`. If `onlyChanged` is set by default, running jest with `--all` will force Jest to run all tests instead of running only tests related to changed files.
      --automock                    [boolean]                  Automock all files by default.
  -b, --bail                        [boolean]                  Exit the test suite immediately after `n` number of failing tests.
      --cache                       [boolean]                  Whether to use the transform cache. Disable the cache using --no-cache.
      --cacheDirectory              [string]                   The directory where Jest should store its cached  dependency information.
      --changedFilesWithAncestor    [boolean]                  Runs tests related to the current changes and the changes made in the last commit. Behaves similarly to `--onlyChanged`.
      --changedSince                [string]                   Runs tests related to the changes since the provided branch. If the current branch has diverged from the given branch, then only changes made locally will be tested. Behaves similarly to `--onlyChanged`.
      --ci                          [boolean]                  Whether to run Jest in continuous integration (CI) mode. This option is on by default in most popular CI environments. It will prevent snapshots from being written unless explicitly requested.
      --clearCache                  [boolean]                  Clears the configured Jest cache directory and then exits. Default directory can be found by calling jest --showConfig
      --clearMocks                  [boolean]                  Automatically clear mock calls, instances, contexts and results before every test. Equivalent to calling jest.clearAllMocks() before each test.
      --collectCoverage             [boolean]                  Alias for --coverage.
      --collectCoverageFrom         [string]                   A glob pattern relative to <rootDir> matching the files that coverage info needs to be collected from.
      --color                       [boolean]                  Forces test results output color highlighting (even If stdout is not a TTY). Set to false If you would like to have no colors.
      --colors                      [boolean]                  Alias for `--color`.
  -c, --config                      [string]                   The path to a jest config file specifying how to find and execute tests. If no rootDir is set in the config, the directory containing the config file is assumed to be the rootDir for the project. This can also be a JSON encoded value which Jest will use as configuration.
      --coverage                    [boolean]                  Indicates that test coverage information should be collected and reported in the output.
      --coverageDirectory           [string]                   The directory where Jest should output its coverage files.
      --coveragePathIgnorePatterns  [array]                    An array of regexp pattern strings that are matched against all file paths before executing the test. If the file path matches any of the patterns, coverage information will be skipped.
      --coverageProvider            [choices: "babel", "v8"]   Select between Babel and V8 to collect coverage
      --coverageReporters           [array]                    A list of reporter names that Jest uses when writing coverage reports. Any istanbul reporter can be used.
      --coverageThreshold           [string]                   A JSON string with which will be used to configure minimum threshold enforcement for coverage results
      --debug                       [boolean]                  Print debugging info about your jest config.
      --detectLeaks                 [boolean]                  **EXPERIMENTAL**: Detect memory leaks in tests. After executing a test, it will try to garbage collect the global object used, and fail If it was leaked
      --detectOpenHandles           [boolean]                  Print out remaining open handles preventing Jest from exiting at the end of a test run. Implies `runInBand`.
      --env                         [string]                   The test environment used for all tests. This can point to any file or node module. Examples: `jsdom`, `node` or `path/to/my-environment.js'
      --errorOnDeprecated           [boolean]                  Make calling deprecated APIs throw helpful error messages.
  -e, --expand                      [boolean]                  Use this flag to show full diffs instead of a patch.
      --filter                      [string]                   Path to a module exporting a filtering function. This method receives a list of tests which can be manipulated to exclude tests from running. Especially useful when used in conjunction with a testing infrastructure to filter known broken tests.
      --findRelatedTests            [boolean]                  Find related tests for a list of source files that were passed in as arguments. Useful for pre-commit hook integration to run the minimal amount of tests necessary.
      --forceExit                   [boolean]                  Force Jest to exit after all tests have completed running. This is useful when resources set up by test code cannot be adequately cleaned up.
      --globalSetup                 [string]                   The path to a module that runs before All Tests.
      --globalTeardown              [string]                   The path to a module that runs after All Tests.
      --globals                     [string]                   A JSON string with map of global variables that need to be available in all test environments.
      --haste                       [string]                   A JSON string with map of variables for the haste module system
      --ignoreProjects              [array]                    Ignore the tests of the specified projects. Jest uses the attribute `displayName` in the configuration to identify each project.
      --init                        [boolean]                  Generate a basic configuration file
      --injectGlobals               [boolean]                  Should Jest inject global variables or not
      --json                        [boolean]                  Prints the test results in JSON. This mode will send all other test output and user messages to stderr.
      --lastCommit                  [boolean]                  Run all tests affected by file changes in the last commit made. Behaves similarly to `--onlyChanged`.
      --listTests                   [boolean]                  Lists all tests Jest will run given the arguments and exits. Most useful in a CI system together with `--findRelatedTests` to determine the tests Jest will run based on specific files
      --logHeapUsage                [boolean]                  Logs the heap usage after every test. Useful to debug memory leaks. Use together with `--runInBand` and `--expose-gc` in node.
      --maxConcurrency              [number]                   Specifies the maximum number of tests that are allowed to run concurrently. This only affects tests using `test.concurrent`.
  -w, --maxWorkers                  [string]                   Specifies the maximum number of workers the worker-pool will spawn for running tests. This defaults to the number of the cores available on your machine. (its usually best not to override this default)
      --moduleDirectories           [array]                    An array of directory names to be searched recursively up from the requiring module's location.
      --moduleFileExtensions        [array]                    An array of file extensions your modules use. If you require modules without specifying a file extension, these are the extensions Jest will look for.
      --moduleNameMapper            [string]                   A JSON string with a map from regular expressions to module names or to arrays of module names that allow to stub out resources, like images or styles with a single module
      --modulePathIgnorePatterns    [array]                    An array of regexp pattern strings that are matched against all module paths before those paths are to be considered "visible" to the module loader.
      --modulePaths                 [array]                    An alternative API to setting the NODE_PATH env variable, modulePaths is an array of absolute paths to additional locations to search when resolving modules.
      --noStackTrace                [boolean]                  Disables stack trace in test results output
      --notify                      [boolean]                  Activates notifications for test results.
      --notifyMode                  [string]                   Specifies when notifications will appear for test results.
  -o, --onlyChanged                 [boolean]                  Attempts to identify which tests to run based on which files have changed in the current repository. Only works If you're running tests in a git or hg repository at the moment.
  -f, --onlyFailures                [boolean]                  Run tests that failed in the previous execution.
      --openHandlesTimeout          [number]                   Print a warning about probable open handles If Jest does not exit cleanly after this number of milliseconds. `0` to disable.
      --outputFile                  [string]                   Write test results to a file when the --json option is also specified.
      --passWithNoTests             [boolean]                  Will not fail If no tests are found (for example while using `--testPathPattern`.)
      --preset                      [string]                   A preset that is used as a base for Jest's configuration.
      --prettierPath                [string]                   The path to the "prettier" module used for inline snapshots.
      --projects                    [array]                    A list of projects that use Jest to run all tests of all projects in a single instance of Jest.
      --randomize                   [boolean]                  Shuffle the order of the tests within a file. In order to choose the seed refer to the `--seed` CLI option.
      --reporters                   [array]                    A list of custom reporters for the test suite.
      --resetMocks                  [boolean]                  Automatically reset mock state before every test. Equivalent to calling jest.resetAllMocks() before each test.
      --resetModules                [boolean]                  If enabled, the module registry for every test file will be reset before running each individual test.
      --resolver                    [string]                   A JSON string which allows the use of a custom resolver.
      --restoreMocks                [boolean]                  Automatically restore mock state and implementation before every test. Equivalent to calling jest.restoreAllMocks() before each test.
      --rootDir                     [string]                   The root directory that Jest should scan for tests and modules within.
      --roots                       [array]                    A list of paths to directories that Jest should use to search for files in.
  -i, --runInBand                   [boolean]                  Run all tests serially in the current process (rather than creating a worker pool of child processes that run tests). This is sometimes useful for debugging, but such use cases are pretty rare.
      --runTestsByPath              [boolean]                  Used when provided patterns are exact file paths. This avoids converting them into a regular expression and matching it against every single file.
      --runner                      [string]                   Allows to use a custom runner instead of Jest's default test runner.
      --seed                        [number]                   Sets a seed value that can be retrieved in a tests file via `jest.getSeed()`. If this option is not specified Jest will randomly generate the value. The seed value must be between `-0x80000000` and `0x7fffffff` inclusive.
      --selectProjects              [array]                    Run the tests of the specified projects. Jest uses the attribute `displayName` in the configuration to identify each project.
      --setupFiles                  [array]                    A list of paths to modules that run some code to configure or set up the testing environment before each test.
      --setupFilesAfterEnv          [array]                    A list of paths to modules that run some code to configure or set up the testing framework before each test
      --shard                       [string]                   Shard tests and execute only the selected shard, specify in the form "current/all". 1-based, for example "3/5".
      --showConfig                  [boolean]                  Print your jest config and then exits.
      --showSeed                    [boolean]                  Prints the seed value in the test report summary. See `--seed` for how to set this value
      --silent                      [boolean]                  Prevent tests from printing messages through the console.
      --skipFilter                  [boolean]                  Disables the filter provided by --filter. Useful for CI jobs, or local enforcement when fixing tests.
      --snapshotSerializers         [array]                    A list of paths to snapshot serializer modules Jest should use for snapshot testing.
      --testEnvironment             [string]                   Alias for --env
      --testEnvironmentOptions      [string]                   A JSON string with options that will be passed to the `testEnvironment`. The relevant options depend on the environment.
      --testFailureExitCode         [string]                   Exit code of `jest` command If the test run failed
      --testLocationInResults       [boolean]                  Add `location` information to the test results
      --testMatch                   [array]                    The glob patterns Jest uses to detect test files.
  -t, --testNamePattern             [string]                   Run only tests with a name that matches the regex pattern.
      --testPathIgnorePatterns      [array]                    An array of regexp pattern strings that are matched against all test paths before executing the test. If the test path matches any of the patterns, it will be skipped.
      --testPathPattern             [array]                    A regexp pattern string that is matched against all tests paths before executing the test.
      --testRegex                   [array]                    A string or array of string regexp patterns that Jest uses to detect test files.
      --testResultsProcessor        [string]                   Allows the use of a custom results processor. This processor must be a node module that exports a function expecting as the first argument the result object.
      --testRunner                  [string]                   Allows to specify a custom test runner. The default is `jest-circus/runner`. A path to a custom test runner can be provided: `<rootDir>/path/to/testRunner.js`.
      --testSequencer               [string]                   Allows to specify a custom test sequencer. The default is `@jest/test-sequencer`. A path to a custom test sequencer can be provided: `<rootDir>/path/to/testSequencer.js`
      --testTimeout                 [number]                   This option sets the default timeouts of test cases.
      --transform                   [string]                   A JSON string which maps from regular expressions to paths to transformers.
      --transformIgnorePatterns     [array]                    An array of regexp pattern strings that are matched against all source file paths before transformation.
      --unmockedModulePathPatterns  [array]                    An array of regexp pattern strings that are matched against all modules before the module loader will automatically Return a mock for them.
  -u, --updateSnapshot              [boolean]                  Use this flag to re-record snapshots. Can be used together with a test suite pattern or with `--testNamePattern` to re-record snapshot for test matching the pattern
      --useStderr                   [boolean]                  Divert all output to stderr.
      --verbose                     [boolean]                  Display individual test results with the test suite hierarchy.
      --watch                       [boolean]                  Watch files for changes and rerun tests related to changed files. If you want to re-run all tests when a file has changed, use the `--watchAll` option.
      --watchAll                    [boolean]                  Watch files for changes and rerun all tests. If you want to re-run only the tests related to the changed files, use the `--watch` option.
      --watchPathIgnorePatterns     [array]                    An array of regexp pattern strings that are matched against all paths before trigger test re-run in watch mode. If the test path matches any of the patterns, it will be skipped.
      --watchman                    [boolean]                  Whether to use watchman for file crawling. Disable using --no-watchman.
      --workerThreads               [boolean]                  Whether to use worker threads for parallelization. Child processes are used by default.

      #>
