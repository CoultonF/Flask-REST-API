
REGID:=$(shell docker-credential-$(shell jq -r .credsStore ~/.docker/config.json) list | jq -r ' . | to_entries[] | select(.key | contains("docker.io")) | last(.value)')\
$(shell docker info | sed '/Username:/!d;s/.* //') #WINDOWS/MAC THEN UBUNTU
REGID:=$(shell echo $(REGID) | xargs)


DK=docker

all: generate-secret svc

# RUN SERVICES
svc: customer db returns cart warehouse history transaction

#RUN REPOS
repo: customer.repo.log db.repo.log returns.repo.log cart.repo.log warehouse.repo.log history.repo.log transaction.repo.log

#START POINTS FOR CONTAINER BUILDS
customer: customer.svc.log
db: db.svc.log
returns: returns.svc.log
cart: cart.svc.log
warehouse: warehouse.svc.log
history: history.svc.log
transaction: transaction.svc.log

clean:
	rm -f {customer,db,returns, cart, warehouse, history, transaction}.{img,repo,svc}.log

# CREATE ACTIONS

#customer docker container build
customer.svc.log: customer.repo.log
	$(DK) run -t --publish 30000:30000 --detach --name customer $(REGID)/t3customer:latest | tee customer.svc.log

customer.repo.log: customer.img.log
	$(DK) push $(REGID)/t3customer:latest | tee customer.repo.log

customer.img.log: ../../code/customer/Dockerfile ../../code/customer/app.py
	cp ../../code/misc/secret-key.config ../../code/customer/secret-key.config
	$(DK) build -t $(REGID)/t3customer:latest ../../code/customer | tee customer.img.log

#db docker container build
db.svc.log: db.repo.log
	$(DK) run -t --publish 30002:30002 --detach --name db $(REGID)/t3db:latest | tee db.svc.log

db.repo.log: db.img.log
	$(DK) push $(REGID)/t3db:latest | tee db.repo.log

db.img.log: ../../code/db/Dockerfile ../../code/db/app.py
	$(DK) build -t $(REGID)/t3db:latest ../../code/db | tee db.img.log

#returns docker container build
returns.svc.log: returns.repo.log
	$(DK) run -t --publish 30006:30006 --detach --name returns $(REGID)/t3returns:latest | tee returns.svc.log

returns.repo.log: returns.img.log
	$(DK) push $(REGID)/t3returns:latest | tee returns.repo.log

returns.img.log: ../../code/returns/Dockerfile ../../code/returns/app.py
	cp ../../code/misc/secret-key.config ../../code/returns/secret-key.config
	$(DK) build -t $(REGID)/t3returns:latest ../../code/returns | tee returns.img.log

#cart docker container build
cart.svc.log: cart.repo.log
	$(DK) run -t --publish 30003:30003 --detach --name cart $(REGID)/t3cart:latest | tee cart.svc.log

cart.repo.log: cart.img.log
	$(DK) push $(REGID)/t3cart:latest | tee cart.repo.log

cart.img.log: ../../code/cart/Dockerfile ../../code/cart/app.py
	cp ../../code/misc/secret-key.config ../../code/cart/secret-key.config
	$(DK) build -t $(REGID)/t3cart:latest ../../code/cart | tee cart.img.log

#warehouse docker container build
warehouse.svc.log: warehouse.repo.log
	$(DK) run -t --publish 30001:30001 --detach --name warehouse $(REGID)/t3warehouse:latest | tee warehouse.svc.log

warehouse.repo.log: warehouse.img.log
	$(DK) push $(REGID)/t3warehouse:latest | tee warehouse.repo.log

warehouse.img.log: ../../code/warehouse/Dockerfile ../../code/warehouse/app.py
	cp ../../code/misc/secret-key.config ../../code/warehouse/secret-key.config
	$(DK) build -t $(REGID)/t3warehouse:latest ../../code/warehouse | tee warehouse.img.log
	
#history docker container build
history.svc.log: history.repo.log
	$(DK) run -t --publish 30005:30005 --detach --name history $(REGID)/t3history:latest | tee history.svc.log

history.repo.log: history.img.log
	$(DK) push $(REGID)/t3history:latest | tee history.repo.log

history.img.log: ../../code/history/Dockerfile ../../code/history/app.py
	cp ../../code/misc/secret-key.config ../../code/history/secret-key.config
	$(DK) build -t $(REGID)/t3history:latest ../../code/history | tee history.img.log
    
#transaction docker container build
transaction.svc.log: transaction.repo.log
	$(DK) run -t --publish 30004:30004 --detach --name transaction $(REGID)/t3transaction:latest | tee transaction.svc.log

transaction.repo.log: history.img.log
	$(DK) push $(REGID)/t3transaction:latest | tee transaction.repo.log

transaction.img.log: ../../code/transaction/Dockerfile ../../code/transaction/app.py
	cp ../../code/misc/secret-key.config ../../code/transaction/secret-key.config
	$(DK) build -t $(REGID)/t3transaction:latest ../../code/transaction | tee transaction.img.log
    

# DELETE ACTIONS
delete: delete-secret delete-db delete-customer delete-returns delete-cart delete-warehouse delete-history delete-transaction clean

delete-db:
	$(DK) kill db || true && $(DK) rm db || true
	$(DK) image rm -f $(REGID)/t3db
	$(DK) system prune -f -a --volumes
	rm -f db.svc.log db.repo.log db.img.log

delete-customer:
	$(DK) kill customer || true && $(DK) rm customer || true
	$(DK) image rm -f $(REGID)/t3customer
	$(DK) system prune -f -a --volumes
	rm -f customer.svc.log customer.repo.log customer.img.log

delete-returns:
	$(DK) kill returns || true && $(DK) rm returns || true
	$(DK) image rm -f $(REGID)/t3returns
	$(DK) system prune -f -a --volumes
	rm -f returns.svc.log returns.repo.log returns.img.log

delete-cart:
	$(DK) kill cart || true && $(DK) rm cart || true
	$(DK) image rm -f $(REGID)/t3cart
	$(DK) system prune -f -a --volumes
	rm -f cart.svc.log cart.repo.log cart.img.log

delete-warehouse:
	$(DK) kill warehouse || true && $(DK) rm warehouse || true
	$(DK) image rm -f $(REGID)/t3warehouse
	$(DK) system prune -f -a --volumes
	rm -f warehouse.svc.log warehouse.repo.log warehouse.img.log
	
delete-history:
	$(DK) kill history || true && $(DK) rm history || true
	$(DK) image rm -f $(REGID)/t3history
	$(DK) system prune -f -a --volumes
	rm -f history.svc.log history.repo.log history.img.log

delete-transaction:
	$(DK) kill transaction || true && $(DK) rm transaction || true
	$(DK) image rm -f $(REGID)/t3transaction
	$(DK) system prune -f -a --volumes
	rm -f transaction.svc.log transaction.repo.log transaction.img.log

#list docker images in system
list-images:
	$(DK) images

generate-secret:
	uuidgen > ../../code/misc/secret-key.config

delete-secret:
	rm -f ../../code/misc/secret-key.config
