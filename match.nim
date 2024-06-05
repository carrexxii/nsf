{.experimental: "codeReordering".}

import std/strutils

type State = object
    pat: ptr char
    str: ptr char
    res: string

template `+`(p: ptr char; offset: int): ptr char = cast[ptr char](cast[uint](p) + offset*(sizeof p[]))
template `-`(p: ptr char; offset: int): ptr char = cast[ptr char](cast[uint](p) - offset*(sizeof p[]))
template `+=`(p: ptr char; offset: int) = p = p + offset
template `-=`(p: ptr char; offset: int) = p = p - offset
proc inc(p: var ptr char): char {.discardable.} = result = p[]; p += 1
proc dec(p: var ptr char): char {.discardable.} = result = p[]; p -= 1

func match_class(c: char; k: ptr char): bool =
    case k[]
    of '.': true
    of 'a': is_alpha_ascii c
    else  : c == k[]

proc step(pat: var ptr char) =
    case pat[]
    of '\\': pat += 2
    else: inc pat

proc match_one(state: var State): bool =
    case state.pat[]
    of '.' : true
    of '\\': match_class(state.str[], state.pat + 1)
    else   : state.str[] == state.pat[]

proc match_many_max(state: var State): string =
    let k = inc state.pat
    assert((inc state.pat) == '*', $state.pat[])

    var
        str = state.str
        pat = state.pat
        len = 0
        prev_match = 0
    step pat
    while true:
        let c = inc str
        if not match_class(c, k.addr):
            if not match_class(c, pat):
                len = prev_match
                break
            prev_match = len
        elif c == '\0':
            break
        else:
            inc len

    for i in 0 ..< len:
        result &= inc state.str

proc match(state: var State) =
    while true:
        case state.pat[]
        of '\0':
            break
        else:
            case (state.pat + 1)[]
            of '*':
                state.res &= state.match_many_max
            else:
                if state.match_one:
                    state.res &= inc state.str
                    step state.pat
                else:
                    break

proc match*(str, pat: string): string =
    var state = State(pat: pat[0].addr, str: str[0].addr)
    match state
    state.res

proc `%`*(str, pat: string): string =
    match(str, pat)
