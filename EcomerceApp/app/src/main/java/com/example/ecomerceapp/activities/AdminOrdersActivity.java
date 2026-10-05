package com.example.ecomerceapp.activities;

import android.os.Bundle;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.example.ecomerceapp.adapters.AdminOrderAdapter;
import com.example.ecomerceapp.databinding.ActivityAdminOrdersBinding;
import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class AdminOrdersActivity extends AppCompatActivity implements AdminOrderAdapter.Listener {

    private ActivityAdminOrdersBinding binding;
    private AdminOrderAdapter adapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAdminOrdersBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        adapter = new AdminOrderAdapter(this);
        binding.recycler.setLayoutManager(new LinearLayoutManager(this));
        binding.recycler.setAdapter(adapter);

        binding.btnBack.setOnClickListener(v -> finish());

        loadOrders();
    }

    private void loadOrders() {
        binding.progress.setVisibility(View.VISIBLE);
        FirebaseUtil.ordersRef().addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<Order> list = new ArrayList<>();
                for (DataSnapshot s : snapshot.getChildren()) {
                    Order o = s.getValue(Order.class);
                    if (o != null) {
                        if (o.getOrderId() == null) o.setOrderId(s.getKey());
                        list.add(o);
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
    public void onAccept(Order order) {
        if (order == null || order.getOrderId() == null) return;

        FirebaseUtil.ordersRef().child(order.getOrderId()).child("status").setValue("accepted");
    }
}
