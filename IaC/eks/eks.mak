EKS=eksctl
KC=kubectl
IC=istioctl
CTX=t3
NS=cmpt756t3

NGROUP=worker-nodes
NTYPE=t3.small
REGION:=$(shell cat ~/.aws/config | sed -n 2p | cut -d'=' -f2 | xargs)
KVER=1.17

start:
	$(EKS) create cluster --name $(CTX) --version $(KVER) --region $(REGION) --nodegroup-name $(NGROUP) --node-type $(NTYPE) --nodes 2 --nodes-max 2 --managed | tee eks-cluster.log
	$(KC) config rename-context $(shell kubectl config get-contexts -o=name) $(CTX)
	$(KC) config use-context $(CTX) | tee mk-reinstate.log
	$(KC) create ns $(NS) | tee -a mk-reinstate.log
	$(KC) config set-context $(CTX) --namespace=$(NS) | tee -a mk-reinstate.log
	$(KC) label ns $(NS) istio-injection=enabled | tee -a mk-reinstate.log
	$(IC) install --set profile=demo | tee -a mk-reinstate.log
	$(KC) -n istio-system get service istio-ingressgateway -o=custom-columns=EXTERNAL-IP:.status.loadBalancer.ingress[0].hostname | sed -n 2p | tee ../../API/external-ip.log

delete:
	$(EKS) delete cluster --name $(CTX) --region $(REGION) | tee eks-delete.log

up:
	$(EKS) create nodegroup --cluster $(CTX) --region $(REGION) --name $(NGROUP) --node-type $(NTYPE) --nodes 2 --nodes-min 2 --nodes-min 2 --managed | tee repl-nodes.log

down:
	$(EKS) delete nodegroup --cluster=$(CTX) --region $(REGION) --name=$(NGROUP)
	rm repl-nodes.log

status: showcontext
	$(EKS) get cluster --region $(REGION) | tee eks-status.log
	$(EKS) get nodegroup --cluster $(CTX) --region $(REGION) | tee -a eks-status.log

dashboard: showcontext
	echo Please follow instructions at https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html
	echo Remember to 'pkill kubectl' when you are done!
	$(KC) proxy &
	open http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login

extern: showcontext
	$(KC) -n istio-system get service istio-ingressgateway

cd:
	$(KC) config use-context $(CTX)

# show svc across all namespaces
lsa: showcontext
	$(KC) get svc --all-namespaces

# show deploy and pods in current ns; svc of cmpt756e4 ns
ls: showcontext
	$(KC) get gw,deployments,pods
	$(KC) -n $(NS) get svc

# show containers across all pods
lsd:
	$(KC) get pods --all-namespaces -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' | sort

# reinstate all the pieces of istio on a new cluster
# do this whenever you create/restart your cluster
# NB: You must rename the long context name down to $(CTX) before using this
reinstate:
	$(KC) config use-context $(CTX) | tee -a eks-reinstate.log
	$(KC) create ns $(NS) | tee -a eks-reinstate.log
	$(KC) config set-context $(CTX) --namespace=$(NS) | tee -a eks-reinstate.log
	$(KC) label ns $(NS) istio-injection=enabled | tee -a eks-reinstate.log
	$(IC) install --set profile=demo | tee -a eks-reinstate.log

setupdashboard:
	$(KC) apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.3.6/components.yaml
	$(KC) apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
	$(KC) apply -f ../../code/misc/eks-admin-service-account.yaml
	$(KC) -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

showcontext:
	$(KC) config get-contexts