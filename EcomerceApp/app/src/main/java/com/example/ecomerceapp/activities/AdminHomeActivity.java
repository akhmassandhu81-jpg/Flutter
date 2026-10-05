package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;

import androidx.appcompat.app.AppCompatActivity;

import com.example.ecomerceapp.databinding.ActivityAdminHomeBinding;
import com.example.ecomerceapp.utils.FirebaseUtil;

public class AdminHomeActivity extends AppCompatActivity {

    private ActivityAdminHomeBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAdminHomeBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        binding.btnManageProducts.setOnClickListener(v ->
                startActivity(new Intent(AdminHomeActivity.this, AdminProductListActivity.class)));

        binding.btnManageOrders.setOnClickListener(v ->
                startActivity(new Intent(AdminHomeActivity.this, AdminOrdersActivity.class)));

        binding.btnManageVendors.setOnClickListener(v ->
                startActivity(new Intent(AdminHomeActivity.this, VendorManagementActivity.class)));

        binding.btnLogout.setOnClickListener(v -> {
            FirebaseUtil.auth().signOut();
            startActivity(new Intent(AdminHomeActivity.this, LoginActivity.class));
            finish();
        });
    }
}
