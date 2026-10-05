package com.example.ecomerceapp.activities;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.example.ecomerceapp.databinding.ActivityAdminCouriersBinding;
import com.example.ecomerceapp.models.Courier;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.example.ecomerceapp.utils.PriceFormatter;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class AdminCouriersActivity extends AppCompatActivity {

    private ActivityAdminCouriersBinding binding;
    private CourierAdapter adapter;
    private List<Courier> courierList = new ArrayList<>();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAdminCouriersBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupRecyclerView();
        setupClickListeners();
        loadCouriers();
    }

    private void setupRecyclerView() {
        adapter = new CourierAdapter(courierList, this::onEditCourier, this::onDeleteCourier);
        binding.recycler.setLayoutManager(new LinearLayoutManager(this));
        binding.recycler.setAdapter(adapter);
    }

    private void setupClickListeners() {
        binding.btnBack.setOnClickListener(v -> finish());
        binding.btnAdd.setOnClickListener(v -> showCourierDialog(null));
    }

    private void loadCouriers() {
        binding.progress.setVisibility(View.VISIBLE);
        FirebaseUtil.couriersRef().addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                courierList.clear();
                for (DataSnapshot data : snapshot.getChildren()) {
                    Courier courier = data.getValue(Courier.class);
                    if (courier != null) {
                        courierList.add(courier);
                    }
                }
                binding.progress.setVisibility(View.GONE);
                adapter.notifyDataSetChanged();
                binding.tvEmpty.setVisibility(courierList.isEmpty() ? View.VISIBLE : View.GONE);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                binding.progress.setVisibility(View.GONE);
                Toast.makeText(AdminCouriersActivity.this, "Error: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void showCourierDialog(Courier courier) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        View view = LayoutInflater.from(this).inflate(
            android.R.layout.simple_list_item_2, null, false);
        
        EditText etName = new EditText(this);
        etName.setHint("Courier Name");
        
        EditText etContact = new EditText(this);
        etContact.setHint("Contact Number");
        
        EditText etAddress = new EditText(this);
        etAddress.setHint("Address");
        
        EditText etCharge = new EditText(this);
        etCharge.setHint("Delivery Charge");
        etCharge.setInputType(android.text.InputType.TYPE_CLASS_NUMBER | android.text.InputType.TYPE_NUMBER_FLAG_DECIMAL);

        if (courier != null) {
            etName.setText(courier.getName());
            etContact.setText(courier.getContact());
            etAddress.setText(courier.getAddress());
            etCharge.setText(String.valueOf(courier.getDeliveryCharge()));
        }

        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setPadding(50, 20, 50, 20);
        layout.addView(etName);
        layout.addView(etContact);
        layout.addView(etAddress);
        layout.addView(etCharge);

        builder.setView(layout);
        builder.setTitle(courier == null ? "Add Courier" : "Edit Courier");
        builder.setPositiveButton("Save", (dialog, which) -> {
            saveCourier(courier, etName, etContact, etAddress, etCharge);
        });
        builder.setNegativeButton("Cancel", null);
        builder.show();
    }

    private void saveCourier(Courier existing, EditText etName, EditText etContact, EditText etAddress, EditText etCharge) {
        String name = etName.getText().toString().trim();
        String contact = etContact.getText().toString().trim();
        String address = etAddress.getText().toString().trim();
        String chargeStr = etCharge.getText().toString().trim();

        if (TextUtils.isEmpty(name)) {
            Toast.makeText(this, "Courier name is required", Toast.LENGTH_SHORT).show();
            return;
        }

        double charge = TextUtils.isEmpty(chargeStr) ? 0 : Double.parseDouble(chargeStr);
        String id = existing != null ? existing.getId() : UUID.randomUUID().toString();

        Courier courier = new Courier(id, name, contact, address, charge);
        
        FirebaseUtil.couriersRef().child(id).setValue(courier)
            .addOnSuccessListener(aVoid -> Toast.makeText(this, "Courier saved successfully", Toast.LENGTH_SHORT).show())
            .addOnFailureListener(e -> Toast.makeText(this, "Failed to save: " + e.getMessage(), Toast.LENGTH_SHORT).show());
    }

    private void onEditCourier(Courier courier) {
        showCourierDialog(courier);
    }

    private void onDeleteCourier(Courier courier) {
        new AlertDialog.Builder(this)
            .setTitle("Delete Courier")
            .setMessage("Are you sure you want to delete " + courier.getName() + "?")
            .setPositiveButton("Delete", (dialog, which) -> {
                FirebaseUtil.couriersRef().child(courier.getId()).removeValue()
                    .addOnSuccessListener(aVoid -> Toast.makeText(this, "Courier deleted", Toast.LENGTH_SHORT).show())
                    .addOnFailureListener(e -> Toast.makeText(this, "Failed to delete: " + e.getMessage(), Toast.LENGTH_SHORT).show());
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private static class CourierAdapter extends androidx.recyclerview.widget.RecyclerView.Adapter<CourierAdapter.ViewHolder> {
        private List<Courier> list;
        private final java.util.function.Consumer<Courier> onEdit;
        private final java.util.function.Consumer<Courier> onDelete;

        CourierAdapter(List<Courier> list, java.util.function.Consumer<Courier> onEdit, 
                      java.util.function.Consumer<Courier> onDelete) {
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
            Courier courier = list.get(position);
            ((android.widget.TextView) holder.itemView.findViewById(android.R.id.text1))
                .setText(courier.getName());
            ((android.widget.TextView) holder.itemView.findViewById(android.R.id.text2))
                .setText("Charge: " + PriceFormatter.formatPrice(courier.getDeliveryCharge()) + " | " + courier.getContact());
            
            holder.itemView.setOnClickListener(v -> onEdit.accept(courier));
            holder.itemView.setOnLongClickListener(v -> {
                onDelete.accept(courier);
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
