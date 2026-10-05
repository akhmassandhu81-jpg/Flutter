package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.example.ecomerceapp.databinding.ActivityAdminPanelBinding;

public class AdminPanelActivity extends AppCompatActivity {

    private ActivityAdminPanelBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAdminPanelBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupClickListeners();
    }

    private void setupClickListeners() {
        // Back button
        binding.btnBack.setOnClickListener(v -> finish());

        // Go to Home button
        binding.btnGoHome.setOnClickListener(v -> {
            Intent intent = new Intent(AdminPanelActivity.this, com.example.ecomerceapp.MainActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(intent);
            finish();
        });

        // Add Product
        binding.btnAddProduct.setOnClickListener(v -> {
            Intent intent = new Intent(AdminPanelActivity.this, AdminProductFormActivity.class);
            startActivity(intent);
        });

        // Manage Products
        binding.btnManageProducts.setOnClickListener(v -> {
            Intent intent = new Intent(AdminPanelActivity.this, AdminProductListActivity.class);
            startActivity(intent);
        });

        // Manage Orders
        binding.btnManageOrders.setOnClickListener(v -> {
            Intent intent = new Intent(AdminPanelActivity.this, AdminOrdersActivity.class);
            startActivity(intent);
        });

        // View All Orders
        binding.btnViewAllOrders.setOnClickListener(v -> {
            Intent intent = new Intent(AdminPanelActivity.this, AdminOrdersActivity.class);
            startActivity(intent);
        });

        // Manage Employees
        binding.btnManageEmployees.setOnClickListener(v -> {
            Intent intent = new Intent(AdminPanelActivity.this, AdminEmployeesActivity.class);
            startActivity(intent);
        });

        // Manage Users
        binding.btnManageUsers.setOnClickListener(v -> {
            Intent intent = new Intent(AdminPanelActivity.this, AdminUserListActivity.class);
            startActivity(intent);
        });

        // Manage Moderators
        binding.btnManageModerators.setOnClickListener(v -> {
            Intent intent = new Intent(AdminPanelActivity.this, AdminModeratorsActivity.class);
            startActivity(intent);
        });

        // Manage Couriers
        binding.btnManageCouriers.setOnClickListener(v -> {
            Intent intent = new Intent(AdminPanelActivity.this, AdminCouriersActivity.class);
            startActivity(intent);
        });

        // Manage Payment Companies
        binding.btnManagePaymentCompanies.setOnClickListener(v -> {
            Intent intent = new Intent(AdminPanelActivity.this, AdminPaymentCompaniesActivity.class);
            startActivity(intent);
        });

        // Manage Vendors
        binding.btnManageVendors.setOnClickListener(v -> {
            Intent intent = new Intent(AdminPanelActivity.this, VendorManagementActivity.class);
            startActivity(intent);
        });

        // Manage Announcements
        binding.btnManageAnnouncements.setOnClickListener(v -> {
            Intent intent = new Intent(AdminPanelActivity.this, AnnouncementManagementActivity.class);
            startActivity(intent);
        });
    }
}
