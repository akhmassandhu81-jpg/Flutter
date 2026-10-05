package com.example.ecomerceapp.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.InsuranceCompany;
import com.example.ecomerceapp.utils.PriceFormatter;

import java.util.ArrayList;
import java.util.List;

public class InsuranceAdapter extends RecyclerView.Adapter<InsuranceAdapter.ViewHolder> {

    private List<InsuranceCompany> insuranceOptions = new ArrayList<>();
    private String selectedInsuranceId = null;
    private OnInsuranceSelectedListener listener;

    public interface OnInsuranceSelectedListener {
        void onInsuranceSelected(InsuranceCompany insuranceCompany);
    }

    public InsuranceAdapter(OnInsuranceSelectedListener listener) {
        this.listener = listener;
    }

    public void submit(List<InsuranceCompany> newInsuranceOptions) {
        this.insuranceOptions = newInsuranceOptions != null ? newInsuranceOptions : new ArrayList<>();
        notifyDataSetChanged();
    }

    public void setSelectedInsuranceId(String insuranceId) {
        this.selectedInsuranceId = insuranceId;
        notifyDataSetChanged();
    }

    public String getSelectedInsuranceId() {
        return selectedInsuranceId;
    }

    public InsuranceCompany getSelectedInsurance() {
        if (selectedInsuranceId == null) return null;
        for (InsuranceCompany insurance : insuranceOptions) {
            if (insurance.getId() != null && insurance.getId().equals(selectedInsuranceId)) {
                return insurance;
            }
        }
        return null;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_insurance, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        InsuranceCompany insurance = insuranceOptions.get(position);
        if (insurance == null) return;

        holder.tvInsuranceName.setText(insurance.getName());
        holder.tvInsurancePrice.setText(PriceFormatter.formatPrice(insurance.getPrice()));
        
        boolean isSelected = insurance.getId() != null && insurance.getId().equals(selectedInsuranceId);
        holder.cbInsurance.setChecked(isSelected);

        if (isSelected) {
            holder.itemView.setBackgroundResource(R.drawable.payment_option_selected_bg);
        } else {
            holder.itemView.setBackgroundResource(R.drawable.payment_option_bg);
        }

        holder.itemView.setOnClickListener(v -> {
            if (selectedInsuranceId != null && selectedInsuranceId.equals(insurance.getId())) {
                // Deselect if already selected
                selectedInsuranceId = null;
                notifyDataSetChanged();
                if (listener != null) {
                    listener.onInsuranceSelected(null);
                }
            } else {
                selectedInsuranceId = insurance.getId();
                notifyDataSetChanged();
                if (listener != null) {
                    listener.onInsuranceSelected(insurance);
                }
            }
        });

        holder.cbInsurance.setOnClickListener(v -> {
            if (holder.cbInsurance.isChecked()) {
                selectedInsuranceId = insurance.getId();
                notifyDataSetChanged();
                if (listener != null) {
                    listener.onInsuranceSelected(insurance);
                }
            } else {
                selectedInsuranceId = null;
                notifyDataSetChanged();
                if (listener != null) {
                    listener.onInsuranceSelected(null);
                }
            }
        });
    }

    @Override
    public int getItemCount() {
        return insuranceOptions.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        CheckBox cbInsurance;
        TextView tvInsuranceName;
        TextView tvInsurancePrice;

        ViewHolder(View itemView) {
            super(itemView);
            cbInsurance = itemView.findViewById(R.id.cbInsurance);
            tvInsuranceName = itemView.findViewById(R.id.tvInsuranceName);
            tvInsurancePrice = itemView.findViewById(R.id.tvInsurancePrice);
        }
    }
}
