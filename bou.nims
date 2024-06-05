import std/[os, sugar, streams, strformat, strutils, sequtils, tables]

--hints:off

let
    cwd = get_current_dir()
    bin_path  = get_current_dir().split('/')[^1] #dir_name
    src_dir   = "src"
    lib_dir   = "lib"
    tools_dir = "tools"
    deps: seq[tuple[src, dst, tag: string; cmds: seq[string]]] = @[
        (src : "https://github.com/libsdl-org/SDL/",
         dst : cwd / lib_dir / "sdl",
         tag : "2fb057af65b0951d063eafd3e052b06e8b4b365e",
         cmds: @[ "cmake -S . -B . -DSDL_DISABLE_INSTALL=ON -DSDL_STATIC=OFF",
                  "cmake --build . -j8",
                 &"cp ./build/libSDL3_ttf.so* {cwd / lib_dir}"])
    ]

#[ -------------------------------------------------------------------- ]#

proc red*    (s: string): string = "\e[31m" & s & "\e[0m"
proc green*  (s: string): string = "\e[32m" & s & "\e[0m"
proc yellow* (s: string): string = "\e[33m" & s & "\e[0m"
proc blue*   (s: string): string = "\e[34m" & s & "\e[0m"
proc magenta*(s: string): string = "\e[35m" & s & "\e[0m"
proc cyan*   (s: string): string = "\e[36m" & s & "\e[0m"

proc error(s: string)   = echo red    ("Error: "   & s)
proc warning(s: string) = echo yellow ("Warning: " & s)

var cmd_count = 0
proc run(cmd: string) =
    if defined `dry-run`:
        echo blue &"[{cmd_count}] ", cmd
        cmd_count += 1
    else:
        exec cmd

#[ -------------------------------------------------------------------- ]#

task add, "Add a dependency to the project [nim add <dependency>]":
    if param_count() < 2:
        error "Error: add requires at least one argument"

task restore, "Fetch and build ":
    if dir_exists ".git":
        run &"git submodule update --init --remote --merge --recursive -j 8"

    for dep in deps:
        if (gorge_ex &"git ls-remote -q {dep.src}")[1] == 0:
            run &"git submodule add {dep.src} {dep.dst}"
        else:
            # run &"wget {dep.src} {dep.dst}"
            echo &"wget {dep.src} {dep.dst}"

        for cmd in dep.cmds:
            run cmd

task build, "Build the project (debug build)":
    assert false

task release, "Build the project (release build)":
    assert false

task test, "Run the project's tests":
    assert false

task info, "Print out information about the project":
    echo green &"Bou Project '{yellow bin_path}'"
    echo &"    Source dir : {yellow src_dir}"
    echo &"    Library dir: {yellow lib_dir}"
    echo &"    Tools dir  : {yellow tools_dir}"
    if deps.len > 0:
        echo &"    Dependencies"
    for dep in deps:
        echo &"        {cyan dep.src} ({yellow dep.tag})"
