# Plugin Distribution System (PDS)

An implementation of the Plugin Distribution System (formerly called Secure Plugin Managment System) proposed in [1].

## About

[Pluginized protocols](https://pluginized-protocols.org/) is an ongoing effort to make Internet protocols programmable.
The idea is to dynamically extend protocols implementations with protocol plugins.
This approach solves the deployment issue of new protocols extensions.
However, it raises safety issues related to the plugins behavior, e.g. do these extensions terminate or act maliciously?

The PDS is a distributed system performing offline verification on such protocols plugins.
It also ensures their secure distribution to networked peers thanks to trust proofs.

## Related publications
- SIGCOMM'21 Poster: https://doi.org/10.1145/3472716.3472860
- Master's thesis: http://hdl.handle.net/2078.1/thesis:30634

## Structure

### General structure

```
.
├── deployment		# deployment specific code
├── design			# design graphs
├── measures		# performance measurements for the Merkle tree
├── README.md	
└── src				# source code of the SPMS components
```

### Source code structure

```
src/
├── common_layers					# Common container layers
│   ├── api								# Embeds the required Python packages to implement REST APIs
│   ├── crypto							# Embeds Python packages to handle SSL/TLS X.509 certificates
│   ├── python							# Simple container embedding Python and pip	
│   └── stack_render					# Service used for the SPMS deployement
├── pr								# PR's services
│   ├── broker
│   └── gateway
├── pv								# PV's microservices
│   ├── binding_generator
│   ├── binding_manager
│   ├── logger
│   ├── mt_manager
│   ├── pr_gateway
│   ├── user_gateway
│   └── verifiers					# PV's verifiers
│       ├── controller.py				# Controller code common to all verifiers
│       ├── dummy_failure				# Returns a failure after 5s
│       ├── dummy_success				# Returns a success after 5s
│       ├── pquic-side-effects			# SeaHorn pipe to verify the side-effects property on PQUIC plugins
│       └── terminator2					# T2 pipe to verify the PQUIC plugins termination
├── tests							# Implements basic tests for some services
└── util							# Utilitary code
```

### Deployment code structure

```
deployment/
├── base_layer						# Packer code required to build the base layer VM
├── build_pipe						# Source code of the Build Pipe
├── certificates					# Helpers to generate the SPMS root CA and certificates
├── common_layers
├── gitolite-admin-data				# Specific data for the gitolite instance in the Build Pipe
├── infrastructure.tf				# Terraform HCL describing the whole SPMS deployment process
├── pr								# PV specific Packer code
├── pv								# PR specific Packer code
├── render.py						# Generic template render for file generation (Containerfiles, Makefiles, docker-compose, ....) upon deployment.
├── ssh_config						# SSH configuration to access the Build Pipe gitolite instance
```

## Requirements

### Infrastructure deployment
- `qemu/kvm`	: Linux kernel VMs
- `libvirt` 	: library to handle KVM VMs
- `packer`		: automate KVM VM images build (Infrastructure As Code)
- `terraform`	: automate KVM VM images deployment (IaC)
- `terraform-provider-libvirt`: allows terraform to handle Linux's KVM using Libvirt

## How to deploy
> WARNING: multiples VMs are created and the embedded verifiers are quite heavy.
>
> Reserve some disk space (multiples GB)
>
> Some disk image are built in /tmp. Consider using at least 16 GB of RAM or change the path from /tmp to a non-volatile disk location.

The deployment process takes a long time.
In some cases, it may fail due to network errors.
If it happens, run `terraform destroy` and relaunch the `apply` command afterwards.

```
# Install terraform, packer, qemu-kvm, libvirt, jq
cd deployment
./setup.sh
```

## Sources

[1]: De Coninck et al. "Pluginizing quic." Proceedings of the ACM Special Interest Group on Data Communication. 2019. 59-74
