package com.example.ecomerceapp.repositories;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;

import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.utils.DataCache;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

/**
 * Repository for handling cart data from Firebase
 */
public class CartRepository {
    
    private static CartRepository instance;
    
    private MutableLiveData<List<CartItem>> cartLiveData;
    private MutableLiveData<Double> cartTotalLiveData;
    private MutableLiveData<Boolean> cartLoading;
    private MutableLiveData<String> cartError;
    
    private ValueEventListener cartListener;
    private DatabaseReference cartRef;
    private String currentUserId;
    
    private CartRepository() {
        cartLiveData = new MutableLiveData<>();
        cartTotalLiveData = new MutableLiveData<>();
        cartLoading = new MutableLiveData<>();
        cartError = new MutableLiveData<>();
    }
    
    public static synchronized CartRepository getInstance() {
        if (instance == null) {
            instance = new CartRepository();
        }
        return instance;
    }
    
    public MutableLiveData<List<CartItem>> getCartLiveData() {
        return cartLiveData;
    }
    
    public MutableLiveData<Double> getCartTotalLiveData() {
        return cartTotalLiveData;
    }
    
    public MutableLiveData<Boolean> getCartLoading() {
        return cartLoading;
    }
    
    public MutableLiveData<String> getCartError() {
        return cartError;
    }
    
    public void loadCart(String userId, boolean forceRefresh) {
        // Check cache first if not forcing refresh
        if (!forceRefresh) {
            DataCache cache = DataCache.getInstance();
            List<CartItem> cached = cache.getCachedCart(userId);
            if (cached != null) {
                double total = calculateTotal(cached);
                cartLiveData.setValue(cached);
                cartTotalLiveData.setValue(total);
                return;
            }
        }
        
        // Remove existing listener if user changed
        if (currentUserId != null && !currentUserId.equals(userId) && cartListener != null) {
            if (cartRef != null) {
                cartRef.removeEventListener(cartListener);
            }
            cartListener = null;
        }
        
        currentUserId = userId;
        cartRef = FirebaseUtil.cartsRef().child(userId);
        
        cartLoading.setValue(true);
        cartError.setValue(null);
        
        cartListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<CartItem> list = new ArrayList<>();
                for (DataSnapshot s : snapshot.getChildren()) {
                    CartItem item = s.getValue(CartItem.class);
                    if (item != null) {
                        if (item.getProductId() == null) {
                            item.setProductId(s.getKey());
                        }
                        list.add(item);
                    }
                }
                
                // Cache the cart data
                DataCache.getInstance().cacheCart(userId, list);
                
                double total = calculateTotal(list);
                
                cartLoading.setValue(false);
                cartLiveData.setValue(list);
                cartTotalLiveData.setValue(total);
            }
            
            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                cartLoading.setValue(false);
                cartError.setValue(error.getMessage());
            }
        };
        
        cartRef.addValueEventListener(cartListener);
    }
    
    public void increaseQuantity(CartItem item, OnCompleteListener listener) {
        if (cartRef == null || item.getProductId() == null) return;
        
        // Check product stock and remaining quantity
        FirebaseUtil.productsRef().child(item.getProductId()).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                Integer stock = snapshot.child("quantity").getValue(Integer.class);
                Integer sold = snapshot.child("sold").getValue(Integer.class);
                
                int totalStock = (stock != null) ? stock : 0;
                int totalSold = (sold != null) ? sold : 0;
                int remaining = totalStock - totalSold;
                
                if (item.getQuantity() >= remaining) {
                    if (listener != null) {
                        listener.onComplete(false, "Only " + remaining + " items available");
                    }
                    return;
                }
                
                cartRef.child(item.getProductId()).child("quantity")
                        .setValue(item.getQuantity() + 1)
                        .addOnSuccessListener(aVoid -> {
                            if (listener != null) listener.onComplete(true, null);
                        })
                        .addOnFailureListener(e -> {
                            if (listener != null) listener.onComplete(false, e.getMessage());
                        });
            }
            
            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                if (listener != null) listener.onComplete(false, error.getMessage());
            }
        });
    }
    
    public void decreaseQuantity(CartItem item) {
        if (cartRef == null || item.getProductId() == null) return;
        
        int newQty = item.getQuantity() - 1;
        if (newQty <= 0) {
            cartRef.child(item.getProductId()).removeValue();
        } else {
            cartRef.child(item.getProductId()).child("quantity").setValue(newQty);
        }
    }
    
    public void removeItem(CartItem item) {
        if (cartRef == null || item.getProductId() == null) return;
        cartRef.child(item.getProductId()).removeValue();
    }
    
    public void clearCart(OnCompleteListener listener) {
        if (cartRef == null) return;
        cartRef.removeValue()
                .addOnSuccessListener(aVoid -> {
                    if (listener != null) listener.onComplete(true, null);
                })
                .addOnFailureListener(e -> {
                    if (listener != null) listener.onComplete(false, e.getMessage());
                });
    }
    
    private double calculateTotal(List<CartItem> items) {
        double total = 0;
        for (CartItem item : items) {
            total += (item.getPrice() * item.getQuantity());
        }
        return total;
    }
    
    public void clearListener() {
        if (cartListener != null && cartRef != null) {
            cartRef.removeEventListener(cartListener);
            cartListener = null;
        }
    }
    
    public interface OnCompleteListener {
        void onComplete(boolean success, String error);
    }
}
