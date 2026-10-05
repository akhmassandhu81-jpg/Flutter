package com.example.ecomerceapp.repositories;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;

import com.example.ecomerceapp.models.Announcement;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.utils.DataCache;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Repository for handling product and announcement data from Firebase
 */
public class ProductRepository {
    
    private static ProductRepository instance;
    
    private MutableLiveData<List<Product>> productsLiveData;
    private MutableLiveData<List<Announcement>> announcementsLiveData;
    private MutableLiveData<Boolean> productsLoading;
    private MutableLiveData<Boolean> announcementsLoading;
    private MutableLiveData<String> productsError;
    private MutableLiveData<String> announcementsError;
    
    private ValueEventListener productsListener;
    private ValueEventListener announcementsListener;
    
    private ProductRepository() {
        productsLiveData = new MutableLiveData<>();
        announcementsLiveData = new MutableLiveData<>();
        productsLoading = new MutableLiveData<>();
        announcementsLoading = new MutableLiveData<>();
        productsError = new MutableLiveData<>();
        announcementsError = new MutableLiveData<>();
    }
    
    public static synchronized ProductRepository getInstance() {
        if (instance == null) {
            instance = new ProductRepository();
        }
        return instance;
    }
    
    // Products
    public MutableLiveData<List<Product>> getProductsLiveData() {
        return productsLiveData;
    }
    
    public MutableLiveData<Boolean> getProductsLoading() {
        return productsLoading;
    }
    
    public MutableLiveData<String> getProductsError() {
        return productsError;
    }
    
    public void loadProducts(boolean forceRefresh) {
        // Check cache first if not forcing refresh
        if (!forceRefresh) {
            DataCache cache = DataCache.getInstance();
            List<Product> cached = cache.getCachedProducts();
            if (cached != null) {
                productsLiveData.setValue(cached);
                return;
            }
        }
        
        productsLoading.setValue(true);
        productsError.setValue(null);
        
        // Remove existing listener
        if (productsListener != null) {
            FirebaseUtil.productsRef().removeEventListener(productsListener);
        }
        
        productsListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<Product> products = new ArrayList<>();
                for (DataSnapshot s : snapshot.getChildren()) {
                    Product p = s.getValue(Product.class);
                    if (p != null && p.isApproved()) {
                        if (p.getId() == null) p.setId(s.getKey());
                        products.add(p);
                    }
                }
                
                // Cache the products
                DataCache.getInstance().cacheProducts(products);
                
                productsLoading.setValue(false);
                productsLiveData.setValue(products);
            }
            
            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                productsLoading.setValue(false);
                productsError.setValue(error.getMessage());
            }
        };
        
        FirebaseUtil.productsRef().limitToLast(50).addListenerForSingleValueEvent(productsListener);
    }
    
    // Announcements
    public MutableLiveData<List<Announcement>> getAnnouncementsLiveData() {
        return announcementsLiveData;
    }
    
    public MutableLiveData<Boolean> getAnnouncementsLoading() {
        return announcementsLoading;
    }
    
    public MutableLiveData<String> getAnnouncementsError() {
        return announcementsError;
    }
    
    public void loadAnnouncements(boolean forceRefresh) {
        // Check cache first if not forcing refresh
        if (!forceRefresh) {
            DataCache cache = DataCache.getInstance();
            List<Announcement> cached = cache.getCachedAnnouncements();
            if (cached != null) {
                // Sort and limit for home screen
                List<Announcement> limited = getLimitedAnnouncements(cached);
                announcementsLiveData.setValue(limited);
                return;
            }
        }
        
        announcementsLoading.setValue(true);
        announcementsError.setValue(null);
        
        // Remove existing listener
        if (announcementsListener != null) {
            FirebaseUtil.announcementsRef().removeEventListener(announcementsListener);
        }
        
        announcementsListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<Announcement> announcements = new ArrayList<>();
                for (DataSnapshot s : snapshot.getChildren()) {
                    Announcement a = s.getValue(Announcement.class);
                    if (a != null && a.isActive()) {
                        a.setId(s.getKey());
                        announcements.add(a);
                    }
                }
                
                // Sort by timestamp (newest first)
                Collections.sort(announcements, new Comparator<Announcement>() {
                    @Override
                    public int compare(Announcement a1, Announcement a2) {
                        String t1 = a1.getTimestamp() != null ? a1.getTimestamp() : "";
                        String t2 = a2.getTimestamp() != null ? a2.getTimestamp() : "";
                        return t2.compareTo(t1);
                    }
                });
                
                // Cache the full list
                DataCache.getInstance().cacheAnnouncements(announcements);
                
                // Limit to 3 for home screen
                List<Announcement> limited = getLimitedAnnouncements(announcements);
                
                announcementsLoading.setValue(false);
                announcementsLiveData.setValue(limited);
            }
            
            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                announcementsLoading.setValue(false);
                announcementsError.setValue(error.getMessage());
            }
        };
        
        FirebaseUtil.announcementsRef().addListenerForSingleValueEvent(announcementsListener);
    }
    
    private List<Announcement> getLimitedAnnouncements(List<Announcement> announcements) {
        List<Announcement> limited = new ArrayList<>();
        for (int i = 0; i < Math.min(3, announcements.size()); i++) {
            limited.add(announcements.get(i));
        }
        return limited;
    }
    
    public void clearListeners() {
        if (productsListener != null) {
            FirebaseUtil.productsRef().removeEventListener(productsListener);
            productsListener = null;
        }
        if (announcementsListener != null) {
            FirebaseUtil.announcementsRef().removeEventListener(announcementsListener);
            announcementsListener = null;
        }
    }
}
