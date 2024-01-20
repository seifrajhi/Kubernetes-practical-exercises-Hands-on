Table of Contents
=================

- [Table of Contents](#table-of-contents)
- [Ingress](#ingress)
  - [What is Ingress?](#what-is-ingress)
  - [Prerequisites](#prerequisites)
  - [The Ingress resource](#the-ingress-resource)
    - [Ingress rules](#ingress-rules)
    - [Path types](#path-types)
  - [Examples](#examples)
      - [Multiple matches](#multiple-matches)
  - [Hostname wildcards](#hostname-wildcards)
  - [Ingress class](#ingress-class)
  - [Types of Ingress](#types-of-ingress)
    - [Ingress backed by a single Service](#ingress-backed-by-a-single-service)
    - [Simple fanout](#simple-fanout)
    - [Name based virtual hosting](#name-based-virtual-hosting)

# Ingress

It manages external access to the services in a cluster, typically HTTP.

Ingress may provide load balancing, SSL termination and name-based virtual hosting.

## What is Ingress?

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

Here is a simple example where an Ingress sends all its traffic to one Service:

![ingress-diagram](/images/ingress.png)

Figure. Ingress

An Ingress may be configured to give Services externally-reachable URLs, load balance traffic, terminate SSL / TLS, and offer name-based virtual hosting. 

An _Ingress controller_ is responsible for fulfilling the Ingress, usually with a load balancer, though it may also configure your edge router or additional frontends to help handle the traffic.

An Ingress does not expose arbitrary ports or protocols. Exposing services other than HTTP and HTTPS to the internet typically uses a service of type _Service.Type=NodePort_ or _Service.Type=LoadBalancer_.

## Prerequisites

You must have an Ingress controller to satisfy an Ingress. Only creating an Ingress resource has no effect.

Ideally, all Ingress controllers should fit the reference specification. In reality, the various Ingress controllers operate slightly differently.


## The Ingress resource

Please refer to `minimal-ingress.yaml` 

### Ingress rules

Each HTTP rule contains the following information:

-   An optional host. In this example, no host is specified, so the rule applies to all inbound HTTP traffic through the IP address specified. If a host is provided (for example, foo.bar.com), the rules apply to that host.

-   A list of paths (for example, `/testpath`), each of which has an associated backend defined with a `service.name` and a `service.port.name` or `service.port.number`. Both the host and path must match the content of an incoming request before the load balancer directs traffic to the referenced Service.

-   A backend is a combination of Service and port names as described in the Service doc or a custom resource backend by way of a CRD. HTTP (and HTTPS) requests to the Ingress that matches the host and path of the rule are sent to the listed backend.


### Path types

Each path in an Ingress is required to have a corresponding path type. Paths that do not include an explicit `pathType` will fail validation. There are three supported path types:

-   `ImplementationSpecific`: With this path type, matching is up to the IngressClass. Implementations can treat this as a separate `pathType` or treat it identically to `Prefix` or `Exact` path types.
  
-   `Exact`: Matches the URL path exactly and with case sensitivity.

-   `Prefix`: Matches based on a URL path prefix split by `/`. Matching is case sensitive and done on a path element by element basis. A path element refers to the list of labels in the path split by the `/` separator. A request is a match for path _p_ if every _p_ is an element-wise prefix of _p_ of the request path.

> **Note:** If the last element of the path is a substring of the last element in request path, it is not a match (for example: `/foo/bar` matches`/foo/bar/baz`, but does not match `/foo/barbaz`).


## Examples

| Kind | Path(s) | Request path(s) | Matches? |
| --- | --- | --- | --- |
| Prefix | / | (all paths) | Yes |
|Exact|	/foo	|/foo|	Yes|
|Exact|	/foo	|/bar|	No|
|Exact|	/foo|   /foo/|	No|
|Exact|	/foo/	|/foo|	No|
|Prefix|	/foo|	/foo, /foo/	|Yes
|Prefix|	/foo/|	/foo, /foo/	|Yes
|Prefix|	/aaa/bb|	/aaa/bbb	|No
|Prefix|	/aaa/bbb|	/aaa/bbb	|Yes
|Prefix|	/aaa/bbb/|	/aaa/bbb	|Yes, ignores trailing slash
|Prefix|	/aaa/bbb|	/aaa/bbb/	|Yes, matches trailing slash
|Prefix|	/aaa/bbb|	/aaa/bbb/ccc	|Yes, matches subpath
|Prefix|	/aaa/bbb|	/aaa/bbbxyz	|No, does not match string Prefix
|Prefix|	/, /aaa|	/aaa/ccc	|Yes, matches /aaa Prefix
|Prefix|	/, /aaa, /aaa/bbb	|/aaa/bbb	|Yes, matches /aaa/bbb Prefix
|Prefix|	/, /aaa, /aaa/bbb|	/ccc	|Yes, matches / Prefix
|Prefix|	/aaa|	/ccc	|No, uses default backend
|Mixed|	/foo (Prefix), /foo (Exact)|	/foo	|Yes, prefers Exact


#### Multiple matches

In some cases, multiple paths within an Ingress will match a request. In those cases precedence will be given first to the longest matching path. If two paths are still equally matched, precedence will be given to paths with an exact path type over prefix path type.


## Hostname wildcards

Hosts can be precise matches (for example “`foo.bar.com`”) or a wildcard (for example “`*.foo.com`”). Precise matches require that the HTTP `host` header matches the `host` field. Wildcard matches require the HTTP `host` header is equal to the suffix of the wildcard rule.

| Host | Host header | Match? |
| --- | --- | --- |
|`*.foo.com`|`bar.foo.com`|Matches based on shared suffix|
|`*.foo.com`|`baz.bar.foo.com`|No match, wildcard only covers a single DNS label|
|`*.foo.com`|`foo.com`|No match, wildcard only covers a single DNS label|

see `ingress-wildcard-host.yaml`

## Ingress class

Ingresses can be implemented by different controllers, often with different configuration. 

Each Ingress should specify a class, a reference to an IngressClass resource that contains additional configuration including the name of the controller that should implement the class.

see `default-ingressclass.yaml`

## Types of Ingress

### Ingress backed by a single Service

There are existing Kubernetes concepts that allow you to expose a single Service. You can also do this with an Ingress by specifying a _default backend_ with no rules.

see `test-ingress.yaml`

If you create it using `kubectl apply -f test-ingress.yaml` you should be able to view the state of the Ingress you added:

```bash
kubectl get ingress test-ingress
```

```
NAME           CLASS         HOSTS   ADDRESS         PORTS   AGE
test-ingress   external-lb   *       203.0.113.123   80      59s
```

Where `203.0.113.123` is the IP allocated by the Ingress controller to satisfy this Ingress.

### Simple fanout

A fanout configuration routes traffic from a single IP address to more than one Service, based on the HTTP URI being requested.

An Ingress allows you to keep the number of load balancers down to a minimum. For example, a setup like:

![ingress-fanout-diagram](/images/IngressFanOut.png)

Figure. Ingress Fan Out

would require an Ingress such as:

see `simple-fanout-example.yaml`

When you create the Ingress with `kubectl apply -f simple-fanout-example.yaml` :

```shell
kubectl describe ingress simple-fanout-example
```

```
Name:             simple-fanout-example
Namespace:        default
Address:          178.91.123.132
Default backend:  default-http-backend:80 (10.8.2.3:8080)
Rules:
  Host         Path  Backends
  ----         ----  --------
  foo.bar.com
               /foo   service1:4200 (10.8.0.90:4200)
               /bar   service2:8080 (10.8.0.91:8080)
Events:
  Type     Reason  Age                From                     Message
  ----     ------  ----               ----                     -------
  Normal   ADD     22s                loadbalancer-controller  default/test
```

The Ingress controller provisions an implementation-specific load balancer that satisfies the Ingress, as long as the Services (`service1`, `service2`) exist. 

When it has done so, you can see the address of the load balancer at the Address field.

### Name based virtual hosting

Name-based virtual hosts support routing HTTP traffic to multiple host names at the same IP address.

![ingress-namebase-diagram](/images/ingressnamebased.png)

Figure. Ingress Name Based Virtual hosting

The following Ingress tells the backing load balancer to route requests based on the Host header.

see `name-virtual-host-ingress.yaml`

If you create an Ingress resource without any hosts defined in the rules, then any web traffic to the IP address of your Ingress controller can be matched without a name based virtual host being required.

For example, the following Ingress routes traffic requested for `first.bar.com` to `service1`, `second.bar.com` to `service2`, and any traffic whose request host header doesn't match `first.bar.com` and `second.bar.com` to `service3`.

see `name-virtual-host-ingress-no-third-host.yaml`

Reference link: [Ingress Concepts](https://kubernetes.io/docs/concepts/services-networking/ingress/)