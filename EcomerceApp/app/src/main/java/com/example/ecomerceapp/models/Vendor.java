package com.example.ecomerceapp.models;

import java.io.Serializable;

public class Vendor implements Serializable {
    private static final long serialVersionUID = 1L;

    private String vendorId;
    private String firstName;
    private String lastName;
    private String gender;
    private String phone;
    private String email;
    private String address;
    private String shopName;
    private String productCategory;
    private String productDomain;
    private String registrationDate;
    private String status; // Active/Inactive

    public Vendor() {
    }

    public Vendor(String vendorId, String firstName, String lastName, String gender, String phone,
                  String email, String address, String shopName, String productCategory,
                  String productDomain, String registrationDate, String status) {
        this.vendorId = vendorId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.gender = gender;
        this.phone = phone;
        this.email = email;
        this.address = address;
        this.shopName = shopName;
        this.productCategory = productCategory;
        this.productDomain = productDomain;
        this.registrationDate = registrationDate;
        this.status = status;
    }

    // Getters and Setters
    public String getVendorId() {
        return vendorId;
    }

    public void setVendorId(String vendorId) {
        this.vendorId = vendorId;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getShopName() {
        return shopName;
    }

    public void setShopName(String shopName) {
        this.shopName = shopName;
    }

    public String getProductCategory() {
        return productCategory;
    }

    public void setProductCategory(String productCategory) {
        this.productCategory = productCategory;
    }

    public String getProductDomain() {
        return productDomain;
    }

    public void setProductDomain(String productDomain) {
        this.productDomain = productDomain;
    }

    public String getRegistrationDate() {
        return registrationDate;
    }

    public void setRegistrationDate(String registrationDate) {
        this.registrationDate = registrationDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
