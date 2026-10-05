package com.example.ecomerceapp.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.utils.PriceFormatter;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class OrderHistoryAdapter extends RecyclerView.Adapter<OrderHistoryAdapter.VH> {

    private final List<Order> items = new ArrayList<>();

    public void submit(List<Order> list) {
        items.clear();
        if (list != null) items.addAll(list);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.row_order, parent, false);
        return new VH(view);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        Order o = items.get(position);

        // Order ID
        holder.tvOrderId.setText("Order #" + (o.getOrderId() != null ? o.getOrderId() : "N/A"));

        // Status with color coding
        String status = o.getStatus();
        if (status == null) status = "pending";
        holder.tvStatus.setText(status.toUpperCase());
        
        int statusColor;
        switch (status.toLowerCase()) {
            case "pending":
                statusColor = 0xFFF59E0B;
                break;
            case "confirmed":
                statusColor = 0xFF3B82F6;
                break;
            case "shipped":
                statusColor = 0xFF8B5CF6;
                break;
            case "delivered":
                statusColor = 0xFF10B981;
                break;
            default:
                statusColor = 0xFF6B7280;
        }
        holder.tvStatus.setBackgroundColor(statusColor);

        // Total price
        holder.tvTotal.setText(PriceFormatter.formatPrice(o.getTotalPrice()));

        // Date
        SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy", Locale.getDefault());
        holder.tvDate.setText(sdf.format(new Date(o.getTimestamp())));

        // Product images
        holder.productsContainer.removeAllViews();
        List<CartItem> products = o.getProductList();
        if (products != null && !products.isEmpty()) {
            for (CartItem item : products) {
                if (item == null) continue;
                
                View productView = LayoutInflater.from(holder.itemView.getContext())
                    .inflate(R.layout.order_product_item, holder.productsContainer, false);
                
                ImageView productImage = productView.findViewById(R.id.ivProductImage);
                TextView productQty = productView.findViewById(R.id.tvProductQty);
                
                if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) {
                    Glide.with(holder.itemView.getContext())
                        .load(item.getImageUrl())
                        .placeholder(R.drawable.ic_launcher_background)
                        .centerCrop()
                        .into(productImage);
                }
                
                productQty.setText("x" + item.getQuantity());
                
                holder.productsContainer.addView(productView);
            }
        }
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        TextView tvOrderId;
        TextView tvStatus;
        TextView tvTotal;
        TextView tvDate;
        LinearLayout productsContainer;

        VH(View itemView) {
            super(itemView);
            tvOrderId = itemView.findViewById(R.id.tvOrderId);
            tvStatus = itemView.findViewById(R.id.tvStatus);
            tvTotal = itemView.findViewById(R.id.tvTotal);
            tvDate = itemView.findViewById(R.id.tvDate);
            productsContainer = itemView.findViewById(R.id.productsContainer);
        }
    }
}
