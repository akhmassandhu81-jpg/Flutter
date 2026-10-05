package com.example.ecomerceapp;

import android.app.Application;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.ViewTarget;

public class EcommerceApp extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        
        // Set Glide view tag to improve performance
        ViewTarget.setTagId(R.id.glide_tag_id);
    }
}
