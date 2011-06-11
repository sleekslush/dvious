module sleek.text.Util;

/**
 * Check to see if a string starts with another.
 */
bool startsWith(T)(T[] source, T[] match)
{
    return (source.length >= match.length) && (match == source[0..match.length]);
}

/**
 * Check to see if a string ends with another.
 *
 */
bool endsWith(T)(T[] source, T[] match)
{
    return (source.length >= match.length) && (match == source[(source.length - match.length)..$]);
}

debug unittest
{
    char[] s = "amnesia caribou and tequiza";
    assert(startsWith(s, "amnesia"));
    assert(!endsWith(s, "amnesia"));
    assert(!startsWith(s, "tequiza"));
    assert(endsWith(s, "tequiza"));
    assert(!startsWith(s, s ~ " off the turn buckle"));
    assert(startsWith("", ""));
}
