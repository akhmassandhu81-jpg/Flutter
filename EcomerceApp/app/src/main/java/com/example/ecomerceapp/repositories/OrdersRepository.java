package com.example.ecomerceapp.repositories;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;

import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.utils.DataCache;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.GenericTypeIndicator;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

/**
 * Repository for handling order data from Firebase
 */
public class OrdersRepository {
    
    private static OrdersRepository instance;
    
    private MutableLiveData<List<Order>> ordersLiveData;
    private MutableLiveData<Boolean> ordersLoading;
    private MutableLiveData<String> ordersError;
    
    private ValueEventListener ordersListener;
    
    private OrdersRepository() {
        ordersLiveData = new MutableLiveData<>();
        ordersLoading = new MutableLiveData<>();
        ordersError = new MutableLiveData<>();
    }
    
    public static synchronized OrdersRepository getInstance() {
        if (instance == null) {
            instance = new OrdersRepository();
        }
        return instance;
    }
    
    public MutableLiveData<List<Order>> getOrdersLiveData() {
        return ordersLiveData;
    }
    
    public MutableLiveData<Boolean> getOrdersLoading() {
        return ordersLoading;
    }
    
    public MutableLiveData<String> getOrdersError() {
        return ordersError;
    }
    
    public void loadOrders(String userId, boolean forceRefresh) {
        // Check cache first if not forcing refresh
        if (!forceRefresh) {
            DataCache cache = DataCache.getInstance();
            List<Order> cached = cache.getCachedOrders(userId);
            if (cached != null) {
                ordersLiveData.setValue(cached);
                return;
            }
        }
        
        ordersLoading.setValue(true);
        ordersError.setValue(null);
        
        // Remove existing listener
        if (ordersListener != null) {
            FirebaseUtil.ordersRef().removeEventListener(ordersListener);
        }
        
        // Use limitToLast to get most recent orders, limit to 20 for performance
        Query q = FirebaseUtil.ordersRef().orderByChild("userId").equalTo(userId).limitToLast(20);
        
        ordersListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<Order> list = new ArrayList<>();
                
                for (DataSnapshot s : snapshot.getChildren()) {
                    Order order = new Order();
                    order.setOrderId(s.child("orderId").getValue(String.class));
                    if (order.getOrderId() == null) {
                        order.setOrderId(s.getKey());
                    }
                    order.setUserId(s.child("userId").getValue(String.class));
                    Double total = s.child("totalPrice").getValue(Double.class);
                    if (total == null) {
                        Long totalLong = s.child("totalPrice").getValue(Long.class);
                        if (totalLong != null) total = totalLong.doubleValue();
                    }
                    order.setTotalPrice(total != null ? total : 0);
                    order.setStatus(s.child("status").getValue(String.class));
                    Long ts = s.child("timestamp").getValue(Long.class);
                    order.setTimestamp(ts != null ? ts : 0);
                    
                    GenericTypeIndicator<List<CartItem>> t = new GenericTypeIndicator<List<CartItem>>() {
                    };
                    List<CartItem> products = s.child("productList").getValue(t);
                    order.setProductList(products);
                    
                    list.add(order);
                }
                
                // Cache the orders
                DataCache.getInstance().cacheOrders(userId, list);
                
                ordersLoading.setValue(false);
                ordersLiveData.setValue(list);
            }
            
            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                ordersLoading.setValue(false);
                ordersError.setValue(error.getMessage());
            }
        };
        
        q.addListenerForSingleValueEvent(ordersListener);
    }
    
    public void clearListener() {
        if (ordersListener != null) {
            FirebaseUtil.ordersRef().removeEventListener(ordersListener);
            ordersListener = null;
        }
    }
}
