#
# Janky front-end to bring some sanity (?) to the litany of tools and switches
# for working with a k8s cluster. Note that this file exercise core k8s
# commands that's independent of where/how you cluster live.
#
# This file addresses APPPLing the Deployment, Service.json, Gateway, and VirtualService
#
# Be sure to set your context appropriately for the log monitor.
#
# The intended approach to working with this makefile is to update select
# elements (body, id, IP, port, etc) as you progress through your workflow.
# Where possible, stodout outputs are tee into .out files for later review.
#
AWS_DEFAULT_REGION:=$(shell cat ~/.aws/config | sed -n 2p | cut -d'=' -f2 | xargs)
AWS_ACCESS_KEY_ID:=$(shell cat ~/.aws/credentials | sed -n 2p | cut -d'=' -f2 | xargs)
AWS_SECRET_ACCESS_KEY:=$(shell cat ~/.aws/credentials | sed -n 3p | cut -d'=' -f2 | xargs)
AWS_SESSION_TOKEN:=$(shell cat ~/.aws/credentials | sed -n 4p | cut -d'=' -f2 | xargs)

REGID:=$(shell docker-credential-$(shell jq -r .credsStore ~/.docker/config.json) list | jq -r ' . | to_entries[] | select(.key | contains("docker.io")) | last(.value)')\
$(shell docker info | sed '/Username:/!d;s/.* //') #WINDOWS/MAC THEN UBUNTU
REGID:=$(shell echo $(REGID) | xargs)
#cluster namespace
NS=cmpt756t3

KC=kubectl
DK=docker

#deploy all
deploy: gw customer db returns cart warehouse history
	$(KC) get gw,deploy,svc,pods

gw: gw.svc.log

#START POINTS FOR K8S BUILDS
customer: customer.svc.log
db: db.svc.log
returns: returns.svc.log
cart: cart.svc.log
warehouse: warehouse.svc.log
history: history.svc.log

gw.svc.log:
	$(KC) -n $(NS) apply -f ../../code/misc/service-gateway.yaml | tee gw.k8s.log


customer.svc.log: create.customer.yaml
	$(KC) -n $(NS) apply -f ../../code/customer/customer.yaml | tee customer.k8s.log

db.svc.log: create.db.yaml
	$(KC) -n $(NS) apply -f ../../code/db/db.yaml | tee db.k8s.log

returns.svc.log: create.returns.yaml
	$(KC) -n $(NS) apply -f ../../code/returns/returns.yaml | tee returns.k8s.log

cart.svc.log: create.cart.yaml
	$(KC) -n $(NS) apply -f ../../code/cart/cart.yaml | tee cart.k8s.log

warehouse.svc.log: create.warehouse.yaml
	$(KC) -n $(NS) apply -f ../../code/warehouse/warehouse.yaml | tee warehouse.k8s.log
	
history.svc.log: create.history.yaml
	$(KC) -n $(NS) apply -f ../../code/history/history.yaml | tee history.k8s.log

extern: showcontext
	$(KC) -n istio-system get svc istio-ingressgateway

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

# handy bits for the container images... not necessary
image: showcontext
	$(DK) image ls | tee __header | grep $(REGID) > __content
	head -n 1 __header
	cat __content
	rm __content __header

#only used to testing why pods failed
get-logs:
	$(KC) logs pod/t3customer-6b8b974f5f-vj7wv -c customer

# reminder of current context
showcontext:
	$(KC) config get-contexts

create.db.yaml:
	cp ../../code/db/db-tpl.yaml ../../code/db/db.yaml
	yq w -i -d1 ../../code/db/db.yaml stringData.AWS_REGION $(AWS_DEFAULT_REGION)
	yq w -i -d1 ../../code/db/db.yaml stringData.AWS_ACCESS_KEY_ID $(AWS_ACCESS_KEY_ID)
	yq w -i -d1 ../../code/db/db.yaml stringData.AWS_SECRET_ACCESS_KEY $(AWS_SECRET_ACCESS_KEY)
	yq w -i -d1 ../../code/db/db.yaml stringData.AWS_SESSION_TOKEN $(AWS_SESSION_TOKEN)
	yq w -i -d3 ../../code/db/db.yaml spec.template.spec.containers[*].image docker.io/$(REGID)/t3db:latest

create.customer.yaml:
	yq w -i -d2 ../../code/customer/customer.yaml spec.template.spec.containers[*].image docker.io/$(REGID)/t3customer:latest

