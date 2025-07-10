using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using System.Net;

namespace Api
{
    public class Live
    {
        [Function(nameof(Live))]
        public HttpResponseData Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = null)] 
            HttpRequestData req)
        {
            var response = req.CreateResponse(HttpStatusCode.OK);
            return response;
        }
    }
}
