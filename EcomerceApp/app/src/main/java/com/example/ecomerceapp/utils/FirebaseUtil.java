package com.example.ecomerceapp.utils;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.storage.FirebaseStorage;
import com.google.firebase.storage.StorageReference;

public class FirebaseUtil {

    private FirebaseUtil() {
    }

    public static FirebaseAuth auth() {
        return FirebaseAuth.getInstance();
    }

    public static DatabaseReference db() {
        return FirebaseDatabase.getInstance().getReference();
    }

    public static DatabaseReference usersRef() {
        return db().child("users");
    }

    public static DatabaseReference productsRef() {
        return db().child("products");
    }

    public static DatabaseReference cartsRef() {
        return db().child("Cart");
    }

    public static DatabaseReference ordersRef() {
        return db().child("Orders");
    }

    public static DatabaseReference moderatorsRef() {
        return db().child("moderators");
    }

    public static DatabaseReference announcementsRef() {
        return db().child("announcements");
    }

    public static DatabaseReference couriersRef() {
        return db().child("couriers");
    }

    public static DatabaseReference paymentCompaniesRef() {
        return db().child("paymentCompanies");
    }

    public static DatabaseReference insuranceCompaniesRef() {
        return db().child("insuranceCompanies");
    }

    public static DatabaseReference transactionsRef() {
        return db().child("transactions");
    }

    public static DatabaseReference employeesRef() {
        return db().child("employees");
    }

    public static DatabaseReference vendorsRef() {
        return db().child("vendors");
    }

    public static StorageReference storage() {
        return FirebaseStorage.getInstance().getReference();
    }
}
