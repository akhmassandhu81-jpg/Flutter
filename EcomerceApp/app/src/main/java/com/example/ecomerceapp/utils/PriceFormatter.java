package com.example.ecomerceapp.utils;

import java.text.NumberFormat;
import java.util.Locale;

public class PriceFormatter {

    /**
     * Formats a price in Pakistani Rupees (PKR)
     * @param price The price value
     * @return Formatted price string (e.g., "Rs 5,000")
     */
    public static String formatPrice(double price) {
        NumberFormat formatter = NumberFormat.getInstance();
        return "Rs " + formatter.format(price);
    }

    /**
     * Formats a price in Pakistani Rupees (PKR) from a long value
     * @param price The price value as long
     * @return Formatted price string (e.g., "Rs 5,000")
     */
    public static String formatPrice(long price) {
        NumberFormat formatter = NumberFormat.getInstance();
        return "Rs " + formatter.format(price);
    }

    /**
     * Formats a price in Pakistani Rupees (PKR) from an int value
     * @param price The price value as int
     * @return Formatted price string (e.g., "Rs 5,000")
     */
    public static String formatPrice(int price) {
        NumberFormat formatter = NumberFormat.getInstance();
        return "Rs " + formatter.format(price);
    }
}
