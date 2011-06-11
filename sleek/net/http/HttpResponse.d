module sleek.net.http.HttpResponse;

import sleek.net.http.HttpRequest;
import tango.io.model.IConduit : InputBuffer;

class HttpResponse
{
    protected HttpRequest request_;
    protected InputBuffer input_;

    this(HttpRequest request, InputBuffer input)
    {
        request_ = request;
        input_ = input;
    }

    HttpRequest request()
    {
        return request;
    }

    InputBuffer input()
    {
        return input_;
    }
}
