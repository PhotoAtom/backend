package com.photoatom.backend.Configuration;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.KeyStore;
import java.time.Duration;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManagerFactory;
import javax.net.ssl.SSLContext;

import org.springframework.beans.factory.annotation.Value;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;

import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.connection.RedisPassword;
import org.springframework.data.redis.connection.RedisStandaloneConfiguration;
import org.springframework.data.redis.connection.jedis.JedisClientConfiguration;
import org.springframework.data.redis.connection.jedis.JedisConnectionFactory;

import org.springframework.data.redis.core.RedisTemplate;

import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext.SerializationPair;

/**
 * Configuration class for Valkey Connection using Jedis Library
 */
@Configuration
public class ValkeyConfiguration {

  // Valkey Host
  @Value("${valkey.host}")
  private String redisHost;

  // Valkey Port
  @Value("${valkey.port}")
  private Integer redisPort;

  // Valkey Password
  @Value("${valkey.password}")
  private String redisPassword;

  // Valkey CA Certificate Path
  @Value("${valkey.caCertPath}")
  private String caCertPath;

  // Valkey CA Certificate Password
  @Value("${valkey.caCertPassword}")
  private String caCertPassword;

  // Valkey User Certificate Path
  @Value("${valkey.userCertPath}")
  private String userCertPath;

  // Valkey User Certificate Password
  @Value("${valkey.userCertPassword}")
  private String userCertPassword;

  /**
   * Jedis Connection Factory Bean with SSL and other connection
   * parameters.
   *
   * @return JedisConnectionFactory
   * @throws GeneralSecurityException
   * @throws IOException
   */
  @Bean
  JedisConnectionFactory jedisConnectionFactory() throws GeneralSecurityException, IOException {

    // Inserting Valkey configuration details as Redis Configuration.
    RedisStandaloneConfiguration redisStandaloneConfiguration = new RedisStandaloneConfiguration();

    redisStandaloneConfiguration.setHostName(redisHost);
    redisStandaloneConfiguration.setPort(redisPort);
    redisStandaloneConfiguration.setPassword(RedisPassword.of(redisPassword));

    // Generating SSL Factory for creating TLS connections with Valkey Database.
    // Generate Truststore and Keystore using:
    // openssl pkcs12 -export -in certificates/cache/tls.crt -inkey
    // certificates/cache/tls.key -out certificates/cache/valkeystore.p12 -name
    // "redis"
    // keytool -importcert -keystore certificates/cache/truststore.jks -storepass
    // changeit -file certificates/cache/ca.crt
    SSLSocketFactory sslFactory = createSslSocketFactory(caCertPath, caCertPassword, userCertPath, userCertPassword);

    // Specifying SSL Connection configuration
    JedisClientConfiguration jedisClientConfiguration = JedisClientConfiguration.builder().useSsl()
        .sslSocketFactory(sslFactory).build();

    // Forming connection factory using both Jedis and Redis configuration.
    JedisConnectionFactory jedisConnectionFactory = new JedisConnectionFactory(redisStandaloneConfiguration,
        jedisClientConfiguration);

    return jedisConnectionFactory;
  }

  /**
   * Redis Template Configuration with Connection Factory Bean.
   *
   * @return RedisTemplate
   * @throws GeneralSecurityException
   * @throws IOException
   */
  @Bean
  RedisTemplate<String, Object> redisTemplate() throws GeneralSecurityException, IOException {

    RedisTemplate<String, Object> template = new RedisTemplate<>();
    template.setConnectionFactory(jedisConnectionFactory());

    return template;
  }

  /**
   * Configuration for caching using Valkey, provides Cache Manager Bean.
   *
   * @param connectionFactory
   * @return RedisCacheManager
   */
  @Bean
  public RedisCacheManager cacheManager(RedisConnectionFactory connectionFactory) {

    connectionFactory.getConnection().echo("Connection ECHO".getBytes(StandardCharsets.UTF_8));
    // Validating connection with the Valkey database.

    // Setting cache configuration such as cache name, TTL duration and
    // serialization.
    RedisCacheConfiguration cacheConfiguration = RedisCacheConfiguration.defaultCacheConfig()
        .prefixCacheNameWith(this.getClass().getPackageName() + ".").entryTtl(Duration.ofMinutes(15))
        .serializeValuesWith(SerializationPair.fromSerializer(new GenericJackson2JsonRedisSerializer()))
        .disableCachingNullValues();

    return RedisCacheManager.builder(connectionFactory).enableStatistics().cacheDefaults(cacheConfiguration).build();

  }

  /**
   * Generate SSL Socket Factory for the provided certificates path and passwords.
   * Reference:
   * https://redis.io/docs/latest/develop/clients/jedis/connect/#connect-to-your-production-redis-with-tls
   *
   * @param caCertPath       CA Certificate Path
   * @param caCertPassword   CA Certificate Password
   * @param userCertPath     User Certificate Path
   * @param userCertPassword User Certificate Password
   * @return SSLSocketFactory
   * @throws IOException
   * @throws GeneralSecurityException
   */
  private static SSLSocketFactory createSslSocketFactory(
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

    SSLContext sslContext = SSLContext.getInstance("TLS");
    sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);

    return sslContext.getSocketFactory();
  }

}
