package com.example.ecomerceapp.activities;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.example.ecomerceapp.databinding.ActivityAdminPaymentCompaniesBinding;
import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.models.PaymentCompany;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class AdminPaymentCompaniesActivity extends AppCompatActivity {

    private ActivityAdminPaymentCompaniesBinding binding;
    private CompanyAdapter adapter;
    private OrderPaymentAdapter orderAdapter;
    private List<PaymentCompany> companyList = new ArrayList<>();
    private List<Order> orderList = new ArrayList<>();
    private final String[] types = {"Payment", "Insurance"};
    private boolean showingOrders = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAdminPaymentCompaniesBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupRecyclerView();
        setupClickListeners();
        loadCompanies();
        loadOrders();
    }

    private void setupRecyclerView() {
        adapter = new CompanyAdapter(companyList, this::onEditCompany, this::onDeleteCompany);
        binding.recycler.setLayoutManager(new LinearLayoutManager(this));
        binding.recycler.setAdapter(adapter);

        orderAdapter = new OrderPaymentAdapter(orderList);
        binding.recyclerOrders.setLayoutManager(new LinearLayoutManager(this));
        binding.recyclerOrders.setAdapter(orderAdapter);
    }

    private void setupClickListeners() {
        binding.btnBack.setOnClickListener(v -> finish());
        binding.btnAdd.setOnClickListener(v -> {
            if (showingOrders) {
                // Don't show add dialog when viewing orders
                Toast.makeText(this, "Switch to Companies tab to add companies", Toast.LENGTH_SHORT).show();
            } else {
                showCompanyDialog(null);
            }
        });

        binding.btnTabCompanies.setOnClickListener(v -> switchToCompaniesTab());
        binding.btnTabOrders.setOnClickListener(v -> switchToOrdersTab());
    }

    private void switchToCompaniesTab() {
        showingOrders = false;
        binding.recycler.setVisibility(View.VISIBLE);
        binding.recyclerOrders.setVisibility(View.GONE);
        binding.tvEmpty.setVisibility(companyList.isEmpty() ? View.VISIBLE : View.GONE);
        binding.tvEmptyOrders.setVisibility(View.GONE);
        binding.btnAdd.setVisibility(View.VISIBLE);
        binding.btnTabCompanies.setBackgroundTintList(getResources().getColorStateList(android.R.color.holo_green_dark));
        binding.btnTabOrders.setBackgroundTintList(getResources().getColorStateList(android.R.color.darker_gray));
    }

    private void switchToOrdersTab() {
        showingOrders = true;
        binding.recycler.setVisibility(View.GONE);
        binding.recyclerOrders.setVisibility(View.VISIBLE);
        binding.tvEmpty.setVisibility(View.GONE);
        binding.tvEmptyOrders.setVisibility(orderList.isEmpty() ? View.VISIBLE : View.GONE);
        binding.btnAdd.setVisibility(View.GONE);
        binding.btnTabCompanies.setBackgroundTintList(getResources().getColorStateList(android.R.color.darker_gray));
        binding.btnTabOrders.setBackgroundTintList(getResources().getColorStateList(android.R.color.holo_green_dark));
    }

    private void loadCompanies() {
        binding.progress.setVisibility(View.VISIBLE);
        FirebaseUtil.paymentCompaniesRef().addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                companyList.clear();
                for (DataSnapshot data : snapshot.getChildren()) {
                    PaymentCompany company = data.getValue(PaymentCompany.class);
                    if (company != null) {
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
                Toast.makeText(AdminPaymentCompaniesActivity.this, "Error: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void loadOrders() {
        FirebaseUtil.ordersRef().addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                orderList.clear();
                for (DataSnapshot data : snapshot.getChildren()) {
                    Order order = data.getValue(Order.class);
                    if (order != null) {
                        if (order.getOrderId() == null) order.setOrderId(data.getKey());
                        orderList.add(order);
                    }
                }
                orderAdapter.notifyDataSetChanged();
                if (showingOrders) {
                    binding.tvEmptyOrders.setVisibility(orderList.isEmpty() ? View.VISIBLE : View.GONE);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Toast.makeText(AdminPaymentCompaniesActivity.this, "Error loading orders: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void showCompanyDialog(PaymentCompany company) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        
        EditText etName = new EditText(this);
        etName.setHint("Company Name");
        
        Spinner spinnerType = new Spinner(this);
        ArrayAdapter<String> typeAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, types);
        typeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerType.setAdapter(typeAdapter);
        
        EditText etContact = new EditText(this);
        etContact.setHint("Contact Number");
        
        EditText etAddress = new EditText(this);
        etAddress.setHint("Address");

        CheckBox cbActive = new CheckBox(this);
        cbActive.setText("Active");

        if (company != null) {
            etName.setText(company.getName());
            etContact.setText(company.getContact());
            etAddress.setText(company.getAddress());
            cbActive.setChecked(company.isActive());
            for (int i = 0; i < types.length; i++) {
                if (types[i].equals(company.getType())) {
                    spinnerType.setSelection(i);
                    break;
                }
            }
        } else {
            cbActive.setChecked(true);
        }

        android.widget.LinearLayout layout = new android.widget.LinearLayout(this);
        layout.setOrientation(android.widget.LinearLayout.VERTICAL);
        layout.setPadding(50, 20, 50, 20);
        layout.addView(etName);
        layout.addView(spinnerType);
        layout.addView(etContact);
        layout.addView(etAddress);
        layout.addView(cbActive);

        builder.setView(layout);
        builder.setTitle(company == null ? "Add Company" : "Edit Company");
        builder.setPositiveButton("Save", (dialog, which) -> {
            saveCompany(company, etName, spinnerType, etContact, etAddress, cbActive);
        });
        builder.setNegativeButton("Cancel", null);
        builder.show();
    }

    private void saveCompany(PaymentCompany existing, EditText etName, Spinner spinnerType, EditText etContact, EditText etAddress, CheckBox cbActive) {
        String name = etName.getText().toString().trim();
        String type = types[spinnerType.getSelectedItemPosition()];
        String contact = etContact.getText().toString().trim();
        String address = etAddress.getText().toString().trim();
        boolean active = cbActive.isChecked();

        if (TextUtils.isEmpty(name)) {
            Toast.makeText(this, "Company name is required", Toast.LENGTH_SHORT).show();
            return;
        }

        String id = existing != null ? existing.getId() : UUID.randomUUID().toString();
        PaymentCompany company = new PaymentCompany(id, name, type, contact, address);
        company.setActive(active);
        
        FirebaseUtil.paymentCompaniesRef().child(id).setValue(company)
            .addOnSuccessListener(aVoid -> Toast.makeText(this, "Company saved successfully", Toast.LENGTH_SHORT).show())
            .addOnFailureListener(e -> Toast.makeText(this, "Failed to save: " + e.getMessage(), Toast.LENGTH_SHORT).show());
    }

    private void onEditCompany(PaymentCompany company) {
        showCompanyDialog(company);
    }

    private void onDeleteCompany(PaymentCompany company) {
        new AlertDialog.Builder(this)
            .setTitle("Delete Company")
            .setMessage("Are you sure you want to delete " + company.getName() + "?")
            .setPositiveButton("Delete", (dialog, which) -> {
                FirebaseUtil.paymentCompaniesRef().child(company.getId()).removeValue()
                    .addOnSuccessListener(aVoid -> Toast.makeText(this, "Company deleted", Toast.LENGTH_SHORT).show())
                    .addOnFailureListener(e -> Toast.makeText(this, "Failed to delete: " + e.getMessage(), Toast.LENGTH_SHORT).show());
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private static class CompanyAdapter extends androidx.recyclerview.widget.RecyclerView.Adapter<CompanyAdapter.ViewHolder> {
        private List<PaymentCompany> list;
        private final java.util.function.Consumer<PaymentCompany> onEdit;
        private final java.util.function.Consumer<PaymentCompany> onDelete;

        CompanyAdapter(List<PaymentCompany> list, java.util.function.Consumer<PaymentCompany> onEdit, 
                      java.util.function.Consumer<PaymentCompany> onDelete) {
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
            PaymentCompany company = list.get(position);
            ((android.widget.TextView) holder.itemView.findViewById(android.R.id.text1))
                .setText(company.getName() + " (" + company.getType() + ")");
            ((android.widget.TextView) holder.itemView.findViewById(android.R.id.text2))
                .setText(company.getContact() + " | " + company.getAddress());
            
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

    private static class OrderPaymentAdapter extends androidx.recyclerview.widget.RecyclerView.Adapter<OrderPaymentAdapter.ViewHolder> {
        private List<Order> list;

        OrderPaymentAdapter(List<Order> list) {
            this.list = list;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull android.view.ViewGroup parent, int viewType) {
            android.view.View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.row_order_payment, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            Order order = list.get(position);
            
            String paymentMethod = order.getPaymentMethod();
            if (paymentMethod == null) paymentMethod = "Cash on Delivery";
            
            holder.tvOrderId.setText("#" + (order.getOrderId() != null ? order.getOrderId() : "Unknown"));
            holder.tvPaymentMethod.setText(paymentMethod);
            holder.tvUserName.setText(order.getUserName() != null ? order.getUserName() : "Unknown Customer");
            holder.tvTotalAmount.setText("₹" + String.format("%.0f", order.getTotalPrice()));
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        static class ViewHolder extends androidx.recyclerview.widget.RecyclerView.ViewHolder {
            TextView tvOrderId, tvPaymentMethod, tvUserName, tvTotalAmount;

            ViewHolder(android.view.View itemView) {
                super(itemView);
                tvOrderId = itemView.findViewById(R.id.tvOrderId);
                tvPaymentMethod = itemView.findViewById(R.id.tvPaymentMethod);
                tvUserName = itemView.findViewById(R.id.tvUserName);
                tvTotalAmount = itemView.findViewById(R.id.tvTotalAmount);
            }
        }
    }
}
