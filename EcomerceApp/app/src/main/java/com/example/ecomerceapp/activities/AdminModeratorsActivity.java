package com.example.ecomerceapp.activities;

import android.app.AlertDialog;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.adapters.ModeratorListAdapter;
import com.example.ecomerceapp.databinding.ActivityAdminModeratorsBinding;
import com.example.ecomerceapp.models.UserModel;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class AdminModeratorsActivity extends AppCompatActivity {

    private ActivityAdminModeratorsBinding binding;
    private ModeratorListAdapter adapter;
    private List<UserModel> moderatorList = new ArrayList<>();
    private ValueEventListener moderatorListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAdminModeratorsBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupRecyclerView();
        setupClickListeners();
        loadModerators();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (moderatorListener != null) {
            FirebaseUtil.usersRef().removeEventListener(moderatorListener);
        }
    }

    private void setupRecyclerView() {
        adapter = new ModeratorListAdapter(new ModeratorListAdapter.Listener() {
            @Override
            public void onView(UserModel moderator) {
                showModeratorDetails(moderator);
            }

            @Override
            public void onEdit(UserModel moderator) {
                showEditDialog(moderator);
            }

            @Override
            public void onDelete(UserModel moderator) {
                showDeleteConfirmation(moderator);
            }
        });
        binding.recycler.setLayoutManager(new LinearLayoutManager(this));
        binding.recycler.setAdapter(adapter);
    }

    private void setupClickListeners() {
        binding.btnBack.setOnClickListener(v -> finish());
        binding.btnAdd.setVisibility(View.VISIBLE);
        binding.btnAdd.setOnClickListener(v -> showAddDialog());

        binding.btnSearch.setOnClickListener(v -> {
            String query = binding.etSearch.getText().toString().trim().toLowerCase();
            searchModerators(query);
        });
    }

    private void loadModerators() {
        binding.progress.setVisibility(View.VISIBLE);

        moderatorListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                moderatorList.clear();
                int moderatorCount = 0;

                for (DataSnapshot data : snapshot.getChildren()) {
                    String userId = data.getKey();
                    UserModel user = data.getValue(UserModel.class);

                    if (user != null) {
                        user.setUid(userId);
                        String role = data.child("role").getValue(String.class);

                        if (role != null && role.trim().equalsIgnoreCase("moderator")) {
                            user.setRole(role);
                            moderatorList.add(user);
                            moderatorCount++;
                        }
                    }
                }

                binding.progress.setVisibility(View.GONE);
                adapter.submitList(moderatorList);

                if (moderatorList.isEmpty()) {
                    binding.tvEmpty.setVisibility(View.VISIBLE);
                    binding.tvEmpty.setText("No moderators found");
                } else {
                    binding.tvEmpty.setVisibility(View.GONE);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                binding.progress.setVisibility(View.GONE);
                Toast.makeText(AdminModeratorsActivity.this, "Error: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        };

        FirebaseUtil.usersRef().addValueEventListener(moderatorListener);
    }

    private void searchModerators(String query) {
        if (TextUtils.isEmpty(query)) {
            adapter.submitList(moderatorList);
            return;
        }

        List<UserModel> filtered = new ArrayList<>();
        for (UserModel user : moderatorList) {
            if ((user.getFirstName() != null && user.getFirstName().toLowerCase().contains(query)) ||
                (user.getLastName() != null && user.getLastName().toLowerCase().contains(query)) ||
                (user.getEmail() != null && user.getEmail().toLowerCase().contains(query)) ||
                (user.getContactNo() != null && user.getContactNo().contains(query)) ||
                (user.getDomain() != null && user.getDomain().toLowerCase().contains(query))) {
                filtered.add(user);
            }
        }
        adapter.submitList(filtered);
    }

    private void showAddDialog() {
        // Open moderator registration activity for adding new moderators
        // This is simpler than creating a form dialog
        Toast.makeText(this, "Use Moderator Registration to add new moderators", Toast.LENGTH_SHORT).show();
    }

    private void showEditDialog(UserModel moderator) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Edit Moderator");

        View dialogView = getLayoutInflater().inflate(R.layout.dialog_moderator_form, null);
        builder.setView(dialogView);

        android.widget.EditText etFirstName = dialogView.findViewById(R.id.etFirstName);
        android.widget.EditText etLastName = dialogView.findViewById(R.id.etLastName);
        android.widget.EditText etEmail = dialogView.findViewById(R.id.etEmail);
        android.widget.EditText etContact = dialogView.findViewById(R.id.etContact);
        android.widget.EditText etAddress = dialogView.findViewById(R.id.etAddress);
        android.widget.Spinner spinnerDomain = dialogView.findViewById(R.id.spinnerDomain);

        // Pre-fill existing data
        etFirstName.setText(moderator.getFirstName());
        etLastName.setText(moderator.getLastName());
        etEmail.setText(moderator.getEmail());
        etContact.setText(moderator.getContactNo());
        etAddress.setText(moderator.getAddress());

        // Setup domain spinner
        String[] domains = {"All", "Electronics", "Sports", "Food", "Fashion and Clothing"};
        android.widget.ArrayAdapter<String> adapter = new android.widget.ArrayAdapter<>(this,
            android.R.layout.simple_spinner_item, domains);
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerDomain.setAdapter(adapter);

        // Select current domain
        if (moderator.getDomain() != null) {
            for (int i = 0; i < domains.length; i++) {
                if (domains[i].equals(moderator.getDomain())) {
                    spinnerDomain.setSelection(i);
                    break;
                }
            }
        }

        builder.setPositiveButton("Save", (dialog, which) -> {
            String firstName = etFirstName.getText().toString().trim();
            String lastName = etLastName.getText().toString().trim();
            String email = etEmail.getText().toString().trim();
            String contact = etContact.getText().toString().trim();
            String address = etAddress.getText().toString().trim();
            String domain = spinnerDomain.getSelectedItem().toString();

            if (TextUtils.isEmpty(firstName) || TextUtils.isEmpty(lastName) || TextUtils.isEmpty(email)) {
                Toast.makeText(this, "Name and email are required", Toast.LENGTH_SHORT).show();
                return;
            }

            // Update moderator in Firebase
            FirebaseUtil.usersRef().child(moderator.getUid()).child("firstName").setValue(firstName);
            FirebaseUtil.usersRef().child(moderator.getUid()).child("lastName").setValue(lastName);
            FirebaseUtil.usersRef().child(moderator.getUid()).child("email").setValue(email);
            FirebaseUtil.usersRef().child(moderator.getUid()).child("contactNo").setValue(contact);
            FirebaseUtil.usersRef().child(moderator.getUid()).child("address").setValue(address);
            FirebaseUtil.usersRef().child(moderator.getUid()).child("domain").setValue(domain)
                .addOnSuccessListener(aVoid -> {
                    Toast.makeText(this, "Moderator updated successfully", Toast.LENGTH_SHORT).show();
                })
                .addOnFailureListener(e -> {
                    Toast.makeText(this, "Failed to update: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                });
        });

        builder.setNegativeButton("Cancel", null);
        builder.show();
    }

    private void showDeleteConfirmation(UserModel moderator) {
        new AlertDialog.Builder(this)
                .setTitle("Delete Moderator")
                .setMessage("Are you sure you want to delete this moderator?\n\n" + moderator.getFullName())
                .setPositiveButton("Delete", (dialog, which) -> {
                    deleteModerator(moderator);
                })
                .setNegativeButton("Cancel", null)
                .show();
    }

    private void deleteModerator(UserModel moderator) {
        FirebaseUtil.usersRef().child(moderator.getUid()).removeValue()
                .addOnSuccessListener(aVoid -> {
                    Toast.makeText(this, "Moderator deleted successfully", Toast.LENGTH_SHORT).show();
                })
                .addOnFailureListener(e -> {
                    Toast.makeText(this, "Failed to delete: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                });
    }

    private void showModeratorDetails(UserModel moderator) {
        StringBuilder details = new StringBuilder();
        details.append("Name: ").append(moderator.getFullName()).append("\n");
        details.append("Email: ").append(moderator.getEmail()).append("\n");
        details.append("Phone: ").append(moderator.getContactNo() != null ? moderator.getContactNo() : "N/A").append("\n");
        details.append("Category: ").append(moderator.getDomain() != null ? moderator.getDomain() : "N/A").append("\n");
        details.append("Address: ").append(moderator.getAddress() != null ? moderator.getAddress() : "N/A").append("\n");
        details.append("Registration Date: ").append(moderator.getDateOfRegistration() != null ? moderator.getDateOfRegistration() : "N/A");

        new AlertDialog.Builder(this)
                .setTitle("Moderator Details")
                .setMessage(details.toString())
                .setPositiveButton("OK", null)
                .show();
    }
}
