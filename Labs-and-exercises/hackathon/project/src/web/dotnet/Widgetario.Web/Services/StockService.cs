using Microsoft.Extensions.Configuration;
using RestSharp;
using System;
using System.Threading.Tasks;
using Widgetario.Web.Models;

namespace Widgetario.Web.Services
{
    public class StockService
    {
        private readonly IConfiguration _config;

        public string ApiUrl { get; private set; }

        public StockService(IConfiguration config)
        {
            _config = config;
            ApiUrl = _config["Widgetario:StockApi:Url"];
        }

        public async Task<ProductStock> GetStock(long productId)
        {
            var client = new RestClient(ApiUrl);
            var request = new RestRequest($"{productId}");
            var response = await client.ExecuteGetAsync<ProductStock>(request);
            if (!response.IsSuccessful)
            {
                throw new Exception($"Service call failed, status: {response.StatusCode}, message: {response.ErrorMessage}");
            }
            return response.Data;
        }
    }
}
