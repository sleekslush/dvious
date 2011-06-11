module sleekui.dwt.util.PropertyResourceBundle;

import dwt.dwthelper.ResourceBundle;
import dwt.dwthelper.utils : ImportData, MissingResourceException;

class PropertyResourceBundle
{
    alias get opCall;
    protected ResourceBundle bundle;

    package this(void[] data, char[] name = "")
    {
        this(ImportData(data, name));
    }

    this(ImportData data)
    {
        this([data]);
    }

    this(ImportData[] data)
    {
        bundle = ResourceBundle.getBundle(data);
    }

    bool has(char[] key)
    {
        return bundle.hasString(key);
    }

    char[] get(char[] key)
    {
        return bundle.getString(key);
    }

    char[] get(char[] key, char[] defaultValue)
    {
        try {
            return get(key);
        } catch (MissingResourceException) {
            return defaultValue;
        }
    }

    char[][] keys()
    {
        return bundle.getKeys();
    }
}

debug unittest
{
    const auto properties = `
        a = hello
        a.b = 5
        a.b.c = true
    `;

    auto bundle = new PropertyResourceBundle(properties);

    assert(bundle.has("a"));
    assert(bundle.has("a.b"));
    assert(bundle.has("a.b.c"));
    assert(!bundle.has("a.c"));

    assert(bundle("a") == "hello");
    assert(bundle("a.b") == "5");
    assert(bundle.get("a.b.c") == "true");
    assert(bundle.get("a.c", "sweet") == "sweet");
}
