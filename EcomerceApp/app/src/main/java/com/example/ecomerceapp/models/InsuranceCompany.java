package com.example.ecomerceapp.models;

public class InsuranceCompany {
    private String id;
    private String name;
    private double price;
    private String contact;
    private String address;
    private boolean active;

    public InsuranceCompany() {
    }

    public InsuranceCompany(String id, String name, double price, String contact, String address) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.contact = contact;
        this.address = address;
        this.active = true;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
