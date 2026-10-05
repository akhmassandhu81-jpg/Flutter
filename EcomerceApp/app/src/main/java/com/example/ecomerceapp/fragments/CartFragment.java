package com.example.ecomerceapp.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.ecomerceapp.R;
import com.example.ecomerceapp.activities.CheckoutActivity;
import com.example.ecomerceapp.adapters.CartAdapter;
import com.example.ecomerceapp.models.CartItem;
import com.example.ecomerceapp.repositories.CartRepository;
import com.example.ecomerceapp.utils.PriceFormatter;
import com.example.ecomerceapp.viewmodels.CartViewModel;
import com.google.android.material.button.MaterialButton;
import com.google.firebase.auth.FirebaseUser;
import com.example.ecomerceapp.utils.FirebaseUtil;

import java.util.ArrayList;
import java.util.List;

public class CartFragment extends Fragment implements CartAdapter.Listener {

    private ImageButton btnDeleteAll;
    private ProgressBar progress;
    private TextView tvEmpty;
    private RecyclerView recycler;
    private TextView tvTotalItems;
    private TextView tvTotal;
    private MaterialButton btnCheckout;

    private CartAdapter adapter;
    private CartViewModel viewModel;
    private boolean hasLoadedData = false;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        try {
            View view = inflater.inflate(R.layout.activity_cart, container, false);

            btnDeleteAll = view.findViewById(R.id.btnDeleteAll);
            progress = view.findViewById(R.id.progress);
            tvEmpty = view.findViewById(R.id.tvEmpty);
            recycler = view.findViewById(R.id.recycler);
            tvTotalItems = view.findViewById(R.id.tvTotalItems);
            tvTotal = view.findViewById(R.id.tvTotal);
            btnCheckout = view.findViewById(R.id.btnCheckout);

            // Hide back button since MainActivity handles navigation
            ImageButton btnBack = view.findViewById(R.id.btnBack);
            if (btnBack != null) {
                btnBack.setVisibility(View.GONE);
            }

            // Initialize ViewModel
            viewModel = new ViewModelProvider(this).get(CartViewModel.class);

            adapter = new CartAdapter(requireContext(), this);
            recycler.setLayoutManager(new LinearLayoutManager(requireContext()));
            recycler.setHasFixedSize(true);
            recycler.setAdapter(adapter);

            btnDeleteAll.setOnClickListener(v -> clearCart());
            btnCheckout.setOnClickListener(v -> {
                if (adapter.getItemCount() == 0) {
                    Toast.makeText(requireContext(), "Your cart is empty", Toast.LENGTH_SHORT).show();
                    return;
                }
                startActivity(new Intent(requireContext(), CheckoutActivity.class));
            });

            FirebaseUser user = FirebaseUtil.auth().getCurrentUser();
            if (user == null) {
                Toast.makeText(requireContext(), "Please login first", Toast.LENGTH_SHORT).show();
                return view;
            }

            observeData();
            
            // Load data only once
            if (!hasLoadedData) {
                viewModel.loadCart(user.getUid(), false);
                hasLoadedData = true;
            }

            return view;
        } catch (Exception e) {
            android.util.Log.e("CartFragment", "Error in onCreateView: " + e.getMessage());
            TextView errorView = new TextView(requireContext());
            errorView.setText("Error loading cart");
            errorView.setPadding(32, 32, 32, 32);
            return errorView;
        }
    }

    private void observeData() {
        // Observe cart items
        viewModel.getCartItems().observe(getViewLifecycleOwner(), items -> {
            if (items != null) {
                adapter.submit(items);
                tvEmpty.setVisibility(items.isEmpty() ? View.VISIBLE : View.GONE);
                tvTotalItems.setText("Total (" + items.size() + " items)");
            }
        });

        // Observe cart total
        viewModel.getCartTotal().observe(getViewLifecycleOwner(), total -> {
            if (total != null) {
                tvTotal.setText(PriceFormatter.formatPrice(total));
            }
        });

        // Observe loading state
        viewModel.getCartLoading().observe(getViewLifecycleOwner(), loading -> {
            if (loading != null) {
                progress.setVisibility(loading ? View.VISIBLE : View.GONE);
            }
        });
    }

    @Override
    public void onIncrease(CartItem item) {
        viewModel.increaseQuantity(item, (success, error) -> {
            if (!success && error != null) {
                Toast.makeText(requireContext(), error, Toast.LENGTH_SHORT).show();
            }
        });
    }

    @Override
    public void onDecrease(CartItem item) {
        viewModel.decreaseQuantity(item);
    }

    @Override
    public void onRemove(CartItem item) {
        viewModel.removeItem(item);
    }

    @Override
    public void onSelectChanged(CartItem item, boolean isSelected) {
        // Not used in basic version
    }

    private void clearCart() {
        viewModel.clearCart((success, error) -> {
            if (success) {
                Toast.makeText(requireContext(), "Cart cleared", Toast.LENGTH_SHORT).show();
            } else {
                Toast.makeText(requireContext(), "Failed to clear cart", Toast.LENGTH_SHORT).show();
            }
        });
    }
}
