package com.example.ecomerceapp.viewmodels;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.example.ecomerceapp.models.Announcement;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.repositories.ProductRepository;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * ViewModel for Home screen
 * Manages product and announcement data
 */
public class HomeViewModel extends ViewModel {
    
    private ProductRepository productRepository;
    private List<Product> allProductsMaster = new ArrayList<>();
    private String selectedCategory = null;
    private String searchQuery = "";
    private int sortMode = 0;
    
    private MutableLiveData<List<Product>> filteredProductsLiveData = new MutableLiveData<>();
    
    public HomeViewModel() {
        productRepository = ProductRepository.getInstance();
    }
    
    public LiveData<List<Product>> getProducts() {
        return productRepository.getProductsLiveData();
    }
    
    public LiveData<List<Announcement>> getAnnouncements() {
        return productRepository.getAnnouncementsLiveData();
    }
    
    public LiveData<Boolean> getProductsLoading() {
        return productRepository.getProductsLoading();
    }
    
    public LiveData<Boolean> getAnnouncementsLoading() {
        return productRepository.getAnnouncementsLoading();
    }
    
    public LiveData<String> getProductsError() {
        return productRepository.getProductsError();
    }
    
    public LiveData<String> getAnnouncementsError() {
        return productRepository.getAnnouncementsError();
    }
    
    public LiveData<List<Product>> getFilteredProducts() {
        return filteredProductsLiveData;
    }
    
    public void loadProducts(boolean forceRefresh) {
        productRepository.loadProducts(forceRefresh);
    }
    
    public void loadAnnouncements(boolean forceRefresh) {
        productRepository.loadAnnouncements(forceRefresh);
    }
    
    public void setProducts(List<Product> products) {
        allProductsMaster.clear();
        allProductsMaster.addAll(products);
        applyProductFilters();
    }
    
    public void setSelectedCategory(String category) {
        selectedCategory = "All".equals(category) ? null : category;
        applyProductFilters();
    }
    
    public void setSearchQuery(String query) {
        searchQuery = query != null ? query.trim().toLowerCase() : "";
        applyProductFilters();
    }
    
    public void setSortMode(int mode) {
        sortMode = mode;
        applyProductFilters();
    }
    
    private void applyProductFilters() {
        String q = searchQuery;
        List<Product> filtered = new ArrayList<>();
        
        for (Product p : allProductsMaster) {
            if (p == null) continue;
            
            // Filter by status - only show approved products to customers
            if (!"approved".equals(p.getStatus())) {
                continue;
            }
            
            if (selectedCategory != null && (p.getCategory() == null || !selectedCategory.equals(p.getCategory()))) {
                continue;
            }
            
            if (!q.isEmpty()) {
                String name = p.getName() != null ? p.getName().toLowerCase() : "";
                if (!name.contains(q)) continue;
            }
            
            filtered.add(p);
        }
        
        // Sorting
        if (sortMode == 1) {
            Collections.sort(filtered, (a, b) -> Double.compare(a.getPrice(), b.getPrice()));
        } else if (sortMode == 2) {
            Collections.sort(filtered, (a, b) -> Double.compare(b.getPrice(), a.getPrice()));
        } else if (sortMode == 3) {
            Collections.sort(filtered, (a, b) -> {
                String n1 = a.getName() != null ? a.getName() : "";
                String n2 = b.getName() != null ? b.getName() : "";
                return n1.compareToIgnoreCase(n2);
            });
        }
        
        filteredProductsLiveData.setValue(filtered);
    }
    
    @Override
    protected void onCleared() {
        super.onCleared();
        productRepository.clearListeners();
    }
}
