# traepis

A UI for bringing up replicated builds of a single app in Kubernetes.

Pronounced tră-pēz′ (like trapeze - if traefik can do it so can I).

## More specifically?

This tool is intended for feature testing in a QA/staging environment. Say you have multiple feature branches you want to test before merging into your mainstream
deployment repo. Traepis lets you point to a docker image tag, assign it an ID (i.e.: a ticket number from your issue tracker) and it will automatically route traffic to a specific URL for that build.

e.g.:

Your mainstream staging build is. http://sandbox.yourapp.com.

Traepis lets you manage additional domains automatically via Kubernetes ingresses. So you can immediately deploy a new image at a
subdomain (http://feat-14.sandbox.yourapp.com) of your staging app with the press of a button.

## Development

To get a development version of traepis working.

1. Start minikube (or if you need to install it first, I hope not if you've used k8s before which you should if you're interested in traepis)
2. Run ./build
3. Edit .minikube/config/2.localconfig.yaml to be relevant to your local system.
4. kubectl create -f .minikube/config
5. expose the ingress controller (don't forget to lookup the NodePort assigned to your Service so you can access the ingress controller as a reverse proxy)
   e.g. `kubectl expose -n kube-system deploy/treapis-development-ingress-controller --port 80 --type NodePort`

### What just happened?

You:

1. Built an empty docker container ready to house a rails app.
2. Mapped the code location you cloned the traepis repo into a persistent volume in minikube.
3. Created a Kubernetes deployment object to boot up a container running the app. The container has an nfs mount to your local file system so you can edit code and have the code immediately be applied to the app running inside minikube.

### rails commands and bundler

By default when you create the k8s deployment to start the app - an init container bundles. (The bundle files are stored in a hostPath volume in the minikube VM at /bundle/traepis_development). However if you need to add gems to the Gemfile - you'll need to bundle from within the container. There are helpers that help you do this:

`source .k8src`

This automatically delegates any rails or bundle commands to the running container in the k8s pod. `rails server` won't do much in this scenario however... (and I still haven't figured out how to handle debugger statements yet).
