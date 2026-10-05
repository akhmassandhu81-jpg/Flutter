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
import com.example.ecomerceapp.adapters.OrderHistoryAdapter;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.GenericTypeIndicator;
import com.google.firebase.database.Query;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class OrderHistoryActivity extends AppCompatActivity {

    private ImageButton btnBack;
    private RecyclerView recycler;
    private BottomNavigationView bottomNav;
    private TextView tvEmpty;
    private ProgressBar progress;
    private OrderHistoryAdapter adapter;
    private ValueEventListener ordersListener;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_order_history);

        btnBack = findViewById(R.id.btnBack);
        recycler = findViewById(R.id.recycler);
        bottomNav = findViewById(R.id.bottomNav);
        tvEmpty = findViewById(R.id.tvEmpty);
        progress = findViewById(R.id.progress);

        adapter = new OrderHistoryAdapter();
        recycler.setLayoutManager(new LinearLayoutManager(this));
        recycler.setHasFixedSize(true);
        recycler.setAdapter(adapter);

        btnBack.setOnClickListener(v -> finish());

        // Bottom Navigation - highlight Orders
        bottomNav.setSelectedItemId(R.id.nav_orders);
        bottomNav.setOnItemSelectedListener(item -> {
            int id = item.getItemId();
            if (id == R.id.nav_home) {
                startActivity(new Intent(this, UserHomeActivity.class));
                finish();
                return true;
            } else if (id == R.id.nav_cart) {
                startActivity(new Intent(this, CartActivity.class));
                finish();
                return true;
            } else if (id == R.id.nav_orders) {
                // Already on orders
                return true;
            } else if (id == R.id.nav_profile) {
                startActivity(new Intent(this, SettingsActivity.class));
                finish();
                return true;
            }
            return false;
        });

        FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
        if (user == null) {
            Toast.makeText(this, "Please login first", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        loadOrders(user.getUid());
    }

    private void loadOrders(String uid) {
        progress.setVisibility(View.VISIBLE);

        // Use limitToLast to get most recent orders, limit to 20 for performance
        Query q = FirebaseUtil.ordersRef().orderByChild("userId").equalTo(uid).limitToLast(20);
        ordersListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<Order> list = new ArrayList<>();

                for (DataSnapshot s : snapshot.getChildren()) {
                    Order order = new Order();
                    order.setOrderId(s.child("orderId").getValue(String.class));
                    if (order.getOrderId() == null) {
                        order.setOrderId(s.getKey());
                    }
                    order.setUserId(s.child("userId").getValue(String.class));
                    Double total = s.child("totalPrice").getValue(Double.class);
                    if (total == null) {
                        Long totalLong = s.child("totalPrice").getValue(Long.class);
                        if (totalLong != null) total = totalLong.doubleValue();
                    }
                    order.setTotalPrice(total != null ? total : 0);
                    order.setStatus(s.child("status").getValue(String.class));
                    Long ts = s.child("timestamp").getValue(Long.class);
                    order.setTimestamp(ts != null ? ts : 0);

                    GenericTypeIndicator<List<CartItem>> t = new GenericTypeIndicator<List<CartItem>>() {
                    };
                    List<CartItem> products = s.child("productList").getValue(t);
                    order.setProductList(products);

                    list.add(order);
                }

                progress.setVisibility(View.GONE);
                adapter.submit(list);
                tvEmpty.setVisibility(list.isEmpty() ? View.VISIBLE : View.GONE);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                progress.setVisibility(View.GONE);
            }
        };
        q.addListenerForSingleValueEvent(ordersListener);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (ordersListener != null) {
            FirebaseUtil.ordersRef().removeEventListener(ordersListener);
        }
    }
}
