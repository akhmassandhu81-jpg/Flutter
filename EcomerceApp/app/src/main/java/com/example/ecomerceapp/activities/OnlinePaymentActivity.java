package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.example.ecomerceapp.databinding.ActivityOnlinePaymentBinding;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.models.Transaction;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.example.ecomerceapp.utils.PriceFormatter;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class OnlinePaymentActivity extends AppCompatActivity {

    private ActivityOnlinePaymentBinding binding;
    private double totalAmount;
    private String userId;
    private String courierId;
    private String courierName;
    private double courierCharge;
    private String deliveryAddress;
    private String insuranceName;
    private double insurancePrice;
    private String paymentCompanyName;
    private DatabaseReference cartRef;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityOnlinePaymentBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        totalAmount = getIntent().getDoubleExtra("totalAmount", 0);
        userId = getIntent().getStringExtra("userId");
        courierId = getIntent().getStringExtra("courierId");
        courierName = getIntent().getStringExtra("courierName");
        courierCharge = getIntent().getDoubleExtra("courierCharge", 0);
        deliveryAddress = getIntent().getStringExtra("deliveryAddress");
        insuranceName = getIntent().getStringExtra("insuranceName");
        insurancePrice = getIntent().getDoubleExtra("insurancePrice", 0);
        paymentCompanyName = getIntent().getStringExtra("paymentCompanyName");
        binding.tvAmount.setText(PriceFormatter.formatPrice(totalAmount));

        FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
        if (user != null) {
            cartRef = FirebaseUtil.cartsRef().child(user.getUid());
        }

        setupClickListeners();
    }

    private void setupClickListeners() {
        binding.btnBack.setOnClickListener(v -> finish());

        // Payment method selection
        binding.btnBankAccount.setOnClickListener(v -> {
            binding.rbBankAccount.setChecked(true);
            binding.rbCreditCard.setChecked(false);
            binding.cardBankDetails.setVisibility(View.VISIBLE);
            binding.cardCardDetails.setVisibility(View.GONE);
        });

        binding.btnCreditCard.setOnClickListener(v -> {
            binding.rbCreditCard.setChecked(true);
            binding.rbBankAccount.setChecked(false);
            binding.cardCardDetails.setVisibility(View.VISIBLE);
            binding.cardBankDetails.setVisibility(View.GONE);
        });

        binding.rbBankAccount.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                binding.rbCreditCard.setChecked(false);
                binding.cardBankDetails.setVisibility(View.VISIBLE);
                binding.cardCardDetails.setVisibility(View.GONE);
            }
        });

        binding.rbCreditCard.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                binding.rbBankAccount.setChecked(false);
                binding.cardCardDetails.setVisibility(View.VISIBLE);
                binding.cardBankDetails.setVisibility(View.GONE);
            }
        });

        binding.btnPayNow.setOnClickListener(v -> processPayment());
    }

    private void processPayment() {
        // Validate inputs based on selected payment method
        if (binding.rbBankAccount.isChecked()) {
            String accountHolder = binding.etAccountHolder.getText().toString().trim();
            String accountNumber = binding.etAccountNumber.getText().toString().trim();
            String ifsc = binding.etIFSC.getText().toString().trim();
            String bankName = binding.etBankName.getText().toString().trim();

            if (accountHolder.isEmpty() || accountNumber.isEmpty() || ifsc.isEmpty() || bankName.isEmpty()) {
                Toast.makeText(this, "Please fill all bank details", Toast.LENGTH_SHORT).show();
                return;
            }
        } else if (binding.rbCreditCard.isChecked()) {
            String cardNumber = binding.etCardNumber.getText().toString().trim();
            String expiry = binding.etExpiry.getText().toString().trim();
            String cvv = binding.etCVV.getText().toString().trim();
            String cardHolder = binding.etCardHolder.getText().toString().trim();

            if (cardNumber.isEmpty() || expiry.isEmpty() || cvv.isEmpty() || cardHolder.isEmpty()) {
                Toast.makeText(this, "Please fill all card details", Toast.LENGTH_SHORT).show();
                return;
            }
        }

        // Show progress
        binding.progress.setVisibility(View.VISIBLE);
        binding.btnPayNow.setEnabled(false);

        // Simulate payment processing then place order
        new android.os.Handler().postDelayed(() -> {
            placeOrder();
        }, 2000);
    }

    private void placeOrder() {
        if (cartRef == null) {
            binding.progress.setVisibility(View.GONE);
            binding.btnPayNow.setEnabled(true);
            Toast.makeText(this, "Error: User not logged in", Toast.LENGTH_SHORT).show();
            return;
        }

        // Fetch user details first
        FirebaseUtil.usersRef().child(userId).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot userSnapshot) {
                String userName = userSnapshot.child("name").getValue(String.class);
                String userEmail = userSnapshot.child("email").getValue(String.class);
                String userPhone = userSnapshot.child("phone").getValue(String.class);

                // Now load cart and place order
                cartRef.addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        List<CartItem> items = new ArrayList<>();

                        for (DataSnapshot s : snapshot.getChildren()) {
                            CartItem item = s.getValue(CartItem.class);
                            if (item != null) {
                                items.add(item);
                            }
                        }

                        if (items.isEmpty()) {
                            binding.progress.setVisibility(View.GONE);
                            binding.btnPayNow.setEnabled(true);
                            Toast.makeText(OnlinePaymentActivity.this, "Cart is empty", Toast.LENGTH_SHORT).show();
                            return;
                        }

                        String orderId = FirebaseUtil.ordersRef().push().getKey();
                        if (orderId == null) {
                            binding.progress.setVisibility(View.GONE);
                            binding.btnPayNow.setEnabled(true);
                            Toast.makeText(OnlinePaymentActivity.this, "Failed to create order", Toast.LENGTH_SHORT).show();
                            return;
                        }

                        String paymentMethod = paymentCompanyName != null ? paymentCompanyName : 
                            (binding.rbBankAccount.isChecked() ? "Bank Account" : "Credit/Debit Card");
                        Order order = new Order(orderId, userId, userName, userEmail, userPhone, paymentMethod, items, totalAmount, "paid", System.currentTimeMillis(),
                                courierId, courierName, courierCharge, deliveryAddress, insuranceName, insurancePrice);

                        FirebaseUtil.ordersRef().child(orderId).setValue(order)
                                .addOnSuccessListener(unused -> {
                                    // Create transaction record
                                    String transactionId = FirebaseUtil.transactionsRef().push().getKey();
                                    if (transactionId != null) {
                                        Transaction transaction = new Transaction(
                                            transactionId,
                                            userId,
                                            orderId,
                                            totalAmount,
                                            paymentMethod,
                                            "success",
                                            System.currentTimeMillis()
                                        );
                                        FirebaseUtil.transactionsRef().child(transactionId).setValue(transaction);
                                    }
                                    
                                    cartRef.removeValue();
                                    binding.progress.setVisibility(View.GONE);
                                    binding.btnPayNow.setEnabled(true);

                                    // Navigate to payment success
                                    Intent intent = new Intent(OnlinePaymentActivity.this, PaymentSuccessActivity.class);
                                    intent.putExtra("totalAmount", totalAmount);
                                    intent.putExtra("paymentMethod", paymentMethod);
                                    startActivity(intent);
                                    finish();
                                })
                                .addOnFailureListener(e -> {
                                    binding.progress.setVisibility(View.GONE);
                                    binding.btnPayNow.setEnabled(true);
                                    Toast.makeText(OnlinePaymentActivity.this, "Failed: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                                });
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        binding.progress.setVisibility(View.GONE);
                        binding.btnPayNow.setEnabled(true);
                        Toast.makeText(OnlinePaymentActivity.this, "Failed: " + error.getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                binding.progress.setVisibility(View.GONE);
                binding.btnPayNow.setEnabled(true);
                Toast.makeText(OnlinePaymentActivity.this, "Failed to load user details: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }
}
