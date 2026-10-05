package com.example.ecomerceapp.models;

public class Courier {
    private String id;
    private String name;
    private String contact;
    private String address;
    private double deliveryCharge;
    private boolean active;

    public Courier() {
    }

    public Courier(String id, String name, String contact, String address, double deliveryCharge) {
        this.id = id;
        this.name = name;
        this.contact = contact;
        this.address = address;
        this.deliveryCharge = deliveryCharge;
        this.active = true;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public double getDeliveryCharge() { return deliveryCharge; }
    public void setDeliveryCharge(double deliveryCharge) { this.deliveryCharge = deliveryCharge; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
