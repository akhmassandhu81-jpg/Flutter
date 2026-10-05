package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.adapters.CartAdapter;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.android.material.button.MaterialButton;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class CartActivity extends AppCompatActivity implements CartAdapter.Listener {

    private ImageButton btnBack;
    private ImageButton btnDeleteAll;
    private ProgressBar progress;
    private TextView tvEmpty;
    private RecyclerView recycler;
    private TextView tvTotalItems;
    private TextView tvTotal;
    private MaterialButton btnCheckout;
    
    private CartAdapter adapter;
    private DatabaseReference cartRef;
    private ValueEventListener cartListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_cart);

        btnBack = findViewById(R.id.btnBack);
        btnDeleteAll = findViewById(R.id.btnDeleteAll);
        progress = findViewById(R.id.progress);
        tvEmpty = findViewById(R.id.tvEmpty);
        recycler = findViewById(R.id.recycler);
        tvTotalItems = findViewById(R.id.tvTotalItems);
        tvTotal = findViewById(R.id.tvTotal);
        btnCheckout = findViewById(R.id.btnCheckout);

        adapter = new CartAdapter(this, this);
        recycler.setLayoutManager(new LinearLayoutManager(this));
        recycler.setHasFixedSize(true);
        recycler.setAdapter(adapter);

        btnBack.setOnClickListener(v -> finish());
        btnDeleteAll.setOnClickListener(v -> clearCart());
        btnCheckout.setOnClickListener(v -> {
            if (adapter.getItemCount() == 0) {
                Toast.makeText(CartActivity.this, "Your cart is empty", Toast.LENGTH_SHORT).show();
                return;
            }
            startActivity(new Intent(CartActivity.this, CheckoutActivity.class));
        });

        FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
        if (user == null) {
            Toast.makeText(this, "Please login first", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        cartRef = FirebaseUtil.cartsRef().child(user.getUid());
        loadCart();
    }

    private void loadCart() {
        progress.setVisibility(View.VISIBLE);
        cartListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<CartItem> list = new ArrayList<>();
                double total = 0;

                for (DataSnapshot s : snapshot.getChildren()) {
                    CartItem item = s.getValue(CartItem.class);
                    if (item != null) {
                        // Set productId from snapshot key since it's the cart item key
                        if (item.getProductId() == null) {
                            item.setProductId(s.getKey());
                        }
                        list.add(item);
                        total += (item.getPrice() * item.getQuantity());
                    }
                }

                progress.setVisibility(View.GONE);
                adapter.submit(list);
                tvEmpty.setVisibility(list.isEmpty() ? View.VISIBLE : View.GONE);
                tvTotalItems.setText("Total (" + list.size() + " items)");
                tvTotal.setText(String.format("₹%,.0f", total));
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                progress.setVisibility(View.GONE);
                Toast.makeText(CartActivity.this, "Error loading cart: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        };
        cartRef.addValueEventListener(cartListener);
    }

    @Override
    public void onIncrease(CartItem item) {
        // Stock validation: read product quantity then increase cart quantity if allowed
        FirebaseUtil.productsRef().child(item.getProductId()).child("quantity")
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        Integer available = snapshot.getValue(Integer.class);
                        if (available == null) available = 0;

                        if (item.getQuantity() >= available) {
                            Toast.makeText(CartActivity.this, "Cannot add more, stock limit reached", Toast.LENGTH_SHORT).show();
                            return;
                        }

                        cartRef.child(item.getProductId()).child("quantity")
                                .setValue(item.getQuantity() + 1);
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                    }
                });
    }

    @Override
    public void onDecrease(CartItem item) {
        int newQty = item.getQuantity() - 1;
        if (newQty <= 0) {
            cartRef.child(item.getProductId()).removeValue();
        } else {
            cartRef.child(item.getProductId()).child("quantity").setValue(newQty);
        }
    }

    @Override
    public void onRemove(CartItem item) {
        cartRef.child(item.getProductId()).removeValue();
    }

    @Override
    public void onSelectChanged(CartItem item, boolean isSelected) {
        // Not used in basic version
    }

    private void clearCart() {
        cartRef.removeValue()
            .addOnSuccessListener(aVoid -> Toast.makeText(this, "Cart cleared", Toast.LENGTH_SHORT).show())
            .addOnFailureListener(e -> Toast.makeText(this, "Failed to clear cart", Toast.LENGTH_SHORT).show());
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (cartRef != null && cartListener != null) {
            cartRef.removeEventListener(cartListener);
        }
    }
}
