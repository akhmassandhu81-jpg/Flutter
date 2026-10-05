package com.example.ecomerceapp.utils;

import com.example.ecomerceapp.models.Announcement;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.models.Product;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * In-memory data cache to reduce Firebase calls and improve app performance
 */
public class DataCache {
    
    private static DataCache instance;
    
    // Cache for products
    private List<Product> cachedProducts = new ArrayList<>();
    private long productsCacheTime = 0;
    private static final long PRODUCTS_CACHE_DURATION = 5 * 60 * 1000; // 5 minutes
    
    // Cache for announcements
    private List<Announcement> cachedAnnouncements = new ArrayList<>();
    private long announcementsCacheTime = 0;
    private static final long ANNOUNCEMENTS_CACHE_DURATION = 10 * 60 * 1000; // 10 minutes
    
    // Cache for cart (per user)
    private Map<String, List<CartItem>> cachedCart = new HashMap<>();
    private Map<String, Long> cartCacheTime = new HashMap<>();
    private static final long CART_CACHE_DURATION = 2 * 60 * 1000; // 2 minutes
    
    // Cache for orders (per user)
    private Map<String, List<Order>> cachedOrders = new HashMap<>();
    private Map<String, Long> ordersCacheTime = new HashMap<>();
    private static final long ORDERS_CACHE_DURATION = 5 * 60 * 1000; // 5 minutes
    
    private DataCache() {}
    
    public static synchronized DataCache getInstance() {
        if (instance == null) {
            instance = new DataCache();
        }
        return instance;
    }
    
    // Products cache
    public void cacheProducts(List<Product> products) {
        cachedProducts = new ArrayList<>(products);
        productsCacheTime = System.currentTimeMillis();
    }
    
    public List<Product> getCachedProducts() {
        if (System.currentTimeMillis() - productsCacheTime > PRODUCTS_CACHE_DURATION) {
            return null; // Cache expired
        }
        return new ArrayList<>(cachedProducts);
    }
    
    public boolean isProductsCacheValid() {
        return System.currentTimeMillis() - productsCacheTime <= PRODUCTS_CACHE_DURATION;
    }
    
    public void clearProductsCache() {
        cachedProducts.clear();
        productsCacheTime = 0;
    }
    
    // Announcements cache
    public void cacheAnnouncements(List<Announcement> announcements) {
        cachedAnnouncements = new ArrayList<>(announcements);
        announcementsCacheTime = System.currentTimeMillis();
    }
    
    public List<Announcement> getCachedAnnouncements() {
        if (System.currentTimeMillis() - announcementsCacheTime > ANNOUNCEMENTS_CACHE_DURATION) {
            return null; // Cache expired
        }
        return new ArrayList<>(cachedAnnouncements);
    }
    
    public boolean isAnnouncementsCacheValid() {
        return System.currentTimeMillis() - announcementsCacheTime <= ANNOUNCEMENTS_CACHE_DURATION;
    }
    
    public void clearAnnouncementsCache() {
        cachedAnnouncements.clear();
        announcementsCacheTime = 0;
    }
    
    // Cart cache
    public void cacheCart(String userId, List<CartItem> cartItems) {
        cachedCart.put(userId, new ArrayList<>(cartItems));
        cartCacheTime.put(userId, System.currentTimeMillis());
    }
    
    public List<CartItem> getCachedCart(String userId) {
        Long cacheTime = cartCacheTime.get(userId);
        if (cacheTime == null || System.currentTimeMillis() - cacheTime > CART_CACHE_DURATION) {
            return null; // Cache expired
        }
        List<CartItem> items = cachedCart.get(userId);
        return items != null ? new ArrayList<>(items) : null;
    }
    
    public boolean isCartCacheValid(String userId) {
        Long cacheTime = cartCacheTime.get(userId);
        return cacheTime != null && System.currentTimeMillis() - cacheTime <= CART_CACHE_DURATION;
    }
    
    public void clearCartCache(String userId) {
        cachedCart.remove(userId);
        cartCacheTime.remove(userId);
    }
    
    // Orders cache
    public void cacheOrders(String userId, List<Order> orders) {
        cachedOrders.put(userId, new ArrayList<>(orders));
        ordersCacheTime.put(userId, System.currentTimeMillis());
    }
    
    public List<Order> getCachedOrders(String userId) {
        Long cacheTime = ordersCacheTime.get(userId);
        if (cacheTime == null || System.currentTimeMillis() - cacheTime > ORDERS_CACHE_DURATION) {
            return null; // Cache expired
        }
        List<Order> orders = cachedOrders.get(userId);
        return orders != null ? new ArrayList<>(orders) : null;
    }
    
    public boolean isOrdersCacheValid(String userId) {
        Long cacheTime = ordersCacheTime.get(userId);
        return cacheTime != null && System.currentTimeMillis() - cacheTime <= ORDERS_CACHE_DURATION;
    }
    
    public void clearOrdersCache(String userId) {
        cachedOrders.remove(userId);
        ordersCacheTime.remove(userId);
    }
    
    // Clear all caches
    public void clearAll() {
        cachedProducts.clear();
        productsCacheTime = 0;
        cachedAnnouncements.clear();
        announcementsCacheTime = 0;
        cachedCart.clear();
        cartCacheTime.clear();
        cachedOrders.clear();
        ordersCacheTime.clear();
    }
}
