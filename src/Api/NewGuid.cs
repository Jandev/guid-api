using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;
using System;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace Api
{
    public class NewGuid
    {
        private readonly ILogger<NewGuid> _logger;

        public NewGuid(ILogger<NewGuid> logger)
        {
            _logger = logger;
        }

        [Function("DefaultNewGuid")]
        public async Task<HttpResponseData> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "GET", Route = null)]
            HttpRequestData req)
        {
            var guid = Guid.NewGuid().ToString("D");
            _logger.LogInformation("Created guid `{Guid}`", guid);

            var acceptHeader = req.Headers.GetValues("Accept").FirstOrDefault();
            
            var response = req.CreateResponse(HttpStatusCode.OK);
            
            if (acceptHeader?.Contains("application/json") == true)
            {
                response.Headers.Add("Content-Type", "application/json");
                var jsonResponse = JsonSerializer.Serialize(new { value = guid });
                await response.WriteStringAsync(jsonResponse);
            }
            else
            {
                response.Headers.Add("Content-Type", "text/plain");
                await response.WriteStringAsync(guid);
            }

            return response;
        }
    }
}
