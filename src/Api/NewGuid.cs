using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using System;
using Microsoft.Extensions.Logging;

namespace Api
{
    public static class NewGuid
    {
        [FunctionName("DefaultNewGuid")]
        public static string Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "GET", Route = null)] 
            HttpRequest req,
            ILogger log)
        {
            var guid = Guid.NewGuid().ToString("D");
            log.LogInformation("Created guid `{0}`", guid);
            return guid;
        }
    }
}
