namespace Widgetario.Web.Models
{
    public class Product
    {
        public long Id { get; set; }

        public string Name { get; set; }

        public double Price { get; set; }

        public int Stock { get;  set; }        

        public string StockMessage 
        {
            get 
            {
                var message = "Plenty";
                if (Stock == 0)
                {
                    message = "SOLD OUT!";
                }
                else if (Stock < 50)
                {
                    message = "Last few...";
                }
                return message;
            }
        }


        public string DisplayPrice
        {
            get
            {
                return $"${Price.ToString("#.00")}";
            }
        }
    }
}
