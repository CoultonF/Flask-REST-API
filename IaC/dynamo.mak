create:
	cd ../../code/misc; aws cloudformation create-stack --stack-name db --template-body file://cloudformationdynamodb.json
delete:
	aws cloudformation delete-stack --stack-name db