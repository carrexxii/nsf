import std/strformat

const TestDir = "./tests"

task test, "Run all tests":
    exec &"testament pattern {TestDir}/*.nim"

task test_match, "Run match tests":
    exec &"nim c -r {TestDir}/match.nim"
