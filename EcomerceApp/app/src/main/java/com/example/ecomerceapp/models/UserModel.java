package com.example.ecomerceapp.models;

public class UserModel {
    private String uid;
    private String email;
    private String role; // "admin", "user", or "moderator"
    
    // Profile fields
    private String firstName;
    private String lastName;
    private String gender; // Male, Female, Other
    private String address;
    private String contactNo;
    private String dateOfRegistration;
    private String domain; // Product domain/category assigned to moderator

    public UserModel() {
    }

    // Constructor for basic user creation
    public UserModel(String uid, String email, String role) {
        this.uid = uid;
        this.email = email;
        this.role = role;
    }

    // Full constructor
    public UserModel(String uid, String email, String role, String firstName, String lastName,
                     String gender, String address, String contactNo, String dateOfRegistration) {
        this.uid = uid;
        this.email = email;
        this.role = role;
        this.firstName = firstName;
        this.lastName = lastName;
        this.gender = gender;
        this.address = address;
        this.contactNo = contactNo;
        this.dateOfRegistration = dateOfRegistration;
    }

    // Getters and Setters
    public String getUid() { return uid; }
    public void setUid(String uid) { this.uid = uid; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getContactNo() { return contactNo; }
    public void setContactNo(String contactNo) { this.contactNo = contactNo; }

    public String getDateOfRegistration() { return dateOfRegistration; }
    public void setDateOfRegistration(String dateOfRegistration) { this.dateOfRegistration = dateOfRegistration; }

    public String getDomain() { return domain; }
    public void setDomain(String domain) { this.domain = domain; }

    // Helper method to get full name
    public String getFullName() {
        if (firstName != null && lastName != null) {
            return firstName + " " + lastName;
        } else if (firstName != null) {
            return firstName;
        } else if (lastName != null) {
            return lastName;
        }
        return email;
    }
}
