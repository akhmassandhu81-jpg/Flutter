package com.example.ecomerceapp;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import com.example.ecomerceapp.fragments.CartFragment;
import com.example.ecomerceapp.fragments.HomeFragment;
import com.example.ecomerceapp.fragments.OrdersFragment;
import com.example.ecomerceapp.fragments.ProfileFragment;
import com.google.android.material.bottomnavigation.BottomNavigationView;

public class MainActivity extends AppCompatActivity {

    private BottomNavigationView bottomNav;
    private boolean isFragmentLoading = false;
    
    // Fragment instances for reuse
    private Fragment homeFragment;
    private Fragment cartFragment;
    private Fragment ordersFragment;
    private Fragment profileFragment;
    private Fragment currentFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            setContentView(R.layout.activity_main);
        } catch (Exception e) {
            android.util.Log.e("MainActivity", "Error setting content view: " + e.getMessage());
            finish();
            return;
        }

        try {
            bottomNav = findViewById(R.id.bottomNav);
            if (bottomNav == null) {
                android.util.Log.e("MainActivity", "BottomNavigationView not found in layout");
                finish();
                return;
            }
        } catch (Exception e) {
            android.util.Log.e("MainActivity", "Error finding views: " + e.getMessage());
            finish();
            return;
        }

        // Initialize fragments only once
        if (savedInstanceState == null) {
            homeFragment = new HomeFragment();
            cartFragment = new CartFragment();
            ordersFragment = new OrdersFragment();
            profileFragment = new ProfileFragment();
            
            // Load HomeFragment by default
            try {
                getSupportFragmentManager()
                    .beginTransaction()
                    .add(R.id.fragment_container, homeFragment, "home")
                    .add(R.id.fragment_container, cartFragment, "cart")
                    .add(R.id.fragment_container, ordersFragment, "orders")
                    .add(R.id.fragment_container, profileFragment, "profile")
                    .hide(cartFragment)
                    .hide(ordersFragment)
                    .hide(profileFragment)
                    .commit();
                currentFragment = homeFragment;
            } catch (Exception e) {
                android.util.Log.e("MainActivity", "Error loading fragments: " + e.getMessage());
            }
        } else {
            // Restore fragments from savedInstanceState
            homeFragment = getSupportFragmentManager().findFragmentByTag("home");
            cartFragment = getSupportFragmentManager().findFragmentByTag("cart");
            ordersFragment = getSupportFragmentManager().findFragmentByTag("orders");
            profileFragment = getSupportFragmentManager().findFragmentByTag("profile");
            
            // Find current visible fragment
            if (homeFragment != null && homeFragment.isVisible()) {
                currentFragment = homeFragment;
            } else if (cartFragment != null && cartFragment.isVisible()) {
                currentFragment = cartFragment;
            } else if (ordersFragment != null && ordersFragment.isVisible()) {
                currentFragment = ordersFragment;
            } else if (profileFragment != null && profileFragment.isVisible()) {
                currentFragment = profileFragment;
            }
        }

        bottomNav.setOnItemSelectedListener(item -> {
            if (isFragmentLoading) {
                return true; // Prevent double loading
            }

            int id = item.getItemId();
            Fragment targetFragment = null;

            if (id == R.id.nav_home) {
                targetFragment = homeFragment;
            } else if (id == R.id.nav_cart) {
                targetFragment = cartFragment;
            } else if (id == R.id.nav_orders) {
                targetFragment = ordersFragment;
            } else if (id == R.id.nav_profile) {
                targetFragment = profileFragment;
            }

            if (targetFragment != null && currentFragment != targetFragment) {
                switchFragment(targetFragment);
                return true;
            }
            return false;
        });
    }

    private void switchFragment(Fragment targetFragment) {
        isFragmentLoading = true;
        try {
            getSupportFragmentManager()
                    .beginTransaction()
                    .hide(currentFragment)
                    .show(targetFragment)
                    .commit();
            currentFragment = targetFragment;
        } catch (Exception e) {
            android.util.Log.e("MainActivity", "Error switching fragment: " + e.getMessage());
        } finally {
            isFragmentLoading = false;
        }
    }

    public void loadFragment(Fragment fragment, boolean updateNavSelection) {
        // For external calls, find the matching fragment and switch to it
        if (fragment instanceof HomeFragment) {
            switchFragment(homeFragment);
            if (updateNavSelection) bottomNav.setSelectedItemId(R.id.nav_home);
        } else if (fragment instanceof CartFragment) {
            switchFragment(cartFragment);
            if (updateNavSelection) bottomNav.setSelectedItemId(R.id.nav_cart);
        } else if (fragment instanceof OrdersFragment) {
            switchFragment(ordersFragment);
            if (updateNavSelection) bottomNav.setSelectedItemId(R.id.nav_orders);
        } else if (fragment instanceof ProfileFragment) {
            switchFragment(profileFragment);
            if (updateNavSelection) bottomNav.setSelectedItemId(R.id.nav_profile);
        }
    }

    @Override
    public void onBackPressed() {
        // Handle back button - if on home, exit app, otherwise go to home
        if (bottomNav.getSelectedItemId() != R.id.nav_home) {
            bottomNav.setSelectedItemId(R.id.nav_home);
        } else {
            super.onBackPressed();
        }
    }
}