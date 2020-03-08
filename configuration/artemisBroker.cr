apiVersion: broker.amq.io/v2alpha1
kind: ActiveMQArtemis
metadata:
  name: ex-aao
  application: ex-aao-app
spec:
  deploymentPlan:
    size: 1
    image: registry.redhat.io/amq7/amq-broker:7.5
    requireLogin: false
    persistenceEnabled: false
    journalType: nio
    messageMigration: false
  console:
    expose: true
  acceptors:
    - name: amqp
      protocols: amqp
      port: 5672
      sslEnabled: false