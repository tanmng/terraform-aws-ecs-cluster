#cloud-config
write_files:
  - path: /etc/ecs/ecs.config
    permissions: '0644'
    owner: root:root
    encoding: base64
    content: |
      ${ ecs_conf_base64 }
  - path: /etc/awslogs/awscli.conf
    permissions: '0600'
    owner: root:root
    encoding: base64
    content: |
      ${ aws_cli_conf_base64 }
  - path: /etc/awslogs/awslogs.conf
    permissions: '0644'
    owner: root:root
    encoding: base64
    content: |
      ${ aws_logs_conf_base64 }

packages:
  - awslogs
  - vim
  - tmux

runcmd:
  - echo 'Restarting ECS just to be sure'
  - [stop, ecs]
  - [start, ecs]
