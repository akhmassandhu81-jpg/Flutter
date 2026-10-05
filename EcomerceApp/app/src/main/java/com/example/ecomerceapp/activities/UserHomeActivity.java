package com.example.ecomerceapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.adapters.AnnouncementAdapter;
import com.example.ecomerceapp.adapters.HomeProductAdapter;
import com.example.ecomerceapp.models.Announcement;
import com.example.ecomerceapp.models.Product;
import com.example.ecomerceapp.utils.FirebaseUtil;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.ValueEventListener;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class UserHomeActivity extends AppCompatActivity {

    private EditText etSearch;
    private ImageButton btnFilter;
    private BottomNavigationView bottomNav;
    private RecyclerView recyclerCategories;
    private RecyclerView recyclerAllProducts;
    private RecyclerView recyclerAnnouncements;
    private TextView tvViewAllAnnouncements;
    
    private HomeProductAdapter allProductsAdapter;
    private CategoryAdapter categoryAdapter;
    private String selectedCategory = null;
    private final List<Product> allProductsMaster = new ArrayList<>();
    private String searchQuery = "";
    private int sortMode = 0;
    
    private AnnouncementAdapter announcementAdapter;
    
    private ValueEventListener allProductsListener;
    private ValueEventListener announcementsListener;
    
    private final String[] categories = {"All", "Electronics", "Sports", "Food", "Fashion and Clothing"};
    private final String[] sortOptions = {"Default", "Price: Low to High", "Price: High to Low", "Name: A-Z"};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user_home);

        etSearch = findViewById(R.id.etSearch);
        btnFilter = findViewById(R.id.btnFilter);
        bottomNav = findViewById(R.id.bottomNav);
        recyclerCategories = findViewById(R.id.recyclerCategories);
        recyclerAllProducts = findViewById(R.id.recyclerAllProducts);
        recyclerAnnouncements = findViewById(R.id.recyclerAnnouncements);
        tvViewAllAnnouncements = findViewById(R.id.tvViewAllAnnouncements);

        setupUI();
        loadCategories();
        loadAnnouncements();
        loadAllProducts();
    }
    
    private void loadCategories() {
        categoryAdapter = new CategoryAdapter(categories, this::onCategorySelected);
        recyclerCategories.setLayoutManager(new LinearLayoutManager(this, RecyclerView.HORIZONTAL, false));
        recyclerCategories.setHasFixedSize(true);
        recyclerCategories.setAdapter(categoryAdapter);
    }
    
    private void onCategorySelected(String category) {
        selectedCategory = "All".equals(category) ? null : category;
        applyProductFilters();
    }

    private void loadAnnouncements() {
        announcementAdapter = new AnnouncementAdapter(this, new ArrayList<>());
        recyclerAnnouncements.setLayoutManager(new LinearLayoutManager(this, RecyclerView.HORIZONTAL, false));
        recyclerAnnouncements.setHasFixedSize(true);
        recyclerAnnouncements.setAdapter(announcementAdapter);

        // "View All" click listener
        tvViewAllAnnouncements.setOnClickListener(v -> {
            startActivity(new Intent(UserHomeActivity.this, AnnouncementsActivity.class));
        });

        // Load latest 3 announcements
        announcementsListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                List<Announcement> announcements = new ArrayList<>();
                for (DataSnapshot s : snapshot.getChildren()) {
                    Announcement a = s.getValue(Announcement.class);
                    if (a != null && a.isActive()) {
                        a.setId(s.getKey());
                        announcements.add(a);
                    }
                }

                // Sort by timestamp (newest first) and limit to 3
                Collections.sort(announcements, new Comparator<Announcement>() {
                    @Override
                    public int compare(Announcement a1, Announcement a2) {
                        String t1 = a1.getTimestamp() != null ? a1.getTimestamp() : "";
                        String t2 = a2.getTimestamp() != null ? a2.getTimestamp() : "";
                        return t2.compareTo(t1);
                    }
                });

                // Limit to 3 items for home screen
                List<Announcement> limitedList = new ArrayList<>();
                for (int i = 0; i < Math.min(3, announcements.size()); i++) {
                    limitedList.add(announcements.get(i));
                }

                announcementAdapter.submit(limitedList);
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                // Handle error
            }
        };
        FirebaseUtil.announcementsRef().addListenerForSingleValueEvent(announcementsListener);
    }

    private void setupUI() {
        // Search (filter locally by product name)
        etSearch.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                searchQuery = s != null ? s.toString() : "";
                applyProductFilters();
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });

        // Filter button (sort options)
        btnFilter.setOnClickListener(v -> showSortDialog());

        // Bottom Navigation
        bottomNav.setOnItemSelectedListener(item -> {
            int id = item.getItemId();
            if (id == R.id.nav_home) {
                return true;
            } else if (id == R.id.nav_cart) {
                startActivity(new Intent(UserHomeActivity.this, CartActivity.class));
                return true;
            } else if (id == R.id.nav_orders) {
                startActivity(new Intent(UserHomeActivity.this, OrderHistoryActivity.class));
                return true;
            } else if (id == R.id.nav_profile) {
                startActivity(new Intent(UserHomeActivity.this, SettingsActivity.class));
                return true;
            }
            return false;
        });
    }

    private void loadAllProducts() {
        if (allProductsAdapter == null) {
            allProductsAdapter = new HomeProductAdapter();

            // 2-column grid layout
            GridLayoutManager gridLayoutManager = new GridLayoutManager(this, 2);
            recyclerAllProducts.setLayoutManager(gridLayoutManager);
            recyclerAllProducts.setHasFixedSize(true);
            recyclerAllProducts.setAdapter(allProductsAdapter);
        }

        // Use limitToLast to get most recent products, limit to 50 for performance
        allProductsListener = new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot snapshot) {
                allProductsMaster.clear();
                int totalCount = 0;
                int approvedCount = 0;
                int pendingCount = 0;
                
                for (DataSnapshot s : snapshot.getChildren()) {
                    Product p = s.getValue(Product.class);
                    if (p != null) {
                        totalCount++;
                        if (p.getId() == null) p.setId(s.getKey());
                        
                        // Show all products for now (remove isApproved() check for testing)
                        allProductsMaster.add(p);
                        
                        // Log status for debugging
                        String status = p.getStatus() != null ? p.getStatus() : "null";
                        if ("approved".equals(status)) {
                            approvedCount++;
                        } else if ("pending".equals(status)) {
                            pendingCount++;
                        }
                    }
                }
                
                android.util.Log.d("UserHome", "Total products: " + totalCount + ", Approved: " + approvedCount + ", Pending: " + pendingCount);
                applyProductFilters();
            }

            @Override
            public void onCancelled(@NonNull DatabaseError error) {
                android.util.Log.e("UserHome", "Error loading products: " + error.getMessage());
                Toast.makeText(UserHomeActivity.this, "Error loading products", Toast.LENGTH_SHORT).show();
            }
        };
        FirebaseUtil.productsRef().limitToLast(50).addValueEventListener(allProductsListener);
    }

    private void showSortDialog() {
        new androidx.appcompat.app.AlertDialog.Builder(this)
                .setTitle("Sort")
                .setSingleChoiceItems(sortOptions, sortMode, (dialog, which) -> {
                    sortMode = which;
                })
                .setPositiveButton("Apply", (dialog, which) -> applyProductFilters())
                .setNegativeButton("Cancel", null)
                .show();
    }

    private void applyProductFilters() {
        if (allProductsAdapter == null) return;

        String q = searchQuery != null ? searchQuery.trim().toLowerCase() : "";
        List<Product> filtered = new ArrayList<>();
        for (Product p : allProductsMaster) {
            if (p == null) continue;

            if (selectedCategory != null && (p.getCategory() == null || !selectedCategory.equals(p.getCategory()))) {
                continue;
            }

            if (!q.isEmpty()) {
                String name = p.getName() != null ? p.getName().toLowerCase() : "";
                if (!name.contains(q)) continue;
            }

            filtered.add(p);
        }

        // Sorting
        if (sortMode == 1) {
            Collections.sort(filtered, (a, b) -> Double.compare(a.getPrice(), b.getPrice()));
        } else if (sortMode == 2) {
            Collections.sort(filtered, (a, b) -> Double.compare(b.getPrice(), a.getPrice()));
        } else if (sortMode == 3) {
            Collections.sort(filtered, (a, b) -> {
                String n1 = a.getName() != null ? a.getName() : "";
                String n2 = b.getName() != null ? b.getName() : "";
                return n1.compareToIgnoreCase(n2);
            });
        }

        allProductsAdapter.submitList(filtered);
    }
    
    // Simple Category Adapter
    private static class CategoryAdapter extends RecyclerView.Adapter<CategoryAdapter.ViewHolder> {
        private final String[] categories;
        private final java.util.function.Consumer<String> onClick;
        private int selectedPosition = 0;

        CategoryAdapter(String[] categories, java.util.function.Consumer<String> onClick) {
            this.categories = categories;
            this.onClick = onClick;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_category_chip, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            String category = categories[position];
            holder.tvCategory.setText(category);
            
            // Styling based on selection
            if (position == selectedPosition) {
                holder.cardView.setCardBackgroundColor(0xFF2D5A4A);
                holder.tvCategory.setTextColor(0xFFFFFFFF);
                holder.cardView.setStrokeWidth(0);
            } else {
                holder.cardView.setCardBackgroundColor(0xFFFFFFFF);
                holder.tvCategory.setTextColor(0xFF6B7280);
                holder.cardView.setStrokeWidth(1);
            }
            
            holder.itemView.setOnClickListener(v -> {
                selectedPosition = position;
                onClick.accept(category);
                notifyDataSetChanged();
            });
        }

        @Override
        public int getItemCount() {
            return categories.length;
        }

        static class ViewHolder extends RecyclerView.ViewHolder {
            com.google.android.material.card.MaterialCardView cardView;
            TextView tvCategory;

            ViewHolder(View itemView) {
                super(itemView);
                cardView = (com.google.android.material.card.MaterialCardView) itemView;
                tvCategory = itemView.findViewById(R.id.tvCategory);
            }
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (allProductsListener != null) {
            FirebaseUtil.productsRef().removeEventListener(allProductsListener);
        }
        if (announcementsListener != null) {
            FirebaseUtil.announcementsRef().removeEventListener(announcementsListener);
        }
    }
}
