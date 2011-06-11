module woot.WootClient;

import sleek.net.http.HttpGetRequest;
import woot.WootItem;
import woot.WootParser;

class WootClient
{
    struct WootType
    {
        final char[] name;
        final char[] url;
    }

    static const WootType Woot = {"Woot!", "http://www.woot.com/salerss.aspx"};
    static const WootType ShirtWoot = {"Shirt.Woot!", "http://shirt.woot.com/salerss.aspx"};
    static const WootType SelloutWoot = {"Sellout.Woot!", "http://sellout.woot.com/salerss.aspx"};
    static const WootType KidsWoot = {"Kids.Woot!", "http://kids.woot.com/salerss.aspx"};
    static const WootType WineWoot = {"Wine.Woot!", "http://wine.woot.com/salerss.aspx"};

    /**
     * Get the Woot of the day for the specified brand.
     *
     * Params:
     *  type = The brand to retrieve from
     */
    WootItem getWoot(WootType type)
    {
        auto client = new HttpGetRequest(type.url);
        auto xml = cast(char[]) client.read();
        auto parser = new WootParser(xml);
        return new WootItem(parser);
    }
}

debug
{
    package class FakeWootClient : WootClient
    {
        WootItem getWoot(WootType type)
        {
            return new WootItem(new WootParser(import("woot.xml")));
        }
    }

    unittest
    {
        auto client = new FakeWootClient;
        auto woot = client.getWoot(WootClient.Woot);
        assert(woot !is null);
    }
}
