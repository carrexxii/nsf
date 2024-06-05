{.experimental: "codeReordering".}

type State = object
    pat: ptr char
    str: ptr char
    res: string = ""

template `+`(p: ptr char; offset: int): ptr char = cast[ptr char](cast[uint](p) + offset*(sizeof p[]))
template `-`(p: ptr char; offset: int): ptr char = cast[ptr char](cast[uint](p) - offset*(sizeof p[]))
template `+=`(p: ptr char; offset: int) = p = p + offset
template `-=`(p: ptr char; offset: int) = p = p - offset
proc inc(p: var ptr char): char {.discardable.} = result = p[]; p += 1
proc dec(p: var ptr char): char {.discardable.} = result = p[]; p -= 1

func match_class(c: char; k: ptr char): bool =
    case k[]
    of '.': result = true
    else:
        result = c == k[]

proc match_one(state: var State): char =
    let p = inc state.pat
    let s = inc state.str
    case p
    of '.':
        result = s
    else:
        assert(false, $p)

proc match_many_max(state: var State): string =
    let k = inc state.pat
    assert((inc state.pat) == '*', $state.pat[])
    while true:
        let c = inc state.str
        if not match_class(c, k.addr):
            dec state.str
            return
        elif c == '\0':
            return
        else:
            result &= c

proc match*(state: var State) =
    while true:
        case state.pat[]
        of '\0':
            break
        else:
            case (state.pat + 1)[]
            of '*':
                state.res &= state.match_many_max
            else:
                state.res &= state.match_one

proc match(str, pat: string): string =
    var state = State(pat: pat[0].addr, str: str[0].addr)
    match state
    state.res

when is_main_module:
    echo "Hello, World!".match ".*"
