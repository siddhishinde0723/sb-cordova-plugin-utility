package org.sunbird.config;


import org.json.JSONException;
import org.json.JSONObject;
import org.sunbird.support.Base64Util;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;


public class JWTTokenCreator {
	  private static String SEPARATOR = ".";
	
	public static String createJWToken(String subject, String secretKey, JWTokenType tokenType) throws JSONException {
        if (tokenType == null) {
            tokenType = JWTokenType.HS256;
        }
        String payLoad = createHeader(tokenType) + SEPARATOR + createBody(subject);
        System.out.println(payLoad);
        String signature = encodeToBase64Uri(CryptoUtil.generateHMAC(payLoad, secretKey.getBytes(), tokenType.getAlgorithmName()));
        System.out.println(signature);
        return payLoad + SEPARATOR + signature;
    }

    private static String createHeader(JWTokenType tokenType) throws JSONException {
        Map<String, String> headerData = new HashMap<>();
        headerData.put("alg", tokenType.getTokenType());
        JSONObject json = new JSONObject();
        json.put("alg", tokenType.getTokenType());
        return encodeToBase64Uri(json.toString().getBytes());
    }


    private static String createBody(String subject) throws JSONException {
        Map<String, String> payloadData = new HashMap<>();
        payloadData.put("iss", subject);
        JSONObject json = new JSONObject();
        json.put("iss", subject);
        return encodeToBase64Uri(json.toString().getBytes());
    }

    private static String encodeToBase64Uri(byte[] data) {
        return Base64Util.encodeToString(data, 11);
    }

    public static String decodeToken(String token) throws JSONException {
        String[] parts = token.split("\\.");
        return new String(android.util.Base64.decode(parts[1], android.util.Base64.DEFAULT),
                StandardCharsets.UTF_8);
    }

}
