package com.example.ecomerceapp.activities;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.example.ecomerceapp.databinding.ActivityAdminAnnouncementsBinding;
import com.example.ecomerceapp.models.Announcement;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

public class AdminAnnouncementsActivity extends AppCompatActivity {

    private ActivityAdminAnnouncementsBinding binding;
    private AnnouncementAdapter adapter;
    private List<Announcement> announcementList = new ArrayList<>();
    private final String[] types = {"General", "Promotion", "Alert", "Update", "Event"};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        binding = ActivityAdminAnnouncementsBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        setupRecyclerView();
        setupClickListeners();
        loadAnnouncements();
    }

    private void setupRecyclerView() {
        adapter = new AnnouncementAdapter(announcementList, this::onEditAnnouncement, this::onDeleteAnnouncement);
        binding.recycler.setLayoutManager(new LinearLayoutManager(this));
        binding.recycler.setAdapter(adapter);
    }

    private void setupClickListeners() {
        binding.btnBack.setOnClickListener(v -> finish());
        binding.btnAdd.setOnClickListener(v -> showAnnouncementDialog(null));
        
        binding.btnSearch.setOnClickListener(v -> {
            String query = binding.etSearch.getText().toString().trim().toLowerCase();
            searchAnnouncements(query);
        });
    }

    private void loadAnnouncements() {
        binding.progress.setVisibility(View.VISIBLE);
        FirebaseUtil.announcementsRef().addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                announcementList.clear();
                for (DataSnapshot data : snapshot.getChildren()) {
                    Announcement ann = data.getValue(Announcement.class);
                    if (ann != null) {
                        announcementList.add(ann);
                    }
                }
                binding.progress.setVisibility(View.GONE);
                adapter.notifyDataSetChanged();
                binding.tvEmpty.setVisibility(announcementList.isEmpty() ? View.VISIBLE : View.GONE);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                binding.progress.setVisibility(View.GONE);
                Toast.makeText(AdminAnnouncementsActivity.this, "Error: " + error.getMessage(), Toast.LENGTH_SHORT).show();
            }
        });
    }

    private void searchAnnouncements(String query) {
        if (TextUtils.isEmpty(query)) {
            adapter.updateList(announcementList);
            return;
        }
        
        List<Announcement> filtered = new ArrayList<>();
        for (Announcement ann : announcementList) {
            if ((ann.getTitle() != null && ann.getTitle().toLowerCase().contains(query)) ||
                (ann.getType() != null && ann.getType().toLowerCase().contains(query)) ||
                (ann.getDate() != null && ann.getDate().contains(query))) {
                filtered.add(ann);
            }
        }
        adapter.updateList(filtered);
    }

    private void showAnnouncementDialog(Announcement announcement) {
        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        
        EditText etTitle = new EditText(this);
        etTitle.setHint("Title");
        
        Spinner spinnerType = new Spinner(this);
        ArrayAdapter<String> typeAdapter = new ArrayAdapter<>(this, android.R.layout.simple_spinner_item, types);
        typeAdapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
        spinnerType.setAdapter(typeAdapter);
        
        EditText etMessage = new EditText(this);
        etMessage.setHint("Message");
        etMessage.setMinLines(3);

        if (announcement != null) {
            etTitle.setText(announcement.getTitle());
            etMessage.setText(announcement.getMessage());
            for (int i = 0; i < types.length; i++) {
                if (types[i].equals(announcement.getType())) {
                    spinnerType.setSelection(i);
                    break;
                }
            }
        }

        android.widget.LinearLayout layout = new android.widget.LinearLayout(this);
        layout.setOrientation(android.widget.LinearLayout.VERTICAL);
        layout.setPadding(50, 20, 50, 20);
        layout.addView(etTitle);
        layout.addView(spinnerType);
        layout.addView(etMessage);

        builder.setView(layout);
        builder.setTitle(announcement == null ? "Add Announcement" : "Edit Announcement");
        builder.setPositiveButton("Save", (dialog, which) -> {
            saveAnnouncement(announcement, etTitle, spinnerType, etMessage);
        });
        builder.setNegativeButton("Cancel", null);
        builder.show();
    }

    private void saveAnnouncement(Announcement existing, EditText etTitle, Spinner spinnerType, EditText etMessage) {
        String title = etTitle.getText().toString().trim();
        String type = types[spinnerType.getSelectedItemPosition()];
        String message = etMessage.getText().toString().trim();

        if (TextUtils.isEmpty(title) || TextUtils.isEmpty(message)) {
            Toast.makeText(this, "Title and message are required", Toast.LENGTH_SHORT).show();
            return;
        }

        String id = existing != null ? existing.getId() : UUID.randomUUID().toString();
        String date = existing != null ? existing.getDate() : 
                new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(new Date());

        Announcement announcement = new Announcement(id, title, message, type, date);
        
        FirebaseUtil.announcementsRef().child(id).setValue(announcement)
            .addOnSuccessListener(aVoid -> Toast.makeText(this, "Announcement saved successfully", Toast.LENGTH_SHORT).show())
            .addOnFailureListener(e -> Toast.makeText(this, "Failed to save: " + e.getMessage(), Toast.LENGTH_SHORT).show());
    }

    private void onEditAnnouncement(Announcement announcement) {
        showAnnouncementDialog(announcement);
    }

    private void onDeleteAnnouncement(Announcement announcement) {
        new AlertDialog.Builder(this)
            .setTitle("Delete Announcement")
            .setMessage("Are you sure you want to delete this announcement?")
            .setPositiveButton("Delete", (dialog, which) -> {
                FirebaseUtil.announcementsRef().child(announcement.getId()).removeValue()
                    .addOnSuccessListener(aVoid -> Toast.makeText(this, "Announcement deleted", Toast.LENGTH_SHORT).show())
                    .addOnFailureListener(e -> Toast.makeText(this, "Failed to delete: " + e.getMessage(), Toast.LENGTH_SHORT).show());
            })
            .setNegativeButton("Cancel", null)
            .show();
    }

    private static class AnnouncementAdapter extends androidx.recyclerview.widget.RecyclerView.Adapter<AnnouncementAdapter.ViewHolder> {
        private List<Announcement> list;
        private final java.util.function.Consumer<Announcement> onEdit;
        private final java.util.function.Consumer<Announcement> onDelete;

        AnnouncementAdapter(List<Announcement> list, java.util.function.Consumer<Announcement> onEdit, 
                           java.util.function.Consumer<Announcement> onDelete) {
            this.list = list;
            this.onEdit = onEdit;
            this.onDelete = onDelete;
        }

        void updateList(List<Announcement> newList) {
            this.list = newList;
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull android.view.ViewGroup parent, int viewType) {
            android.view.View view = LayoutInflater.from(parent.getContext())
                .inflate(android.R.layout.simple_list_item_2, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            Announcement ann = list.get(position);
            ((android.widget.TextView) holder.itemView.findViewById(android.R.id.text1))
                .setText(ann.getTitle() + " (" + ann.getType() + ")");
            ((android.widget.TextView) holder.itemView.findViewById(android.R.id.text2))
                .setText(ann.getDate() + " | " + ann.getMessage());
            
            holder.itemView.setOnClickListener(v -> onEdit.accept(ann));
            holder.itemView.setOnLongClickListener(v -> {
                onDelete.accept(ann);
                return true;
            });
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        static class ViewHolder extends androidx.recyclerview.widget.RecyclerView.ViewHolder {
            ViewHolder(android.view.View itemView) {
                super(itemView);
            }
        }
    }
}
