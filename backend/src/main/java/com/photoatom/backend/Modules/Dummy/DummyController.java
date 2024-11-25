package com.photoatom.backend.Modules.Dummy;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("dummy")
public class DummyController {

  @Autowired
  private DummyService dummyService;

  @GetMapping
  @Cacheable("say-hello")
  public String sayHello() {
    return dummyService.sayHello();
  }

}
