package com.example.ecomerceapp.models;

public class Announcement {
    private String id;
    private String title;
    private String message;
    private String type; // Type: offer / alert / news
    private String imageUrl; // Image URL from Firebase Storage
    private String discount; // Optional discount text (e.g., "50% OFF")
    private String productName; // Optional product name
    private String timestamp; // Creation timestamp
    private String date; // Legacy date field
    private boolean active;

    public Announcement() {
    }

    public Announcement(String id, String title, String message, String type, String date) {
        this.id = id;
        this.title = title;
        this.message = message;
        this.type = type;
        this.date = date;
        this.active = true;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getDiscount() { return discount; }
    public void setDiscount(String discount) { this.discount = discount; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getTimestamp() { return timestamp; }
    public void setTimestamp(String timestamp) { this.timestamp = timestamp; }
}
