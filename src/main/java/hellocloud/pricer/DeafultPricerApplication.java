package hellocloud.pricer;

import hellocloud.pricer.repository.PriceRepository;
import hellocloud.pricer.repository.jpa.JPAPriceRepository;
import hellocloud.pricer.rest.PricerController;
import hellocloud.pricer.service.PricerService;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

/**
 * Bootstrap class for running in IDE only.
 * This project does not specify the Spring Boot Maven plugin.
 * To bootstrap Pricer, use one of its dependent projects.
 */
@SpringBootApplication
public class DeafultPricerApplication {
    public static void main(String... args) {
        SpringApplication.run(DeafultPricerApplication.class, args);
    }

    @Bean
    public PricerController pricerController() {
        return new PricerController(pricerService());
    }

    @Bean
    public PricerService pricerService() {
        return new PricerService(pricerRepository());
    }

    @Bean
    public PriceRepository pricerRepository() {
        return new JPAPriceRepository();
    }

}
