package com.example.ecomerceapp.adapters;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.example.ecomerceapp.R;
import com.example.ecomerceapp.models.Announcement;

import java.util.ArrayList;
import java.util.List;

public class AnnouncementAdapter extends RecyclerView.Adapter<AnnouncementAdapter.VH> {

    public interface Listener {
        void onEdit(Announcement announcement);
        void onDelete(Announcement announcement);
    }

    private final Context context;
    private final Listener listener;
    private final List<Announcement> items = new ArrayList<>();

    public AnnouncementAdapter(Context context, List<Announcement> items, Listener listener) {
        this.context = context;
        this.items.addAll(items);
        this.listener = listener;
    }

    public AnnouncementAdapter(Context context, List<Announcement> items) {
        this.context = context;
        this.items.addAll(items);
        this.listener = null;
    }

    public void submit(List<Announcement> list) {
        items.clear();
        if (list != null) items.addAll(list);
        notifyDataSetChanged();
    }

    @NonNull
    @Override
    public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_announcement, parent, false);
        return new VH(view);
    }

    @Override
    public void onBindViewHolder(@NonNull VH holder, int position) {
        Announcement announcement = items.get(position);

        holder.tvTitle.setText(announcement.getTitle());
        holder.tvMessage.setText(announcement.getMessage());
        holder.tvDate.setText(announcement.getDate() != null ? announcement.getDate() : "");
        holder.tvType.setText(announcement.getType() != null ? 
            announcement.getType().substring(0, 1).toUpperCase() + announcement.getType().substring(1).toLowerCase() : "News");

        // Set type badge color
        GradientDrawable badgeBg = (GradientDrawable) holder.tvType.getBackground();
        String type = announcement.getType() != null ? announcement.getType().toLowerCase() : "news";
        switch (type) {
            case "offer":
                badgeBg.setColor(Color.parseColor("#10B981")); // Green
                break;
            case "alert":
                badgeBg.setColor(Color.parseColor("#EF4444")); // Red
                break;
            default:
                badgeBg.setColor(Color.parseColor("#3B82F6")); // Blue
                break;
        }

        // Show discount if available
        if (announcement.getDiscount() != null && !announcement.getDiscount().isEmpty()) {
            holder.tvDiscount.setText(announcement.getDiscount());
            holder.tvDiscount.setVisibility(View.VISIBLE);
        } else {
            holder.tvDiscount.setVisibility(View.GONE);
        }

        // Handle edit/delete clicks (long press for delete)
        holder.itemView.setOnClickListener(v -> {
            if (listener != null) listener.onEdit(announcement);
        });

        holder.itemView.setOnLongClickListener(v -> {
            if (listener != null) listener.onDelete(announcement);
            return true;
        });
    }

    @Override
    public int getItemCount() {
        return items.size();
    }

    static class VH extends RecyclerView.ViewHolder {
        TextView tvDiscount;
        TextView tvTitle;
        TextView tvType;
        TextView tvMessage;
        TextView tvDate;

        VH(View itemView) {
            super(itemView);
            tvDiscount = itemView.findViewById(R.id.tvDiscount);
            tvTitle = itemView.findViewById(R.id.tvTitle);
            tvType = itemView.findViewById(R.id.tvType);
            tvMessage = itemView.findViewById(R.id.tvMessage);
            tvDate = itemView.findViewById(R.id.tvDate);
        }
    }
}
