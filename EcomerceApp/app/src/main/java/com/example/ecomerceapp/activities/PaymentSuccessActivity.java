package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;
import com.example.ecomerceapp.databinding.ActivityPaymentSuccessBinding;

public class PaymentSuccessActivity extends AppCompatActivity {

    private ActivityPaymentSuccessBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityPaymentSuccessBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        double totalAmount = getIntent().getDoubleExtra("totalAmount", 0);
        String paymentMethod = getIntent().getStringExtra("paymentMethod");

        binding.tvAmount.setText(String.format("₹%,.0f", totalAmount));
        binding.tvPaymentMethod.setText(paymentMethod);

        setupClickListeners();
    }

    private void setupClickListeners() {
        binding.btnContinueShopping.setOnClickListener(v -> {
            Intent intent = new Intent(PaymentSuccessActivity.this, UserHomeActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
            startActivity(intent);
            finish();
        });

        binding.btnViewOrders.setOnClickListener(v -> {
            Intent intent = new Intent(PaymentSuccessActivity.this, OrderHistoryActivity.class);
            startActivity(intent);
            finish();
        });
    }
}
