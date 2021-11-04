using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using System;
using System.Threading.Tasks;

namespace Api
{
    public static class NewGuid
    {
        [FunctionName(nameof(NewGuid))]
        public static async Task<string> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "GET", Route = "")] 
            HttpRequest req)
        {
            return Guid.NewGuid().ToString("D");
        }
    }
}
