package com.example.ecomerceapp.viewmodels;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.ViewModel;

import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.repositories.CartRepository;

import java.util.List;

/**
 * ViewModel for Cart screen
 * Manages cart data and operations
 */
public class CartViewModel extends ViewModel {
    
    private CartRepository cartRepository;
    
    public CartViewModel() {
        cartRepository = CartRepository.getInstance();
    }
    
    public LiveData<List<CartItem>> getCartItems() {
        return cartRepository.getCartLiveData();
    }
    
    public LiveData<Double> getCartTotal() {
        return cartRepository.getCartTotalLiveData();
    }
    
    public LiveData<Boolean> getCartLoading() {
        return cartRepository.getCartLoading();
    }
    
    public LiveData<String> getCartError() {
        return cartRepository.getCartError();
    }
    
    public void loadCart(String userId, boolean forceRefresh) {
        cartRepository.loadCart(userId, forceRefresh);
    }
    
    public void increaseQuantity(CartItem item, CartRepository.OnCompleteListener listener) {
        cartRepository.increaseQuantity(item, listener);
    }
    
    public void decreaseQuantity(CartItem item) {
        cartRepository.decreaseQuantity(item);
    }
    
    public void removeItem(CartItem item) {
        cartRepository.removeItem(item);
    }
    
    public void clearCart(CartRepository.OnCompleteListener listener) {
        cartRepository.clearCart(listener);
    }
    
    @Override
    protected void onCleared() {
        super.onCleared();
        cartRepository.clearListener();
    }
}
