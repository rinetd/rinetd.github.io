---
title: drone支持webhook
date: 2016-10-04T04:15:26+08:00
update: 2016-10-04 04:15:26
categories:
tags:
---
https://github.com/drone-plugins/drone-webhook

```

notify:
  webhook:
    debug: true
    method: POST
    auth:
      username: $$TOWER_USER
      password: $$TOWER_PASS
    urls:
      - http://tower.example.com/api/v1/job_templates/44/launch/
      - http://tower.example.com/api/v1/job_templates/45/launch/
      content_type: application/json
      template: '{"name": "project.deploy","extra_vars": "{\"env\": \"dev\",\"git_branch\": \"{{ build.branch }}\",\"hipchat_token\": \"$$HIPCHAT_TOKEN\"}"}'
```


https://github.com/zyclonite/drone-webhook

```
pipeline:
  notify:
    image: zyclonite/drone-webhook
    webhook: https://your.domain.com/drone/hook
    token: bearer token for authentication
    skip_verify: false|true
    when:
      status: [ success, failure ]

```
