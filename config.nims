import std/strformat

const
    TestDir  = "./tests"
    BuildDir = "./build"

    Flags    = &"--cc:tcc --threads:off --nimCache:{BuildDir}"

task test, "Run all tests":
    exec &"testament pattern {TestDir}/*.nim"

task test_match, "Run match tests":
    exec &"nim c -r {Flags} {TestDir}/match.nim"
