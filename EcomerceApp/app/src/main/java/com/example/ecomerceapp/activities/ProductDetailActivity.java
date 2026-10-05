package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.bumptech.glide.Glide;
import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.example.ecomerceapp.utils.PriceFormatter;
import com.google.android.material.button.MaterialButton;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;


public class ProductDetailActivity extends AppCompatActivity {

    private ImageButton btnBack;
    private ImageButton btnFavorite;
    private ProgressBar progress;
    private ImageView ivProductImage;
    private TextView tvProductName;
    private TextView tvRating;
    private TextView tvCategory;
    private TextView tvDescription;
    private View colorSelectionContainer;
    private View colorTeal;
    private View colorBlack;
    private View colorRed;
    private ImageButton btnMinus;
    private TextView tvQuantity;
    private ImageButton btnPlus;
    private MaterialButton btnAddToCart;
    
    private Product product;
    private int selectedQuantity = 1;
    private String selectedColor = "teal";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_product_detail);

        btnBack = findViewById(R.id.btnBack);
        btnFavorite = findViewById(R.id.btnFavorite);
        progress = findViewById(R.id.progress);
        ivProductImage = findViewById(R.id.ivProductImage);
        tvProductName = findViewById(R.id.tvProductName);
        tvRating = findViewById(R.id.tvRating);
        tvCategory = findViewById(R.id.tvCategory);
        tvDescription = findViewById(R.id.tvDescription);
        colorSelectionContainer = findViewById(R.id.colorSelectionContainer);
        colorTeal = findViewById(R.id.colorTeal);
        colorBlack = findViewById(R.id.colorBlack);
        colorRed = findViewById(R.id.colorRed);
        btnMinus = findViewById(R.id.btnMinus);
        tvQuantity = findViewById(R.id.tvQuantity);
        btnPlus = findViewById(R.id.btnPlus);
        btnAddToCart = findViewById(R.id.btnAddToCart);

        String productId = getIntent().getStringExtra("productId");
        if (TextUtils.isEmpty(productId)) {
            Toast.makeText(this, "Product not found", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        loadProduct(productId);
        setupClickListeners();
    }

    private void loadProduct(String productId) {
        progress.setVisibility(View.VISIBLE);
        
        FirebaseUtil.productsRef().child(productId)
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        progress.setVisibility(View.GONE);
                        product = snapshot.getValue(Product.class);
                        if (product == null) {
                            Toast.makeText(ProductDetailActivity.this, "Product not found", Toast.LENGTH_SHORT).show();
                            finish();
                            return;
                        }
                        displayProduct();
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        progress.setVisibility(View.GONE);
                        Toast.makeText(ProductDetailActivity.this, "Error loading product", Toast.LENGTH_SHORT).show();
                    }
                });
    }

    private void displayProduct() {
        // Product name
        tvProductName.setText(product.getName());

        // Category
        if (product.getCategory() != null) {
            tvCategory.setText(product.getCategory());
            
            // Hide color selection for Food category
            if ("Food".equalsIgnoreCase(product.getCategory())) {
                colorSelectionContainer.setVisibility(View.GONE);
            } else {
                colorSelectionContainer.setVisibility(View.VISIBLE);
            }
        }

        // Product image
        if (!TextUtils.isEmpty(product.getImageUrl())) {
            Glide.with(this)
                    .load(product.getImageUrl())
                    .placeholder(R.drawable.ic_launcher_background)
                    .centerCrop()
                    .into(ivProductImage);
        }

        // Price - update button text
        updateTotalPrice();

        // Stock
        if (product.getQuantity() <= 0) {
            btnAddToCart.setEnabled(false);
            btnAddToCart.setText("Out of stock");
        }

        // Description (show product-specific description with null safety)
        if (!TextUtils.isEmpty(product.getDescription())) {
            tvDescription.setText(product.getDescription());
            tvDescription.setVisibility(View.VISIBLE);
        } else {
            tvDescription.setText("No description available");
            tvDescription.setVisibility(View.VISIBLE);
        }
    }

    private void setupClickListeners() {
        // Back button
        btnBack.setOnClickListener(v -> finish());

        // Favorite button
        btnFavorite.setOnClickListener(v -> {
            Toast.makeText(this, "Added to favorites", Toast.LENGTH_SHORT).show();
        });

        // Quantity controls
        btnMinus.setOnClickListener(v -> {
            if (selectedQuantity > 1) {
                selectedQuantity--;
                tvQuantity.setText(String.valueOf(selectedQuantity));
                updateTotalPrice();
            }
        });

        btnPlus.setOnClickListener(v -> {
            if (product != null && selectedQuantity < product.getQuantity()) {
                selectedQuantity++;
                tvQuantity.setText(String.valueOf(selectedQuantity));
                updateTotalPrice();
            } else {
                Toast.makeText(this, "Cannot exceed available stock", Toast.LENGTH_SHORT).show();
            }
        });

        // Color selection - new colors
        colorTeal.setOnClickListener(v -> selectColor("teal", colorTeal));
        colorBlack.setOnClickListener(v -> selectColor("black", colorBlack));
        colorRed.setOnClickListener(v -> selectColor("red", colorRed));

        // Add to cart
        btnAddToCart.setOnClickListener(v -> addToCart());
    }

    private void selectColor(String color, View view) {
        selectedColor = color;
        
        // Reset all backgrounds
        colorTeal.setBackgroundResource(R.drawable.circle_teal);
        colorBlack.setBackgroundResource(R.drawable.circle_black);
        colorRed.setBackgroundResource(R.drawable.circle_red);
        
        // Add stroke/border to selected color
        // Create a drawable with stroke for selected state
        android.graphics.drawable.GradientDrawable drawable = new android.graphics.drawable.GradientDrawable();
        drawable.setShape(android.graphics.drawable.GradientDrawable.OVAL);
        
        int colorValue;
        switch (color) {
            case "teal":
                colorValue = 0xFF009688;
                break;
            case "black":
                colorValue = 0xFF000000;
                break;
            case "red":
                colorValue = 0xFFFF0000;
                break;
            default:
                colorValue = 0xFF009688;
        }
        
        drawable.setColor(colorValue);
        drawable.setStroke(3, 0xFF2D5A4A); // Dark green border for selected
        view.setBackground(drawable);
    }

    private void updateTotalPrice() {
        if (product != null) {
            double total = product.getPrice() * selectedQuantity;
            btnAddToCart.setText("Add to cart " + PriceFormatter.formatPrice(total));
        }
    }

    private void addToCart() {
        if (product == null) return;

        String userId = FirebaseUtil.auth().getCurrentUser().getUid();
        CartItem cartItem = new CartItem(product.getId(), product.getName(), product.getPrice(), selectedQuantity, product.getImageUrl());

        // Check current cart quantity
        FirebaseUtil.cartsRef().child(userId).child(product.getId())
                .addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot snapshot) {
                        int currentQty = 0;
                        if (snapshot.exists()) {
                            CartItem existing = snapshot.getValue(CartItem.class);
                            if (existing != null) currentQty = existing.getQuantity();
                        }

                        int newQty = currentQty + selectedQuantity;
                        if (newQty > product.getQuantity()) {
                            Toast.makeText(ProductDetailActivity.this, "Cannot add more, only " + product.getQuantity() + " available", Toast.LENGTH_LONG).show();
                            return;
                        }

                        cartItem.setQuantity(newQty);
                        FirebaseUtil.cartsRef().child(userId).child(product.getId()).setValue(cartItem)
                                .addOnCompleteListener(task -> {
                                    if (task.isSuccessful()) {
                                        Toast.makeText(ProductDetailActivity.this, "Added to cart!", Toast.LENGTH_SHORT).show();
                                    } else {
                                        Toast.makeText(ProductDetailActivity.this, "Failed to add to cart", Toast.LENGTH_SHORT).show();
                                    }
                                });
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError error) {
                        Toast.makeText(ProductDetailActivity.this, "Error checking cart", Toast.LENGTH_SHORT).show();
                    }
                });
    }
}
