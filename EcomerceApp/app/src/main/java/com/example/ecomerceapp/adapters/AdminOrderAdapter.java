package com.example.ecomerceapp.adapters;

import android.view.LayoutInflater;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.databinding.RowAdminOrderBinding;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.models.Order;
import com.example.ecomerceapp.utils.PriceFormatter;

import java.util.ArrayList;
import java.util.List;

public class AdminOrderAdapter extends RecyclerView.Adapter<AdminOrderAdapter.VH> {

    public interface Listener {
        void onAccept(Order order);
    }

    private final Listener listener;
    private final List<Order> items = new ArrayList<>();

    public AdminOrderAdapter(Listener listener) {
        this.listener = listener;
    }

    public void submit(List<Order> list) {
        items.clear();
        if (list != null) items.addAll(list);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        RowAdminOrderBinding b = RowAdminOrderBinding.inflate(LayoutInflater.from(parent.getContext()), parent, false);
        return new VH(b);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        Order o = items.get(position);

        // User details
        holder.b.tvUserId.setText("User ID: " + (o.getUserId() != null ? o.getUserId() : "-"));
        holder.b.tvUserName.setText("Name: " + (o.getUserName() != null ? o.getUserName() : "-"));
        holder.b.tvUserEmail.setText("Email: " + (o.getUserEmail() != null ? o.getUserEmail() : "-"));
        holder.b.tvUserPhone.setText("Phone: " + (o.getUserPhone() != null ? o.getUserPhone() : "-"));
        
        // Payment method
        String paymentMethod = o.getPaymentMethod();
        if (paymentMethod == null) paymentMethod = "Cash on Delivery";
        holder.b.tvPaymentMethod.setText("Payment: " + paymentMethod);
        
        holder.b.tvTotal.setText("Total: " + PriceFormatter.formatPrice(o.getTotalPrice()));

        String status = o.getStatus();
        if (status == null) status = "pending";
        String statusText = status.equalsIgnoreCase("accepted") ? "Accepted" : "Pending";
        holder.b.tvStatus.setText("Status: " + statusText);

        holder.b.tvProducts.setText(buildProductsText(o.getProductList()));

        boolean canAccept = !status.equalsIgnoreCase("accepted");
        holder.b.btnAccept.setEnabled(canAccept);
        holder.b.btnAccept.setText(canAccept ? "Accept" : "Accepted");
        holder.b.btnAccept.setOnClickListener(v -> listener.onAccept(o));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    private String buildProductsText(List<CartItem> list) {
        if (list == null || list.isEmpty()) {
            return "Products: -";
        }
        StringBuilder sb = new StringBuilder();
        sb.append("Products:\n");
        for (int i = 0; i < list.size(); i++) {
            CartItem it = list.get(i);
            if (it == null) continue;
            sb.append("- ")
                    .append(it.getName() != null ? it.getName() : "Item")
                    .append(" x ")
                    .append(it.getQuantity());
            if (i != list.size() - 1) sb.append("\n");
        }
        return sb.toString();
    }

    static class VH extends RecyclerView.ViewHolder {
        final RowAdminOrderBinding b;

        VH(RowAdminOrderBinding b) {
            super(b.getRoot());
            this.b = b;
        }
    }
}
