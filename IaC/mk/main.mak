start:
	$(MAKE) -f ../dynamo.mak
	$(MAKE) -f mk.mak
	$(MAKE) -f ../docker.mak
	$(MAKE) -f ../k8s.mak
start-ubuntu:
	$(MAKE) -f ../dynamo.mak
	$(MAKE) -f mk.mak start-ubuntu-mk
	$(MAKE) -f ../docker.mak
	$(MAKE) -f ../k8s.mak
stop:
	$(MAKE) -f ../dynamo.mak delete -k
	$(MAKE) -f ../k8s.mak delete -k
	$(MAKE) -f ../docker.mak delete -k
	$(MAKE) -f mk.mak delete -k
	rm -f ../../code/db/db.yaml
	cd ../../; find . -name "*.log" -delete
	cd ../../; find . -name "*.out" -delete
	cd ../../; find . -name "*.config" -delete

#USED FOR TESTING SERVICES
redeploy-returns-api:
	$(MAKE) -f ../docker.mak delete-returns -k
	$(MAKE) -f ../k8s.mak delete-returns -k
	$(MAKE) -f ../docker.mak returns
	$(MAKE) -f ../k8s.mak returns
redeploy-customer-api:
	$(MAKE) -f ../docker.mak delete-customer -k
	$(MAKE) -f ../k8s.mak delete-customer -k
	$(MAKE) -f ../docker.mak customer
	$(MAKE) -f ../k8s.mak customer
redeploy-warehouse-api:
	$(MAKE) -f ../docker.mak delete-warehouse -k
	$(MAKE) -f ../k8s.mak delete-warehouse -k
	$(MAKE) -f ../docker.mak warehouse
	$(MAKE) -f ../k8s.mak warehouse
redeploy-cart-api:
	$(MAKE) -f ../docker.mak delete-cart -k
	$(MAKE) -f ../k8s.mak delete-cart -k
	$(MAKE) -f ../docker.mak cart
	$(MAKE) -f ../k8s.mak cart
redeploy-db-api:
	$(MAKE) -f ../docker.mak delete-db -k
	$(MAKE) -f ../k8s.mak delete-db -k
	$(MAKE) -f ../docker.mak db
	$(MAKE) -f ../k8s.mak db
redeploy-history-api:
	$(MAKE) -f ../docker.mak delete-history -k
	$(MAKE) -f ../k8s.mak delete-history -k
	$(MAKE) -f ../docker.mak history
	$(MAKE) -f ../k8s.mak history
# redeploys the misc/service-gateway.yaml. Ensure your service is available in the yaml.
redeploy-gateways:
	$(MAKE) -f ../k8s.mak delete-gateways -k
	$(MAKE) -f ../k8s.mak gw.svc.log

kube-status:
	$(MAKE) -f ../k8s.mak ls
