<%@ WebHandler Language="C#" Class="DictionaryProxyHandler" %>

using System.Net;
using System.Web;

public class DictionaryProxyHandler : IHttpHandler
{

    private string _allowedServer = "http://www.dictionaryapi.com";

    public void ProcessRequest (HttpContext context)
    {
        if(IsValidRequest(context.Request))
        {
            MakeRequestAndWriteResponse(context);
        }
        else
        {
            WriteUsageMessage(context.Response);
        }
    }

    private void WriteUsageMessage(HttpResponse response)
    {
        response.ContentType = "text/plain";
        response.Write("Usage: DictionaryProxyHandler.ashx?url=<url to dictionary web service> - must be server: " + _allowedServer);
    }

    private bool IsValidRequest(HttpRequest request)
    {
        var hasUrlParam = request.QueryString.Keys.Count == 1 &&
                          request.QueryString.Keys[0] == "url";
        if(!hasUrlParam)
        {
            return false;
        }

        var url = GetUrlFromRequest(request);

        return url.StartsWith(_allowedServer);
    }

    private void MakeRequestAndWriteResponse(HttpContext context)
    {
        context.Response.ContentType = "text/xml";

        using (var client = new WebClient())
        {
            var url = GetUrlFromRequest(context.Request);
            //example: "http://www.dictionaryapi.com/api/v1/references/collegiate/xml/inchoate?key=43ff6ed6-94a1-4e5d-881a-e85a37550217";

            var bytes = client.DownloadString(url);

            context.Response.Write(bytes);
        }
    }

    private string GetUrlFromRequest(HttpRequest request)
    {
        return request.QueryString["url"];
    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }
}
