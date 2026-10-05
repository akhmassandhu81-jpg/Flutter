package com.example.ecomerceapp.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.utils.PriceFormatter;

import java.util.ArrayList;
import java.util.List;

public class AdminProductAdapter extends RecyclerView.Adapter<AdminProductAdapter.VH> {

    public interface Listener {
        void onEdit(Product product);

        void onDelete(Product product);
    }

    private final Context context;
    private final Listener listener;
    private final List<Product> items = new ArrayList<>();

    public AdminProductAdapter(Context context, Listener listener) {
        this.context = context;
        this.listener = listener;
    }

    public void submit(List<Product> list) {
        items.clear();
        if (list != null) items.addAll(list);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.row_admin_product, parent, false);
        return new VH(view);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        Product p = items.get(position);
        holder.tvName.setText(p.getName());
        holder.tvPrice.setText(PriceFormatter.formatPrice(p.getPrice()));
        
        // Show stock information
        int stock = p.getQuantity();
        int sold = p.getSold();
        int remaining = p.getRemaining();
        
        holder.tvStock.setText("Stock: " + stock);
        holder.tvSold.setText("Sold: " + sold);
        holder.tvRemaining.setText("Remaining: " + remaining);
        
        // Show low stock indicator
        if (p.isLowStock()) {
            holder.tvRemaining.setTextColor(context.getColor(android.R.color.holo_red_dark));
            holder.tvLowStock.setVisibility(View.VISIBLE);
        } else if (remaining == 0) {
            holder.tvRemaining.setTextColor(context.getColor(android.R.color.holo_red_dark));
            holder.tvLowStock.setText("Out of Stock");
            holder.tvLowStock.setVisibility(View.VISIBLE);
        } else {
            holder.tvRemaining.setTextColor(context.getColor(android.R.color.black));
            holder.tvLowStock.setVisibility(View.GONE);
        }
        
        // Show vendor name if available
        String vendorName = p.getVendorName();
        holder.tvVendor.setText("Vendor: " + (vendorName != null ? vendorName : "-"));

        // Show status badge
        String status = p.getStatus();
        if (status == null) status = "pending";
        
        holder.tvStatus.setText(status.substring(0, 1).toUpperCase() + status.substring(1));
        
        if ("approved".equals(status)) {
            holder.tvStatus.setBackgroundResource(R.drawable.status_approved_bg);
        } else if ("rejected".equals(status)) {
            holder.tvStatus.setBackgroundResource(R.drawable.status_rejected_bg);
        } else {
            holder.tvStatus.setBackgroundResource(R.drawable.status_pending_bg);
        }

        Glide.with(context)
                .load(p.getImageUrl())
                .centerCrop()
                .into(holder.ivImage);

        holder.btnEdit.setOnClickListener(v -> listener.onEdit(p));
        holder.btnDelete.setOnClickListener(v -> listener.onDelete(p));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        ImageView ivImage;
        TextView tvName;
        TextView tvPrice;
        TextView tvStock;
        TextView tvSold;
        TextView tvRemaining;
        TextView tvLowStock;
        TextView tvVendor;
        TextView tvStatus;
        Button btnEdit;
        Button btnDelete;

        VH(View itemView) {
            super(itemView);
            ivImage = itemView.findViewById(R.id.ivImage);
            tvName = itemView.findViewById(R.id.tvName);
            tvPrice = itemView.findViewById(R.id.tvPrice);
            tvStock = itemView.findViewById(R.id.tvStock);
            tvSold = itemView.findViewById(R.id.tvSold);
            tvRemaining = itemView.findViewById(R.id.tvRemaining);
            tvLowStock = itemView.findViewById(R.id.tvLowStock);
            tvVendor = itemView.findViewById(R.id.tvVendor);
            tvStatus = itemView.findViewById(R.id.tvStatus);
            btnEdit = itemView.findViewById(R.id.btnEdit);
            btnDelete = itemView.findViewById(R.id.btnDelete);
        }
    }
}
