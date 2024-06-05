#!/bin/bash

write_files:
  - path: /etc/cloud/cloud.cfg
    content: |
      bootcmd:
        - /bin/bash /home/ubuntu/scripts/update_route53.sh

