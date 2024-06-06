import std/[os, strformat, strutils]

let
    cwd = get_current_dir()
    bin_path  = cwd.split('/')[^1]
    src_dir   = "src"
    lib_dir   = "lib"
    tools_dir = "tools"
    build_dir = "build"
    deps: seq[tuple[src, dst, tag: string; cmds: seq[string]]] = @[
        (src : "https://github.com/libsdl-org/SDL/",
         dst : lib_dir / "sdl",
         tag : "3c5b1b52ac2aa34e902f01040e8d4a2691c234e7",
         cmds: @[""])
    ]

    entry =
        if file_exists &"{src_dir}/main.nim":
            src_dir / "main.nim"
        else:
            src_dir / &"{cwd.split('/')[^1]}.nim"
    debug_flags   = "--hints:off --nimCache:{build_dir} -o:{bin_path} --cc:tcc " &
                    "--passL:\"-ldl -lm\" --tlsEmulation:on -d:useMalloc"
    release_flags = "--nimCache:{build_dir} -o:{bin_path} --cc:gcc " &
                    "-d:release -d:danger"
    post_release = @[""]

#[ -------------------------------------------------------------------- ]#

--hints:off

proc red    (s: string): string = "\e[31m" & s & "\e[0m"
proc green  (s: string): string = "\e[32m" & s & "\e[0m"
proc yellow (s: string): string = "\e[33m" & s & "\e[0m"
proc blue   (s: string): string = "\e[34m" & s & "\e[0m"
proc magenta(s: string): string = "\e[35m" & s & "\e[0m"
proc cyan   (s: string): string = "\e[36m" & s & "\e[0m"

proc error(s: string)   = echo red    ("Error: "   & s)
proc warning(s: string) = echo yellow ("Warning: " & s)

var cmd_count = 0
proc run(cmd: string) =
    if defined `dry-run`:
        echo blue &"[{cmd_count}] ", cmd
        cmd_count += 1
    else:
        exec cmd

func is_git_repo(url: string): bool =
    (gorge_ex &"git ls-remote -q {url}")[1] == 0

#[ -------------------------------------------------------------------- ]#

task restore, "Fetch and build dependencies":
    run &"git submodule update --init --remote --merge --recursive -j 8"
    for dep in deps:
        if is_git_repo dep.src:
            if not (dir_exists dep.dst):
                run &"git submodule add {dep.src} {dep.dst}"
            with_dir dep.dst:
                run &"git checkout {dep.tag}"

        with_dir dep.dst:
            for cmd in dep.cmds:
                run cmd

task build, "Build the project (debug build)":
    run &"nim c {debug_flags} {entry}"

task release, "Build the project (release build)":
    run &"nim c {debug_flags} {entry}"
    for cmd in post_release:
        run cmd

task run, "Build and run with debug build":
    build_task()
    run &"./{bin_path}"

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
