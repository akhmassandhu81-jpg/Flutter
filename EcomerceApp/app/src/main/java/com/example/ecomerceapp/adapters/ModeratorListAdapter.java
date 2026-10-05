package com.example.ecomerceapp.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.UserModel;

import java.util.ArrayList;
import java.util.List;

public class ModeratorListAdapter extends RecyclerView.Adapter<ModeratorListAdapter.ViewHolder> {

    public interface Listener {
        void onView(UserModel moderator);
        void onEdit(UserModel moderator);
        void onDelete(UserModel moderator);
    }

    private final List<UserModel> items = new ArrayList<>();
    private final Listener listener;

    public ModeratorListAdapter(Listener listener) {
        this.listener = listener;
    }

    public void submitList(List<UserModel> list) {
        items.clear();
        if (list != null) items.addAll(list);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.row_moderator, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        UserModel moderator = items.get(position);

        String name = moderator.getFullName();
        if (name == null || name.isEmpty()) {
            name = moderator.getEmail();
        }
        holder.tvName.setText(name);
        holder.tvEmail.setText(moderator.getEmail());
        
        // Show category/domain if available
        String category = moderator.getDomain();
        if (category != null && !category.isEmpty()) {
            holder.tvCategory.setText("Category: " + category);
            holder.tvCategory.setVisibility(View.VISIBLE);
        } else {
            holder.tvCategory.setVisibility(View.GONE);
        }

        // Show status badge
        boolean isActive = true; // Default to active
        if (moderator.getRole() != null && moderator.getRole().equals("moderator")) {
            holder.tvStatus.setText("Active");
            holder.tvStatus.setBackgroundResource(R.drawable.status_approved_bg);
        } else {
            holder.tvStatus.setText("Inactive");
            holder.tvStatus.setBackgroundResource(R.drawable.status_rejected_bg);
        }

        holder.btnView.setOnClickListener(v -> listener.onView(moderator));
        holder.btnEdit.setOnClickListener(v -> listener.onEdit(moderator));
        holder.btnDelete.setOnClickListener(v -> listener.onDelete(moderator));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        ImageView ivAvatar;
        TextView tvName;
        TextView tvEmail;
        TextView tvCategory;
        TextView tvStatus;
        Button btnView;
        Button btnEdit;
        Button btnDelete;

        ViewHolder(View itemView) {
            super(itemView);
            ivAvatar = itemView.findViewById(R.id.ivAvatar);
            tvName = itemView.findViewById(R.id.tvName);
            tvEmail = itemView.findViewById(R.id.tvEmail);
            tvCategory = itemView.findViewById(R.id.tvCategory);
            tvStatus = itemView.findViewById(R.id.tvStatus);
            btnView = itemView.findViewById(R.id.btnView);
            btnEdit = itemView.findViewById(R.id.btnEdit);
            btnDelete = itemView.findViewById(R.id.btnDelete);
        }
    }
}
