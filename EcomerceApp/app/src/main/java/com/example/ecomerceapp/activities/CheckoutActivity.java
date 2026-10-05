package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RadioButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.adapters.CourierAdapter;
import com.example.ecomerceapp.adapters.InsuranceAdapter;
import com.example.ecomerceapp.adapters.PaymentMethodAdapter;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.models.Courier;
import com.example.ecomerceapp.models.InsuranceCompany;
import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.models.PaymentCompany;
import com.example.ecomerceapp.models.Transaction;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.example.ecomerceapp.utils.PriceFormatter;
import com.google.android.material.card.MaterialCardView;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class CheckoutActivity extends AppCompatActivity {

    private ImageButton btnBack;
    private TextView tvItemCount;
    private TextView tvSubtotal;
    private TextView tvTotal;
    private TextView tvInsurance;
    private Button btnPlaceOrder;
    private ProgressBar progress;
    private RecyclerView recyclerCouriers;
    private RecyclerView recyclerPaymentMethods;
    private RecyclerView recyclerInsurance;
    private TextView tvNoCouriers;
    private TextView tvNoPaymentMethods;
    private TextView tvNoInsurance;
    private TextView tvShipping;
    private TextView tvAddress;
    private ImageButton btnEditAddress;
    private RadioButton rbCashOnDelivery;
    private LinearLayout btnCashOnDelivery;

    private DatabaseReference cartRef;
    private double totalAmount = 0;
    private double courierCharge = 0;
    private double subtotalAmount = 0;
    private double insurancePrice = 0;
    private List<CartItem> cartItems = new ArrayList<>();
    private CourierAdapter courierAdapter;
    private PaymentMethodAdapter paymentMethodAdapter;
    private InsuranceAdapter insuranceAdapter;
    private Courier selectedCourier = null;
    private PaymentCompany selectedPaymentMethod = null;
    private InsuranceCompany selectedInsurance = null;
    private String userAddress = "";
    private String userId;
    private boolean isCashOnDelivery = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_checkout);

        try {
            btnBack = findViewById(R.id.btnBack);
            tvItemCount = findViewById(R.id.tvItemCount);
            tvSubtotal = findViewById(R.id.tvSubtotal);
            tvTotal = findViewById(R.id.tvTotal);
            tvInsurance = findViewById(R.id.tvInsurance);
            btnPlaceOrder = findViewById(R.id.btnPlaceOrder);
            progress = findViewById(R.id.progress);
            recyclerCouriers = findViewById(R.id.recyclerCouriers);
            recyclerPaymentMethods = findViewById(R.id.recyclerPaymentMethods);
            recyclerInsurance = findViewById(R.id.recyclerInsurance);
            tvNoCouriers = findViewById(R.id.tvNoCouriers);
            tvNoPaymentMethods = findViewById(R.id.tvNoPaymentMethods);
            tvNoInsurance = findViewById(R.id.tvNoInsurance);
            tvShipping = findViewById(R.id.tvShipping);
            tvAddress = findViewById(R.id.tvAddress);
            btnEditAddress = findViewById(R.id.btnEditAddress);
            rbCashOnDelivery = findViewById(R.id.rbCashOnDelivery);
            btnCashOnDelivery = findViewById(R.id.btnCashOnDelivery);

            if (btnBack == null || tvItemCount == null || tvSubtotal == null ||
                tvTotal == null || tvInsurance == null || btnPlaceOrder == null || progress == null ||
                rbCashOnDelivery == null || btnCashOnDelivery == null ||
                recyclerPaymentMethods == null || recyclerInsurance == null ||
                tvNoPaymentMethods == null || tvNoInsurance == null ||
                tvShipping == null || tvAddress == null || btnEditAddress == null) {
                Toast.makeText(this, "Error initializing checkout", Toast.LENGTH_SHORT).show();
                finish();
                return;
            }

            btnBack.setOnClickListener(v -> finish());

            FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
            if (user == null) {
                Toast.makeText(this, "Please login first", Toast.LENGTH_SHORT).show();
                finish();
                return;
            }

            userId = user.getUid();
            cartRef = FirebaseUtil.cartsRef().child(userId);

            loadUserAddress();
            setupCourierList();
            setupPaymentMethodList();
            setupInsuranceList();
            setupCashOnDeliverySelection();
            loadTotal();
            btnPlaceOrder.setOnClickListener(v -> handlePlaceOrder(userId));
            btnEditAddress.setOnClickListener(v -> showAddressEditDialog());
        } catch (Exception e) {
            Toast.makeText(this, "Error: " + e.getMessage(), Toast.LENGTH_SHORT).show();
            finish();
        }
    }

    private void loadUserAddress() {
        FirebaseUtil.usersRef().child(userId).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                String address = snapshot.child("address").getValue(String.class);
                if (address != null && !address.isEmpty()) {
                    userAddress = address;
                    tvAddress.setText(address);
                } else {
                    tvAddress.setText("Add your delivery address");
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                // Keep default text
            }
        });
    }

    private void showAddressEditDialog() {
        android.app.AlertDialog.Builder builder = new android.app.AlertDialog.Builder(this);
        builder.setTitle("Edit Delivery Address");

        final EditText input = new EditText(this);
        input.setText(userAddress);
        input.setHint("Enter your full address");
        input.setMinLines(3);
        input.setMaxLines(5);
        builder.setView(input);

        builder.setPositiveButton("Save", (dialog, which) -> {
            String newAddress = input.getText().toString().trim();
            if (!newAddress.isEmpty()) {
                userAddress = newAddress;
                tvAddress.setText(newAddress);
                saveAddressToFirebase(newAddress);
            }
        });

        builder.setNegativeButton("Cancel", (dialog, which) -> dialog.cancel());

        builder.show();
    }

    private void saveAddressToFirebase(String address) {
        FirebaseUtil.usersRef().child(userId).child("address").setValue(address)
                .addOnSuccessListener(unused -> {
                    Toast.makeText(this, "Address saved", Toast.LENGTH_SHORT).show();
                })
                .addOnFailureListener(e -> {
                    Toast.makeText(this, "Failed to save address", Toast.LENGTH_SHORT).show();
                });
    }

    private void setupCourierList() {
        courierAdapter = new CourierAdapter(courier -> {
            selectedCourier = courier;
            courierCharge = courier.getDeliveryCharge();
            updateTotal();
        });
        recyclerCouriers.setLayoutManager(new LinearLayoutManager(this));
        recyclerCouriers.setAdapter(courierAdapter);

        FirebaseUtil.couriersRef().addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<Courier> activeCouriers = new ArrayList<>();
                for (DataSnapshot s : snapshot.getChildren()) {
                    Courier courier = s.getValue(Courier.class);
                    if (courier != null && courier.isActive()) {
                        courier.setId(s.getKey());
                        activeCouriers.add(courier);
                    }
                }

                if (activeCouriers.isEmpty()) {
                    recyclerCouriers.setVisibility(View.GONE);
                    tvNoCouriers.setVisibility(View.VISIBLE);
                } else {
                    recyclerCouriers.setVisibility(View.VISIBLE);
                    tvNoCouriers.setVisibility(View.GONE);
                    courierAdapter.submit(activeCouriers);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Toast.makeText(CheckoutActivity.this, "Error loading couriers: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void setupPaymentMethodList() {
        paymentMethodAdapter = new PaymentMethodAdapter(paymentCompany -> {
            selectedPaymentMethod = paymentCompany;
            isCashOnDelivery = false;
            rbCashOnDelivery.setChecked(false);
            btnCashOnDelivery.setBackgroundResource(R.drawable.payment_option_bg);
        });
        recyclerPaymentMethods.setLayoutManager(new LinearLayoutManager(this));
        recyclerPaymentMethods.setAdapter(paymentMethodAdapter);

        FirebaseUtil.paymentCompaniesRef().addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<PaymentCompany> activePaymentMethods = new ArrayList<>();
                for (DataSnapshot s : snapshot.getChildren()) {
                    PaymentCompany paymentCompany = s.getValue(PaymentCompany.class);
                    if (paymentCompany != null && paymentCompany.isActive() && "Payment".equals(paymentCompany.getType())) {
                        paymentCompany.setId(s.getKey());
                        activePaymentMethods.add(paymentCompany);
                    }
                }

                if (activePaymentMethods.isEmpty()) {
                    recyclerPaymentMethods.setVisibility(View.GONE);
                    tvNoPaymentMethods.setVisibility(View.VISIBLE);
                } else {
                    recyclerPaymentMethods.setVisibility(View.VISIBLE);
                    tvNoPaymentMethods.setVisibility(View.GONE);
                    paymentMethodAdapter.submit(activePaymentMethods);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Toast.makeText(CheckoutActivity.this, "Error loading payment methods: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void setupCashOnDeliverySelection() {
        btnCashOnDelivery.setOnClickListener(v -> {
            isCashOnDelivery = true;
            selectedPaymentMethod = null;
            rbCashOnDelivery.setChecked(true);
            btnCashOnDelivery.setBackgroundResource(R.drawable.payment_option_selected_bg);
            paymentMethodAdapter.setSelectedPaymentId(null);
        });

        rbCashOnDelivery.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                isCashOnDelivery = true;
                selectedPaymentMethod = null;
                btnCashOnDelivery.setBackgroundResource(R.drawable.payment_option_selected_bg);
                paymentMethodAdapter.setSelectedPaymentId(null);
            } else {
                isCashOnDelivery = false;
                btnCashOnDelivery.setBackgroundResource(R.drawable.payment_option_bg);
            }
        });
    }

    private void setupInsuranceList() {
        insuranceAdapter = new InsuranceAdapter(insuranceCompany -> {
            selectedInsurance = insuranceCompany;
            insurancePrice = insuranceCompany != null ? insuranceCompany.getPrice() : 0;
            updateTotal();
        });
        recyclerInsurance.setLayoutManager(new LinearLayoutManager(this));
        recyclerInsurance.setAdapter(insuranceAdapter);

        FirebaseUtil.insuranceCompaniesRef().addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<InsuranceCompany> activeInsuranceOptions = new ArrayList<>();
                for (DataSnapshot s : snapshot.getChildren()) {
                    InsuranceCompany insuranceCompany = s.getValue(InsuranceCompany.class);
                    if (insuranceCompany != null && insuranceCompany.isActive()) {
                        insuranceCompany.setId(s.getKey());
                        activeInsuranceOptions.add(insuranceCompany);
                    }
                }

                if (activeInsuranceOptions.isEmpty()) {
                    recyclerInsurance.setVisibility(View.GONE);
                    tvNoInsurance.setVisibility(View.VISIBLE);
                } else {
                    recyclerInsurance.setVisibility(View.VISIBLE);
                    tvNoInsurance.setVisibility(View.GONE);
                    insuranceAdapter.submit(activeInsuranceOptions);
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                Toast.makeText(CheckoutActivity.this, "Error loading insurance options: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void loadTotal() {
        if (progress == null || cartRef == null) {
            Toast.makeText(this, "Error loading cart", Toast.LENGTH_SHORT).show();
            return;
        }

        progress.setVisibility(View.VISIBLE);
        cartRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                progress.setVisibility(View.GONE);

                try {
                    double total = 0;
                    int itemCount = 0;
                    cartItems.clear();
                    for (DataSnapshot s : snapshot.getChildren()) {
                        CartItem item = s.getValue(CartItem.class);
                        if (item != null) {
                            total += item.getPrice() * item.getQuantity();
                            itemCount += item.getQuantity();
                            cartItems.add(item);
                        }
                    }

                    subtotalAmount = total;
                    if (tvItemCount != null) {
                        tvItemCount.setText(itemCount + " items");
                    }
                    if (tvSubtotal != null) {
                        tvSubtotal.setText(PriceFormatter.formatPrice(subtotalAmount));
                    }
                    updateTotal();

                    if (itemCount == 0) {
                        Toast.makeText(CheckoutActivity.this, "Your cart is empty", Toast.LENGTH_SHORT).show();
                    }
                } catch (Exception e) {
                    Toast.makeText(CheckoutActivity.this, "Error loading cart: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                progress.setVisibility(View.GONE);
                Toast.makeText(CheckoutActivity.this, "Error: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void updateTotal() {
        totalAmount = subtotalAmount + courierCharge + insurancePrice;
        if (tvTotal != null) {
            tvTotal.setText(PriceFormatter.formatPrice(totalAmount));
        }
        if (tvShipping != null) {
            if (courierCharge > 0) {
                tvShipping.setText(PriceFormatter.formatPrice(courierCharge));
            } else {
                tvShipping.setText("Free");
            }
        }
        if (tvInsurance != null) {
            if (insurancePrice > 0) {
                tvInsurance.setText(PriceFormatter.formatPrice(insurancePrice));
            } else {
                tvInsurance.setText("Rs 0");
            }
        }
    }

    private void placeOrder(String userId) {
        if (cartRef == null) {
            Toast.makeText(this, "Error: Cart reference not found", Toast.LENGTH_SHORT).show();
            return;
        }

        setLoading(true);
        
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
                        try {
                            List<CartItem> items = new ArrayList<>();
                            double total = 0;

                            for (DataSnapshot s : snapshot.getChildren()) {
                                CartItem item = s.getValue(CartItem.class);
                                if (item != null) {
                                    items.add(item);
                                    total += item.getPrice() * item.getQuantity();
                                }
                            }

                            if (items.isEmpty()) {
                                setLoading(false);
                                Toast.makeText(CheckoutActivity.this, "Cart is empty", Toast.LENGTH_SHORT).show();
                                return;
                            }

                            String orderId = FirebaseUtil.ordersRef().push().getKey();
                            if (orderId == null) {
                                setLoading(false);
                                Toast.makeText(CheckoutActivity.this, "Failed to create order", Toast.LENGTH_SHORT).show();
                                return;
                            }

                            final double finalTotal = total;
                            Order order = new Order(orderId, userId, userName, userEmail, userPhone, "Cash on Delivery", items, total, "pending", System.currentTimeMillis(),
                                    selectedCourier.getId(), selectedCourier.getName(), selectedCourier.getDeliveryCharge(), userAddress,
                                    selectedInsurance != null ? selectedInsurance.getName() : null,
                                    selectedInsurance != null ? selectedInsurance.getPrice() : 0);

                            FirebaseUtil.ordersRef().child(orderId).setValue(order)
                                    .addOnSuccessListener(unused -> {
                                        // Update sold count for each product
                                        updateProductSoldCount(items);
                                        
                                        // Create transaction record
                                        String transactionId = FirebaseUtil.transactionsRef().push().getKey();
                                        if (transactionId != null) {
                                            Transaction transaction = new Transaction(
                                                transactionId,
                                                userId,
                                                orderId,
                                                finalTotal,
                                                "Cash on Delivery",
                                                "success",
                                                System.currentTimeMillis()
                                            );
                                            FirebaseUtil.transactionsRef().child(transactionId).setValue(transaction);
                                        }
                                        
                                        if (cartRef != null) {
                                            cartRef.removeValue();
                                        }
                                        setLoading(false);
                                        Toast.makeText(CheckoutActivity.this, "Order placed successfully!", Toast.LENGTH_SHORT).show();
                                        finish();
                                    })
                                    .addOnFailureListener(e -> {
                                        setLoading(false);
                                        Toast.makeText(CheckoutActivity.this, "Failed: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                                    });
                        } catch (Exception e) {
                            setLoading(false);
                            Toast.makeText(CheckoutActivity.this, "Error: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                        }
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        setLoading(false);
                        Toast.makeText(CheckoutActivity.this, "Failed: " + error.getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                setLoading(false);
                Toast.makeText(CheckoutActivity.this, "Failed to load user details: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void handlePlaceOrder(String userId) {
        if (userId == null || userId.isEmpty()) {
            Toast.makeText(this, "User not logged in", Toast.LENGTH_SHORT).show();
            return;
        }

        // Validate courier selection
        if (selectedCourier == null) {
            Toast.makeText(this, "Please select a delivery courier", Toast.LENGTH_SHORT).show();
            return;
        }

        // Validate address
        if (userAddress == null || userAddress.isEmpty()) {
            Toast.makeText(this, "Please add your delivery address", Toast.LENGTH_SHORT).show();
            return;
        }

        // Validate payment method selection (either Cash on Delivery or online payment)
        if (!isCashOnDelivery && selectedPaymentMethod == null) {
            Toast.makeText(this, "Please select a payment method", Toast.LENGTH_SHORT).show();
            return;
        }

        // Check if Cash on Delivery is selected
        if (isCashOnDelivery) {
            // Place order directly with Cash on Delivery
            placeOrder(userId);
        } else {
            // Navigate to Online Payment
            Intent intent = new Intent(CheckoutActivity.this, OnlinePaymentActivity.class);
            intent.putExtra("totalAmount", totalAmount);
            intent.putExtra("userId", userId);
            intent.putExtra("courierId", selectedCourier.getId());
            intent.putExtra("courierName", selectedCourier.getName());
            intent.putExtra("courierCharge", selectedCourier.getDeliveryCharge());
            intent.putExtra("deliveryAddress", userAddress);
            intent.putExtra("insuranceName", selectedInsurance != null ? selectedInsurance.getName() : null);
            intent.putExtra("insurancePrice", selectedInsurance != null ? selectedInsurance.getPrice() : 0);
            intent.putExtra("paymentCompanyName", selectedPaymentMethod.getName());
            startActivity(intent);
        }
    }

    private void setLoading(boolean loading) {
        if (progress != null) {
            progress.setVisibility(loading ? View.VISIBLE : View.GONE);
        }
        if (btnPlaceOrder != null) {
            btnPlaceOrder.setEnabled(!loading);
        }
    }

    private void updateProductSoldCount(List<CartItem> items) {
        for (CartItem item : items) {
            if (item.getProductId() != null) {
                FirebaseUtil.productsRef().child(item.getProductId()).child("sold")
                        .addListenerForSingleValueEvent(new ValueEventListener() {
                            @Override
                            public void onDataChange(@NonNull DataSnapshot snapshot) {
                                Integer currentSold = snapshot.getValue(Integer.class);
                                int newSold = (currentSold != null ? currentSold : 0) + item.getQuantity();
                                FirebaseUtil.productsRef().child(item.getProductId()).child("sold").setValue(newSold);
                            }

                            @Override
                            public void onCancelled(@NonNull DatabaseError error) {
                                // Ignore errors in sold count update
                            }
                        });
            }
        }
    }
}
