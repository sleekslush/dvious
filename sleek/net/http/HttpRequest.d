module sleek.net.http.HttpRequest;

import tango.io.compress.ZlibStream : ZlibInput;
import tango.io.model.IConduit : InputBuffer;
import tango.io.stream.Buffered : Bin;
import tango.net.Uri;
import tango.net.http.HttpClient;
import tango.net.http.HttpHeaders;
version (NoSSL) {
    // don't include SSL support
} else {
    import tango.net.device.SSLSocket; // requires OpenSSL
}
import tango.net.device.Socket;

/**
 * The base HttpClient doesn't handle HTTPS requests by default. This
 * class overrides this behavior to allow for both HTTP and HTTPS requests
 * be made.
 */
abstract class HttpRequest : HttpClient
{
    static const DEFAULT_TIMEOUT_SECONDS = 10;

    /**
     * Create a client with the provided request method and url.
     */
    this(RequestMethod method, char[] url)
    {
        this(method, new Uri(url));
    }

    /*
     * Create a client with the provided request method and Uri instance.
     */
    this(RequestMethod method, Uri uri)
    {
        super(method, uri);
        setTimeout(DEFAULT_TIMEOUT_SECONDS);
    }

    /**
     * and call parent.
     */
    override InputBuffer open()
    {
        return super.open();
    }

    /**
     * and call parent.
     */
    override InputBuffer open(Pump pump)
    {
        return super.open(pump);
    }

    /**
     * Overridden to handle Gzip compression. Should be transparent to the user.
     */
    override InputBuffer open(RequestMethod method, Pump pump)
    {
        const char[] CONTENT_CODING = "gzip";

        // Request a compressed response
        getRequestHeaders().add(HttpHeader.AcceptEncoding, CONTENT_CODING);

        auto buffer = super.open(method, pump);

        // Server responded with compressed content, so wrap it in the proper stream
        if (CONTENT_CODING == getResponseHeaders().get(HttpHeader.ContentEncoding)) {
            return new Bin(new ZlibInput(buffer, ZlibInput.Encoding.Gzip));
        }

        return buffer;
    }

    /**
     * Returns an SSLSocketConduit when the "https" scheme is requested,
     * otherwise the base socket is returned.
     */
    protected Socket createSocket()
    {
        version (NoSSL) {
            // no SSL support
        } else {
            if ("https" == getUri().getScheme()) {
                return new SSLSocket;
            }
        }

        return super.createSocket();
    }
}

debug
{
    import tango.io.Stdout;

    unittest
    {
        class MyHttpRequest : HttpRequest
        {
            this(RequestMethod method, char[] url)
            {
                this(method, new Uri(url));
            }

            this(RequestMethod method, Uri uri)
            {
                super(method, uri);
            }
        }

        auto url = "http://www.reddit.com/r/programming/";
        //new MyHttpRequest(HttpRequest.Get, url);
    }
}
