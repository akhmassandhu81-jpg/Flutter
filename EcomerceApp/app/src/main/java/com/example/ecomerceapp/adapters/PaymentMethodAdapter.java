package com.example.ecomerceapp.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.PaymentCompany;

import java.util.ArrayList;
import java.util.List;

public class PaymentMethodAdapter extends RecyclerView.Adapter<PaymentMethodAdapter.ViewHolder> {

    private List<PaymentCompany> paymentMethods = new ArrayList<>();
    private String selectedPaymentId = null;
    private OnPaymentSelectedListener listener;

    public interface OnPaymentSelectedListener {
        void onPaymentSelected(PaymentCompany paymentCompany);
    }

    public PaymentMethodAdapter(OnPaymentSelectedListener listener) {
        this.listener = listener;
    }

    public void submit(List<PaymentCompany> newPaymentMethods) {
        this.paymentMethods = newPaymentMethods != null ? newPaymentMethods : new ArrayList<>();
        notifyDataSetChanged();
    }

    public void setSelectedPaymentId(String paymentId) {
        this.selectedPaymentId = paymentId;
        notifyDataSetChanged();
    }

    public String getSelectedPaymentId() {
        return selectedPaymentId;
    }

    public PaymentCompany getSelectedPayment() {
        if (selectedPaymentId == null) return null;
        for (PaymentCompany payment : paymentMethods) {
            if (payment.getId() != null && payment.getId().equals(selectedPaymentId)) {
                return payment;
            }
        }
        return null;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_payment_method, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        PaymentCompany payment = paymentMethods.get(position);
        if (payment == null) return;

        holder.tvPaymentName.setText(payment.getName());
        
        boolean isSelected = payment.getId() != null && payment.getId().equals(selectedPaymentId);
        holder.rbPayment.setChecked(isSelected);

        if (isSelected) {
            holder.itemView.setBackgroundResource(R.drawable.payment_option_selected_bg);
        } else {
            holder.itemView.setBackgroundResource(R.drawable.payment_option_bg);
        }

        holder.itemView.setOnClickListener(v -> {
            selectedPaymentId = payment.getId();
            notifyDataSetChanged();
            if (listener != null) {
                listener.onPaymentSelected(payment);
            }
        });

        holder.rbPayment.setOnClickListener(v -> {
            selectedPaymentId = payment.getId();
            notifyDataSetChanged();
            if (listener != null) {
                listener.onPaymentSelected(payment);
            }
        });
    }

    @Override
    public int getItemCount() {
        return paymentMethods.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        RadioButton rbPayment;
        TextView tvPaymentName;

        ViewHolder(View itemView) {
            super(itemView);
            rbPayment = itemView.findViewById(R.id.rbPayment);
            tvPaymentName = itemView.findViewById(R.id.tvPaymentName);
        }
    }
}
