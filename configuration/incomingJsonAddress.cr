apiVersion: broker.amq.io/v2alpha1
kind: ActiveMQArtemisAddress
metadata:
  name: ex-aaoaddress
  namespace: x12-json-db
spec:
  addressName: incomingJson
  queueName: incomingJson
  routingType: anycast