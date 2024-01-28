using Microsoft.Extensions.Configuration;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Widgetario.Web.Models;

namespace Widgetario.Web.Services
{
    public class ProductService
    {
        private readonly IConfiguration _config;

        public string ApiUrl { get; private set; }

        public ProductService(IConfiguration config)
        {
            _config = config;
            ApiUrl = _config["Widgetario:ProductsApi:Url"];
        }

        public async Task<IEnumerable<Product>> GetProducts()
        {
            var client = new RestClient(ApiUrl);
            var request = new RestRequest();
            var response = await client.ExecuteGetAsync<IEnumerable<Product>>(request);
            if (!response.IsSuccessful)
            {
                throw new Exception($"Service call failed, status: {response.StatusCode}, message: {response.ErrorMessage}");
            }
            return response.Data;
        }
    }
}
