package com.photoatom.backend.Configuration;

import java.io.IOException;
import javax.net.ssl.SSLContext;

import org.springframework.http.client.SimpleClientHttpRequestFactory;

public class CustomRequestFactory extends SimpleClientHttpRequestFactory {

  private final SSLContext sslContext;

  public CustomRequestFactory(SSLContext sslContext) {
    this.sslContext = sslContext;
  }

  @Override
  protected void prepareConnection(java.net.HttpURLConnection connection, String httpMethod) throws IOException {
    if (connection instanceof javax.net.ssl.HttpsURLConnection) {
      ((javax.net.ssl.HttpsURLConnection) connection).setSSLSocketFactory(sslContext.getSocketFactory());
    }
    super.prepareConnection(connection, httpMethod);
  }
}
