KC=kubectl
CURL=curl

IGW=$(shell cat external-ip.log)
BODY_USER= { \
"cart": [] \
}
RETURN_PRODUCT={ \
  "index": 0 \
}
PRODUCT={ \
	"product": "test", \
	"quantity": 10000, \
	"price": 10 \
}
PRODUCT_UPDATE = { \
	"attr": "quantity", \
	"value": 9 \
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
BODY_CID={"cid":"41eae615-c223-41c0-9504-7c36c8be8b6b"}

CART_PRODUCT={ \
  "product_id": "073e653d-ba69-44f5-94ec-5ff7d1ce0f72", \
  "quantity": 1 \
  }
ADD={ \
  "column": "cart", \
  "value": { \
  "date": "2020/11/30", \
  "price": 10, \
  "product": "test product", \
  "quantity": 1 \
  } \
}
REMOVE={"column":"history","index":0}
MODIFY={"column":"cart","index":0, "field":"quantity", "value":2}
BODY_CID={"cid":"c99587a8-b8c5-4a19-8826-988e57e7dbd5"}
PRODUCT_ID=5500bc11-ef41-4ebc-ac87-6e102930cea4

TRANSACTION={ \
  "transaction": "5500bc11-ef41-4ebc-ac87-6e102930cea4" \
  }
ADD={ \
  "column": "cart" \
  } \
}

DELETE={"column":"transaction","index":0}

#========================================
#		C U S T O M E R 	A P I
#========================================
create_customer:
	@echo curl --location --request POST 'http://$(IGW)/api/v1/customer/' --header 'Content-Type: application/json' --data-raw '$(BODY_USER)'
	$(CURL) --location --request POST 'http://$(IGW)/api/v1/customer/' --header 'Content-Type: application/json' --data-raw '$(BODY_USER)'

update_customer:
	@echo curl -b session.log --location --request PUT 'http://$(IGW)/api/v1/customer/' --header 'Content-Type: application/json' --data-raw '$(BODY_USER)'
	$(CURL) -b session.log --location --request PUT 'http://$(IGW)/api/v1/customer/' --header 'Content-Type: application/json' --data-raw '$(BODY_USER)'

login:
	echo curl -c session.log --location --request PUT 'http://$(IGW)/api/v1/customer/login' --header 'Content-Type: application/json' --data-raw '$(BODY_CID)'
	$(CURL) -c session.log --location --request PUT 'http://$(IGW)/api/v1/customer/login' --header 'Content-Type: application/json' --data-raw '$(BODY_CID)'

logoff:
	echo curl -b session.log --location --request PUT 'http://$(IGW)/api/v1/customer/logoff'
	$(CURL) -b session.log --location --request PUT 'http://$(IGW)/api/v1/customer/logoff'
	rm session.log

authenticate:
	echo -b session.log curl --location --request GET 'http://$(IGW)/api/v1/customer/authenticate'
	$(CURL) -b session.log --location --request GET 'http://$(IGW)/api/v1/customer/authenticate'

read_customer:
	echo curl -b session.log --location --request GET 'http://$(IGW)/api/v1/customer/'
	$(CURL) -b session.log --location --request GET 'http://$(IGW)/api/v1/customer/'

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
	@echo curl -b session.log --location --request PUT 'http://$(IGW)/api/v1/returns/' --header 'Content-Type: application/json' --data-raw '$(RETURN_PRODUCT)'
	$(CURL) -b session.log --location --request PUT 'http://$(IGW)/api/v1/returns/' --header 'Content-Type: application/json' --data-raw '$(RETURN_PRODUCT)'

read_returns:
	echo curl -b session.log --location --request GET 'http://$(IGW)/api/v1/returns/'
	$(CURL) -b session.log --location --request GET 'http://$(IGW)/api/v1/returns/'
    
#==================================
#		C A R T 	A P I
#==================================
create_cart:
	@echo curl -b session.log --location --request PUT 'http://$(IGW)/api/v1/cart/' --header 'Content-Type: application/json' --data-raw '$(CART_PRODUCT)'
	$(CURL) -b session.log --location --request PUT 'http://$(IGW)/api/v1/cart/' --header 'Content-Type: application/json' --data-raw '$(CART_PRODUCT)'

read_cart:
	echo curl -b session.log --location --request GET 'http://$(IGW)/api/v1/cart/'
	$(CURL) -b session.log --location --request GET 'http://$(IGW)/api/v1/cart/'

#==================================
#		P R O D U C T 	A P I
#==================================
read_product:
	echo curl --location --request GET 'http://$(IGW)/api/v1/warehouse/$(PRODUCT_ID)'
	$(CURL) --location --request GET 'http://$(IGW)/api/v1/warehouse/$(PRODUCT_ID)'

create_product:
	@echo curl --location --request POST 'http://$(IGW)/api/v1/warehouse/' --header 'Content-Type: application/json' --data-raw '$(PRODUCT)'
	$(CURL) --location --request POST 'http://$(IGW)/api/v1/warehouse/' --header 'Content-Type: application/json' --data-raw '$(PRODUCT)'

update_product:
	@echo curl --location --request PUT 'http://$(IGW)/api/v1/warehouse/$(PRODUCT_ID)' --header 'Content-Type: application/json' --data-raw '$(PRODUCT_UPDATE)'
	$(CURL) --location --request PUT 'http://$(IGW)/api/v1/warehouse/$(PRODUCT_ID)' --header 'Content-Type: application/json' --data-raw '$(PRODUCT_UPDATE)'
#==================================
#		H I S T O R Y 	A P I
#==================================
get_history:
	echo curl -b session.log --location --request GET 'http://$(IGW)/api/v1/history/'
	$(CURL) -b session.log --location --request GET 'http://$(IGW)/api/v1/history/'

create_history:
	@echo curl -b session.log --location --request PUT 'http://$(IGW)/api/v1/history/'
	$(CURL) -b session.log --location --request PUT 'http://$(IGW)/api/v1/history/'

#==================================
#		T R A N S A C T I O N 	A P I
#==================================
check_balance:
	@echo curl -b session.log --location --request PUT 'http://$(IGW)/api/v1/transaction/' --header 'Content-Type: application/json' --data-raw '$(PRODUCT_PRICE)'
	$(CURL) -b session.log --location --request PUT 'http://$(IGW)/api/v1/transaction/' --header 'Content-Type: application/json' --data-raw '$(PRODUCT_PRICE)'

add_transaction:
	@echo curl -b session.log --location --request POST 'http://$(IGW)/api/v1/transaction/' --header 'Content-Type: application/json' --data-raw '$(TRANSACTION)'
	$(CURL) -b session.log --location --request POST 'http://$(IGW)/api/v1/transaction/' --header 'Content-Type: application/json' --data-raw '$(TRANSACTION)'

delete_transaction:
	@echo curl -b session.log --location --request PUT 'http://$(IGW)/api/v1/transaction/remove' --header 'Content-Type: application/json' --data-raw '$(DELETE)'
	$(CURL) -b session.log --location --request PUT 'http://$(IGW)/api/v1/transaction/remove' --header 'Content-Type: application/json' --data-raw '$(DELETE)'