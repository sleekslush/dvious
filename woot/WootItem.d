module woot.WootItem;

import woot.WootParser;

class WootItem
{
    static const TITLE = "title";
    static const DESCRIPTION = "description";
    static const GUID = "guid";
    static const WOOT_NS = "woot";
    static const SUBTITLE = "subtitle";
    static const PRICE = "price";
    static const CONDITION = "condition";
    static const PURCHASE_URL = "purchaseurl";
    static const THUMBNAIL_IMAGE = "thumbnailimage";
    static const SUB_STANDARD_IMAGE = "substandardimage";
    static const STANDARD_IMAGE = "standardimage";

    private WootParser parser;
    private char[] title_;
    private char[] description_;
    private char[] guid_;
    private char[] subTitle_;
    private char[] price_;
    private char[] condition_;
    private char[] purchaseUrl_;
    private char[] thumbnailImage_;
    private char[] subStandardImage_;
    private char[] standardImage_;

    package this(WootParser parser)
    {
        this.parser = parser;
    }

    char[] title()
    {
        return parser.getItemNode(title_, TITLE);
    }

    char[] description()
    {
        return parser.getItemNode(description_, DESCRIPTION);
    }

    char[] guid()
    {
        return parser.getItemNode(guid_, GUID);
    }

    char[] subTitle()
    {
        return parser.getNSItemNode(subTitle_, WOOT_NS, SUBTITLE);
    }

    char[] price()
    {
        return parser.getNSItemNode(price_, WOOT_NS, PRICE);
    }

    char[] condition()
    {
        return parser.getNSItemNode(condition_, WOOT_NS, CONDITION);
    }

    char[] purchaseUrl()
    {
        return parser.getNSItemNode(purchaseUrl_, WOOT_NS, PURCHASE_URL);
    }

    char[] thumbnailImage()
    {
        return parser.getNSItemNode(thumbnailImage_, WOOT_NS, THUMBNAIL_IMAGE);
    }

    char[] subStandardImage()
    {
        return parser.getNSItemNode(subStandardImage_, WOOT_NS, SUB_STANDARD_IMAGE);
    }

    char[] standardImage()
    {
        return parser.getNSItemNode(standardImage_, WOOT_NS, STANDARD_IMAGE);
    }
}
