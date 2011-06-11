module sleek.net.http.HttpForm;

import sleek.net.http.HttpGetRequest;
import sleek.net.http.HttpMultipartPostRequest;
import sleek.net.http.HttpPostRequest;
import sleek.net.http.HttpRequest;
import sleek.net.http.HttpResponse;
import tango.net.Uri;
import tango.net.http.HttpHeaders;
import tango.net.http.HttpParams;
import tango.io.FilePath;
import tango.io.device.File;
import tango.time.Time;

class HttpForm
{
    alias void delegate(uint, uint) OnUploadProgress;

    protected Uri uri_;
    protected char[] requestMethod_;
    protected HttpParams params;
    protected File[char[]] files;

    /**
     * Create a new HTTP form that sends data to the provided URL.
     *
     * Params:
     *      url = The URL to send data to
     */
    this(char[] url)
    {
        this(new Uri(url));
    }

    /**
     * Create a new HTTP form that sends data to the provided URI.
     *
     * Params:
     *      uri = The URI to send data to
     */
    this(Uri uri)
    {
        this.uri = uri;
        params = new HttpParams;
    }

    /**
     * The URI that this form will send data to.
     *
     * Returns: The URI
     */
    Uri uri()
    {
        return uri_;
    }

    /**
     * Specify the URI that this form will send data to.
     *
     * Params:
     *      uri = The URI
     */
    void uri(Uri uri)
    {
        uri_ = uri;
    }

    /**
     * Specify the form request method.
     *
     * Params:
     *      requestMethod = GET or POST
     */
    void requestMethod(char[] requestMethod)
    {
        requestMethod_ = requestMethod;
    }

    /**
     * The form request method.
     *
     * Returns: GET or POST
     */
    char[] requestMethod()
    {
        return requestMethod_;
    }

    /**
     * Adds a parameter to the form.
     *
     * Params:
     *      name = The name of the parameter
     *      value = The string value
     */
    void addParam(char[] name, char[] value)
    {
        params.add(name, value);
    }

    /**
     * Adds a parameter to the form.
     *
     * Params:
     *      name = The name of the parameter
     *      value = The integer value
     */
    void addParam(char[] name, int value)
    {
        params.addInt(name, value);
    }

    /**
     * Adds a parameter to the form.
     *
     * Params:
     *      name = The name of the parameter
     *      value = The time value
     */
    void addParam(char[] name, Time value)
    {
        params.addDate(name, value);
    }

    /**
     * Adds a file to the form.
     *
     * Params:
     *      name = The name of the parameter
     *      value = The file path
     */
    void addParam(char[] name, FilePath filePath)
    {
        addParam(name, new File(filePath.toString));
    }

    void addParam(char[] name, File file)
    {
        files[name] = file;
    }

    /**
     * Reset params and files for a clean request.
     */
    void reset()
    {
        params = null;
        files = null;
    }

    /**
     * Submit the form to the server.
     *
     * Params:
     *      dg = The callback when a request completes
     */
    HttpResponse submit(HttpMultipartPostRequest.UploadProgress uploadProgress = null)
    {
        auto request = createRequest;
        scope(exit)
            request.close;

        attachInputParams(request);

        auto buffer = openConnection(request, uploadProgress);

        auto responseHeaders = request.getResponseHeaders;
        buffer.load(responseHeaders.getInt(HttpHeader.ContentLength, uint.max));

        return new HttpResponse(request, buffer);
    }

    private void attachInputParams(HttpRequest request)
    {
        // Attach all form parameters
        foreach (param; params) {
            request.getRequestParams.add(param.name, param.value);
        }

        // Check for files to add
        if (auto multipartPostRequest = cast(HttpMultipartPostRequest) request) {
            foreach (name, file; files) {
                multipartPostRequest.addFile(name, file);
            }
        }
    }

    private HttpRequest createRequest()
    {
        if (requestMethod == HttpRequest.Get.name) {
            return new HttpGetRequest(uri);
        }

        return files.length ? new HttpMultipartPostRequest(uri) : new HttpPostRequest(uri);
    }

    /**
     * Opens a connection to the server and performs either a GET or POST depending
     * on the type of HttpRequest object passed in.
     *
     * Params:
     *      request = HttpPostRequest or HttpPostRequest object
     *      buffer = The buffer used to return the response from the server
     */
    protected InputBuffer openConnection(HttpRequest request, 
            HttpMultipartPostRequest.UploadProgress uploadProgress)
    {
        if (auto multipartPostRequest = cast(HttpMultipartPostRequest) request) {
            return multipartPostRequest.open(uploadProgress);
        }

        return request.open;
    }
}

debug
{
    unittest
    {
    }
}
