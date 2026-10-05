package com.example.ecomerceapp.activities;

import android.app.AlertDialog;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class ModeratorProductReviewActivity extends AppCompatActivity {

    private RecyclerView recyclerProducts;
    private ProductReviewAdapter adapter;
    private TextView tvEmpty;
    private ProgressBar progress;
    private TextView tabPending, tabApproved, tabRejected;
    private ImageButton btnBack;

    private List<Product> productList = new ArrayList<>();
    private String currentTab = "pending";
    private String moderatorName;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_moderator_product_review);

        btnBack = findViewById(R.id.btnBack);
        tabPending = findViewById(R.id.tabPending);
        tabApproved = findViewById(R.id.tabApproved);
        tabRejected = findViewById(R.id.tabRejected);
        recyclerProducts = findViewById(R.id.recyclerProducts);
        tvEmpty = findViewById(R.id.tvEmpty);
        progress = findViewById(R.id.progress);

        btnBack.setOnClickListener(v -> finish());

        setupRecyclerView();
        setupTabListeners();
        loadModeratorName();
        loadProducts();
    }

    private void setupRecyclerView() {
        adapter = new ProductReviewAdapter(productList, this::onApprove, this::onReject);
        recyclerProducts.setLayoutManager(new LinearLayoutManager(this));
        recyclerProducts.setAdapter(adapter);
    }

    private void setupTabListeners() {
        tabPending.setOnClickListener(v -> switchTab("pending"));
        tabApproved.setOnClickListener(v -> switchTab("approved"));
        tabRejected.setOnClickListener(v -> switchTab("rejected"));
    }

    private void switchTab(String tab) {
        currentTab = tab;
        updateTabUI();
        loadProducts();
    }

    private void updateTabUI() {
        // Reset all tabs
        tabPending.setTextColor(0xFF6B7280);
        tabPending.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_unselected_bg));
        tabApproved.setTextColor(0xFF6B7280);
        tabApproved.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_unselected_bg));
        tabRejected.setTextColor(0xFF6B7280);
        tabRejected.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_unselected_bg));

        // Highlight selected tab
        switch (currentTab) {
            case "pending":
                tabPending.setTextColor(0xFF059669);
                tabPending.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_selected_bg));
                break;
            case "approved":
                tabApproved.setTextColor(0xFF059669);
                tabApproved.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_selected_bg));
                break;
            case "rejected":
                tabRejected.setTextColor(0xFF059669);
                tabRejected.setBackgroundDrawable(getResources().getDrawable(R.drawable.tab_selected_bg));
                break;
        }
    }

    private void loadModeratorName() {
        if (FirebaseAuth.getInstance().getCurrentUser() != null) {
            String uid = FirebaseAuth.getInstance().getCurrentUser().getUid();
            FirebaseUtil.usersRef().child(uid).child("firstName").addListenerForSingleValueEvent(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot snapshot) {
                    moderatorName = snapshot.getValue(String.class);
                    if (moderatorName == null) moderatorName = "Moderator";
                }

                @Override
                public void onCancelled(@NonNull DatabaseError error) {
                    moderatorName = "Moderator";
                }
            });
        } else {
            moderatorName = "Moderator";
        }
    }

    private void loadProducts() {
        progress.setVisibility(View.VISIBLE);
        tvEmpty.setVisibility(View.GONE);

        FirebaseUtil.productsRef().addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                progress.setVisibility(View.GONE);
                productList.clear();

                for (DataSnapshot child : snapshot.getChildren()) {
                    Product product = child.getValue(Product.class);
                    if (product != null) {
                        product.setId(child.getKey());
                        // Filter by current tab
                        if (currentTab.equals(product.getStatus())) {
                            productList.add(product);
                        }
                    }
                }

                if (productList.isEmpty()) {
                    tvEmpty.setVisibility(View.VISIBLE);
                    tvEmpty.setText("No " + currentTab + " products found");
                } else {
                    tvEmpty.setVisibility(View.GONE);
                }

                adapter.notifyDataSetChanged();
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                progress.setVisibility(View.GONE);
                tvEmpty.setText("Error loading products: " + error.getMessage());
                tvEmpty.setVisibility(View.VISIBLE);
            }
        });
    }

    private void onApprove(Product product) {
        if (product == null) return;

        new AlertDialog.Builder(this)
                .setTitle("Approve Product")
                .setMessage("Are you sure you want to approve this product?")
                .setPositiveButton("Approve", (dialog, which) -> {
                    String approvedAt = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault()).format(new Date());
                    
                    FirebaseUtil.productsRef().child(product.getId()).child("status").setValue("approved");
                    FirebaseUtil.productsRef().child(product.getId()).child("approvedBy").setValue(moderatorName);
                    FirebaseUtil.productsRef().child(product.getId()).child("approvedAt").setValue(approvedAt)
                            .addOnSuccessListener(aVoid -> {
                                Toast.makeText(this, "Product approved successfully", Toast.LENGTH_SHORT).show();
                            })
                            .addOnFailureListener(e -> {
                                Toast.makeText(this, "Failed to approve: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                            });
                })
                .setNegativeButton("Cancel", null)
                .show();
    }

    private void onReject(Product product) {
        if (product == null) return;

        // Create dialog with reason input
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Reject Product");
        builder.setMessage("Please enter a reason for rejection");

        EditText etReason = new EditText(this);
        etReason.setHint("Rejection reason (required)");
        builder.setView(etReason);

        builder.setPositiveButton("Reject", (dialog, which) -> {
            String reason = etReason.getText().toString().trim();
            if (TextUtils.isEmpty(reason)) {
                Toast.makeText(this, "Please enter a rejection reason", Toast.LENGTH_SHORT).show();
                return;
            }

            String rejectedAt = new SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault()).format(new Date());

            FirebaseUtil.productsRef().child(product.getId()).child("status").setValue("rejected");
            FirebaseUtil.productsRef().child(product.getId()).child("rejectionReason").setValue(reason);
            FirebaseUtil.productsRef().child(product.getId()).child("rejectedBy").setValue(moderatorName);
            FirebaseUtil.productsRef().child(product.getId()).child("rejectedAt").setValue(rejectedAt)
                    .addOnSuccessListener(aVoid -> {
                        Toast.makeText(this, "Product rejected successfully", Toast.LENGTH_SHORT).show();
                    })
                    .addOnFailureListener(e -> {
                        Toast.makeText(this, "Failed to reject: " + e.getMessage(), Toast.LENGTH_SHORT).show();
                    });
        });

        builder.setNegativeButton("Cancel", null);
        builder.show();
    }

    private static class ProductReviewAdapter extends RecyclerView.Adapter<ProductReviewAdapter.ViewHolder> {
        private List<Product> list;
        private final java.util.function.Consumer<Product> onApprove;
        private final java.util.function.Consumer<Product> onReject;

        ProductReviewAdapter(List<Product> list, java.util.function.Consumer<Product> onApprove,
                           java.util.function.Consumer<Product> onReject) {
            this.list = list;
            this.onApprove = onApprove;
            this.onReject = onReject;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = android.view.LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.row_moderator_product_review, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            Product product = list.get(position);
            
            holder.tvProductName.setText(product.getName());
            holder.tvPrice.setText("₹" + String.format("%.0f", product.getPrice()));
            holder.tvVendor.setText("Vendor: " + (product.getVendorName() != null ? product.getVendorName() : "Unknown"));
            holder.tvCategory.setText(product.getCategory() != null ? product.getCategory() : "No category");
            holder.tvDate.setText("Added: " + (product.getDateAdded() != null ? product.getDateAdded() : "Unknown"));

            Glide.with(holder.itemView.getContext())
                    .load(product.getImageUrl())
                    .centerCrop()
                    .placeholder(android.R.drawable.ic_menu_gallery)
                    .into(holder.ivProduct);

            // Show/hide buttons based on status
            if ("pending".equals(product.getStatus())) {
                holder.btnApprove.setVisibility(View.VISIBLE);
                holder.btnReject.setVisibility(View.VISIBLE);
                holder.tvRejectionReason.setVisibility(View.GONE);
            } else if ("rejected".equals(product.getStatus())) {
                holder.btnApprove.setVisibility(View.GONE);
                holder.btnReject.setVisibility(View.GONE);
                holder.tvRejectionReason.setVisibility(View.VISIBLE);
                holder.tvRejectionReason.setText("Reason: " + (product.getRejectionReason() != null ? product.getRejectionReason() : "No reason"));
            } else {
                holder.btnApprove.setVisibility(View.GONE);
                holder.btnReject.setVisibility(View.GONE);
                holder.tvRejectionReason.setVisibility(View.GONE);
            }

            holder.btnApprove.setOnClickListener(v -> onApprove.accept(product));
            holder.btnReject.setOnClickListener(v -> onReject.accept(product));
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        static class ViewHolder extends RecyclerView.ViewHolder {
            ImageView ivProduct;
            TextView tvProductName, tvPrice, tvVendor, tvCategory, tvDate, tvRejectionReason;
            Button btnApprove, btnReject;

            ViewHolder(View itemView) {
                super(itemView);
                ivProduct = itemView.findViewById(R.id.ivProduct);
                tvProductName = itemView.findViewById(R.id.tvProductName);
                tvPrice = itemView.findViewById(R.id.tvPrice);
                tvVendor = itemView.findViewById(R.id.tvVendor);
                tvCategory = itemView.findViewById(R.id.tvCategory);
                tvDate = itemView.findViewById(R.id.tvDate);
                tvRejectionReason = itemView.findViewById(R.id.tvRejectionReason);
                btnApprove = itemView.findViewById(R.id.btnApprove);
                btnReject = itemView.findViewById(R.id.btnReject);
            }
        }
    }
}
