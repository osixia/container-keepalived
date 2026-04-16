# osixia/keepalived 🐳🛟🌴

[docker hub]: https://hub.docker.com/r/osixia/keepalived
[github]: https://github.com/osixia/container-keepalived

[![Docker Pulls](https://img.shields.io/docker/pulls/osixia/keepalived.svg?style=flat-square)][docker hub]
[![Docker Stars](https://img.shields.io/docker/stars/osixia/keepalived.svg?style=flat-square)][docker hub]
[![GitHub Stars](https://img.shields.io/github/stars/osixia/container-keepalived?label=github%20stars&style=flat-square)][github]
[![Contributors](https://img.shields.io/github/contributors/osixia/container-keepalived?style=flat-square)](https://github.com/osixia/container-keepalived/graphs/contributors)

[Keepalived](https://keepalived.org/) container image for VRRP high availability and VIP failover with dynamic configuration and hot reload.

![osixia/keepalived logo.](./docs/assets/images/osixia-container-keepalived.jpg)

- [osixia/keepalived 🐳🛟🌴](#osixiakeepalived-)
	- [⚡ Quickstart](#-quickstart)
	- [🔤 Environment Variables](#-environment-variables)
	- [📄 Documentation](#-documentation)
	- [🔀 Contributing](#-contributing)
	- [🔓 License](#-license)

## ⚡ Quickstart

This image requires the `ip_vs` kernel module to be loaded on the host (`modprobe ip_vs`).  
It must be run with the following Docker options:

``` bash
docker run --cap-add=NET_ADMIN --cap-add=NET_RAW --cap-add=NET_BROADCAST --network=host osixia/keepalived
```

**Using your own Keepalived configuration**

This image ships with a Keepalived configuration template that can be customized using environment variables for quick bootstrapping.  

You can also provide your own `keepalived.conf` by mounting it at the path defined by `KEEPALIVED_CONF` (default: `/etc/keepalived/keepalived.conf`):

``` bash
docker run --volume /data/my-keepalived.conf:/etc/keepalived/keepalived.conf osixia/keepalived
```

**Passing command-line arguments to Keepalived**

The `osixia/keepalived` container allows you to pass additional command-line arguments directly to the keepalived binary.

Arguments specified after `--` are forwarded to the keepalived process inside the container:

``` bash
docker run osixia/keepalived -- --dont-release-ipvs
```

**Debugging**

To debug the container manually, you can start it with an interactive shell.

The `--debug` option from `osixia/baseimage` enables debug logging, installs debugging tools, and launches an interactive shell.

If Keepalived keeps crashing, you can add `--skip-process` to start the container without launching service processes.

``` bash
docker run -it osixia/keepalived --debug
docker run -it osixia/keepalived --skip-process --debug 
```

You can also enable Keepalived debugging options:
``` bash
docker run osixia/keepalived -- --log-detail --dump-conf
```

To see all available command-line options:
``` bash
docker run --rm osixia/keepalived --help # osixia/baseimage options
docker run --rm osixia/keepalived -x keepalived -- --help # keepalived command-line options
```

## 🔤 Environment Variables

| Variable                        | Description                                                           | Default                                                                     |
| ------------------------------- | --------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `KEEPALIVED_CONF`               | Path to the Keepalived configuration file                             | `/etc/keepalived/keepalived.conf`                                           |
| `KEEPALIVED_CONF_TEMPLATE`      | Path to the configuration template used to generate `keepalived.conf` | `/container/services/keepalived-conf/assets/confs/keepalived.conf.template` |
| `KEEPALIVED_CONF_RELOAD_SCRIPT` | Script executed when configuration changes are detected               | `/container/services/keepalived-conf/assets/scripts/reload.sh`              |
| `KEEPALIVED_INTERFACE`          | Network interface used by VRRP                                        | `eth0`                                                                      |
| `KEEPALIVED_STATE`              | Initial VRRP state (`MASTER` or `BACKUP`)                             | `BACKUP`                                                                    |
| `KEEPALIVED_ROUTER_ID`          | VRRP router ID                                                        | `51`                                                                        |
| `KEEPALIVED_PRIORITY`           | VRRP priority of the node                                             | `150`                                                                       |
| `KEEPALIVED_UNICAST_PEERS`      | List of peer nodes used for VRRP unicast communication                | `192.168.1.10` `192.168.1.11`                                               |
| `KEEPALIVED_VIRTUAL_IPS`        | Virtual IP addresses managed by Keepalived                            | `192.168.1.231` `192.168.1.232`                                             |
| `KEEPALIVED_PASSWORD`           | VRRP authentication password                                          | `d0cker`                                                                    |
| `KEEPALIVED_NOTIFY_SCRIPT`      | Script executed when Keepalived state changes                         | `/container/services/keepalived/assets/scripts/notify.sh`                   |

## 📄 Documentation

See full documentation and complete features list on [osixia/keepalived documentation](https://opensource.osixia.net/projects/container-images/keepalived/).

This image is based on [osixia/baseimage](https://github.com/osixia/container-baseimage).

## 🔀 Contributing

If you find this project useful here's how you can help:

- Send a pull request with new features and bug fixes.
- Help new users with [issues](https://github.com/osixia/container-keepalived/issues) they may encounter.
- Support the development of this image and star [this repo][github] and the image [docker hub repository][docker hub].

This project use a CI/CD tool to build, test and deploy images. See source code and usefull command lines in [build directory](build/).

## 🔓 License

This project is licensed under the terms of the MIT license. See [LICENSE.md](LICENSE.md) file for more information.
