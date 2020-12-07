start:
	$(MAKE) -f ../dynamo.mak
	$(MAKE) -f eks.mak
	$(MAKE) -f ../docker.mak
	$(MAKE) -f ../k8s.mak
stop:
	$(MAKE) -f ../dynamo.mak delete -k
	$(MAKE) -f ../k8s.mak delete -k
	$(MAKE) -f ../docker.mak delete -k
	$(MAKE) -f eks.mak delete -k
	rm -f ../../code/db/db.yaml
	cd ../../; find . -name "*.log" -delete
	cd ../../; find . -name "*.out" -delete
	cd ../../; find . -name "*.config" -delete

#USED FOR TESTING SERVICES BY REDEPLOYING FROM SCRATCH
#USEFUL FOR RESTARTING DB SERVICE WHEN AWS TOKEN EXPIRES
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
redeploy-db-api:
	$(MAKE) -f ../docker.mak delete-db -k
	$(MAKE) -f ../k8s.mak delete-db -k
	$(MAKE) -f ../docker.mak db
	$(MAKE) -f ../k8s.mak db
# redeploys the misc/service-gateway.yaml. Ensure your service is available in the yaml.
redeploy-gateways:
	$(MAKE) -f ../k8s.mak delete-gateways -k
	$(MAKE) -f ../k8s.mak gw.svc.log