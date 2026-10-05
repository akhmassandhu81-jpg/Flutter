package com.example.ecomerceapp.activities;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
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
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.ValueEventListener;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class ModeratorOrdersActivity extends AppCompatActivity {

    private RecyclerView recyclerOrders;
    private ProgressBar progress;
    private TextView tvEmpty;
    private ImageButton btnBack;
    private OrderAdapter adapter;
    private List<Order> orders;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_moderator_orders);

        recyclerOrders = findViewById(R.id.recyclerOrders);
        progress = findViewById(R.id.progress);
        tvEmpty = findViewById(R.id.tvEmpty);
        btnBack = findViewById(R.id.btnBack);

        orders = new ArrayList<>();
        adapter = new OrderAdapter(orders, this::onStatusUpdate);
        recyclerOrders.setLayoutManager(new LinearLayoutManager(this));
        recyclerOrders.setAdapter(adapter);

        btnBack.setOnClickListener(v -> finish());

        FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
        if (user == null) {
            Toast.makeText(this, "Please login first", Toast.LENGTH_SHORT).show();
            finish();
            return;
        }

        loadOrders();
    }

    private void loadOrders() {
        progress.setVisibility(View.VISIBLE);
        FirebaseUtil.ordersRef().addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                orders.clear();
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

                    List<CartItem> products = new ArrayList<>();
                    DataSnapshot productsSnapshot = s.child("productList");
                    for (DataSnapshot ps : productsSnapshot.getChildren()) {
                        CartItem item = ps.getValue(CartItem.class);
                        if (item != null) {
                            products.add(item);
                        }
                    }
                    order.setProductList(products);

                    orders.add(order);
                }

                progress.setVisibility(View.GONE);
                adapter.notifyDataSetChanged();
                tvEmpty.setVisibility(orders.isEmpty() ? View.VISIBLE : View.GONE);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                progress.setVisibility(View.GONE);
                Toast.makeText(ModeratorOrdersActivity.this, "Error: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void onStatusUpdate(Order order) {
        String[] statuses = {"pending", "confirmed", "shipped", "delivered"};
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Update Order Status");
        builder.setItems(statuses, (dialog, which) -> {
            String newStatus = statuses[which];
            FirebaseUtil.ordersRef().child(order.getOrderId()).child("status").setValue(newStatus)
                    .addOnSuccessListener(unused -> Toast.makeText(this, "Status updated to " + newStatus, Toast.LENGTH_SHORT).show())
                    .addOnFailureListener(e -> Toast.makeText(this, "Failed: " + e.getMessage(), Toast.LENGTH_SHORT).show());
        });
        builder.show();
    }

    private static class OrderAdapter extends RecyclerView.Adapter<OrderAdapter.ViewHolder> {
        private List<Order> list;
        private final java.util.function.Consumer<Order> onStatusUpdate;

        OrderAdapter(List<Order> list, java.util.function.Consumer<Order> onStatusUpdate) {
            this.list = list;
            this.onStatusUpdate = onStatusUpdate;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                    .inflate(R.layout.order_item, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            Order order = list.get(position);
            holder.tvOrderId.setText("Order #" + (order.getOrderId() != null ? order.getOrderId().substring(0, 8) : "N/A"));
            holder.tvPrice.setText("₹" + String.format("%.0f", order.getTotalPrice()));
            holder.tvItemCount.setText(order.getProductList().size() + " items");
            
            SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, HH:mm", Locale.getDefault());
            String date = sdf.format(new Date(order.getTimestamp()));
            holder.tvDate.setText(date);
            
            // Set status with color
            String status = order.getStatus() != null ? order.getStatus().toUpperCase() : "PENDING";
            holder.tvStatus.setText(status);
            
            int statusColor;
            switch (status) {
                case "PENDING":
                    statusColor = 0xFFF59E0B;
                    break;
                case "CONFIRMED":
                    statusColor = 0xFF3B82F6;
                    break;
                case "SHIPPED":
                    statusColor = 0xFF8B5CF6;
                    break;
                case "DELIVERED":
                    statusColor = 0xFF10B981;
                    break;
                default:
                    statusColor = 0xFF6B7280;
            }
            holder.tvStatus.setBackgroundColor(statusColor);

            // Display product images and names
            holder.productsContainer.removeAllViews();
            List<CartItem> products = order.getProductList();
            if (products != null && !products.isEmpty()) {
                for (CartItem item : products) {
                    if (item == null) continue;
                    
                    View productView = LayoutInflater.from(holder.itemView.getContext())
                        .inflate(R.layout.order_product_item, holder.productsContainer, false);
                    
                    ImageView productImage = productView.findViewById(R.id.ivProductImage);
                    TextView productName = productView.findViewById(R.id.tvProductName);
                    TextView productQty = productView.findViewById(R.id.tvProductQty);
                    
                    if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) {
                        Glide.with(holder.itemView.getContext())
                            .load(item.getImageUrl())
                            .placeholder(R.drawable.ic_launcher_background)
                            .centerCrop()
                            .into(productImage);
                    }
                    
                    if (item.getName() != null) {
                        productName.setText(item.getName());
                    }
                    
                    productQty.setText("x" + item.getQuantity());
                    
                    holder.productsContainer.addView(productView);
                }
            }

            holder.btnUpdateStatus.setOnClickListener(v -> onStatusUpdate.accept(order));
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        static class ViewHolder extends RecyclerView.ViewHolder {
            TextView tvOrderId;
            TextView tvPrice;
            TextView tvItemCount;
            TextView tvDate;
            TextView tvStatus;
            Button btnUpdateStatus;
            LinearLayout productsContainer;

            ViewHolder(View itemView) {
                super(itemView);
                tvOrderId = itemView.findViewById(R.id.tvOrderId);
                tvPrice = itemView.findViewById(R.id.tvPrice);
                tvItemCount = itemView.findViewById(R.id.tvItemCount);
                tvDate = itemView.findViewById(R.id.tvDate);
                tvStatus = itemView.findViewById(R.id.tvStatus);
                btnUpdateStatus = itemView.findViewById(R.id.btnUpdateStatus);
                productsContainer = itemView.findViewById(R.id.productsContainer);
            }
        }
    }
}
