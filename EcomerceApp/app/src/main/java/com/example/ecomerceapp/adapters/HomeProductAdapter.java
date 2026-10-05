package com.example.ecomerceapp.adapters;

import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.ecomerceapp.R;
import com.example.ecomerceapp.activities.ProductDetailActivity;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.utils.PriceFormatter;

import java.util.ArrayList;
import java.util.List;

public class HomeProductAdapter extends RecyclerView.Adapter<HomeProductAdapter.VH> {

    private List<Product> items = new ArrayList<>();

    public void submitList(List<Product> list) {
        items.clear();
        if (list != null) items.addAll(list);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_home_product, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        if (items == null || position < 0 || position >= items.size()) {
            return;
        }
        
        Product p = items.get(position);
        if (p == null) {
            return;
        }
        
        holder.tvName.setText(p.getName() != null ? p.getName() : "Product");
        holder.tvBrand.setText("Brand Store");
        holder.tvPrice.setText(PriceFormatter.formatPrice(p.getPrice()));
        
        // Show stock status
        int remaining = p.getRemaining();
        if (remaining <= 0) {
            holder.tvStock.setText("Out of Stock");
            holder.tvStock.setTextColor(holder.itemView.getContext().getColor(android.R.color.holo_red_dark));
        } else if (remaining < 10) {
            holder.tvStock.setText("Only " + remaining + " left");
            holder.tvStock.setTextColor(holder.itemView.getContext().getColor(android.R.color.holo_orange_dark));
        } else {
            holder.tvStock.setText("In Stock");
            holder.tvStock.setTextColor(holder.itemView.getContext().getColor(android.R.color.holo_green_dark));
        }
        
        // Load image with optimized caching
        if (p.getImageUrl() != null && !p.getImageUrl().isEmpty()) {
            Glide.with(holder.itemView.getContext())
                    .load(p.getImageUrl())
                    .placeholder(R.drawable.ic_launcher_background)
                    .error(R.drawable.ic_launcher_background)
                    .diskCacheStrategy(com.bumptech.glide.load.engine.DiskCacheStrategy.ALL)
                    .skipMemoryCache(false)
                    .thumbnail(0.1f)
                    .centerCrop()
                    .into(holder.ivImage);
        } else {
            holder.ivImage.setImageResource(R.drawable.ic_launcher_background);
        }
        
        // Click listener to open product detail
        holder.itemView.setOnClickListener(v -> {
            Intent intent = new Intent(holder.itemView.getContext(), ProductDetailActivity.class);
            intent.putExtra("productId", p.getId());
            holder.itemView.getContext().startActivity(intent);
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        ImageView ivImage, ivFavorite;
        TextView tvName, tvBrand, tvPrice, tvStock;

        VH(View v) {
            super(v);
            ivImage = v.findViewById(R.id.ivProduct);
            ivFavorite = v.findViewById(R.id.ivFavorite);
            tvName = v.findViewById(R.id.tvProductName);
            tvBrand = v.findViewById(R.id.tvBrand);
            tvPrice = v.findViewById(R.id.tvPrice);
            tvStock = v.findViewById(R.id.tvStock);
        }
    }
}
