package com.practice.etl.util;

import org.junit.Test;

/**
 * @author qxy
 */
public class EtlUtil {
    public static String etl(String s) {
        String[] words = s.split("\t");
        int minLen = 9;
        if (words.length < minLen) {
            return null;
        }
        words[3] = words[3].replaceAll(" & ", "&");
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < words.length; i++) {
            String splitStr = "";
            splitStr = i <= 8 ? "\t" : "&";
            splitStr = i == words.length - 1 ? "":splitStr;
            sb.append(words[i]);
            sb.append(splitStr);
        }
        return sb.toString();
    }
}
