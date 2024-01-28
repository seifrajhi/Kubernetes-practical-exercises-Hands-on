package widgetario.products;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class Application {
   
    @Autowired
	ProductRepository repository;

    @RequestMapping("/")
    public String home() {
        return "Nothing to see here, try /products";
    }

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
