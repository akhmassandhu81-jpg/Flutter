package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.List;

public class ModeratorDashboardActivity extends AppCompatActivity {

    private RecyclerView recyclerPending;
    private ProgressBar progress;
    private TextView tvEmpty;
    private TextView tvPendingCount;
    private TextView tvApprovedCount;
    private TextView tvTotalCount;
    private Button btnLogout;
    private View btnProductReview;
    private TextView tabPending;
    private TextView tabApproved;
    private TextView tabOrders;
    
    private PendingProductAdapter adapter;
    private List<Product> pendingProducts = new ArrayList<>();
    private List<Product> approvedProducts = new ArrayList<>();
    private String moderatorId;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            setContentView(R.layout.activity_moderator_dashboard);
        } catch (Exception e) {
            android.util.Log.e("ModeratorDashboard", "Error inflating layout: " + e.getMessage());
            Toast.makeText(this, "Error loading dashboard", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        try {
            recyclerPending = findViewById(R.id.recyclerPending);
            progress = findViewById(R.id.progress);
            tvEmpty = findViewById(R.id.tvEmpty);
            tvPendingCount = findViewById(R.id.tvPendingCount);
            tvApprovedCount = findViewById(R.id.tvApprovedCount);
            tvTotalCount = findViewById(R.id.tvTotalCount);
            btnLogout = findViewById(R.id.btnLogout);
            btnProductReview = findViewById(R.id.btnProductReview);
            tabPending = findViewById(R.id.tabPending);
            tabApproved = findViewById(R.id.tabApproved);
            tabOrders = findViewById(R.id.tabOrders);

            if (recyclerPending == null || progress == null || tvEmpty == null ||
                tvPendingCount == null || tvApprovedCount == null || tvTotalCount == null ||
                btnLogout == null || btnProductReview == null || tabPending == null || tabApproved == null || tabOrders == null) {
                Toast.makeText(this, "Error initializing dashboard UI", Toast.LENGTH_SHORT).show();
                finish();
                return;
            }
        } catch (Exception e) {
            android.util.Log.e("ModeratorDashboard", "Error finding views: " + e.getMessage());
            Toast.makeText(this, "Error initializing dashboard", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
        if (user == null) {
            Toast.makeText(this, "Please login first", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }
        moderatorId = user.getUid();

        setupRecyclerView();
        setupClickListeners();
        loadProducts();
    }

    private void setupRecyclerView() {
        adapter = new PendingProductAdapter(pendingProducts, this::onApproveProduct, this::onRejectProduct, this);
        recyclerPending.setLayoutManager(new LinearLayoutManager(this));
        recyclerPending.setAdapter(adapter);
    }

    private void setupClickListeners() {
        btnProductReview.setOnClickListener(v -> {
            startActivity(new Intent(this, ModeratorProductReviewActivity.class));
        });

        btnLogout.setOnClickListener(v -> {
            FirebaseUtil.auth().signOut();
            startActivity(new Intent(this, LoginActivity.class));
            finish();
        });

        tabPending.setOnClickListener(v -> {
            showPendingProducts();
            updateTabBackgrounds(0);
        });

        tabApproved.setOnClickListener(v -> {
            showApprovedProducts();
            updateTabBackgrounds(1);
        });

        tabOrders.setOnClickListener(v -> {
            startActivity(new Intent(this, ModeratorOrdersActivity.class));
        });
    }

    private void updateTabBackgrounds(int selectedIndex) {
        tabPending.setBackgroundResource(selectedIndex == 0 ? R.drawable.tab_selected_bg : R.drawable.tab_unselected_bg);
        tabPending.setTextColor(selectedIndex == 0 ? 0xFF059669 : 0xFF6B7280);

        tabApproved.setBackgroundResource(selectedIndex == 1 ? R.drawable.tab_selected_bg : R.drawable.tab_unselected_bg);
        tabApproved.setTextColor(selectedIndex == 1 ? 0xFF059669 : 0xFF6B7280);
    }

    private void loadProducts() {
        progress.setVisibility(View.VISIBLE);
        FirebaseUtil.productsRef().addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                pendingProducts.clear();
                approvedProducts.clear();
                
                Toast.makeText(ModeratorDashboardActivity.this, "Loading " + snapshot.getChildrenCount() + " products", Toast.LENGTH_SHORT).show();
                
                for (DataSnapshot data : snapshot.getChildren()) {
                    Product product = data.getValue(Product.class);
                    if (product != null) {
                        if (product.getId() == null) product.setId(data.getKey());
                        // Show ALL pending products for moderator to review quality
                        // Show ALL approved products to track what has been approved
                        // Treat null/empty status as pending (needs review)
                        String status = product.getStatus();
                        if ("approved".equals(status)) {
                            approvedProducts.add(product);
                        } else if ("rejected".equals(status)) {
                            // Skip rejected products
                        } else {
                            // pending or null
                            pendingProducts.add(product);
                        }
                    }
                }
                
                progress.setVisibility(View.GONE);
                updateStats();
                showPendingProducts();
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                progress.setVisibility(View.GONE);
                Toast.makeText(ModeratorDashboardActivity.this, "Error loading products: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void updateStats() {
        tvPendingCount.setText(String.valueOf(pendingProducts.size()));
        tvApprovedCount.setText(String.valueOf(approvedProducts.size()));
        tvTotalCount.setText(String.valueOf(pendingProducts.size() + approvedProducts.size()));
    }

    private void showPendingProducts() {
        adapter.updateList(pendingProducts);
        tvEmpty.setVisibility(pendingProducts.isEmpty() ? View.VISIBLE : View.GONE);
        recyclerPending.setVisibility(View.VISIBLE);
    }

    private void showApprovedProducts() {
        adapter.updateList(approvedProducts);
        tvEmpty.setVisibility(approvedProducts.isEmpty() ? View.VISIBLE : View.GONE);
        recyclerPending.setVisibility(View.VISIBLE);
    }

    private void onApproveProduct(Product product) {
        // Set status to "approved" and moderatorId when approving
        FirebaseUtil.productsRef().child(product.getId()).child("status").setValue("approved");
        FirebaseUtil.productsRef().child(product.getId()).child("moderatorId").setValue(moderatorId)
            .addOnSuccessListener(aVoid -> Toast.makeText(this, "Product approved successfully", Toast.LENGTH_SHORT).show())
            .addOnFailureListener(e -> Toast.makeText(this, "Failed to approve: " + e.getMessage(), Toast.LENGTH_SHORT).show());
    }

    private void onRejectProduct(Product product) {
        new AlertDialog.Builder(this)
            .setTitle("Reject Product")
            .setMessage("Are you sure you want to reject " + product.getName() + "? This will mark it as rejected.")
            .setPositiveButton("Reject", (dialog, which) -> {
                FirebaseUtil.productsRef().child(product.getId()).child("status").setValue("rejected")
                    .addOnSuccessListener(aVoid -> Toast.makeText(this, "Product rejected", Toast.LENGTH_SHORT).show())
                    .addOnFailureListener(e -> Toast.makeText(this, "Failed to reject: " + e.getMessage(), Toast.LENGTH_SHORT).show());
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private static class PendingProductAdapter extends androidx.recyclerview.widget.RecyclerView.Adapter<PendingProductAdapter.ViewHolder> {
        private List<Product> list;
        private final java.util.function.Consumer<Product> onApprove;
        private final java.util.function.Consumer<Product> onReject;
        private final ModeratorDashboardActivity activity;

        PendingProductAdapter(List<Product> list, java.util.function.Consumer<Product> onApprove, 
                             java.util.function.Consumer<Product> onReject, ModeratorDashboardActivity activity) {
            this.list = list;
            this.onApprove = onApprove;
            this.onReject = onReject;
            this.activity = activity;
        }

        void updateList(List<Product> newList) {
            this.list = newList;
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull android.view.ViewGroup parent, int viewType) {
            android.view.View view = android.view.LayoutInflater.from(parent.getContext())
                .inflate(R.layout.row_moderator_product, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            Product product = list.get(position);
            holder.tvName.setText(product.getName());
            holder.tvPrice.setText("₹" + product.getPrice());
            holder.tvQuantity.setText("Qty: " + product.getQuantity());
            holder.tvCategory.setText(product.getCategory() != null ? product.getCategory() : "Uncategorized");

            // Vendor information
            String vendorName = product.getVendorName() != null ? product.getVendorName() : "Unknown Vendor";
            String vendorId = product.getVendorId() != null ? product.getVendorId() : "---";
            holder.tvVendorName.setText(vendorName);
            holder.tvVendorId.setText("ID: " + (vendorId.length() > 8 ? vendorId.substring(0, 8) + "..." : vendorId));

            Glide.with(activity)
                .load(product.getImageUrl())
                .centerCrop()
                .into(holder.ivImage);

            holder.btnApprove.setOnClickListener(v -> {
                new AlertDialog.Builder(activity)
                    .setTitle("Approve Product")
                    .setMessage("Approve " + product.getName() + " for sale?")
                    .setPositiveButton("Approve", (dialog, which) -> onApprove.accept(product))
                    .setNegativeButton("Cancel", null)
                    .show();
            });

            holder.btnReject.setOnClickListener(v -> onReject.accept(product));
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        static class ViewHolder extends androidx.recyclerview.widget.RecyclerView.ViewHolder {
            ImageView ivImage;
            TextView tvName;
            TextView tvPrice;
            TextView tvQuantity;
            TextView tvCategory;
            TextView tvVendorName;
            TextView tvVendorId;
            Button btnApprove;
            Button btnReject;

            ViewHolder(android.view.View itemView) {
                super(itemView);
                ivImage = itemView.findViewById(R.id.ivImage);
                tvName = itemView.findViewById(R.id.tvName);
                tvPrice = itemView.findViewById(R.id.tvPrice);
                tvQuantity = itemView.findViewById(R.id.tvQuantity);
                tvCategory = itemView.findViewById(R.id.tvCategory);
                tvVendorName = itemView.findViewById(R.id.tvVendorName);
                tvVendorId = itemView.findViewById(R.id.tvVendorId);
                btnApprove = itemView.findViewById(R.id.btnApprove);
                btnReject = itemView.findViewById(R.id.btnReject);
            }
        }
    }
}
