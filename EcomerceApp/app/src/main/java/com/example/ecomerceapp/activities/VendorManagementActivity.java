package com.example.ecomerceapp.activities;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.databinding.ActivityVendorManagementBinding;
import com.example.ecomerceapp.models.Vendor;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

public class VendorManagementActivity extends AppCompatActivity {

    private ActivityVendorManagementBinding binding;
    private VendorAdapter adapter;
    private List<Vendor> vendorList = new ArrayList<>();
    private List<Vendor> filteredList = new ArrayList<>();
    private final String[] genders = {"Male", "Female", "Other"};
    private final String[] statuses = {"Active", "Inactive"};
    private final String[] searchFilters = {"All", "Name", "Category", "Date"};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityVendorManagementBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupRecyclerView();
        setupSearchFilter();
        setupClickListeners();
        loadVendors();
    }

    private void setupRecyclerView() {
        adapter = new VendorAdapter(filteredList, this::onEditVendor, this::onDeleteVendor);
        binding.recycler.setLayoutManager(new LinearLayoutManager(this));
        binding.recycler.setAdapter(adapter);
    }

    private void setupSearchFilter() {
        ArrayAdapter<String> filterAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, searchFilters);
        filterAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        binding.spinnerSearchFilter.setAdapter(filterAdapter);

        binding.etSearch.addTextChangedListener(new android.text.TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                filterVendors(s.toString());
            }

            @Override
            public void afterTextChanged(android.text.Editable s) {}
        });
    }

    private void setupClickListeners() {
        binding.btnBack.setOnClickListener(v -> finish());
        binding.btnAdd.setOnClickListener(v -> showVendorDialog(null));
    }

    private void loadVendors() {
        binding.progress.setVisibility(View.VISIBLE);
        FirebaseUtil.vendorsRef().addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                vendorList.clear();
                for (DataSnapshot data : snapshot.getChildren()) {
                    Vendor vendor = data.getValue(Vendor.class);
                    if (vendor != null) {
                        if (vendor.getVendorId() == null) vendor.setVendorId(data.getKey());
                        vendorList.add(vendor);
                    }
                }
                filteredList.clear();
                filteredList.addAll(vendorList);
                binding.progress.setVisibility(View.GONE);
                adapter.notifyDataSetChanged();
                binding.tvEmpty.setVisibility(filteredList.isEmpty() ? View.VISIBLE : View.GONE);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                binding.progress.setVisibility(View.GONE);
                Toast.makeText(VendorManagementActivity.this, "Error: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void filterVendors(String query) {
        String filterType = searchFilters[binding.spinnerSearchFilter.getSelectedItemPosition()];
        filteredList.clear();

        if (TextUtils.isEmpty(query)) {
            filteredList.addAll(vendorList);
        } else {
            String lowerQuery = query.toLowerCase();
            for (Vendor vendor : vendorList) {
                boolean matches = false;
                switch (filterType) {
                    case "Name":
                        String fullName = (vendor.getFirstName() + " " + vendor.getLastName()).toLowerCase();
                        matches = fullName.contains(lowerQuery);
                        break;
                    case "Category":
                        matches = vendor.getProductCategory() != null && 
                                  vendor.getProductCategory().toLowerCase().contains(lowerQuery);
                        break;
                    case "Date":
                        matches = vendor.getRegistrationDate() != null && 
                                  vendor.getRegistrationDate().contains(query);
                        break;
                    default: // All
                        fullName = (vendor.getFirstName() + " " + vendor.getLastName()).toLowerCase();
                        matches = fullName.contains(lowerQuery) ||
                                  (vendor.getProductCategory() != null && 
                                   vendor.getProductCategory().toLowerCase().contains(lowerQuery)) ||
                                  (vendor.getRegistrationDate() != null && 
                                   vendor.getRegistrationDate().contains(query));
                }
                if (matches) {
                    filteredList.add(vendor);
                }
            }
        }
        adapter.notifyDataSetChanged();
        binding.tvEmpty.setVisibility(filteredList.isEmpty() ? View.VISIBLE : View.GONE);
    }

    private void showVendorDialog(Vendor vendor) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        
        View dialogView = LayoutInflater.from(this).inflate(R.layout.dialog_vendor, null);
        
        EditText etFirstName = dialogView.findViewById(R.id.etFirstName);
        EditText etLastName = dialogView.findViewById(R.id.etLastName);
        Spinner spinnerGender = dialogView.findViewById(R.id.spinnerGender);
        EditText etPhone = dialogView.findViewById(R.id.etPhone);
        EditText etEmail = dialogView.findViewById(R.id.etEmail);
        EditText etAddress = dialogView.findViewById(R.id.etAddress);
        EditText etShopName = dialogView.findViewById(R.id.etShopName);
        EditText etProductCategory = dialogView.findViewById(R.id.etProductCategory);
        EditText etProductDomain = dialogView.findViewById(R.id.etProductDomain);
        Spinner spinnerStatus = dialogView.findViewById(R.id.spinnerStatus);

        // Setup spinners
        ArrayAdapter<String> genderAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, genders);
        genderAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerGender.setAdapter(genderAdapter);

        ArrayAdapter<String> statusAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, statuses);
        statusAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerStatus.setAdapter(statusAdapter);

        if (vendor != null) {
            etFirstName.setText(vendor.getFirstName());
            etLastName.setText(vendor.getLastName());
            etPhone.setText(vendor.getPhone());
            etEmail.setText(vendor.getEmail());
            etAddress.setText(vendor.getAddress());
            etShopName.setText(vendor.getShopName());
            etProductCategory.setText(vendor.getProductCategory());
            etProductDomain.setText(vendor.getProductDomain());

            for (int i = 0; i < genders.length; i++) {
                if (genders[i].equals(vendor.getGender())) {
                    spinnerGender.setSelection(i);
                    break;
                }
            }

            for (int i = 0; i < statuses.length; i++) {
                if (statuses[i].equals(vendor.getStatus())) {
                    spinnerStatus.setSelection(i);
                    break;
                }
            }
        }

        builder.setView(dialogView);
        builder.setTitle(vendor == null ? "Add Vendor" : "Edit Vendor");
        builder.setPositiveButton("Save", (dialog, which) -> {
            saveVendor(vendor, etFirstName, etLastName, spinnerGender, etPhone, etEmail, 
                      etAddress, etShopName, etProductCategory, etProductDomain, spinnerStatus);
        });
        builder.setNegativeButton("Cancel", null);
        builder.show();
    }

    private void saveVendor(Vendor existing, EditText etFirstName, EditText etLastName, Spinner spinnerGender,
                           EditText etPhone, EditText etEmail, EditText etAddress, EditText etShopName,
                           EditText etProductCategory, EditText etProductDomain, Spinner spinnerStatus) {
        String firstName = etFirstName.getText().toString().trim();
        String lastName = etLastName.getText().toString().trim();
        String gender = genders[spinnerGender.getSelectedItemPosition()];
        String phone = etPhone.getText().toString().trim();
        String email = etEmail.getText().toString().trim();
        String address = etAddress.getText().toString().trim();
        String shopName = etShopName.getText().toString().trim();
        String productCategory = etProductCategory.getText().toString().trim();
        String productDomain = etProductDomain.getText().toString().trim();
        String status = statuses[spinnerStatus.getSelectedItemPosition()];

        if (TextUtils.isEmpty(firstName) || TextUtils.isEmpty(lastName)) {
            Toast.makeText(this, "Name is required", Toast.LENGTH_SHORT).show();
            return;
        }

        if (TextUtils.isEmpty(phone)) {
            Toast.makeText(this, "Phone number is required", Toast.LENGTH_SHORT).show();
            return;
        }

        if (TextUtils.isEmpty(email)) {
            Toast.makeText(this, "Email is required", Toast.LENGTH_SHORT).show();
            return;
        }

        String id = existing != null ? existing.getVendorId() : UUID.randomUUID().toString();
        String registrationDate = existing != null ? existing.getRegistrationDate() : 
                                   new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(new Date());

        Vendor vendor = new Vendor(id, firstName, lastName, gender, phone, email, address,
                                   shopName, productCategory, productDomain, registrationDate, status);

        FirebaseUtil.vendorsRef().child(id).setValue(vendor)
            .addOnSuccessListener(aVoid -> {
                Toast.makeText(this, "Vendor saved successfully", Toast.LENGTH_SHORT).show();
                loadVendors();
            })
            .addOnFailureListener(e -> Toast.makeText(this, "Failed to save: " + e.getMessage(), Toast.LENGTH_SHORT).show());
    }

    private void onEditVendor(Vendor vendor) {
        showVendorDialog(vendor);
    }

    private void onDeleteVendor(Vendor vendor) {
        new AlertDialog.Builder(this)
            .setTitle("Delete Vendor")
            .setMessage("Are you sure you want to delete " + vendor.getFirstName() + " " + vendor.getLastName() + "?")
            .setPositiveButton("Delete", (dialog, which) -> {
                FirebaseUtil.vendorsRef().child(vendor.getVendorId()).removeValue()
                    .addOnSuccessListener(aVoid -> {
                        Toast.makeText(this, "Vendor deleted", Toast.LENGTH_SHORT).show();
                        loadVendors();
                    })
                    .addOnFailureListener(e -> Toast.makeText(this, "Failed to delete: " + e.getMessage(), Toast.LENGTH_SHORT).show());
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private static class VendorAdapter extends androidx.recyclerview.widget.RecyclerView.Adapter<VendorAdapter.ViewHolder> {
        private List<Vendor> list;
        private final java.util.function.Consumer<Vendor> onEdit;
        private final java.util.function.Consumer<Vendor> onDelete;

        VendorAdapter(List<Vendor> list, java.util.function.Consumer<Vendor> onEdit, 
                      java.util.function.Consumer<Vendor> onDelete) {
            this.list = list;
            this.onEdit = onEdit;
            this.onDelete = onDelete;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull android.view.ViewGroup parent, int viewType) {
            android.view.View view = LayoutInflater.from(parent.getContext())
                .inflate(android.R.layout.simple_list_item_2, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            Vendor vendor = list.get(position);
            String fullName = vendor.getFirstName() + " " + vendor.getLastName();
            String details = vendor.getShopName() + " | " + vendor.getProductCategory() + " | " + vendor.getStatus();
            
            ((android.widget.TextView) holder.itemView.findViewById(android.R.id.text1)).setText(fullName);
            ((android.widget.TextView) holder.itemView.findViewById(android.R.id.text2)).setText(details);
            
            holder.itemView.setOnClickListener(v -> onEdit.accept(vendor));
            holder.itemView.setOnLongClickListener(v -> {
                onDelete.accept(vendor);
                return true;
            });
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        static class ViewHolder extends androidx.recyclerview.widget.RecyclerView.ViewHolder {
            ViewHolder(android.view.View itemView) {
                super(itemView);
            }
        }
    }
}
