package hellocloud.pricer.repository.map;

import hellocloud.pricer.model.Price;
import hellocloud.pricer.repository.PriceRepository;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component("mapPricerRepository")
public class MapPricerRepository implements PriceRepository {

    private Map<String, Price> priceMap = new ConcurrentHashMap<>();

    @Override
    public Price get(String symbol) {
        return priceMap.get(symbol);
    }

    @Override
    public Collection<Price> getAll() {
        return priceMap.values();
    }

    @Override
    public void create(Price price) {
        putInMap(price);
    }

    @Override
    public void update(Price price) {
        putInMap(price);
    }

    @Override
    public void delete(String symbol) {
        priceMap.remove(symbol);
    }

    private void putInMap(Price price) {
        priceMap.put(price.getSymbol(), price);
    }
}
