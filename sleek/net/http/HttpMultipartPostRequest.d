module sleek.net.http.HttpMultipartPostRequest;

import sleek.net.http.HttpPostRequest;

import tango.io.device.Array;
import tango.io.device.File;
import tango.io.model.IConduit : IConduit, InputBuffer, OutputBuffer;
import tango.net.Uri;
import tango.net.http.HttpHeaders;
import tango.text.convert.Format;
import TimeStamp = tango.text.convert.TimeStamp;
import tango.time.Clock;
import tango.util.digest.Md5;

class HttpMultipartPostRequest : HttpPostRequest
{
    protected File[char[]] files;
    protected char[] boundary;

    alias void delegate (long sent, long total) UploadProgress;

    this(char[] url)
    {
        this(new Uri(url));
    }

    this(Uri uri)
    {
        super(uri);
        boundary = createBoundary;
    }

    /*InputBuffer open()
    {
        return open(null);
    }*/

    InputBuffer open(UploadProgress uploadProgress)
    {
        auto input = buildInputBuffer;

        getRequestHeaders.add(HttpHeader.ContentType, contentType);
        getRequestHeaders.addInt(HttpHeader.ContentLength, input.limit);

        final dg = delegate void(OutputBuffer output) {
            pump(input, output, uploadProgress);
        };

        return super.open(dg);
    }

    void addFile(char[] name, File file)
    {
        files[name] = file;
    }

    private Array buildInputBuffer()
    {
        auto input = new Array(1024, 1);
        appendInputParams(input);
        appendInputFiles(input);
        return input;
    }

    protected void pump(Array input, OutputBuffer output, UploadProgress onUploadProgress)
    {
        auto done = false;
        auto totalBytesRead = 0;

        do {
            // buffer to hold data from the input buffer
            auto content = new void[HttpHeader.IOBufferSize];

            // read from the input buffer
            auto bytesRead = input.read(content);

            // we're done if no bytes were read
            done = (bytesRead == IConduit.Eof);

            // append each chunk of bytes to the output buffer
            if (!done) {
                totalBytesRead += bytesRead;

                // append the content and flush to the server
                output.append(content[0..bytesRead]);
                output.flush;

                // fire upload progress
                if (onUploadProgress.funcptr) {
                    onUploadProgress(totalBytesRead, input.limit);
                }
            }
        } while (!done);
    }

    private void appendInputParams(Array input)
    {
        foreach (param; getRequestParams) {
            input.append(Format("--{}\r\n", boundary));
            input.append("Content-Disposition: form-data;");
            input.append(Format(" name=\"{}\"\r\n\r\n", param.name));
            input.append(Uri.encode(param.value, Uri.IncQueryAll));
            input.append("\r\n");
        }
    }

    private void appendInputFiles(Array input)
    {
        foreach (name, file; files) {
            input.append(Format("--{}\r\n", boundary));
            input.append("Content-Disposition: form-data;");
            input.append(Format(" name=\"{}\"; filename=\"{}\"\r\n", name, file.toString));
            input.append("Content-Type: application/octet-stream;");
            input.append(Format(" boundary={}\r\n\r\n", boundary));
            input.append(file.load);
            input.append(Format("\r\n--{}--\r\n", boundary));
        }
    }

    private char[] contentType()
    {
        return "multipart/form-data; boundary=" ~ boundary;
    }

    protected char[] createBoundary()
    {
        with (new Md5) {
            update(TimeStamp.toString(Clock.now));
            return hexDigest;
        }
    }
}

debug
{
    import tango.util.log.Trace;

    unittest
    {
        char[] url = "http://www.google.com";
        new HttpMultipartPostRequest(url);

        auto request = new HttpMultipartPostRequest(new Uri(url));
        request.getRequestParams.add("hello", "world");
        request.getRequestParams.add("d", "reborn");

        /*auto dg = delegate void(long bytesRead, long total) {
            auto percent = cast(float) bytesRead / total * 100;
            Trace.formatln("Multipart POST: {}% complete", cast(int) percent);
        };

        request.open(dg);*/
    }
}
