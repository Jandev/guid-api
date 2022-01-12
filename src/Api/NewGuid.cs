using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace Api
{
    public static class NewGuid
    {
        private const string JsonMimeType = "application/json";
        private const string PlainTextMimeType = "text/plain";

        [FunctionName("DefaultNewGuid")]
        public static HttpResponseMessage Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "GET", Route = null)]
            HttpRequest req,
            ILogger log)
        {
            var guid = Guid.NewGuid().ToString("D");
            log.LogInformation("Created guid `{0}`", guid);

            var mimeTypeRequest = req.Headers["Accept"].FirstOrDefault();

            return CreateContentByAcceptHeader(mimeTypeRequest, guid);
        }

        private static HttpResponseMessage CreateContentByAcceptHeader(string mimeTypeRequest, string guid)
        {
            return mimeTypeRequest switch
            {
                JsonMimeType => new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(JsonConvert.SerializeObject(new { value = guid }), Encoding.UTF8,
                        JsonMimeType)
                },
                _ => new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(guid, Encoding.UTF8, PlainTextMimeType)
                }
            };
        }
    }
}
