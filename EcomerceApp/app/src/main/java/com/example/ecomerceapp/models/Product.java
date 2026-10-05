package com.example.ecomerceapp.models;

public class Product {
    private String id;
    private String name;
    private double price;
    private int quantity; // Total stock quantity
    private int sold; // Sold quantity
    private String imageUrl;
    private String category;
    private String subcategory;
    private String dateAdded; // Date of registration/creation
    private String moderatorId; // ID of moderator who approved this product
    private String status; // pending / approved / rejected
    private String vendorId; // ID of vendor who owns this product
    private String vendorName; // Name of vendor for display purposes
    private String description; // Product description

    // Approval fields
    private String approvedBy; // Name of moderator who approved
    private String approvedAt; // Timestamp of approval
    private String rejectionReason; // Reason for rejection
    private String rejectedBy; // Name of moderator who rejected
    private String rejectedAt; // Timestamp of rejection

    // Empty constructor required for Firebase
    public Product() {
    }

    // Basic constructor
    public Product(String id, String name, double price, int quantity, String imageUrl) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.quantity = quantity;
        this.imageUrl = imageUrl;
        this.status = "pending";
    }

    // Full constructor
    public Product(String id, String name, double price, int quantity, String imageUrl,
                   String category, String subcategory, String dateAdded, String moderatorId, String status) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.quantity = quantity;
        this.imageUrl = imageUrl;
        this.category = category;
        this.subcategory = subcategory;
        this.dateAdded = dateAdded;
        this.moderatorId = moderatorId;
        this.status = status;
    }

    // Getters and Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public int getSold() { return sold; }
    public void setSold(int sold) { this.sold = sold; }

    // Calculate remaining stock dynamically
    public int getRemaining() {
        return quantity - sold;
    }

    // Check if product is in stock
    public boolean isInStock() {
        return getRemaining() > 0;
    }

    // Check if stock is low (less than 10)
    public boolean isLowStock() {
        return getRemaining() > 0 && getRemaining() < 10;
    }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getSubcategory() { return subcategory; }
    public void setSubcategory(String subcategory) { this.subcategory = subcategory; }

    public String getDateAdded() { return dateAdded; }
    public void setDateAdded(String dateAdded) { this.dateAdded = dateAdded; }

    public String getModeratorId() { return moderatorId; }
    public void setModeratorId(String moderatorId) { this.moderatorId = moderatorId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public boolean isApproved() {
        return "approved".equals(status);
    }

    public String getVendorId() { return vendorId; }
    public void setVendorId(String vendorId) { this.vendorId = vendorId; }

    public String getVendorName() { return vendorName; }
    public void setVendorName(String vendorName) { this.vendorName = vendorName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    // Approval field getters and setters
    public String getApprovedBy() { return approvedBy; }
    public void setApprovedBy(String approvedBy) { this.approvedBy = approvedBy; }

    public String getApprovedAt() { return approvedAt; }
    public void setApprovedAt(String approvedAt) { this.approvedAt = approvedAt; }

    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

    public String getRejectedBy() { return rejectedBy; }
    public void setRejectedBy(String rejectedBy) { this.rejectedBy = rejectedBy; }

    public String getRejectedAt() { return rejectedAt; }
    public void setRejectedAt(String rejectedAt) { this.rejectedAt = rejectedAt; }
}
