package com.example.ecomerceapp.models;

public class Moderator {
    private String uid;
    private String email;
    private String firstName;
    private String lastName;
    private String gender;
    private String domain; // Product domain/category they manage
    private String address;
    private String contactNo;
    private String dateOfRegistration;
    private boolean active;

    public Moderator() {
    }

    public Moderator(String uid, String email, String firstName, String lastName, String gender,
                     String domain, String address, String contactNo, String dateOfRegistration) {
        this.uid = uid;
        this.email = email;
        this.firstName = firstName;
        this.lastName = lastName;
        this.gender = gender;
        this.domain = domain;
        this.address = address;
        this.contactNo = contactNo;
        this.dateOfRegistration = dateOfRegistration;
        this.active = true;
    }

    // Getters and Setters
    public String getId() { return uid; }
    public void setId(String id) { this.uid = id; }
    public String getUid() { return uid; }
    public void setUid(String uid) { this.uid = uid; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getDomain() { return domain; }
    public void setDomain(String domain) { this.domain = domain; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getContactNo() { return contactNo; }
    public void setContactNo(String contactNo) { this.contactNo = contactNo; }

    public String getDateOfRegistration() { return dateOfRegistration; }
    public void setDateOfRegistration(String dateOfRegistration) { this.dateOfRegistration = dateOfRegistration; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

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
