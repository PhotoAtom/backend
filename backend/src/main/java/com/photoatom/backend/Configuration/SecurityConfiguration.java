package com.photoatom.backend.Configuration;

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

import lombok.extern.slf4j.Slf4j;

import org.springframework.security.oauth2.jwt.Jwt;

import java.util.Map;
import java.util.Optional;
import java.util.stream.Stream;

import java.util.Collection;
import java.util.List;

@Slf4j
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfiguration {

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

}
