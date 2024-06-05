import std/strformat
import "../match.nim"

func red(s: string)  : string = "\e[31m" & s & "\e[0m"
proc green(s: string): string = "\e[32m" & s & "\e[0m"

var count = 0
proc check(str, pat, expect: string) =
    count += 1
    let actual = str % pat
    let msg = &"[{count}] '{str}' % '{pat}' == '{expect}' -> '{actual}'"
    if actual != expect:
        echo red msg
    else:
        echo green msg

check("Hello, World!", r"\a" , "H")
check("aaab"         , r".*b", "aaab")
check("aaa"          , r".*a", "aaa")

check("b"      , r".*b", "b")
check("aaab"   , r".+b", "aaab")
check("aaa"    , r".+a", "aaa")
check("b"      , r".+b", "")
check("aaab"   , r".?b", "ab")
check("aaa"    , r".?a", "aa")
check("b"      , r".?b", "b")
check("aloALO" , r"%l*", "alo")
check("aLo_ALO", r"%a*", "aLo")
