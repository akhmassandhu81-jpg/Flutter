package com.example.ecomerceapp.activities;

import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.Button;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class DummyPaymentActivity extends AppCompatActivity {

    private double totalAmount;
    private List<CartItem> cartItems;
    private String userId;
    private String courierId;
    private String courierName;
    private double courierCharge;
    private String deliveryAddress;

    private ProgressBar progressBar;
    private TextView tvAmount;
    private Button btnPay;
    private Button btnCancel;

    private DatabaseReference cartRef;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_dummy_payment);

        // Get data from intent
        totalAmount = getIntent().getDoubleExtra("totalAmount", 0);
        cartItems = (ArrayList<CartItem>) getIntent().getSerializableExtra("cartItems");
        userId = getIntent().getStringExtra("userId");
        courierId = getIntent().getStringExtra("courierId");
        courierName = getIntent().getStringExtra("courierName");
        courierCharge = getIntent().getDoubleExtra("courierCharge", 0);
        deliveryAddress = getIntent().getStringExtra("deliveryAddress");

        if (totalAmount <= 0) {
            Toast.makeText(this, "Invalid amount", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        if (cartItems == null || cartItems.isEmpty()) {
            Toast.makeText(this, "Cart is empty", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        if (userId == null || userId.isEmpty()) {
            Toast.makeText(this, "User not logged in", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        // Initialize views
        progressBar = findViewById(R.id.progressBar);
        tvAmount = findViewById(R.id.tvAmount);
        btnPay = findViewById(R.id.btnPay);
        btnCancel = findViewById(R.id.btnCancel);

        if (progressBar == null || tvAmount == null || btnPay == null || btnCancel == null) {
            Toast.makeText(this, "Failed to initialize views", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        tvAmount.setText(String.format("₹%,.0f", totalAmount));

        // Set up buttons
        btnPay.setOnClickListener(v -> processPayment());
        btnCancel.setOnClickListener(v -> finish());

        // Get cart reference
        FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
        if (user != null) {
            cartRef = FirebaseUtil.cartsRef().child(user.getUid());
        }
    }

    private void processPayment() {
        progressBar.setVisibility(View.VISIBLE);
        btnPay.setEnabled(false);

        // Simulate payment processing with delay
        new Handler().postDelayed(() -> {
            // Payment successful (dummy)
            createOrderAfterPayment();
        }, 2000); // 2 second delay to simulate processing
    }

    private void createOrderAfterPayment() {
        // Fetch user details first
        FirebaseUtil.usersRef().child(userId).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot userSnapshot) {
                String userName = userSnapshot.child("name").getValue(String.class);
                String userEmail = userSnapshot.child("email").getValue(String.class);
                String userPhone = userSnapshot.child("phone").getValue(String.class);

                String orderId = FirebaseUtil.ordersRef().push().getKey();
                if (orderId == null) {
                    progressBar.setVisibility(View.GONE);
                    btnPay.setEnabled(true);
                    Toast.makeText(DummyPaymentActivity.this, "Failed to create order", Toast.LENGTH_SHORT).show();
                    return;
                }

                Order order = new Order(orderId, userId, userName, userEmail, userPhone, "Online Payment", cartItems, totalAmount, "paid", System.currentTimeMillis(),
                        courierId, courierName, courierCharge, deliveryAddress);

                FirebaseUtil.ordersRef().child(orderId).setValue(order)
                        .addOnSuccessListener(unused -> {
                            if (cartRef != null) {
                                cartRef.removeValue();
                            }
                            progressBar.setVisibility(View.GONE);
                            Toast.makeText(DummyPaymentActivity.this, "Payment successful! Order placed.", Toast.LENGTH_SHORT).show();
                            finish();
                        })
                        .addOnFailureListener(e -> {
                            progressBar.setVisibility(View.GONE);
                            btnPay.setEnabled(true);
                            Toast.makeText(DummyPaymentActivity.this, "Failed to save order: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                        });
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                progressBar.setVisibility(View.GONE);
                btnPay.setEnabled(true);
                Toast.makeText(DummyPaymentActivity.this, "Failed to load user details: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }
}
