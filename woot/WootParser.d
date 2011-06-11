module woot.WootParser;

import sleek.net.http.HttpGetRequest;
import DocEntity = tango.text.xml.DocEntity;
import tango.text.xml.Document;

class WootParser
{
    private alias Document!(char) XmlDoc;
    private alias XmlPath!(char) XPath;

    private XmlDoc document;
    private XPath.NodeSet itemNodeSet;

    this(char[] xml)
    {
        document = new XmlDoc;
        document.parse(xml);
        itemNodeSet = document.query["rss"]["channel"]["item"];
    }

    T getItemNode(T)(ref T member, char[] nodeName) {
        return getCachedNodeValue(member, itemNodeSet[nodeName]);
    }

    T getNSItemNode(T)(ref T member, char[] prefix, char[] nodeName)
    {
        final auto filter = delegate bool(XmlDoc.Node node) {
            return (node.prefix == prefix) && (node.name == nodeName);
        };

        return getCachedNodeValue(member, itemNodeSet.child(filter));
    }

    private T getCachedNodeValue(T)(ref T member, XPath.NodeSet nodeSet)
    {
        if (member is null) {
            member = decodeValue(nodeSet.nodes[0].value);
        }

        return member;
    }

    private T decodeValue(T)(T value)
    {
        if (is(T == char[])) {
            // need to double-decode
            value = DocEntity.fromEntity(value);
            value = DocEntity.fromEntity(value);
        }

        return value;
    }
}

debug
{
    import woot.WootItem;

    unittest
    {
        char[] dummy_string;
        auto parser = new WootParser(import("woot.xml"));
        assert("My Hero" == parser.getItemNode(dummy_string, WootItem.TITLE), "Got an unexpected value for the \"title\" node");
    }
}
