package com.example.ecomerceapp.models;

public class PaymentCompany {
    private String id;
    private String name;
    private String type; // Insurance or Payment
    private String contact;
    private String address;
    private boolean active;

    public PaymentCompany() {
    }

    public PaymentCompany(String id, String name, String type, String contact, String address) {
        this.id = id;
        this.name = name;
        this.type = type;
        this.contact = contact;
        this.address = address;
        this.active = true;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
