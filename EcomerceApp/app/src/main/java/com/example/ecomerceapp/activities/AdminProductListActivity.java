package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.example.ecomerceapp.adapters.AdminProductAdapter;
import com.example.ecomerceapp.databinding.ActivityAdminProductListBinding;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class AdminProductListActivity extends AppCompatActivity implements AdminProductAdapter.Listener {

    private ActivityAdminProductListBinding binding;
    private AdminProductAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAdminProductListBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        adapter = new AdminProductAdapter(this, this);
        binding.recycler.setLayoutManager(new LinearLayoutManager(this));
        binding.recycler.setAdapter(adapter);

        binding.btnBack.setOnClickListener(v -> finish());
        binding.fabAdd.setOnClickListener(v -> startActivity(new Intent(this, AdminProductFormActivity.class)));

        loadProducts();
    }

    private void loadProducts() {
        binding.progress.setVisibility(View.VISIBLE);
        FirebaseUtil.productsRef().addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<Product> list = new ArrayList<>();
                for (DataSnapshot s : snapshot.getChildren()) {
                    Product p = s.getValue(Product.class);
                    if (p != null) list.add(p);
                }
                binding.progress.setVisibility(View.GONE);
                adapter.submit(list);
                binding.tvEmpty.setVisibility(list.isEmpty() ? View.VISIBLE : View.GONE);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                binding.progress.setVisibility(View.GONE);
            }
        });
    }

    @Override
    public void onEdit(Product product) {
        Intent i = new Intent(this, AdminProductFormActivity.class);
        i.putExtra("productId", product.getId());
        startActivity(i);
    }

    @Override
    public void onDelete(Product product) {
        new AlertDialog.Builder(this)
                .setTitle("Delete Product")
                .setMessage("Are you sure you want to delete this product?")
                .setPositiveButton("Delete", (d, w) -> FirebaseUtil.productsRef().child(product.getId()).removeValue())
                .setNegativeButton("Cancel", null)
                .show();
    }
}