create.returns.yaml:
	yq w -i -d2 ../../code/returns/returns.yaml spec.template.spec.containers[*].image docker.io/$(REGID)/t3returns:latest

create.cart.yaml:
	yq w -i -d2 ../../code/cart/cart.yaml spec.template.spec.containers[*].image docker.io/$(REGID)/t3cart:latest

create.warehouse.yaml:
	yq w -i -d2 ../../code/warehouse/warehouse.yaml spec.template.spec.containers[*].image docker.io/$(REGID)/t3warehouse:latest
	
create.history.yaml:
	yq w -i -d2 ../../code/history/history.yaml spec.template.spec.containers[*].image docker.io/$(REGID)/t3history:latest

#delete all kubes
delete: delete-deployments delete-services delete-serviceaccounts delete-gateways delete-virtualservices clean

#Delete a specific api
delete-customer: delete-customer-services delete-customer-deploy delete-customer-svcacc
delete-db: delete-db-services delete-db-deploy delete-db-svcacc
delete-returns: delete-returns-services delete-returns-deploy delete-returns-svcacc
delete-cart: delete-cart-services delete-cart-deploy delete-cart-svcacc
delete-warehouse: delete-warehouse-services delete-warehouse-deploy delete-warehouse-svcacc
delete-history: delete-history-services delete-history-deploy delete-history-svcacc

# callables
delete-deployments: delete-customer-deploy delete-db-deploy delete-returns-deploy delete-cart-deploy delete-warehouse-deploy delete-history-deploy
delete-customer-deploy:
	$(KC) delete deploy --ignore-not-found=true t3customer
	rm -f customer.k8s.log
delete-db-deploy:
	$(KC) delete deploy --ignore-not-found=true t3db
	rm -f db.k8s.log
delete-returns-deploy:
	$(KC) delete deploy --ignore-not-found=true t3returns
	rm -f customer.k8s.log
delete-cart-deploy:
	$(KC) delete deploy --ignore-not-found=true t3cart
	rm -f cart.k8s.log
delete-warehouse-deploy:
	$(KC) delete deploy --ignore-not-found=true t3warehouse
	rm -f warehouse.k8s.log
delete-history-deploy:
	$(KC) delete deploy --ignore-not-found=true t3history
	rm -f history.k8s.log
	

delete-services: delete-customer-services delete-returns-services delete-db-services delete-warehouse-services delete-cart-services delete-history-services
delete-customer-services:
	$(KC) delete svc --ignore-not-found=true t3customer
	rm -f customer.k8s.log
delete-db-services:
	$(KC) delete svc --ignore-not-found=true t3db
	rm -f db.k8s.log
delete-returns-services:
	$(KC) delete svc --ignore-not-found=true t3returns
	rm -f returns.k8s.log
delete-cart-services:
	$(KC) delete svc --ignore-not-found=true t3cart
	rm -f cart.k8s.log
delete-warehouse-services:
	$(KC) delete svc --ignore-not-found=true t3warehouse
	rm -f warehouse.k8s.log
delete-history-services:
	$(KC) delete svc --ignore-not-found=true t3history
	rm -f history.k8s.log

delete-serviceaccounts: delete-customer-svcacc delete-returns-svcacc delete-db-svcacc delete-cart-svcacc delete-warehouse-svcacc delete-history-svcacc
delete-customer-svcacc:
	$(KC) delete serviceaccount --ignore-not-found=true svc-customer
	rm -f customer.k8s.log
delete-db-svcacc:
	$(KC) delete serviceaccount --ignore-not-found=true svc-db
	rm -f db.k8s.log
delete-returns-svcacc:
	$(KC) delete serviceaccount --ignore-not-found=true svc-returns
	rm -f returns.k8s.log
delete-warehouse-svcacc:
	$(KC) delete serviceaccount --ignore-not-found=true svc-warehouse
	rm -f warehouse.k8s.log
delete-cart-svcacc:
	$(KC) delete serviceaccount --ignore-not-found=true svc-cart
	rm -f cart.k8s.log
delete-history-svcacc:
	$(KC) delete serviceaccount --ignore-not-found=true svc-history
	rm -f history.k8s.log

delete-gateways:
	$(KC) delete gw --ignore-not-found=true my-gateway
delete-virtualservices:
	$(KC) delete virtualservice --ignore-not-found=true cmpt756t3

clean:
	rm -f {customer,db,returns,cart,warehouse,history}.{img,repo,svc}.log gw.svc.log
