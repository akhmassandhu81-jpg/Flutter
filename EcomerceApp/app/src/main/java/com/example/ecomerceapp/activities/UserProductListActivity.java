package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.example.ecomerceapp.adapters.UserProductAdapter;
import com.example.ecomerceapp.databinding.ActivityUserProductListBinding;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.MutableData;
import com.google.firebase.database.Transaction;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class UserProductListActivity extends AppCompatActivity implements UserProductAdapter.Listener {

    private ActivityUserProductListBinding binding;
    private UserProductAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityUserProductListBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        adapter = new UserProductAdapter(this, this);
        binding.recycler.setLayoutManager(new LinearLayoutManager(this));
        binding.recycler.setAdapter(adapter);

        binding.btnBack.setOnClickListener(v -> finish());

        binding.fabAddProduct.setOnClickListener(v ->
                startActivity(new Intent(UserProductListActivity.this, AdminProductFormActivity.class)));

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
                    if (p != null && p.isApproved()) {
                        list.add(p);
                    }
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
    public void onAddToCart(Product product) {
        FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
        if (user == null) {
            Toast.makeText(this, "Please login first", Toast.LENGTH_SHORT).show();
            return;
        }

        if (product.getQuantity() <= 0) {
            Toast.makeText(this, "Out of stock", Toast.LENGTH_SHORT).show();
            return;
        }

        // Always validate latest stock from Firebase Products node before increasing
        FirebaseUtil.productsRef().child(product.getId()).child("quantity")
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        Integer stock = snapshot.getValue(Integer.class);
                        if (stock == null) stock = 0;

                        if (stock <= 0) {
                            Toast.makeText(UserProductListActivity.this, "Out of stock", Toast.LENGTH_SHORT).show();
                            return;
                        }

                        DatabaseReference itemRef = FirebaseUtil.cartsRef().child(user.getUid()).child(product.getId());

                        // IMPORTANT LOGIC (atomic): if exists -> quantity + 1, else -> new item quantity = 1
                        // Also prevents duplicates because key is productId
                        final int finalStock = stock;
                        itemRef.runTransaction(new Transaction.Handler() {
                            @NonNull
                            @Override
                            public Transaction.Result doTransaction(@NonNull MutableData currentData) {
                                CartItem existing = currentData.getValue(CartItem.class);

                                int newQty = 1;
                                if (existing != null) {
                                    newQty = existing.getQuantity() + 1;
                                }

                                if (newQty > finalStock) {
                                    return Transaction.abort();
                                }

                                CartItem toSave = new CartItem(product.getId(), product.getName(), product.getPrice(), newQty, product.getImageUrl());
                                currentData.setValue(toSave);
                                return Transaction.success(currentData);
                            }

                            @Override
                            public void onComplete(DatabaseError error, boolean committed, DataSnapshot currentData) {
                                if (error != null) {
                                    Toast.makeText(UserProductListActivity.this, "Failed: " + error.getMessage(), Toast.LENGTH_SHORT).show();
                                    return;
                                }

                                if (!committed) {
                                    Toast.makeText(UserProductListActivity.this, "Cannot add more, stock limit reached", Toast.LENGTH_SHORT).show();
                                    return;
                                }

                                Toast.makeText(UserProductListActivity.this, "Added to cart", Toast.LENGTH_SHORT).show();
                            }
                        });
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        Toast.makeText(UserProductListActivity.this, "Failed: " + error.getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });
    }
}
