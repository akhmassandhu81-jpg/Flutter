package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

public class SettingsActivity extends AppCompatActivity {

    private LinearLayout btnSettings;
    private LinearLayout btnNotifications;
    private LinearLayout btnOrderHistory;
    private LinearLayout btnPrivacy;
    private LinearLayout btnTerms;
    private LinearLayout btnAdminPanel;
    private LinearLayout btnModeratorPanel;
    private LinearLayout btnLogout;
    private TextView tvUserName;
    private TextView tvEmail;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);

        btnSettings = findViewById(R.id.btnSettings);
        btnNotifications = findViewById(R.id.btnNotifications);
        btnOrderHistory = findViewById(R.id.btnOrderHistory);
        btnPrivacy = findViewById(R.id.btnPrivacy);
        btnTerms = findViewById(R.id.btnTerms);
        btnAdminPanel = findViewById(R.id.btnAdminPanel);
        btnModeratorPanel = findViewById(R.id.btnModeratorPanel);
        btnLogout = findViewById(R.id.btnLogout);
        tvUserName = findViewById(R.id.tvUserName);
        tvEmail = findViewById(R.id.tvEmail);

        loadUserData();
        checkAdminRole();
        setupClickListeners();
    }

    private void loadUserData() {
        FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
        if (user != null) {
            tvUserName.setText(user.getDisplayName() != null ? user.getDisplayName() : "User");
            tvEmail.setText(user.getEmail());
        }
    }

    private void checkAdminRole() {
        FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
        if (user != null) {
            FirebaseUtil.usersRef().child(user.getUid()).child("role")
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        String role = snapshot.getValue(String.class);
                        if ("admin".equalsIgnoreCase(role)) {
                            btnAdminPanel.setVisibility(View.VISIBLE);
                        } else if ("moderator".equalsIgnoreCase(role)) {
                            btnModeratorPanel.setVisibility(View.VISIBLE);
                        }
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        // Keep hidden
                    }
                });
        }
    }

    private void setupClickListeners() {
        // Settings
        btnSettings.setOnClickListener(v -> {
            Toast.makeText(this, "Settings coming soon", Toast.LENGTH_SHORT).show();
        });

        // Notifications
        btnNotifications.setOnClickListener(v -> {
            Toast.makeText(this, "Notifications coming soon", Toast.LENGTH_SHORT).show();
        });

        // Order History
        btnOrderHistory.setOnClickListener(v -> {
            startActivity(new Intent(SettingsActivity.this, OrderHistoryActivity.class));
        });

        // Privacy & Policy
        btnPrivacy.setOnClickListener(v -> {
            Toast.makeText(this, "Privacy & Policy coming soon", Toast.LENGTH_SHORT).show();
        });

        // Terms & Conditions
        btnTerms.setOnClickListener(v -> {
            Toast.makeText(this, "Terms & Conditions coming soon", Toast.LENGTH_SHORT).show();
        });

        // Admin Panel
        btnAdminPanel.setOnClickListener(v -> {
            startActivity(new Intent(SettingsActivity.this, AdminPanelActivity.class));
        });

        // Moderator Panel
        btnModeratorPanel.setOnClickListener(v -> {
            startActivity(new Intent(SettingsActivity.this, ModeratorDashboardActivity.class));
        });

        // Logout
        btnLogout.setOnClickListener(v -> {
            FirebaseUtil.auth().signOut();
            startActivity(new Intent(SettingsActivity.this, LoginActivity.class));
            finishAffinity();
        });
    }
}
