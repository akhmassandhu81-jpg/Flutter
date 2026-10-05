package com.example.ecomerceapp.viewmodels;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.ViewModel;

import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.repositories.OrdersRepository;

import java.util.List;

/**
 * ViewModel for Orders screen
 * Manages order data
 */
public class OrdersViewModel extends ViewModel {
    
    private OrdersRepository ordersRepository;
    
    public OrdersViewModel() {
        ordersRepository = OrdersRepository.getInstance();
    }
    
    public LiveData<List<Order>> getOrders() {
        return ordersRepository.getOrdersLiveData();
    }
    
    public LiveData<Boolean> getOrdersLoading() {
        return ordersRepository.getOrdersLoading();
    }
    
    public LiveData<String> getOrdersError() {
        return ordersRepository.getOrdersError();
    }
    
    public void loadOrders(String userId, boolean forceRefresh) {
        ordersRepository.loadOrders(userId, forceRefresh);
    }
    
    @Override
    protected void onCleared() {
        super.onCleared();
        ordersRepository.clearListener();
    }
}
