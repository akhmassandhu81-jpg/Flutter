package com.example.ecomerceapp.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.ecomerceapp.databinding.RowUserProductBinding;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.utils.PriceFormatter;

import java.util.ArrayList;
import java.util.List;

public class UserProductAdapter extends RecyclerView.Adapter<UserProductAdapter.VH> {

    public interface Listener {
        void onAddToCart(Product product);
    }

    private final Context context;
    private final Listener listener;
    private final List<Product> items = new ArrayList<>();

    public UserProductAdapter(Context context, Listener listener) {
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
        RowUserProductBinding b = RowUserProductBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);
        return new VH(b);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        Product p = items.get(position);

        holder.b.tvName.setText(p.getName());
        holder.b.tvPrice.setText(PriceFormatter.formatPrice(p.getPrice()));
        holder.b.tvQuantity.setText("Available: " + p.getQuantity());

        Glide.with(context)
                .load(p.getImageUrl())
                .placeholder(android.R.drawable.ic_menu_gallery)
                .error(android.R.drawable.ic_menu_gallery)
                .diskCacheStrategy(com.bumptech.glide.load.engine.DiskCacheStrategy.ALL)
                .skipMemoryCache(false)
                .centerCrop()
                .into(holder.b.ivImage);

        boolean inStock = p.getQuantity() > 0;
        holder.b.btnAddToCart.setEnabled(inStock);
        holder.b.btnAddToCart.setText(inStock ? "Add to Cart" : "Out of Stock");

        holder.b.btnAddToCart.setOnClickListener(v -> listener.onAddToCart(p));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        final RowUserProductBinding b;

        VH(RowUserProductBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
