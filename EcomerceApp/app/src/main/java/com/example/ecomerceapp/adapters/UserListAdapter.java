package com.example.ecomerceapp.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.UserModel;

import java.util.ArrayList;
import java.util.List;

public class UserListAdapter extends RecyclerView.Adapter<UserListAdapter.VH> {

    private List<UserModel> items = new ArrayList<>();

    public void submitList(List<UserModel> list) {
        items.clear();
        if (list != null) items.addAll(list);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(parent.getContext()).inflate(R.layout.row_admin_user, parent, false);
        return new VH(v);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        UserModel user = items.get(position);
        
        holder.tvName.setText(user.getFullName() != null ? user.getFullName() : "Unknown");
        holder.tvEmail.setText(user.getEmail() != null ? user.getEmail() : "No email");
        holder.tvPhone.setText(user.getContactNo() != null ? user.getContactNo() : "No phone");
        holder.tvAddress.setText(user.getAddress() != null ? user.getAddress() : "No address");
        
        // Set role text and color
        String role = user.getRole();
        if (role != null) {
            holder.tvRole.setText(role.toUpperCase());
            
            // Set different background colors based on role
            if ("admin".equalsIgnoreCase(role)) {
                holder.tvRole.setBackgroundResource(R.drawable.role_background_admin);
            } else if ("moderator".equalsIgnoreCase(role)) {
                holder.tvRole.setBackgroundResource(R.drawable.role_background_moderator);
            } else {
                holder.tvRole.setBackgroundResource(R.drawable.role_background);
            }
        } else {
            holder.tvRole.setText("USER");
            holder.tvRole.setBackgroundResource(R.drawable.role_background);
        }
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        TextView tvName, tvEmail, tvPhone, tvAddress, tvRole;

        VH(View v) {
            super(v);
            tvName = v.findViewById(R.id.tvName);
            tvEmail = v.findViewById(R.id.tvEmail);
            tvPhone = v.findViewById(R.id.tvPhone);
            tvAddress = v.findViewById(R.id.tvAddress);
            tvRole = v.findViewById(R.id.tvRole);
        }
    }
}
