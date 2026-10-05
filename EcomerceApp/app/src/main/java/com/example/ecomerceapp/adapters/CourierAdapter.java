package com.example.ecomerceapp.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.Courier;
import com.example.ecomerceapp.utils.PriceFormatter;
import com.google.android.material.card.MaterialCardView;

import java.util.ArrayList;
import java.util.List;

public class CourierAdapter extends RecyclerView.Adapter<CourierAdapter.ViewHolder> {

    private List<Courier> couriers = new ArrayList<>();
    private String selectedCourierId = null;
    private OnCourierSelectedListener listener;

    public interface OnCourierSelectedListener {
        void onCourierSelected(Courier courier);
    }

    public CourierAdapter(OnCourierSelectedListener listener) {
        this.listener = listener;
    }

    public void submit(List<Courier> newCouriers) {
        this.couriers = newCouriers != null ? newCouriers : new ArrayList<>();
        notifyDataSetChanged();
    }

    public void setSelectedCourierId(String courierId) {
        this.selectedCourierId = courierId;
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_courier, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        Courier courier = couriers.get(position);
        if (courier == null) return;

        holder.tvCourierName.setText(courier.getName());
        holder.tvDeliveryCharge.setText(PriceFormatter.formatPrice(courier.getDeliveryCharge()));
        
        // Note: Courier model doesn't have deliveryTime field, using placeholder
        holder.tvDeliveryTime.setText("Standard Delivery");

        boolean isSelected = courier.getId() != null && courier.getId().equals(selectedCourierId);
        holder.rbCourier.setChecked(isSelected);

        if (isSelected) {
            holder.cardView.setStrokeColor(0xFF2D5A4A);
            holder.cardView.setStrokeWidth(2);
        } else {
            holder.cardView.setStrokeColor(0xFFE5E7EB);
            holder.cardView.setStrokeWidth(2);
        }

        holder.itemView.setOnClickListener(v -> {
            selectedCourierId = courier.getId();
            notifyDataSetChanged();
            if (listener != null) {
                listener.onCourierSelected(courier);
            }
        });

        holder.rbCourier.setOnClickListener(v -> {
            selectedCourierId = courier.getId();
            notifyDataSetChanged();
            if (listener != null) {
                listener.onCourierSelected(courier);
            }
        });
    }

    @Override
    public int getItemCount() {
        return couriers.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        MaterialCardView cardView;
        RadioButton rbCourier;
        TextView tvCourierName;
        TextView tvDeliveryTime;
        TextView tvDeliveryCharge;

        ViewHolder(View itemView) {
            super(itemView);
            cardView = (MaterialCardView) itemView;
            rbCourier = itemView.findViewById(R.id.rbCourier);
            tvCourierName = itemView.findViewById(R.id.tvCourierName);
            tvDeliveryTime = itemView.findViewById(R.id.tvDeliveryTime);
            tvDeliveryCharge = itemView.findViewById(R.id.tvDeliveryCharge);
        }
    }
}
