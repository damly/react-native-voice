package com.damly.voice.recognizer.microsoft;

/**
 * Created by damly on 2018/1/17.
 */

import com.damly.voice.recognizer.microsoft.SpeechAPI.*;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

public class SpeechClient {

    private static final String REQUEST_URI = "https://speech.platform.bing" +
            ".com/speech/recognition/%s/cognitiveservices/v1";
    private static final String PARAMETERS = "language=%s&format=%s";

    private RecognitionMode mode = RecognitionMode.Interactive;
    private Language language = Language.en_US;
    private OutputFormat format = OutputFormat.Simple;

    private final Authentication auth;

    public SpeechClient(String subscriptionKey) {
        this.auth = new Authentication(subscriptionKey);
    }

    public SpeechClient(Authentication auth) {
        this.auth = auth;
    }

    public RecognitionMode getMode() {
        return mode;
    }

    public void setMode(RecognitionMode mode) {
        this.mode = mode;
    }

    public Language getLanguage() {
        return language;
    }

    public void setLanguage(Language language) {
        this.language = language;
    }

    public void setLanguage(String langCode) {

        Language language = Language.en_US;
        for (Language e : Language.values()) {
            String code = e.name().replace('_', '-');

            if(code.toLowerCase().equals(langCode.toLowerCase())) {
                language = e;
                break;
            }
        }

        this.language = language;
    }

    public OutputFormat getFormat() {
        return format;
    }

    public void setFormat(OutputFormat format) {
        this.format = format;
    }

    private URL buildRequestURL() throws MalformedURLException {
        String url = String.format(REQUEST_URI, mode.name().toLowerCase());
        String params = String.format(PARAMETERS, language.name().replace('_', '-'), format.name().toLowerCase());
        return new URL(String.format("%s?%s", url, params));
    }

    private HttpURLConnection connect() throws MalformedURLException, IOException {
        HttpURLConnection connection = (HttpURLConnection) buildRequestURL().openConnection();
        connection.setDoInput(true);
        connection.setDoOutput(true);
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-type", "audio/wav; codec=\"audio/pcm\"; samplerate=16000");
        connection.setRequestProperty("Accept", "application/json;text/xml");
        connection.setRequestProperty("Authorization", "Bearer " + auth.getToken());
        connection.setChunkedStreamingMode(0); // 0 == default chunk size
        connection.connect();

        return connection;
    }

    private String getResponse(HttpURLConnection connection) throws IOException {
        if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
            throw new RuntimeException(String.format("Something went wrong, server returned: %d (%s)",
                    connection.getResponseCode(), connection.getResponseMessage()));
        }
        BufferedReader reader =
                new BufferedReader(new InputStreamReader(connection.getInputStream()));

        String source = "";
        String line;

        while ((line = reader.readLine()) != null) {
            source += line;
        }

        return source;
    }

    private HttpURLConnection upload(InputStream is, HttpURLConnection connection) throws IOException {

        OutputStream output = connection.getOutputStream();
        byte[] buffer = new byte[1024];
        int length;
        while ((length = is.read(buffer)) != -1) {
            output.write(buffer, 0, length);
        }
        output.flush();

        return connection;
    }

    public JSONObject process(String path) throws Exception {
        InputStream input = new FileInputStream(path);
        return new JSONObject(getResponse(upload(input, connect())));
    }
}