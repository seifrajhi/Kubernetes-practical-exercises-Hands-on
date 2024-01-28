using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace Widgetario.Web.Controllers
{
    public class UpController : Controller
    {
        private readonly ILogger<UpController> _logger;

        public UpController(ILogger<UpController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {            
            _logger.LogTrace($"/up called");
            return Ok();
        }
    }
}
