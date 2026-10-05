package com.example.ecomerceapp.models;

import java.util.List;

public class Order {
    private String orderId;
    private String userId;
    private String userName;
    private String userEmail;
    private String userPhone;
    private String paymentMethod;
    private List<CartItem> productList;
    private double totalPrice;
    private String status;
    private long timestamp;
    private String courierId;
    private String courierName;
    private double deliveryPrice;
    private String deliveryAddress;
    private String insuranceName;
    private double insurancePrice;

    public Order() {
    }

    public Order(String orderId, String userId, List<CartItem> productList, double totalPrice, String status, long timestamp) {
        this.orderId = orderId;
        this.userId = userId;
        this.productList = productList;
        this.totalPrice = totalPrice;
        this.status = status;
        this.timestamp = timestamp;
    }

    public Order(String orderId, String userId, String userName, String userEmail, String userPhone, String paymentMethod, List<CartItem> productList, double totalPrice, String status, long timestamp) {
        this.orderId = orderId;
        this.userId = userId;
        this.userName = userName;
        this.userEmail = userEmail;
        this.userPhone = userPhone;
        this.paymentMethod = paymentMethod;
        this.productList = productList;
        this.totalPrice = totalPrice;
        this.status = status;
        this.timestamp = timestamp;
    }

    public Order(String orderId, String userId, String userName, String userEmail, String userPhone, String paymentMethod, List<CartItem> productList, double totalPrice, String status, long timestamp, String courierId, String courierName, double deliveryPrice, String deliveryAddress) {
        this.orderId = orderId;
        this.userId = userId;
        this.userName = userName;
        this.userEmail = userEmail;
        this.userPhone = userPhone;
        this.paymentMethod = paymentMethod;
        this.productList = productList;
        this.totalPrice = totalPrice;
        this.status = status;
        this.timestamp = timestamp;
        this.courierId = courierId;
        this.courierName = courierName;
        this.deliveryPrice = deliveryPrice;
        this.deliveryAddress = deliveryAddress;
    }

    public Order(String orderId, String userId, String userName, String userEmail, String userPhone, String paymentMethod, List<CartItem> productList, double totalPrice, String status, long timestamp, String courierId, String courierName, double deliveryPrice, String deliveryAddress, String insuranceName, double insurancePrice) {
        this.orderId = orderId;
        this.userId = userId;
        this.userName = userName;
        this.userEmail = userEmail;
        this.userPhone = userPhone;
        this.paymentMethod = paymentMethod;
        this.productList = productList;
        this.totalPrice = totalPrice;
        this.status = status;
        this.timestamp = timestamp;
        this.courierId = courierId;
        this.courierName = courierName;
        this.deliveryPrice = deliveryPrice;
        this.deliveryAddress = deliveryAddress;
        this.insuranceName = insuranceName;
        this.insurancePrice = insurancePrice;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getUserPhone() {
        return userPhone;
    }

    public void setUserPhone(String userPhone) {
        this.userPhone = userPhone;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public List<CartItem> getProductList() {
        return productList;
    }

    public void setProductList(List<CartItem> productList) {
        this.productList = productList;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public long getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }

    public String getCourierId() {
        return courierId;
    }

    public void setCourierId(String courierId) {
        this.courierId = courierId;
    }

    public String getCourierName() {
        return courierName;
    }

    public void setCourierName(String courierName) {
        this.courierName = courierName;
    }

    public double getDeliveryPrice() {
        return deliveryPrice;
    }

    public void setDeliveryPrice(double deliveryPrice) {
        this.deliveryPrice = deliveryPrice;
    }

    public String getDeliveryAddress() {
        return deliveryAddress;
    }

    public void setDeliveryAddress(String deliveryAddress) {
        this.deliveryAddress = deliveryAddress;
    }

    public String getInsuranceName() {
        return insuranceName;
    }

    public void setInsuranceName(String insuranceName) {
        this.insuranceName = insuranceName;
    }

    public double getInsurancePrice() {
        return insurancePrice;
    }

    public void setInsurancePrice(double insurancePrice) {
        this.insurancePrice = insurancePrice;
    }
}
