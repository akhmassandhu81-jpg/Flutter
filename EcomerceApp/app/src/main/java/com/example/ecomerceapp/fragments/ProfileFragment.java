package com.example.ecomerceapp.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.activities.AdminPanelActivity;
import com.example.ecomerceapp.activities.LoginActivity;
import com.example.ecomerceapp.activities.ModeratorDashboardActivity;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

public class ProfileFragment extends Fragment {

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
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        try {
            View view = inflater.inflate(R.layout.activity_settings, container, false);

            btnSettings = view.findViewById(R.id.btnSettings);
            btnNotifications = view.findViewById(R.id.btnNotifications);
            btnOrderHistory = view.findViewById(R.id.btnOrderHistory);
            btnPrivacy = view.findViewById(R.id.btnPrivacy);
            btnTerms = view.findViewById(R.id.btnTerms);
            btnAdminPanel = view.findViewById(R.id.btnAdminPanel);
            btnModeratorPanel = view.findViewById(R.id.btnModeratorPanel);
            btnLogout = view.findViewById(R.id.btnLogout);
            tvUserName = view.findViewById(R.id.tvUserName);
            tvEmail = view.findViewById(R.id.tvEmail);

            // Hide admin/moderator panels by default
            btnAdminPanel.setVisibility(View.GONE);
            btnModeratorPanel.setVisibility(View.GONE);

            loadUserData();
            checkAdminRole();
            setupClickListeners();

            return view;
        } catch (Exception e) {
            android.util.Log.e("ProfileFragment", "Error in onCreateView: " + e.getMessage());
            TextView errorView = new TextView(requireContext());
            errorView.setText("Error loading profile");
            errorView.setPadding(32, 32, 32, 32);
            return errorView;
        }
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
            Toast.makeText(requireContext(), "Settings coming soon", Toast.LENGTH_SHORT).show();
        });

        // Notifications
        btnNotifications.setOnClickListener(v -> {
            Toast.makeText(requireContext(), "Notifications coming soon", Toast.LENGTH_SHORT).show();
        });

        // Order History - navigate to Orders tab
        btnOrderHistory.setOnClickListener(v -> {
            if (getActivity() instanceof com.example.ecomerceapp.MainActivity) {
                ((com.example.ecomerceapp.MainActivity) getActivity()).loadFragment(new OrdersFragment(), true);
            }
        });

        // Privacy & Policy
        btnPrivacy.setOnClickListener(v -> {
            Toast.makeText(requireContext(), "Privacy & Policy coming soon", Toast.LENGTH_SHORT).show();
        });

        // Terms & Conditions
        btnTerms.setOnClickListener(v -> {
            Toast.makeText(requireContext(), "Terms & Conditions coming soon", Toast.LENGTH_SHORT).show();
        });

        // Admin Panel
        btnAdminPanel.setOnClickListener(v -> {
            startActivity(new Intent(requireContext(), AdminPanelActivity.class));
        });

        // Moderator Panel
        btnModeratorPanel.setOnClickListener(v -> {
            startActivity(new Intent(requireContext(), ModeratorDashboardActivity.class));
        });

        // Logout
        btnLogout.setOnClickListener(v -> {
            FirebaseUtil.auth().signOut();
            Intent intent = new Intent(requireContext(), LoginActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(intent);
            if (getActivity() != null) {
                getActivity().finishAffinity();
            }
        });
    }
}
