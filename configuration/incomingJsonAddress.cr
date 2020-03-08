apiVersion: broker.amq.io/v2alpha1
kind: ActiveMQArtemisAddress
metadata:
  name: ex-aaoaddress
spec:
  addressName: incomingJson
  queueName: incomingJson
  routingType: anycast