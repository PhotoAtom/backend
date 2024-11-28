package com.photoatom.backend.Configuration;

import org.springframework.beans.factory.annotation.Value;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.core.convert.converter.Converter;

import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.web.SecurityFilterChain;

import org.springframework.web.client.RestTemplate;

import lombok.extern.slf4j.Slf4j;

import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;

import java.util.Map;
import java.util.Optional;
import java.util.stream.Stream;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;

import java.io.FileInputStream;
import java.io.IOException;

import java.security.GeneralSecurityException;
import java.security.KeyStore;

import java.util.Collection;
import java.util.List;

@Slf4j
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfiguration {

  @Value("${spring.security.oauth2.resourceserver.jwt.issuer-uri}")
  String issuerUri;

  // Keycloak CA Certificate Path
  @Value("${keycloak.caCertPath}")
  private String caCertPath;

  // Keycloak CA Certificate Password
  @Value("${keycloak.caCertPassword}")
  private String caCertPassword;

  // Keycloak User Certificate Path
  @Value("${keycloak.userCertPath}")
  private String userCertPath;

  // Keycloak User Certificate Password
  @Value("${keycloak.userCertPassword}")
  private String userCertPassword;

  interface AuthoritiesConverter extends Converter<Map<String, Object>, Collection<GrantedAuthority>> {
  }

  /**
   * Converting Keycloak Realm Roles to Authorities
   *
   * @return AuthoritiesConverter
   */
  @Bean
  AuthoritiesConverter realmRolesAuthoritiesConverter() {
    return claims -> {
      // Get Realms Access
      final var realmAccess = Optional.ofNullable((Map<String, Object>) claims.get("realm_access"));

      // Extract applied roles on the user
      final var roles = realmAccess.flatMap(map -> Optional.ofNullable((List<String>) map.get("roles")));

      // Map all roles to GrantedAuthorities.
      return roles.map(List::stream).orElse(Stream.empty()).map(SimpleGrantedAuthority::new)
          .map(GrantedAuthority.class::cast).toList();
    };
  }

  /**
   * Conversion of JWT to a Spring Boot Authentication
   * which is a collection of granted authorities.
   *
   * @param authoritiesConverter
   * @return JwtAuthenticationConverter
   */
  @Bean
  JwtAuthenticationConverter authenticationConverter(
      Converter<Map<String, Object>, Collection<GrantedAuthority>> authoritiesConverter) {

    // Initialize JWT to Authentication Converter
    var authenticationConverter = new JwtAuthenticationConverter();

    // Set Granted Authorities to the claims extracted from the JWT
    authenticationConverter.setJwtGrantedAuthoritiesConverter(jwt -> {
      return authoritiesConverter.convert(jwt.getClaims());
    });

    // Return Authentication Converter
    return authenticationConverter;
  }

  /**
   * Override the JWT Decode process by supplying
   * Keycloak Ingress Certificates to use against
   * the Issuer URI.
   *
   * @return
   * @throws IOException
   * @throws GeneralSecurityException
   */
  @Bean
  JwtDecoder jwtDecoder() throws IOException, GeneralSecurityException {

    // Load keycloak SSL certificates
    SSLContext sslSocket = createSslSocketFactory(caCertPath, caCertPassword, userCertPath, userCertPassword);

    // For REST Operations, attach the SSL certificates to ensure SSL communication
    RestTemplate restOperations = new RestTemplate(new CustomRequestFactory(sslSocket));

    // Return the Decoder with Issuer URI and configured REST Operations
    return NimbusJwtDecoder.withIssuerLocation(issuerUri)
        .restOperations(restOperations).build();
  }

  /**
   * OAuth2 Resource Server Authentication Implementation
   *
   * @param http
   * @param authenticationConverter
   * @return SecurityFilterChain
   * @throws Exception
   */
  @Bean
  public SecurityFilterChain resourceServerSecurityFilterChain(HttpSecurity http,
      Converter<Jwt, AbstractAuthenticationToken> authenticationConverter) throws Exception {

    // Set the JWT to Authentication Converter
    http.oauth2ResourceServer(resourceServer -> {
      resourceServer.jwt(jwtDecoder -> {
        jwtDecoder.jwtAuthenticationConverter(authenticationConverter);
      });
    });

    // Disable CSRF protection
    http.sessionManagement(sessions -> {
      sessions.sessionCreationPolicy(SessionCreationPolicy.STATELESS);
    }).csrf(csrf -> {
      csrf.disable();
    });

    // Methods and paths to protect with authentication
    http.authorizeHttpRequests(requests -> {
      requests.requestMatchers("/dummy").authenticated();
      requests.anyRequest().denyAll();
    });

    // Return all authentication rules
    return http.build();
  }

  /**
   * Generate SSL Context for the provided certificates path and passwords.
   *
   * @param caCertPath       CA Certificate Path
   * @param caCertPassword   CA Certificate Password
   * @param userCertPath     User Certificate Path
   * @param userCertPassword User Certificate Password
   * @return SSLContext
   * @throws IOException
   * @throws GeneralSecurityException
   */
  private SSLContext createSslSocketFactory(
      String caCertPath, String caCertPassword, String userCertPath, String userCertPassword)
      throws IOException, GeneralSecurityException {

    KeyStore keyStore = KeyStore.getInstance("pkcs12");
    keyStore.load(new FileInputStream(userCertPath), userCertPassword.toCharArray());

    KeyStore trustStore = KeyStore.getInstance("jks");
    trustStore.load(new FileInputStream(caCertPath), caCertPassword.toCharArray());

    TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance("X509");
    trustManagerFactory.init(trustStore);

    KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance("PKIX");
    keyManagerFactory.init(keyStore, userCertPassword.toCharArray());

    SSLContext sslContext = SSLContext.getInstance("SSL");
    sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);

    return sslContext;
  }

}
