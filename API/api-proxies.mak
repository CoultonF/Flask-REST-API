KC=kubectl
CURL=curl

IGW=$(shell cat external-ip.log)
BODY_USER= { \
"fname": "firstname", \
"email": "student@sfu.ca", \
"lname": "lastname" \
}
RETURN_PRODUCT={ \
  "price": 6.99, \
  "product": "testing", \
  "quantity": 1 \
  }
ADD={ \
  "column": "returns", \
  "value": { \
  "date": "2020/11/30", \
  "price": 10, \
  "product": "test product", \
  "quantity": 1 \
  } \
}
REMOVE={"column":"returns","index":0}
MODIFY={"column":"returns","index":0, "field":"quantity", "value":2}
BODY_CID={"cid":"1e564d24-fae7-4615-820b-2d58cecc4e56"}

#========================================
#		C U S T O M E R 	A P I
#========================================
create_customer:
	$(CURL) -x localhost:8000 --location --request POST 'http://$(IGW)/api/v1/customer/' --header 'Content-Type: application/json' --data-raw '$(BODY_USER)'

update_customer:
	$(CURL) -x localhost:8000 -b session.log --location --request PUT 'http://$(IGW)/api/v1/customer/' --header 'Content-Type: application/json' --data-raw '$(BODY_USER)'

login:
	$(CURL) -x localhost:8000 -c session.log --location --request PUT 'http://$(IGW)/api/v1/customer/login' --header 'Content-Type: application/json' --data-raw '$(BODY_CID)'

logoff:
	echo curl -b session.log --location --request PUT 'http://$(IGW)/api/v1/customer/logoff'
	$(CURL) -b session.log --location --request PUT 'http://$(IGW)/api/v1/customer/logoff'
	rm session.log

authenticate:
	echo -b session.log curl --location --request GET 'http://$(IGW)/api/v1/customer/authenticate'
	$(CURL) -b session.log --location --request GET 'http://$(IGW)/api/v1/customer/authenticate'

read_customer:
	$(CURL) -x localhost:8000 -b session.log --location --request GET 'http://$(IGW)/api/v1/customer/'

add_to_list:
	@echo curl -b session.log  --location --request PUT 'http://$(IGW)/api/v1/customer/append' --header 'Content-Type: application/json' --data-raw '$(ADD)'
	$(CURL) -b session.log  --location --request PUT 'http://$(IGW)/api/v1/customer/append' --header 'Content-Type: application/json' --data-raw '$(ADD)'

remove_from_list:
	@echo curl -b session.log --location --request PUT 'http://$(IGW)/api/v1/customer/remove' --header 'Content-Type: application/json' --data-raw '$(REMOVE)'
	$(CURL) -b session.log --location --request PUT 'http://$(IGW)/api/v1/customer/remove' --header 'Content-Type: application/json' --data-raw '$(REMOVE)'

modify_list_item:
	@echo curl -b session.log --location --request PUT 'http://$(IGW)/api/v1/customer/modify' --header 'Content-Type: application/json' --data-raw '$(MODIFY)'
	$(CURL) -b session.log --location --request PUT 'http://$(IGW)/api/v1/customer/modify' --header 'Content-Type: application/json' --data-raw '$(MODIFY)'

#==================================
#		R E T U R N S 	A P I
#==================================
create_return:
	$(CURL) -x localhost:8000 -b session.log --location --request PUT 'http://$(IGW)/api/v1/returns/0' --header 'Content-Type: application/json' --data-raw '$(RETURN_PRODUCT)'

read_returns:
	$(CURL) -x localhost:8000 -b session.log --location --request GET 'http://$(IGW)/api/v1/returns/'