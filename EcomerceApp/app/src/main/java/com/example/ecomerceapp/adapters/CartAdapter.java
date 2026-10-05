package com.example.ecomerceapp.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.ecomerceapp.databinding.RowCartItemBinding;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.utils.PriceFormatter;

import java.util.ArrayList;
import java.util.List;

public class CartAdapter extends RecyclerView.Adapter<CartAdapter.VH> {

    public interface Listener {
        void onIncrease(CartItem item);
        void onDecrease(CartItem item);
        void onRemove(CartItem item);
        void onSelectChanged(CartItem item, boolean isSelected);
    }

    private final Context context;
    private final Listener listener;
    private final List<CartItem> items = new ArrayList<>();
    private final List<Boolean> selectedItems = new ArrayList<>();

    public CartAdapter(Context context, Listener listener) {
        this.context = context;
        this.listener = listener;
    }

    public void submit(List<CartItem> list) {
        items.clear();
        selectedItems.clear();
        if (list != null) {
            items.addAll(list);
            for (int i = 0; i < list.size(); i++) {
                selectedItems.add(true); // Default all selected
            }
        }
        notifyDataSetChanged();
    }

    public List<CartItem> getSelectedItems() {
        List<CartItem> selected = new ArrayList<>();
        for (int i = 0; i < items.size(); i++) {
            if (selectedItems.get(i)) {
                selected.add(items.get(i));
            }
        }
        return selected;
    }

    public double getSelectedTotal() {
        double total = 0;
        for (int i = 0; i < items.size(); i++) {
            if (selectedItems.get(i)) {
                CartItem item = items.get(i);
                total += (item.getPrice() * item.getQuantity());
            }
        }
        return total;
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        RowCartItemBinding b = RowCartItemBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);
        return new VH(b);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        CartItem item = items.get(position);

        holder.b.tvName.setText(item.getName());
        holder.b.tvCategory.setText("Category"); // Placeholder - will show category
        holder.b.tvQty.setText(String.valueOf(item.getQuantity()));
        
        // Show unit price (not total) to match the design
        holder.b.tvPrice.setText(PriceFormatter.formatPrice(item.getPrice()));

        // Load image with null check and optimization
        if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) {
            Glide.with(context)
                    .load(item.getImageUrl())
                    .placeholder(android.R.drawable.ic_menu_gallery)
                    .error(android.R.drawable.ic_menu_gallery)
                    .diskCacheStrategy(com.bumptech.glide.load.engine.DiskCacheStrategy.ALL)
                    .skipMemoryCache(false)
                    .thumbnail(0.1f) // Load thumbnail first for faster display
                    .centerCrop()
                    .into(holder.b.ivImage);
        } else {
            holder.b.ivImage.setImageResource(android.R.drawable.ic_menu_gallery);
        }

        // Checkbox
        holder.b.cbSelect.setChecked(selectedItems.get(position));
        holder.b.cbSelect.setOnCheckedChangeListener((buttonView, isChecked) -> {
            selectedItems.set(position, isChecked);
            if (listener != null) {
                listener.onSelectChanged(item, isChecked);
            }
        });

        holder.b.btnPlus.setOnClickListener(v -> listener.onIncrease(item));
        holder.b.btnMinus.setOnClickListener(v -> listener.onDecrease(item));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final RowCartItemBinding b;

        VH(RowCartItemBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
