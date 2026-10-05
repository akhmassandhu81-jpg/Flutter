package com.example.ecomerceapp.activities;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.example.ecomerceapp.databinding.ActivityAdminInsuranceCompaniesBinding;
import com.example.ecomerceapp.models.InsuranceCompany;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class AdminInsuranceCompaniesActivity extends AppCompatActivity {

    private ActivityAdminInsuranceCompaniesBinding binding;
    private InsuranceAdapter adapter;
    private List<InsuranceCompany> companyList = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAdminInsuranceCompaniesBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupRecyclerView();
        setupClickListeners();
        loadCompanies();
    }

    private void setupRecyclerView() {
        adapter = new InsuranceAdapter(companyList, this::onEditCompany, this::onDeleteCompany);
        binding.recycler.setLayoutManager(new LinearLayoutManager(this));
        binding.recycler.setAdapter(adapter);
    }

    private void setupClickListeners() {
        binding.btnBack.setOnClickListener(v -> finish());
        binding.btnAdd.setOnClickListener(v -> showCompanyDialog(null));
    }

    private void loadCompanies() {
        binding.progress.setVisibility(View.VISIBLE);
        FirebaseUtil.insuranceCompaniesRef().addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                companyList.clear();
                for (DataSnapshot data : snapshot.getChildren()) {
                    InsuranceCompany company = data.getValue(InsuranceCompany.class);
                    if (company != null) {
                        company.setId(data.getKey());
                        companyList.add(company);
                    }
                }
                binding.progress.setVisibility(View.GONE);
                adapter.notifyDataSetChanged();
                binding.tvEmpty.setVisibility(companyList.isEmpty() ? View.VISIBLE : View.GONE);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                binding.progress.setVisibility(View.GONE);
                Toast.makeText(AdminInsuranceCompaniesActivity.this, "Error: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void showCompanyDialog(InsuranceCompany company) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        
        EditText etName = new EditText(this);
        etName.setHint("Insurance Company Name");
        
        EditText etPrice = new EditText(this);
        etPrice.setHint("Price");
        etPrice.setInputType(android.text.InputType.TYPE_CLASS_NUMBER | android.text.InputType.TYPE_NUMBER_FLAG_DECIMAL);
        
        EditText etContact = new EditText(this);
        etContact.setHint("Contact Number");
        
        EditText etAddress = new EditText(this);
        etAddress.setHint("Address");

        CheckBox cbActive = new CheckBox(this);
        cbActive.setText("Active");

        if (company != null) {
            etName.setText(company.getName());
            etPrice.setText(String.valueOf(company.getPrice()));
            etContact.setText(company.getContact());
            etAddress.setText(company.getAddress());
            cbActive.setChecked(company.isActive());
        } else {
            cbActive.setChecked(true);
        }

        android.widget.LinearLayout layout = new android.widget.LinearLayout(this);
        layout.setOrientation(android.widget.LinearLayout.VERTICAL);
        layout.setPadding(50, 20, 50, 20);
        layout.addView(etName);
        layout.addView(etPrice);
        layout.addView(etContact);
        layout.addView(etAddress);
        layout.addView(cbActive);

        builder.setView(layout);
        builder.setTitle(company == null ? "Add Insurance Company" : "Edit Insurance Company");
        builder.setPositiveButton("Save", (dialog, which) -> {
            saveCompany(company, etName, etPrice, etContact, etAddress, cbActive);
        });
        builder.setNegativeButton("Cancel", null);
        builder.show();
    }

    private void saveCompany(InsuranceCompany existing, EditText etName, EditText etPrice, EditText etContact, EditText etAddress, CheckBox cbActive) {
        String name = etName.getText().toString().trim();
        String priceStr = etPrice.getText().toString().trim();
        String contact = etContact.getText().toString().trim();
        String address = etAddress.getText().toString().trim();
        boolean active = cbActive.isChecked();

        if (TextUtils.isEmpty(name)) {
            Toast.makeText(this, "Company name is required", Toast.LENGTH_SHORT).show();
            return;
        }

        double price = 0;
        if (!TextUtils.isEmpty(priceStr)) {
            try {
                price = Double.parseDouble(priceStr);
            } catch (NumberFormatException e) {
                Toast.makeText(this, "Invalid price", Toast.LENGTH_SHORT).show();
                return;
            }
        }

        String id = existing != null ? existing.getId() : UUID.randomUUID().toString();
        InsuranceCompany company = new InsuranceCompany(id, name, price, contact, address);
        company.setActive(active);
        
        FirebaseUtil.insuranceCompaniesRef().child(id).setValue(company)
            .addOnSuccessListener(aVoid -> Toast.makeText(this, "Insurance company saved successfully", Toast.LENGTH_SHORT).show())
            .addOnFailureListener(e -> Toast.makeText(this, "Failed to save: " + e.getMessage(), Toast.LENGTH_SHORT).show());
    }

    private void onEditCompany(InsuranceCompany company) {
        showCompanyDialog(company);
    }

    private void onDeleteCompany(InsuranceCompany company) {
        new AlertDialog.Builder(this)
            .setTitle("Delete Insurance Company")
            .setMessage("Are you sure you want to delete " + company.getName() + "?")
            .setPositiveButton("Delete", (dialog, which) -> {
                FirebaseUtil.insuranceCompaniesRef().child(company.getId()).removeValue()
                    .addOnSuccessListener(aVoid -> Toast.makeText(this, "Insurance company deleted", Toast.LENGTH_SHORT).show())
                    .addOnFailureListener(e -> Toast.makeText(this, "Failed to delete: " + e.getMessage(), Toast.LENGTH_SHORT).show());
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private static class InsuranceAdapter extends androidx.recyclerview.widget.RecyclerView.Adapter<InsuranceAdapter.ViewHolder> {
        private List<InsuranceCompany> list;
        private final java.util.function.Consumer<InsuranceCompany> onEdit;
        private final java.util.function.Consumer<InsuranceCompany> onDelete;

        InsuranceAdapter(List<InsuranceCompany> list, java.util.function.Consumer<InsuranceCompany> onEdit, 
                      java.util.function.Consumer<InsuranceCompany> onDelete) {
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
            InsuranceCompany company = list.get(position);
            ((android.widget.TextView) holder.itemView.findViewById(android.R.id.text1))
                .setText(company.getName() + (company.isActive() ? " (Active)" : " (Inactive)"));
            ((android.widget.TextView) holder.itemView.findViewById(android.R.id.text2))
                .setText("Price: Rs " + company.getPrice() + " | " + company.getContact() + " | " + company.getAddress());
            
            holder.itemView.setOnClickListener(v -> onEdit.accept(company));
            holder.itemView.setOnLongClickListener(v -> {
                onDelete.accept(company);
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
