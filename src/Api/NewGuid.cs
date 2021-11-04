using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using System;

namespace Api
{
    public static class NewGuid
    {
        [FunctionName(nameof(NewGuid))]
        public static string Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "GET", Route = "")] 
            HttpRequest req)
        {
            return Guid.NewGuid().ToString("D");
        }
    }
}
