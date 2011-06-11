/**
 * Figure out what the code looks like if cache isn't being used.
 * Also determine if we would even bother not having a cache...
 */
module sleek.net.http.HttpGetRequest;

import sleek.net.http.HttpRequest;
import Path = tango.io.Path;
import tango.io.device.File;
import tango.io.stream.Buffered : Bin;
import tango.net.Uri;
import tango.net.http.HttpConst : HttpHeader, HttpResponseCode;
import tango.net.http.HttpHeaders;
import HomeFolder = tango.sys.HomeFolder;
import tango.util.digest.Sha1;

class HttpGetRequest : HttpRequest
{
    private bool useCache_ = true;
    private char[] cachePath_;
    private char[] hash_;

    /**
     * Constructs an HTTP GET request with the provided URL.
     *
     * Params:
     *  url = The URL of the server
     */
    this(char[] url)
    {
        this(new Uri(url));
    }

    /**
     * Constructs an HTTP GET request with the provided URI object.
     *
     * Params:
     *  uri = The URI of the server
     */
    this(Uri uri)
    {
        super(Get, uri);
    }

    void useCache(bool flag)
    {
        useCache_ = flag;
    }

    bool usingCache()
    {
        return useCache_;
    }

    void cachePath(char[] path)
    {
        cachePath_ = path;
    }

    char[] cachePath()
    {
        if (!cachePath_) {
            cachePath_ = defaultCachePath;
        }

        return cachePath_;
    }

    char[] defaultCachePath()
    {
        return Path.join(HomeFolder.homeFolder, ".sleeknet", "cache");
    }

    protected char[] cachedFilePath()
    {
        return Path.join(cachePath, urlHash);
    }

    protected char[] urlHash()
    {
        if (!hash_) {
            auto sha1 = new Sha1;
            sha1.update(getUri().toString());
            hash_ = sha1.hexDigest();
        }

        return hash_;
    }

    override InputBuffer open()
    {
        return super.open();
    }

    override InputBuffer open(Pump pump)
    {
        return super.open(pump);
    }

    override InputBuffer open(RequestMethod method, Pump pump)
    {
        if (usingCache && Path.exists(cachedFilePath)) {
            auto modifiedTime = Path.modified(cachedFilePath);
            getRequestHeaders().addDate(HttpHeader.IfModifiedSince, modifiedTime);
        }

        return super.open(method, pump);
    }

    /**
     * Perform a GET request and return the response text as a void[].
     */
    void[] read()
    {
        return File.get(writeToFile);
    }

    char[] writeToFile(bool ifModifiedSince = true)
    {
        return writeToFile(null, ifModifiedSince);
    }

    /**
     * Performs a GET to the URL in the constructor and writes the response text to
     * the file specified. The file must have been opened in Write mode.
     *
     * Params:
     *  file = The file instance
     *  ifModifiedSince = Perform a conditional GET based on modified date of the file
     */
    char[] writeToFile(char[] path, bool ifModifiedSince = true)
    {
        writeCachedFile();

        // if a user-specified path is provided, copy the cached file to it
        if (path) {
            Path.copy(cachedFilePath, path);
        } else {
            return cachedFilePath;
        }

        return path;
    }

    private void writeCachedFile()
    {
        auto buffer = open();

        scope(exit) {
            close();
        }

        if (isResponseOK) {
            Path.createPath(cachePath);
            scope destination = new File(cachedFilePath, File.WriteCreate);
            destination.copy(buffer);
        } else if (getStatus() !is HttpResponseCode.NotModified) {
            throw new Exception("http failure!");
        }
    }
}

debug unittest
{
    //char[] url = "http://shirt.woot.com/salerss.aspx";
    //auto client = new HttpGetRequest(url);
    //client.writeToFile();
    //new HttpGetRequest(new Uri(url));
}
