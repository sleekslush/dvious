module sleek.net.http.HttpPostRequest;

import sleek.net.http.HttpRequest;
import tango.io.model.IConduit : InputBuffer, OutputBuffer;
import tango.net.Uri;
import tango.net.http.HttpHeaders;

class HttpPostRequest : HttpRequest
{
    /**
     * Constructs an HTTP POST request with the provided URL.
     *
     * Params:
     *  url = The URL of the server
     */
    this(char[] url)
    {
        this(new Uri(url));
    }

    /**
     * Constructs an HTTP POST request with the provided URI object.
     *
     * Params:
     *  uri = The URI of the server
     */
    this(Uri uri)
    {
        super(Post, uri);
    }

    /**
     * Open the connection without a specific Pump.
     *
     * Returns: The response from the server
     */
    InputBuffer open()
    {
        return open(null);
    }

    /**
     * Open the connection with the Pump specified.
     *
     * Params:
     *  pump = The delegate responsible for pumping data during a request
     *
     * Returns: The response from the server
     */
    InputBuffer open(Pump pump)
    {
        return super.open(pump);
    }

    /**
     * Post raw data to the server with the specified content type.
     *
     * Params:
     *  content = The raw content
     *  type = The Content-Type
     *
     * Returns: The response from the server
     */
    InputBuffer write(void[] content, char[] type)
    {
        with (getRequestHeaders) {
            add(HttpHeader.ContentType, type);
            addInt(HttpHeader.ContentLength, content.length);
        }

        final dg = delegate void(OutputBuffer output) {
            output.append(content);
        };

        return open(dg);
    }
}

debug
{
    import tango.util.log.Trace;

    unittest
    {

        char[] url = "http://www.google.com";
        new HttpPostRequest(url);

        auto request = new HttpPostRequest(new Uri(url));
        request.getRequestParams.add("hello", "world");
        request.getRequestParams.add("d", "reborn");
    }
}
